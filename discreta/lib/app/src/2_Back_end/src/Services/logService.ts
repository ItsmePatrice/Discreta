import { sql } from "../Config/database";
import logger from "../logs";

const LogService = {
    async logEvent(firebaseUserId: string, message: string) {
        try {
            await sql`
                INSERT INTO Logs (firebase_user_id, message)
                VALUES (${firebaseUserId}, ${message})
            `;
        } catch (e) {
            logger.error('Database error while logging event: ', e);
            throw e;
        }
    }
};

export default LogService;
