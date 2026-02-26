import UserService from '../Services/userService';
import { Request, Response } from "express";
import StatusCodes from '../StatusCodes/statusCode';
import logger from '../logs';
import AlertService from '../Services/alertService';
import path from 'path';
import fs from 'fs';

const userController = {

    saveAlertMessage: async (req: Request, res: Response) => {
        try {
            const firebaseUid = req.firebaseUid;
            if (!firebaseUid) {
                throw ("firebaseUid was null");
            }

            const messageContent: string = req.body.message;
            if (!messageContent || messageContent.length === 0) {
                return res.status(StatusCodes.badRequest).json({ message: 'Message content is required' });
            }
            await UserService.saveAlertMessage(firebaseUid, messageContent);
            return res.status(StatusCodes.ok).json({ message: 'Alert message saved successfully' });
            
        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    fetchAlertMessage: async (req: Request, res: Response) => {
        try {
            const firebaseUid = req.firebaseUid;
            if (!firebaseUid) {
                throw ("firebaseUid was null");
            }

            const message = await UserService.fetchAlertMessage(firebaseUid);
            if (message === null) {
                return res.status(StatusCodes.notFound).json({ message: 'No alert message found' });
            }
            return res.status(StatusCodes.ok).json({ message: message });
            
        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    fetchContacts: async (req: Request, res: Response) => {
        try {
            const firebaseUid = req.firebaseUid;
            if (!firebaseUid) {
                throw ("firebaseUid was null");
            }
            const contacts = await UserService.fetchContacts(firebaseUid);
            return res.status(StatusCodes.ok).json({ contacts: contacts });
        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    addContact: async (req: Request, res: Response) => {
        try {
            const firebaseUid = req.firebaseUid;
            if (!firebaseUid) {
                throw ("firebaseUid was null");
            }
            const { name, phoneNumber } = req.body;
            if (!name || !phoneNumber) {
                return res.status(StatusCodes.badRequest).json({ message: 'Name and phone number are required' });
            }
            const newContact = await UserService.addContact(firebaseUid, name, phoneNumber);
            return res.status(StatusCodes.created).json({ contact: newContact });
        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    deleteContact: async (req: Request, res: Response) => {
        try {
            const firebaseUid = req.firebaseUid;
            if (!firebaseUid) {
                throw ("firebaseUid was null");
            }
            const contactId = req.params.contactId;
            if (!contactId) {
                return res.status(StatusCodes.badRequest).json({ message: 'Contact ID is required' });
            }
            await UserService.deleteContact(contactId, firebaseUid);
            return res.status(StatusCodes.ok).json({ message: 'Contact deleted successfully' });
        }
        catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    updateContact: async (req: Request, res: Response) => {
        try {
            const firebaseUid = req.firebaseUid;
            if (!firebaseUid) {
                throw ("firebaseUid was null");
            }
            const contactId = req.params.contactId;
            const { name, phoneNumber } = req.body;
            if (!contactId || !name || !phoneNumber) {
                return res.status(StatusCodes.badRequest).json({ message: 'Contact ID, name, and phone number are required' });
            }
            const updatedContact = await UserService.updateContact(contactId, firebaseUid, name, phoneNumber);
            return res.status(StatusCodes.ok).json({ contact: updatedContact });
        }
        catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    updateLanguagePreference: async (req: Request, res: Response) => {
        try {
            const firebaseUid = req.firebaseUid;
            if (!firebaseUid) {
                throw ("firebaseUid was null");
            }
            const { language } = req.body;
            if (!language || (language !== 'fr' && language !== 'en')) {
                return res.status(StatusCodes.badRequest).json({ message: 'Language is required' });
            }
            const newLanguage = await UserService.updateLanguagePreference(firebaseUid, language);
            return res.status(StatusCodes.ok).json({ language: newLanguage });
        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },
    sendAlert: async (req: Request, res: Response) => {
        try {
            const firebaseUid = req.firebaseUid;
            if (!firebaseUid || !req.firstName) {
                throw ("firebaseUid was null");
            }
            const sentAlert = await AlertService.sendAlertMessage(firebaseUid, req.firstName);
            return res.status(StatusCodes.ok).json({ sentAlert });
        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    startTrackingSession: async (req: Request, res: Response) => {
        try {
            const firebaseUid = req.firebaseUid;
            if (!firebaseUid || !req.firstName) {
                throw ("firebaseUid was null");
            }
            const { trackingToken } = await AlertService.startTrackingSession(firebaseUid, req.firstName);
            return res.status(StatusCodes.created).json({ trackingToken });
        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    stopTrackingSession: async (req: Request, res: Response) => {
        try {
            const firebaseUid = req.firebaseUid;
            if (!firebaseUid || !req.firstName) {
                throw ("firebaseUid was null");
            }
            const { trackingToken } = req.body;
            if (!trackingToken) {
                return res.status(StatusCodes.badRequest).json({ message: 'Tracking token is required' });
            }
            const username = req.firstName;
            await AlertService.stopTrackingSession(username, firebaseUid, trackingToken);
            return res.status(StatusCodes.ok).json({ message: 'Tracking session stopped successfully' });
        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    updateLocation: async (req: Request, res: Response) => {
        try {
            const firebaseUid = req.firebaseUid;
            if (!firebaseUid) {
                throw ("firebaseUid was null");
            }
            const { trackingToken, lat, lng } = req.body;
            if (!trackingToken || lat === undefined || lng === undefined) {
                return res.status(StatusCodes.badRequest).json({ message: 'Tracking token, latitude, and longitude are required' });
            }
            await AlertService.updateLocation(firebaseUid, trackingToken, lat, lng);
            return res.status(StatusCodes.ok).json({ message: 'Location updated successfully' });
        }
        catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    getAlertPage: async (req: Request, res: Response) => {
        try {
            const trackingToken = req.params.token;
            if (!trackingToken) {
                return res.status(StatusCodes.badRequest).json({ message: 'Tracking token missing' });
            }
            const htmlPath = path.join(__dirname, '../../public/alert.html');
            res.sendFile(htmlPath);
        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    getLocation: async (req: Request, res: Response) => {
        try {
            const trackingToken  = req.params.token;
            if (!trackingToken) {
                return res.status(StatusCodes.badRequest).json({ message: 'Tracking token missing' });
            }
            const { lat, lng, minutesSinceLastUpdate } = await AlertService.getTrackingData(trackingToken);

            return res.status(StatusCodes.ok).json({ lat, lng, minutesSinceLastUpdate });
        }
        catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },
    
}

export default userController;