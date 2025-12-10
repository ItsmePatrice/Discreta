import UserService from '../Services/userService.js';
import type { UserDto } from '../Models/userDTO.js';
import { Request, Response } from "express";
import StatusCodes from '../StatusCodes/statusCode.js';
import logger from '../logs.js';

const authController = {
    googleSignUp: async (req: Request, res: Response) => {
        try {
            const firebaseUid = req.firebaseUid;
            if (!firebaseUid) {
                throw ("firebaseUid was null");
            }
            const existingUser = await UserService.findUserByFirebaseId(firebaseUid);
            if (!existingUser) {
                const { profilePictureUrl, userType } = req.body;
                if (!profilePictureUrl || !userType) {
                    return res
                        .status(StatusCodes.badRequest)
                        .json({ message: 'profilePictureUrl and userType are required' });
                }
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
            return res.status(StatusCodes.conflict).json({
                message:
                    `This user account already exists`
            });
        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    checkIfUserExists: async (req: Request, res: Response) => {
        const firebaseUserId = req.params.firebaseUid;
        try {
            if (!firebaseUserId) {
                logger.info('the Firebase user id was not found in the request');
                return res.status(StatusCodes.badRequest).json({
                    'message':
                        'the Firebase user id was not found in the request'
                });
            }
            const existingUser = await UserService.findUserByFirebaseId(firebaseUserId);
            if (!existingUser) {
                return res.status(StatusCodes.notFound).json({ exists: false });
            } else {
                return res.status(StatusCodes.ok).json(existingUser);
            }
        } catch (e) {
            return res.status(StatusCodes.internalServerError).json({
                message: `error checking 
            if user exits: ${e}`
            });
        }
    }
}

export default authController;