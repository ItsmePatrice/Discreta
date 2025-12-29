import express from 'express';
const router = express.Router();
import userController from '../Controllers/userController';
import tokenVerifier from '../Middlewares/verifyToken';


// Alert message routes
router.put('/alert-message', tokenVerifier.verifyToken, userController.saveAlertMessage);
router.get('/alert-message', tokenVerifier.verifyToken, userController.fetchAlertMessage);
router.post('/send-alert', tokenVerifier.verifyToken, userController.sendAlert);


// Contact management routes
router.get('/contacts', tokenVerifier.verifyToken, userController.fetchContacts);
router.post('/contacts', tokenVerifier.verifyToken, userController.addContact);
router.delete('/contacts/:contactId', tokenVerifier.verifyToken, userController.deleteContact);
router.put('/contacts/:contactId', tokenVerifier.verifyToken, userController.updateContact);



export default router;
