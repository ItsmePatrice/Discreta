import "dotenv/config";
import { neon } from "@neondatabase/serverless";
import crypto from "crypto";

const { DB_URL, DATA_ENCRYPTION_KEY } = process.env;

if (!DB_URL) throw new Error("DATABASE_URL is not defined in the environment variables");
if (!DATA_ENCRYPTION_KEY) throw new Error("DATA_ENCRYPTION_KEY is not defined in the environment variables (32 bytes key)");

const sql = neon(DB_URL);

// ----- Encryption helpers -----
const algorithm = "aes-256-gcm";
const key = Buffer.from(DATA_ENCRYPTION_KEY, "hex");

export function encrypt(text: string) {
  const iv = crypto.randomBytes(12);
  const cipher = crypto.createCipheriv(algorithm, key, iv);

  const encrypted = Buffer.concat([
    cipher.update(text, "utf8"),
    cipher.final(),
  ]);

  const authTag = cipher.getAuthTag();

  return {
    iv: iv.toString("hex"),
    content: encrypted.toString("hex"),
    tag: authTag.toString("hex"),
  };
}

export function decrypt(payload: {
  iv: string;
  content: string;
  tag: string;
}) {
  const decipher = crypto.createDecipheriv(
    algorithm,
    key,
    Buffer.from(payload.iv, "hex")
  );

  decipher.setAuthTag(Buffer.from(payload.tag, "hex"));

  const decrypted = Buffer.concat([
    decipher.update(Buffer.from(payload.content, "hex")),
    decipher.final(),
  ]);

  return decrypted.toString("utf8");
}

export async function testDbConnection() {
  try {
    const result = await sql`SELECT version()` as { version: string }[];
    console.log("Database connected:", result[0].version);
  } catch (err) {
    console.error("Error connecting to the database:", err);
  }
}

export async function createUsersTable() {
  try {
    // Enable UUID generation
    await sql`CREATE EXTENSION IF NOT EXISTS "pgcrypto";`;

    // Users table
    await sql`
        CREATE TABLE IF NOT EXISTS Users (
        uid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        firebase_user_id TEXT UNIQUE NOT NULL,

        first_name TEXT,
        last_name JSONB NOT NULL,
        email JSONB NOT NULL,
        language TEXT DEFAULT 'fr',

        is_subscribed BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );
    `;

    // Trigger function for updated_at
    await sql`
      CREATE OR REPLACE FUNCTION update_user_trigger_function()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.updated_at := NOW();
        RETURN NEW;
      END
      $$ LANGUAGE plpgsql;
    `;

    await sql`
      DROP TRIGGER IF EXISTS trg_before_update_on_users ON Users;
    `;

    await sql`
      CREATE TRIGGER trg_before_update_on_users
      BEFORE UPDATE ON Users
      FOR EACH ROW
      EXECUTE FUNCTION update_user_trigger_function();
    `;

  } catch (e) {
    throw new Error(`Failed to initialize Users table: ${e}`);
  }
}

export async function initDB() {
  try {
    await testDbConnection();
    await createUsersTable();
    console.log("Database initialization complete ✅");
  } catch (e) {
    console.error("Database initialization failed:", e);
    throw e;
  }
}

export { sql };
