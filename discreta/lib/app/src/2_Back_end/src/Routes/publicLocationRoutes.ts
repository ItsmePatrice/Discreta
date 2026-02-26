import express from 'express';
const router = express.Router();
import userController from '../Controllers/userController';

router.get('/track/page/:token', userController.getAlertPage);
router.get('/track/:token', userController.getLocation);

export default router;