import "dotenv/config";
import { neon } from "@neondatabase/serverless";
import crypto from "crypto";

const { DATABASE_URL_STAGING, DATA_ENCRYPTION_KEY } = process.env;

if (!DATABASE_URL_STAGING) throw new Error("DATABASE_URL is not defined in the environment variables");
if (!DATA_ENCRYPTION_KEY) throw new Error("DATA_ENCRYPTION_KEY is not defined in the environment variables (32 bytes key)");

const sql = neon(DATABASE_URL_STAGING);

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

export async function initDB() {
  try {
    await testDbConnection();
    await createUsersTable();
    await createAccessCodesTable();
    await createRefreshTokensTable();
    await createContactsTable();
    await createAlertMessagesTable();
    await createTrackingSessionsTable();
    await createLogsTable();
    console.log("Database initialization complete ✅");
  } catch (e) {
    console.error("Database initialization failed:", e);
    throw e;
  }
}

async function testDbConnection() {
  try {
    const result = await sql`SELECT version()` as { version: string }[];
    console.log("Database connected:", result[0].version);
  } catch (err) {
    console.error("Error connecting to the database:", err);
  }
}

async function createUsersTable() {
  try {
    // Enable UUID generation
    await sql`CREATE EXTENSION IF NOT EXISTS "pgcrypto";`;

    await sql`ALTER TABLE Users ALTER COLUMN email TYPE VARCHAR(255) USING email::text;`;

    // Users table
    await sql`
        CREATE TABLE IF NOT EXISTS Users (
        uid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        first_name VARCHAR(100) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        language TEXT DEFAULT 'fr',
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

async function createAccessCodesTable() {
  try {
    await sql`
      CREATE TABLE IF NOT EXISTS AccessCodes (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        access_code VARCHAR(255) UNIQUE NOT NULL,
        max_uses INTEGER NOT NULL,
        used_count INTEGER NOT NULL DEFAULT 0,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
    `;
  } catch (e) {
    throw new Error(`Failed to initialize AccessCodes table: ${e}`);
  }
}

async function createRefreshTokensTable() {
  try {
    await sql`
      CREATE TABLE IF NOT EXISTS RefreshTokens (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES Users(uid) ON DELETE CASCADE,
        token TEXT UNIQUE NOT NULL,
        expires_at TIMESTAMP NOT NULL,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
    `;
  } catch (e) {
    throw new Error(`Failed to initialize RefreshTokens table: ${e}`);
  }
}

async function createContactsTable() {
  try {
    await sql`
        CREATE TABLE IF NOT EXISTS Contacts (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES Users(uid) ON DELETE CASCADE,
        contact_name VARCHAR(20) NOT NULL, 
        contact_phone JSONB NOT NULL,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );
    `;
  } catch (e) {
    throw new Error(`Failed to initialize Contacts table: ${e}`);
  }
}

async function createAlertMessagesTable() {
  try {
    await sql`
      CREATE TABLE IF NOT EXISTS AlertMessages (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES Users(uid) ON DELETE CASCADE,
        message_content VARCHAR(160) NOT NULL
      );
    `;

    await sql`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1
          FROM pg_constraint
          WHERE conname = 'unique_alert_per_user'
        ) THEN
          ALTER TABLE AlertMessages
          ADD CONSTRAINT unique_alert_per_user UNIQUE (user_id);
        END IF;
      END
      $$;
    `;
  } catch (e) {
    throw new Error(`Failed to initialize AlertMessages table: ${e}`);
  }
}

async function createTrackingSessionsTable() {
  try {
    await sql`
      CREATE TABLE IF NOT EXISTS TrackingSessions (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES Users(uid) ON DELETE CASCADE,
        token TEXT UNIQUE NOT NULL DEFAULT encode(gen_random_bytes(24), 'hex'),
        last_lat DOUBLE PRECISION,
        last_lng DOUBLE PRECISION,
        expires_at TIMESTAMP NOT NULL,
        status TEXT NOT NULL CHECK (status IN ('ACTIVE', 'ENDED')),
        start_time TIMESTAMPTZ DEFAULT NOW(),
        end_time TIMESTAMPTZ DEFAULT NOW()
      );
    `;
  } catch (e) {
    throw new Error(`Failed to initialize TrackingSessions table: ${e}`);
  }
}

async function createLogsTable() {
  try {
    await sql`
      CREATE TABLE IF NOT EXISTS Logs (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES Users(uid) ON DELETE CASCADE,
        message TEXT NOT NULL,
        timestamp TIMESTAMPTZ DEFAULT NOW()
      );
    `;
  } catch (e) {
    throw new Error(`Failed to initialize Logs table: ${e}`);
  }
}

export { sql };
