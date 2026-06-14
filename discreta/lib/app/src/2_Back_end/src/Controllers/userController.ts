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
            const uid = req.uid;
            if (!uid) {
                throw ("uid was null");
            }

            const messageContent: string = req.body.message;
            if (!messageContent || messageContent.length === 0) {
                return res.status(StatusCodes.badRequest).json({ message: 'Message content is required' });
            }
            await UserService.saveAlertMessage(uid, messageContent);
            return res.status(StatusCodes.ok).json({ message: 'Alert message saved successfully' });
            
        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    fetchAlertMessage: async (req: Request, res: Response) => {
        try {
            const uid = req.uid;
            if (!uid) {
                throw ("uid was null");
            }

            const message = await UserService.fetchAlertMessage(uid);
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
            const uid = req.uid;
            if (!uid) {
                throw ("uid was null");
            }
            const contacts = await UserService.fetchContacts(uid);
            return res.status(StatusCodes.ok).json({ contacts: contacts });
        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    addContact: async (req: Request, res: Response) => {
        try {
            const uid = req.uid;
            if (!uid) {
                throw ("uid was null");
            }
            const { name, phoneNumber } = req.body;
            if (!name || !phoneNumber) {
                return res.status(StatusCodes.badRequest).json({ message: 'Name and phone number are required' });
            }
            const newContact = await UserService.addContact(uid, name, phoneNumber);
            return res.status(StatusCodes.created).json({ contact: newContact });
        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    deleteContact: async (req: Request, res: Response) => {
        try {
            const uid = req.uid;
            if (!uid) {
                throw ("uid was null");
            }
            const contactId = req.params.contactId;
            if (!contactId) {
                return res.status(StatusCodes.badRequest).json({ message: 'Contact ID is required' });
            }
            await UserService.deleteContact(contactId, uid);
            return res.status(StatusCodes.ok).json({ message: 'Contact deleted successfully' });
        }
        catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    updateContact: async (req: Request, res: Response) => {
        try {
            const uid = req.uid;
            if (!uid) {
                throw ("uid was null");
            }
            const contactId = req.params.contactId;
            const { name, phoneNumber } = req.body;
            if (!contactId || !name || !phoneNumber) {
                return res.status(StatusCodes.badRequest).json({ message: 'Contact ID, name, and phone number are required' });
            }
            const updatedContact = await UserService.updateContact(contactId, uid, name, phoneNumber);
            return res.status(StatusCodes.ok).json({ contact: updatedContact });
        }
        catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    updateLanguagePreference: async (req: Request, res: Response) => {
        try {
            const uid = req.uid;
            if (!uid) {
                throw ("uid was null");
            }
            const { language } = req.body;
            if (!language || (language !== 'fr' && language !== 'en')) {
                return res.status(StatusCodes.badRequest).json({ message: 'Language is required' });
            }
            const newLanguage = await UserService.updateLanguagePreference(uid, language);
            return res.status(StatusCodes.ok).json({ language: newLanguage });
        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },
    sendAlert: async (req: Request, res: Response) => {
        try {
            const uid = req.uid;
            const { firstName } = req.body;

            if (!uid) {
                throw ("uid was null");
            }
            const sentAlert = await AlertService.sendAlertMessage(uid, firstName);
            return res.status(StatusCodes.ok).json({ sentAlert });
        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    startTrackingSession: async (req: Request, res: Response) => {
        try {
            const uid = req.uid;
            const { firstName } = req.body;
            if (!uid || !firstName) {
                throw ("uid was null");
            }
            const { trackingToken } = await AlertService.startTrackingSession(uid, firstName);
            return res.status(StatusCodes.created).json({ trackingToken });
        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    stopTrackingSession: async (req: Request, res: Response) => {
        try {
            const uid = req.uid;
            const { firstName } = req.body;
            if (!uid || !firstName) {
                throw ("uid was null");
            }
            await AlertService.stopTrackingSession(firstName, uid);
            return res.status(StatusCodes.ok).json({ message: 'Tracking session stopped successfully' });
        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    updateLocation: async (req: Request, res: Response) => {
        try {
            const uid = req.uid;
            if (!uid) {
                throw ("uid was null");
            }
            const { trackingToken, lat, lng } = req.body;
            if (!trackingToken || lat === undefined || lng === undefined) {
                return res.status(StatusCodes.badRequest).json({ message: 'Tracking token, latitude, and longitude are required' });
            }
            await AlertService.updateLocation(uid, trackingToken, lat, lng);
            return res.status(StatusCodes.ok).json({ message: 'Location updated successfully' });
        }
        catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    hasActiveTrackingSession: async (req: Request, res: Response) => {
        try {
            const uid = req.uid;
            if (!uid) {
                throw ("uid was null");
            }
            const hasActiveSession = await AlertService.hasActiveTrackingSession(uid);
            return res.status(StatusCodes.ok).json({ "hasActiveTrackingSession": hasActiveSession });
        } catch (e) {
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

    getJsFileForAlertPage: async (req: Request, res: Response) => {
        try {
            const jsPath = path.join(__dirname, '../../public/js/alert.js');
            res.sendFile(jsPath);
        } catch (e) {
            logger.error(e);
            return res.status(StatusCodes.internalServerError).json({ message: `${e}` });
        }
    },

    getCssFileForAlertPage: async (req: Request, res: Response) => {
        try {
            const cssPath = path.join(__dirname, '../../public/css/alert.css');
            res.setHeader('Content-Type', 'text/css');
            res.sendFile(cssPath);
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