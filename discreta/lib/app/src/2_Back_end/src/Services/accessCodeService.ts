import { sql } from "../Config/database";
import logger from "../logs";

const AccessCodeService = {
    
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
    },

    async decrementAccessCodeUseCount(accessCode: string) {
        try {
            await sql`
                UPDATE AccessCodes
                SET used_count = used_count - 1
                WHERE access_code = ${accessCode} AND used_count > 0
            `;
        } catch (e) {
            logger.error('Database error while decrementing access code use count: ', e);
            throw e;
        }   
    }
};

export default AccessCodeService;
