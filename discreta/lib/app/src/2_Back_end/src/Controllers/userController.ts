import UserService from '../Services/userService';
import { Request, Response } from "express";
import StatusCodes from '../StatusCodes/statusCode';
import logger from '../logs';

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
}

export default userController;