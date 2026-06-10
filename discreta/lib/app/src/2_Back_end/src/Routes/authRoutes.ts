import express from 'express';
const router = express.Router();
import authController from '../Controllers/authController';

router.post('/login',  authController.signInUser);
router.post('/refresh-token', authController.refreshTokens);
router.post('/refresh-access-token', authController.refreshAccessToken);

export default router;
