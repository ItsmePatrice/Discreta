import dotenv from "dotenv";
dotenv.config();
import {Pool} from 'pg';

if (!process.env.DB_PORT) {
    throw new Error('DB_PORT is not defined in the environment variables');
}

const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASSWORD,
    port: parseInt(process.env.DB_PORT),
});

async function initDB() {
    try {
        await pool.query(`CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`);
        await createUsersTable();
    } catch (e) {
        throw e;
    }
}

async function createUsersTable() {
    try {
        await pool.query(`
            CREATE TABLE IF NOT EXISTS Users (
                uID UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                firebase_user_id TEXT UNIQUE NOT NULL,
                first_name TEXT NOT NULL,
                last_name TEXT NOT NULL,
                email TEXT UNIQUE NOT NULL,
                is_subscribed BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMPTZ DEFAULT NOW(),
                updated_at TIMESTAMPTZ DEFAULT NOW()
            );
        `);
        await pool.query(`
            CREATE OR REPLACE FUNCTION update_user_trigger_function()
            RETURNS TRIGGER AS $$
            BEGIN
                NEW.updated_at := NOW();
                RETURN NEW;
            END
            $$ LANGUAGE plpgsql;
        `);
        await pool.query(`
            DROP TRIGGER IF EXISTS trg_before_update_on_users ON Users;
        `);
        await pool.query(`
            CREATE TRIGGER trg_before_update_on_users
            BEFORE UPDATE ON Users
            FOR EACH ROW
            EXECUTE FUNCTION update_user_trigger_function();
        `);
    } catch (e) {
        throw (`An error occured while initializing the Users table: ${e}`);
    }
}

export { pool, initDB };