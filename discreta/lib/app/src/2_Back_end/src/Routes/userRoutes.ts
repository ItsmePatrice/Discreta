import express from 'express';
const router = express.Router();
import userController from '../Controllers/userController';
import tokenVerifier from '../Middlewares/verifyToken';

router.put('/alert-message', tokenVerifier.verifyToken, userController.saveAlertMessage);
router.get('/alert-message', tokenVerifier.verifyToken, userController.fetchAlertMessage);

router.get('/contacts', tokenVerifier.verifyToken, userController.fetchContacts);
router.post('/contacts', tokenVerifier.verifyToken, userController.addContact);
router.delete('/contacts/:contactId', tokenVerifier.verifyToken, userController.deleteContact);

export default router;
