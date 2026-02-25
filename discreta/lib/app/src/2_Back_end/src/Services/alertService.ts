import { sql, decrypt, generateToken } from "../Config/database";
import { MapboxContext } from "../Interface/mapboxContext";
import logger from "../logs";
import LogService from "./logService";
import SmsService from "./smsService";

const AlertService = {

    async startTrackingSession(firebaseUserId: string, username: string) {
        try {
            const trackingToken = generateToken();
            const expiresAt = new Date(Date.now() + 2 * 60 * 60 * 1000); // 2 hours

            await sql`
                INSERT INTO TrackingSessions (firebase_user_id, token, expires_at, status)
                VALUES (${firebaseUserId}, ${trackingToken}, ${expiresAt}, 'ACTIVE')
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

            await sql`
            UPDATE TrackingSessions
            SET status = 'EXPIRED',
                end_time = NOW()
            WHERE status = 'ACTIVE'
                AND expires_at < NOW()
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
            SET last_lat = ${lat}, last_lng = ${lng}
            WHERE firebase_user_id = ${firebaseUserId}
                AND token = ${trackingToken}
                AND status = 'ACTIVE'
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
            SELECT last_lat, last_lng
            FROM TrackingSessions
            WHERE token = ${trackingToken}
                AND status = 'ACTIVE'
            LIMIT 1;
        `;


        if (result.length === 0) {
            throw new Error('No active tracking session found for the provided token.');
        }
        const lat = result[0].last_lat;
        const lng = result[0].last_lng;
        return { lat, lng };
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

            const locationLink = `${process.env.PUBLIC_BASE_URL}/track/${public_token}`;

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

    async getAddress(lat: number, lng: number) {
        try {
            const url = `https://api.mapbox.com/geocoding/v5/mapbox.places/${lng},${lat}.json?access_token=${process.env.MAPBOX_TOKEN}`;
            const response = await fetch(url);
            const data = await response.json();

            logger.info('Mapbox API response', data);
            logger.info('number was ', process.env.TWILIO_PHONE_NUMBER);

            if (data.features && data.features.length > 0) {
                const place = data.features[0];
                return {
                    fullAddress: place.place_name,
                    street: place.text,
                    city: place.context?.find((c: MapboxContext) => c.id.startsWith('place'))?.text,
                    postalCode: place.context?.find((c: MapboxContext) => c.id.startsWith('postcode'))?.text
                };
            }
            return null;
        } catch (e) {
            logger.error('Error while fetching address from Mapbox API', e);
            throw e;
        }
    }
};

export default AlertService;
