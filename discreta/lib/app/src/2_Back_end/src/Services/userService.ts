import { sql, encrypt, decrypt } from "../Config/database";
import logger from "../logs";
import { UserDto } from "../Models/userDTO";
import LogService from "./logService";

const UserService = {
    async findUserById(uid: string) {
        try {
            const res = await sql`
                SELECT * FROM Users WHERE uid = ${uid} LIMIT 1
            `;
            
            const user = res[0];
            if (!user) return null;

            const decryptedUser = {
                uid: user.uid,
                first_name: user.first_name,
                language: user.language,
                email: decrypt(user.email),
                created_at: user.created_at,
                updated_at: user.updated_at
            };

            return decryptedUser;
        } catch (e) {
            logger.error('Database error while looking for user: ', e);
            throw e;
        }
    },
    
    
    async findUser(email: string) {
        try {
            const res = await sql`
                SELECT * FROM Users WHERE email = ${encrypt(email)} LIMIT 1
            `;
            
            const user = res[0];
            if (!user) return null;

            const decryptedUser = {
                uid: user.uid,
                first_name: user.first_name,
                language: user.language,
                email: decrypt(user.email),
                created_at: user.created_at,
                updated_at: user.updated_at
            };

            return decryptedUser;
        } catch (e) {
            logger.error('Database error while looking for user: ', e);
            throw e;
        }
    },

    async createUser(dto: UserDto) {
        try {
            const createdUser = await sql`
                INSERT INTO Users (first_name, email)
                VALUES (
                    ${dto.firstName},
                    ${encrypt(dto.email)},
                )
                RETURNING *;
            `;

            const user = createdUser[0];
            const decryptedUser = {
                uid: user.uid,
                first_name: user.first_name,
                email: decrypt(user.email),
                language: user.language,
                created_at: user.created_at,
                updated_at: user.updated_at
            };
            const message = `${decryptedUser.first_name} joined`;
            await LogService.logEvent(decryptedUser.uid, message);

            return decryptedUser;
        } catch (e) {
            logger.error('Database error while creating user: ', e);
            throw e;
        }
    },


    async saveAlertMessage(firebaseUserId: string, messageContent: string) {
        try {
            const res = await sql`
                INSERT INTO AlertMessages (firebase_user_id, message_content)
                VALUES (${firebaseUserId}, ${messageContent})
                ON CONFLICT (firebase_user_id)
                DO UPDATE SET
                    message_content = EXCLUDED.message_content
                RETURNING *;
            `;

            return res[0];
        } catch (e) {
            logger.error('Database error while saving alert message', e);
            throw e;
        }
    },


    async fetchAlertMessage(firebaseUserId: string) {
        try {
            const res = await sql`
                SELECT * FROM AlertMessages WHERE firebase_user_id = ${firebaseUserId} LIMIT 1
            `;
            return res[0]?.message_content ?? null;
        }
        catch (e) {
            logger.error('Database error while fetching alert message: ', e);
            throw e;
        }
    },

    async addContact(firebaseUserId: string, name: string, phoneNumber: string) {
        try {
            const res = await sql`
                INSERT INTO Contacts (firebase_user_id, contact_name, contact_phone)
                VALUES (${firebaseUserId}, ${name}, ${encrypt(phoneNumber)})
                RETURNING *;
            `;
            return res[0];
        } catch (e) {
            logger.error('Database error while adding contact: ', e);
            throw e;
        }
    },

    async fetchContacts(firebaseUserId: string) {
        try {
            const res = await sql`
                SELECT * FROM Contacts WHERE firebase_user_id = ${firebaseUserId};
            `;
            return res.map(contact => ({
                id: contact.id,
                name: contact.contact_name,
                phoneNumber: decrypt(contact.contact_phone)
            }));
        } catch (e) {
            logger.error('Database error while fetching contacts: ', e);
            throw e;
        }
    },
    async deleteContact(contactId: string, firebaseUserId: string) {
        try {
            await sql`
                DELETE FROM Contacts 
                WHERE id = ${contactId} AND firebase_user_id = ${firebaseUserId};
            `;
        } catch (e) {
            logger.error('Database error while deleting contact: ', e);
            throw e;
        }
    },

    async updateContact(contactId: string, firebaseUserId: string, name: string, phoneNumber: string) {
        try {
            const res = await sql`
                UPDATE Contacts
                SET contact_name = ${name}, contact_phone = ${encrypt(phoneNumber)}, updated_at = NOW()
                WHERE id = ${contactId} AND firebase_user_id = ${firebaseUserId}
                RETURNING *;
            `;
            return res[0];
        } catch (e) {
            logger.error('Database error while updating contact: ', e);
            throw e;
        }   
    },

    async updateLanguagePreference(firebaseUserId: string, language: string) {
        try {
            const res = await sql`
                UPDATE Users
                SET language = ${language}, updated_at = NOW()
                WHERE firebase_user_id = ${firebaseUserId}
                RETURNING *;
            `;
            return res[0].language;
        } catch (e) {
            logger.error('Database error while updating user language: ', e);
            throw e;
        }
    },
};

export default UserService;
