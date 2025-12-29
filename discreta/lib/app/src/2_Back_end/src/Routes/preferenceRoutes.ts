import express from 'express';
const router = express.Router();
import userController from '../Controllers/userController';
import tokenVerifier from '../Middlewares/verifyToken';

router.patch('/language', tokenVerifier.verifyToken, userController.updateLanguagePreference);


export default router;
