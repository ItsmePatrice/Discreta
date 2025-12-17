import "dotenv/config";
// import { Pool } from "pg"; // only use when you transition DB form NEON to Aurora
import { neon } from "@neondatabase/serverless";

const {
  DB_URL,
  DB_USER,
  DB_PASSWORD,
  DB_HOST,
  DB_NAME,
  DB_PORT
} = process.env;

if (!DB_URL) throw new Error("DATABASE_URL is not defined in the environment variables");

// ----- Neon connection (serverless) -----
const sql = neon(DB_URL);

// Only use this when you transition DB form NEON to Aurora
/* const pool = new Pool({
  user: DB_USER,
  host: DB_HOST,
  database: DB_NAME,
  password: DB_PASSWORD,
  port: parseInt(DB_PORT),
  ssl: { rejectUnauthorized: false }, // required for Neon free tier
}); */

// ----- HTTP server to test DB connection -----
async function testDbConnection() {
  try {
    const result = await sql`SELECT version()` as { version: string }[];
    const { version } = result[0];
    console.log("Database connected:", version);
  } catch (err) {
    console.error("An error occurred while connecting to the database:", err);
  }
};

async function initDB() {
  try {
    // await Pool.query(`CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`); // only use when you transition DB form NEON to Aurora
    await sql`CREATE EXTENSION IF NOT EXISTS "pgcrypto";`; // remove this when you transition DB form NEON to Aurora
    await testDbConnection();
    await createUsersTable();
  } catch (e) {
    throw e;
  }
}

 async function createUsersTable() {
  try {
    await sql`
      CREATE TABLE IF NOT EXISTS Users (
        uID UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        firebase_user_id TEXT UNIQUE NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        is_subscribed BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );
    `;

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
    throw new Error(`An error occurred while initializing the Users table: ${e}`);
  }
} 

export {initDB, sql };
