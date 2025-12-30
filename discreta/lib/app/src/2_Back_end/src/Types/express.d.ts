import * as express from 'express';

declare global {
    namespace Express {
        interface Request {
            firebaseUid?: string;
            firstName?: string;
            lastName?: string;
            email?: string;
            stripeCustomerID?: string;
            paymentIntentID?: string
        }
    }
}

export {};