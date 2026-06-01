import * as express from 'express';

declare global {
    namespace Express {
        interface Request {
            firstName?: string;
            email?: string;
            uid?: string;
        }
    }
}

export {};