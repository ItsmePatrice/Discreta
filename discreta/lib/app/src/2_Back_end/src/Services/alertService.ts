import { sql, decrypt } from "../Config/database";
import logger from "../logs";
import SmsService from "./smsService";

const AlertService = {

    async sendAlertMessage(firebaseUserId: string, username: string | undefined) {
        try {
            // find all user contacts for the given firebaseUserId
            const contacts = await sql`
                SELECT contact_name, contact_phone
                FROM Contacts
                WHERE firebase_user_id = ${firebaseUserId}
                LIMIT 10;
            `;

            const decryptedContacts = contacts.map(contact => ({
                name: contact.contact_name,
                phone_number: decrypt(contact.contact_phone)
            }));

            // find user's alert message
            const message = await sql`
                SELECT message_content
                FROM AlertMessages
                WHERE firebase_user_id = ${firebaseUserId}
                LIMIT 1;
            `;

            if (decryptedContacts.length === 0 || message.length === 0) {
                return false;
            }

            const alertMessage = message[0]?.message_content;

            // send SMS to each contact
            for (const contact of decryptedContacts) {
                await SmsService.sendSMS(username!, contact.name, contact.phone_number, alertMessage);
                logger.info(`Alert messages sent to ${contact.name} contacts for user ${username}`);
            }

            return true;
        } catch (e) {
            logger.error('Database error while saving alert message', e);
            throw e;
        }
    },


    
};

export default AlertService;
