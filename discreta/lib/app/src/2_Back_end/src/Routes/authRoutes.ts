import express from 'express';
const router = express.Router();
import authController from '../Controllers/authController.js';
import tokenVerifier from '../Middlewares/verifyToken.js';

router.get('/user-exists/:firebaseUid', authController.checkIfUserExists);
router.post('/register', tokenVerifier.verifyToken, authController.googleSignUp);

export default router;
