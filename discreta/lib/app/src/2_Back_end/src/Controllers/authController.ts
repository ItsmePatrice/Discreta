import UserService from '../Services/userService';
import type { UserDto } from '../Models/userDTO';
import { Request, Response } from "express";
import StatusCodes from '../StatusCodes/statusCode';
import logger from '../logs';

const authController = {

    // creates a new user or returns an existing one
    googleSignIn: async (req: Request, res: Response) => {
        try {
            const firebaseUid = req.firebaseUid;
            if (!firebaseUid) {
                throw ("firebaseUid was null");
            }
            const existingUser = await UserService.findUserByFirebaseId(firebaseUid);
            if (!existingUser?.uid) {
                if (!req.firebaseUid || !req.firstName || !req.lastName || !req.email) {
                    throw ("One or more of these fields are undefined: firebaseUid, firstName, lastName, email");
                }
                const newUser: UserDto = {
                    firebaseUserId: req.firebaseUid,
                    firstName: req.firstName,
                    lastName: req.lastName,
                    email: req.email,
                    isSubscribed: false
                };
                const user = await UserService.createUser(newUser);
                return res.status(StatusCodes.created).json(user);
            }
            logger.info(`User with firebaseUid ${firebaseUid} already exists. ${JSON.stringify(existingUser)}`);
            return res.status(StatusCodes.ok).json(existingUser);
        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },
}

export default authController;