import { sql } from "../Config/database";
import logger from "../logs";

const AuthService = {
    async storeRefreshToken(userId: string, refreshToken: string) {
        // if a refresh token already exists for the user, update it. Otherwise, create a new record
        try {
            const existingToken = await sql`
                SELECT * FROM RefreshTokens WHERE user_id = ${userId} LIMIT 1
            `;
            if (existingToken.length > 0) {
                await sql`
                    UPDATE RefreshTokens
                    SET token = ${refreshToken}, expires_at = NOW() + INTERVAL '90 days'
                    WHERE user_id = ${userId}
                `;
            } else {
                await sql`
                    INSERT INTO RefreshTokens (user_id, token, expires_at)
                    VALUES (${userId}, ${refreshToken}, NOW() + INTERVAL '90 days')
                `;
            }
        } catch (e) {
            logger.error('Database error while storing refresh token: ', e);
            throw e;
        }
    },

    async hasValidRefreshToken(userId: string, refreshToken: string) {
        try {
            const res = await sql`
                SELECT * FROM RefreshTokens
                WHERE user_id = ${userId}
                AND token = ${refreshToken}
                AND expires_at > NOW()
                LIMIT 1
            `;
            return res.length > 0;
        } catch (e) {
            logger.error('Database error while validating refresh token: ', e);
            throw e;
        }
    }
};

export default AuthService;
