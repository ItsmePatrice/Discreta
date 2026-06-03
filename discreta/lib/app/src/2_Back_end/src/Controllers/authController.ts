import UserService from '../Services/userService';
import type { UserDto } from '../Models/userDTO';
import { Request, Response } from "express";
import StatusCodes from '../StatusCodes/statusCode';
import logger from '../logs';
import LogService from '../Services/logService';
import AccessCodeService from '../Services/accessCodeService';
import jwt from "jsonwebtoken";
import "dotenv/config";
import AuthService from '../Services/authService';
import { AUTH_ERROR_CODES } from '../ErrorCodes/errorCodes';

const ACCESS_TOKEN_SECRET = process.env.ACCESS_TOKEN_SECRET as string;
const REFRESH_TOKEN_SECRET = process.env.REFRESH_TOKEN_SECRET as string;

const authController = {

    signInUser: async (req: Request, res: Response) => {
        const { firstName, email, accessCode } = req.body;

        if (!firstName || !email || !accessCode) {
            return res.status(StatusCodes.badRequest).json({ message: "Missing required fields", code: AUTH_ERROR_CODES.MISSING_FIELDS });
        }

        try {
            // Check if user exists
            let user = await UserService.findUser(email);

            if (user) {
                // Existing user — verify the access code matches their account
                if (user.access_code !== accessCode) {
                    return res.status(StatusCodes.unauthorized).json({ message: "Invalid access code", code: AUTH_ERROR_CODES.INVALID_CREDENTIALS });
                }
            } else {
                // New user — create account
                const incremented = await AccessCodeService.incrementAccessCodeUseCount(accessCode);
                if (!incremented) {
                    // This means the access code was already used up between the validation and the increment, so we should delete the newly created user and return an error
                    return res.status(StatusCodes.badRequest).json({ message: "Access code has reached its maximum uses or is expired",
                         code: AUTH_ERROR_CODES.ACCESS_CODE_MAX_USES_OR_INVALID });
                }
                try {
                    const newUser: UserDto = { firstName, email };
                    user = await UserService.createUser(newUser, accessCode);

                } catch (e) {
                    // Rollback the increment if user creation fails
                    try {
                        await AccessCodeService.decrementAccessCodeUseCount(accessCode);
                    } catch (decrementError) {
                        logger.error('Failed to rollback access code use count after user creation failure: ', decrementError);
                    }
                    throw e;
                }
                
            }

            // Generate tokens
            const accessToken = jwt.sign(
                { uid: user.uid, email: user.email },
                ACCESS_TOKEN_SECRET,
                { expiresIn: '24h' }
            );

            const refreshToken = jwt.sign(
                { uid: user.uid },
                REFRESH_TOKEN_SECRET,
                { expiresIn: '90d' }
            );

            await AuthService.storeRefreshToken(user.uid, refreshToken);

            await LogService.logEvent(user.uid, `${user.first_name} signed in`);

            return res.status(StatusCodes.ok).json({
                access_token: accessToken,
                refresh_token: refreshToken,
                user: {
                    uid: user.uid,
                    first_name: user.first_name,
                    email: user.email,
                    language: user.language,
                    created_at: user.created_at,
                    updated_at: user.updated_at
                }
            });

        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}`, code: AUTH_ERROR_CODES.SERVER_ERROR });
        }
    },

    // return an access token if the provided refresh token is valid
    refreshToken: async (req: Request, res: Response) => {
        const { refresh_token } = req.body;

        if (!refresh_token) {
            return res.status(StatusCodes.badRequest).json({ message: "Missing refresh token", code: AUTH_ERROR_CODES.INVALID_REFRESH_TOKEN });
        }

        try {
            // Verify the refresh token signature
            let decoded: any;
            try {
                decoded = jwt.verify(refresh_token, REFRESH_TOKEN_SECRET);
            } catch (e) {
                return res.status(StatusCodes.unauthorized).json({ message: "Invalid or expired refresh token", code: AUTH_ERROR_CODES.INVALID_REFRESH_TOKEN });
            }

            // Check if refresh token exists in DB
            const hasValidRefreshToken = await AuthService.hasValidRefreshToken(decoded.uid, refresh_token);
            if (!hasValidRefreshToken) {
                return res.status(StatusCodes.unauthorized).json({ message: "Refresh token not found or expired", code: AUTH_ERROR_CODES.INVALID_REFRESH_TOKEN });
            }

            // Fetch user
            const user = await UserService.findUserById(decoded.uid);
            if (!user) {
                return res.status(StatusCodes.unauthorized).json({ message: "User not found", code: AUTH_ERROR_CODES.INVALID_REFRESH_TOKEN });
            }

            // Generate new access token
            const newAccessToken = jwt.sign(
                { uid: user.uid, email: user.email },
                ACCESS_TOKEN_SECRET,
                { expiresIn: '24h' }
            );

            const newRefreshToken = jwt.sign(
                { uid: user.uid },
                REFRESH_TOKEN_SECRET,
                { expiresIn: '90d' }
            );

            await AuthService.storeRefreshToken(user.uid, newRefreshToken);

            return res.status(StatusCodes.ok).json({
                access_token: newAccessToken,
                refresh_token: newRefreshToken, 
                user: {
                    uid: user.uid,
                    first_name: user.first_name,
                    email: user.email,
                    language: user.language,
                    created_at: user.created_at,
                    updated_at: user.updated_at
                }
            });

        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}`, code: AUTH_ERROR_CODES.SERVER_ERROR });
        }
    }
}

export default authController;