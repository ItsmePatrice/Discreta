import { sql, decrypt } from "../Config/database";
import logger from "../logs";
import LogService from "./logService";
import SmsService from "./smsService";

const AlertService = {

    async startTrackingSession(uid: string, username: string) {
        
        const existing = await sql`
            SELECT token FROM TrackingSessions
            WHERE user_id = ${uid} AND status = 'ACTIVE' AND expires_at > NOW()
            LIMIT 1;
        `;
        if (existing.length > 0) {
            return { trackingToken: existing[0].token };
        }

        const result = await sql`
            INSERT INTO TrackingSessions (user_id, expires_at, status)
            VALUES (${uid}, NOW() + INTERVAL '2 hours', 'ACTIVE')
            RETURNING token;
        `;
        await LogService.logEvent(uid, `${username} started a tracking session.`);
        return { trackingToken: result[0].token };
    },

    async stopTrackingSession(username: string, uid: string) {
        try {
            const result = await sql`
            UPDATE TrackingSessions
            SET status = 'ENDED',
                end_time = NOW()
            WHERE user_id = ${uid}
                AND status = 'ACTIVE'
            `;

            const message = `${username} ended the tracking session`;
            await LogService.logEvent(uid, message);

            logger.info(message);
        } catch (e) {
            logger.error('Database error while stopping tracking session', e);
            throw e;
        }
    },

    async hasActiveTrackingSession(uid: string) {
        try {
            const result = await sql`
                SELECT COUNT(*) AS count
                FROM TrackingSessions
                WHERE user_id = ${uid}
                    AND status = 'ACTIVE'
                    AND expires_at > NOW();
            `;
            return parseInt(result[0].count) > 0;
        } catch (e) {
            logger.error('Database error while checking active tracking session', e);
            throw e;
        }
    },

    async updateLocation(uid: string, trackingToken: string, lat: number, lng: number) {
        try {
            const result = await sql`
            UPDATE TrackingSessions
            SET last_lat = ${lat}, 
            last_lng = ${lng},
            last_updated = NOW()
            WHERE user_id = ${uid}
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

    async getTrackingToken(uid: string) {
        try {
            const result = await sql`
                SELECT token
                FROM TrackingSessions
                WHERE user_id = ${uid}
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

    async sendAlertMessage(uid: string, username: string) {
        try {
            // find all user contacts for the given uid
            const contacts = await sql`
                SELECT contact_name, contact_phone
                FROM Contacts
                WHERE user_id = ${uid}
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
                WHERE user_id = ${uid}
                LIMIT 1;
            `;

            if (decryptedContacts.length === 0) {
                return false;
            }

            const alertMessage = message[0]?.message_content;

            const public_token = await this.getTrackingToken(uid);

            const locationLink = `${process.env.BASE_URL}/api/public/track/page/${public_token}`;

            // send SMS to each contact
            for (const contact of decryptedContacts) {
                await SmsService.sendSMS(username!, contact.name, contact.phone_number, alertMessage, locationLink);
            }

            const logMessage = `${username} sent an alert to ${decryptedContacts.length} contacts.`;
            await LogService.logEvent(uid, logMessage);
            return true;
        } catch (e) {
            logger.error('Database error while sending alert message.', e);
            throw e;
        }
    },
};

export default AlertService;
