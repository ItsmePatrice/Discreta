import { sql } from "../Config/database";
import logger from "../logs";

const LogService = {
    async logEvent(userId: string, message: string) {
        try {
            await sql`
                INSERT INTO Logs (user_id, message)
                VALUES (${userId}, ${message})
            `;
        } catch (e) {
            logger.error('Database error while logging event: ', e);
            throw e;
        }
    }
};

export default LogService;
