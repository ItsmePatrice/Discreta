import { sql, decrypt, generateToken } from "../Config/database";
import logger from "../logs";
import LogService from "./logService";
import SmsService from "./smsService";

const AlertService = {

    async startTrackingSession(firebaseUserId: string, username: string) {
        try {
            const trackingToken = generateToken();
            await sql`
                INSERT INTO TrackingSessions (firebase_user_id, token, expires_at, status)
                VALUES (
                    ${firebaseUserId},
                    ${trackingToken},
                    NOW() + INTERVAL '2 hours',
                    'ACTIVE'
                )
            `;
            await LogService.logEvent(firebaseUserId, `${username} started a tracking session.`);

            return { trackingToken };

        } catch (e) {
            logger.error('Database error while starting tracking session', e);
            throw e;
        }   
    },

    async stopTrackingSession(username: string, firebaseUserId: string, trackingToken: string) {
        try {
            const result = await sql`
            UPDATE TrackingSessions
            SET status = 'ENDED',
                end_time = NOW()
            WHERE firebase_user_id = ${firebaseUserId}
                AND token = ${trackingToken}
                AND status = 'ACTIVE'
            `;

            const message = `${username} ended the tracking session`;
            await LogService.logEvent(firebaseUserId, message);

        if (result.length === 0) {
            throw new Error('No active tracking session found for the provided token.');
        }
        } catch (e) {
            logger.error('Database error while stopping tracking session', e);
            throw e;
        }
    },

    async updateLocation(firebaseUserId: string, trackingToken: string, lat: number, lng: number) {
        try {
            const result = await sql`
            UPDATE TrackingSessions
            SET last_lat = ${lat}, 
            last_lng = ${lng},
            last_updated = NOW()
            WHERE firebase_user_id = ${firebaseUserId}
                AND token = ${trackingToken}
                AND status = 'ACTIVE'
                AND expires_at > NOW()
            RETURNING id;
        `;
        if (result.length === 0) {
            throw new Error('No active tracking session found for the provided token.');
        }
        } catch (e) {
            logger.error('Database error while updating location', e);
            throw e;
        }
    },

    async getTrackingData(trackingToken: string) {
        try {
            const result = await sql`
                SELECT last_lat, last_lng, last_updated, expires_at
                FROM TrackingSessions
                WHERE token = ${trackingToken}
                    AND status = 'ACTIVE'
                    AND expires_at > NOW()
                LIMIT 1;
            `;

        if (result.length === 0) {
            throw new Error('Tracking session not found or ended by user.');
        }

        const lat = result[0].last_lat;
        const lng = result[0].last_lng;
        const updatedAt = result[0].last_updated;
        const lastUpdated = new Date(updatedAt);
        const now = new Date();
        const minutesSinceLastUpdate = Math.floor((now.getTime() - lastUpdated.getTime()) / (1000 * 60));
        return { lat, lng, minutesSinceLastUpdate };
        } catch (e) {
            logger.error('Database error while fetching tracking data', e);
            throw e;
        }
    },

    async getTrackingToken(firebaseUserId: string) {
        try {
            const result = await sql`
                SELECT token
                FROM TrackingSessions
                WHERE firebase_user_id = ${firebaseUserId}
                    AND status = 'ACTIVE'
                LIMIT 1;
            `;

            if (result.length === 0) {
                throw new Error('No active tracking session found for the provided token.');
            }
        
            return result[0].token;
        } catch (e) {
            logger.error('Database error while fetching tracking token', e);
            throw e;
        }
    },

    async sendAlertMessage(firebaseUserId: string, username: string) {
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

            if (decryptedContacts.length === 0) {
                return false;
            }

            const alertMessage = message[0]?.message_content;

            const public_token = await this.getTrackingToken(firebaseUserId);

            const locationLink = `${process.env.PUBLIC_BASE_URL}/api/public/track/page/${public_token}`;

            // send SMS to each contact
            for (const contact of decryptedContacts) {
                await SmsService.sendSMS(username!, contact.name, contact.phone_number, alertMessage, locationLink);
            }

            const logMessage = `${username} sent an alert to ${decryptedContacts.length} contacts.`;
            await LogService.logEvent(firebaseUserId, logMessage);
            return true;
        } catch (e) {
            logger.error('Database error while sending alert message.', e);
            throw e;
        }
    },
};

export default AlertService;
