import { Request, Response, NextFunction } from "express";
import StatusCodes from "../StatusCodes/statusCode";

import logger from "../logs";
import jwt  from "jsonwebtoken";

const ACCESS_TOKEN_SECRET = process.env.ACCESS_TOKEN_SECRET as string;

const tokenVerifier = {
    verifyToken: async (req: Request, res: Response, next: NextFunction) => {
        const authHeader = req.get('Authorization');
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(StatusCodes.unauthorized).send('Missing or invalid authorization header');
        }
        const accessToken = authHeader.split(' ')[1];
        try {
            // verify the validity of the the token. 
            const decoded = jwt.verify(accessToken, ACCESS_TOKEN_SECRET) as { uid: string; email: string };
            req.uid = decoded.uid;
            next();
        } catch (e) {
            logger.error('Token verification failed:', e);
            return res.status(StatusCodes.unauthorized).send({ message: 'Token verification failed' });
        }
    }
}

export default tokenVerifier;