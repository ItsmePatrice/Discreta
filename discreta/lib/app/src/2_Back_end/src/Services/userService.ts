import { pool } from "../Config/database";
import logger from "../logs";
import { UserDto } from "../Models/userDTO";


const UserService = {
    async findUserByFirebaseId(firebaseUserId: string) {
        const query = 'SELECT * FROM Users WHERE firebase_user_id = $1 LIMIT 1';
        const values = [firebaseUserId];
        try {
            const res = await pool.query(query, values);
            return res.rows[0];
        } catch (e) {
            logger.error('Database error while looking for user: ', e);
            throw e;
        }
    },
    async createUser(dto: UserDto) {
        const query = `
            INSERT INTO Users (firebase_user_id, first_name, last_name, email, is_subscribed)
            VALUES($1, $2, $3, $4, $5)
            RETURNING *;
        `;
        const values = [
            dto.firebaseUserId,
            dto.firstName,
            dto.lastName,
            dto.email,
            dto.isSubscribed
        ];
        try {
            const createdUser = await pool.query(query, values);
            return createdUser.rows[0];
        } catch (e) {
            logger.error('Database error while creating user: ');
            throw e;
        }
    },
}

export default UserService;