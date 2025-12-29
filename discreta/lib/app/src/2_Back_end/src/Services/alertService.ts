import { sql, decrypt } from "../Config/database";
import logger from "../logs";

const AlertService = {

    async sendAlertMessage(firebaseUserId: string) {
        try {
            // simply log that the alert has been sent

        } catch (e) {
            logger.error('Database error while saving alert message', e);
            throw e;
        }
    },


    
};

export default AlertService;
