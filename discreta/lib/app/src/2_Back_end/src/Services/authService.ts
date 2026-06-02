import { sql } from "../Config/database";
import logger from "../logs";

const AuthService = {
    async storeRefreshToken(userId: string, refreshToken: string) {
        try {
            await sql`
                INSERT INTO RefreshTokens (user_id, token, expires_at)
                VALUES (${userId}, ${refreshToken}, NOW() + INTERVAL '90 days')
                ON CONFLICT (user_id)
                DO UPDATE SET
                    token = EXCLUDED.token,
                    expires_at = EXCLUDED.expires_at
            `;
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
