import { sql, encrypt, decrypt } from "../Config/database";
import logger from "../logs";
import { UserDto } from "../Models/userDTO";

const UserService = {
    async findUserByFirebaseId(firebaseUserId: string) {
        try {
            const res = await sql`
                SELECT * FROM Users WHERE firebase_user_id = ${firebaseUserId} LIMIT 1
            `;
            
            const user = res[0];
            if (!user) return null;

            const decryptedUser = {
                uid: user.uid,
                firebase_user_id: user.firebase_user_id,
                first_name: user.first_name,
                language: user.language,
                last_name: decrypt(user.last_name),
                email: decrypt(user.email),
                is_subscribed: user.is_subscribed,
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
                INSERT INTO Users (firebase_user_id, first_name, last_name, email, is_subscribed)
                VALUES (
                    ${dto.firebaseUserId},
                    ${dto.firstName},
                    ${encrypt(dto.lastName)},
                    ${encrypt(dto.email)},
                    ${dto.isSubscribed}
                )
                RETURNING *;
            `;

            const user = createdUser[0];
            const decryptedUser = {
                uid: user.uid,
                firebase_user_id: user.firebase_user_id,
                first_name: user.first_name,
                last_name: decrypt(user.last_name),
                email: decrypt(user.email),
                language: user.language,
                is_subscribed: user.is_subscribed,
                created_at: user.created_at,
                updated_at: user.updated_at
            };

            return decryptedUser;
        } catch (e) {
            logger.error('Database error while creating user: ', e);
            throw e;
        }
    },
};

export default UserService;
