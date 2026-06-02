import { sql } from "../Config/database";
import logger from "../logs";

const AccessCodeService = {
    
    async isValidAccessCode(accessCode: string) {
        try {
            // hash the entered access code before checking if it exists in the database (after launch)
            const result = await sql`
                SELECT * 
                FROM AccessCodes 
                WHERE access_code = ${accessCode} AND used_count < max_uses
                LIMIT 1
            `;
            if (result.length === 0) {
                return false;
            }
            return true;
        }
        catch (e) {
            logger.error('Database error while validating access code: ', e);
            throw e;
        }
    },

    async incrementAccessCodeUseCount(accessCode: string) {
        try {
            const result = await sql`
                UPDATE AccessCodes
                SET used_count = used_count + 1
                WHERE access_code = ${accessCode} AND used_count < max_uses
                RETURNING id
            `;
            return result.length > 0; // false means the slot was taken
        } catch (e) {
            logger.error('Database error while incrementing access code use count: ', e);
            throw e;
        }
    }
};

export default AccessCodeService;
