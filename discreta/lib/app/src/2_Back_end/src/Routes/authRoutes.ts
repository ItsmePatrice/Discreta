import express from 'express';
const router = express.Router();
import authController from '../Controllers/authController';
import tokenVerifier from '../Middlewares/verifyToken';

router.post('/login', tokenVerifier.verifyToken, authController.googleSignUp);

export default router;
