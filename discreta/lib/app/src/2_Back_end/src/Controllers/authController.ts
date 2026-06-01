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

const ACCESS_TOKEN_SECRET = process.env.ACCESS_TOKEN_SECRET as string;
const REFRESH_TOKEN_SECRET = process.env.REFRESH_TOKEN_SECRET as string;

const authController = {

    signInUser: async (req: Request, res: Response) => {
        const { firstName, email, accessCode } = req.body;

        if (!firstName || !email || !accessCode) {
            return res.status(StatusCodes.badRequest).json({ error: "Missing required fields" });
        }

        try {
            // Validate access code
            const isValidAccessCode = await AccessCodeService.isValidAccessCode(accessCode);
            if (!isValidAccessCode) {
                return res.status(StatusCodes.unauthorized).json({ error: "Invalid access code" });
            }

            // Check if user exists
            let user = await UserService.findUser(email);

            if (!user) {
                const newUser: UserDto = { firstName, email };
                user = await UserService.createUser(newUser);
                await AccessCodeService.incrementAccessCodeUseCount(accessCode);
            }

            // Generate tokens
            const accessToken = jwt.sign(
                { uid: user.uid, email: user.email },
                ACCESS_TOKEN_SECRET,
                { expiresIn: '4h' }
            );

            const refreshToken = jwt.sign(
                { uid: user.uid },
                REFRESH_TOKEN_SECRET,
                { expiresIn: '90d' }
            );

            await AuthService.storeRefreshToken(user.uid, refreshToken);

            await LogService.logEvent(user.uid, `${firstName} signed in`);

            return res.status(StatusCodes.ok).json({
                access_token: accessToken,
                refresh_token: refreshToken,
                user: {
                    uid: user.uid,
                    first_name: user.first_name,
                    email: user.email,
                    language: user.language
                }
            });

        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    // return an access token if the provided refresh token is valid
    refreshToken: async (req: Request, res: Response) => {
        const { refresh_token } = req.body;

        if (!refresh_token) {
            return res.status(StatusCodes.badRequest).json({ error: "Missing refresh token" });
        }

        try {
            // Verify the refresh token signature
            let decoded: any;
            try {
                decoded = jwt.verify(refresh_token, REFRESH_TOKEN_SECRET);
            } catch (e) {
                return res.status(StatusCodes.unauthorized).json({ error: "Invalid or expired refresh token" });
            }

            // Check if refresh token exists in DB
            const hasValidRefreshToken = await AuthService.hasValidRefreshToken(decoded.uid, refresh_token);
            if (!hasValidRefreshToken) {
                return res.status(StatusCodes.unauthorized).json({ error: "Refresh token not found or expired" });
            }

            // Fetch user
            const user = await UserService.findUserById(decoded.uid);
            if (!user) {
                return res.status(StatusCodes.unauthorized).json({ error: "User not found" });
            }

            // Generate new access token
            const newAccessToken = jwt.sign(
                { uid: user.uid, email: user.email },
                ACCESS_TOKEN_SECRET,
                { expiresIn: '4h' }
            );

            const newRefreshToken = jwt.sign(
                { uid: user.uid },
                REFRESH_TOKEN_SECRET,
                { expiresIn: '90d' }
            );

            await AuthService.storeRefreshToken(user.uid, newRefreshToken);

            return res.status(StatusCodes.ok).json({
                access_token: newAccessToken,
                refresh_token: newRefreshToken
            });

        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    }
}

export default authController;