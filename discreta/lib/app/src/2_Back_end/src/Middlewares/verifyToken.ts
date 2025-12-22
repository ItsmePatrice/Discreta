import { Request, Response, NextFunction } from "express";
import StatusCodes from "../StatusCodes/statusCode";

import logger from "../logs";
import admin from '../Config/firebase';

const tokenVerifier = {
    verifyToken: async (req: Request, res: Response, next: NextFunction) => {
        const authHeader = req.get('Authorization');
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(StatusCodes.unauthorized).send('Missing or invalid authorization header');
        }
        const idToken = authHeader.split(' ')[1];
        try {
            const decodedToken = await admin.auth().verifyIdToken(idToken);
            const firebaseUid = decodedToken.uid;
            const fullName = decodedToken.name || '';
            const [firstName, ...rest] = fullName.split(' ');
            const lastName = rest.join(' ');
            req.firebaseUid = firebaseUid;
            req.firstName = firstName;
            req.lastName = lastName;
            req.email = decodedToken.email;
            next();
        } catch (e) {
            logger.error('Token verification failed:', e);
            return res.status(StatusCodes.unauthorized).send({ message: 'Token verification failed' });
        }
    }
}

export default tokenVerifier;