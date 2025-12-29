import logger from "../logs";
import twilio from "twilio";

const client = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);

// create your phone number in twilio 
const SmsService = {

    async sendSMS(from:string, contactName: string, contactPhoneNumber: string, message: string) {
        try {
            // Make sure to add time and the location url
            // Make the message is based on the user's language preference
            const body = `🚨 DISCRETA SAFETY ALERT 
Hey ${contactName}, this message was sent by Discreta. ${from} may be unsafe. Her message to you: "${message}" If this is an emergency, please call local authorities immediately and share her live location with them.

                — Discreta Safety System`;
            ; 
                
            return client.messages.create({
                body: body,
                from: process.env.TWILIO_PHONE_NUMBER,
                to: contactPhoneNumber
            });
        } catch (e) {
            logger.error('Error while sending SMS: ', e);
            throw e;
        }
    }
};

export default SmsService;

