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
        await pool.query('SELECT NOW()');
    } catch (e) {
        throw e;
    }
}

export { pool, initDB };