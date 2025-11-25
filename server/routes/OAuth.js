import express from 'express';
import { OAuthController } from "../controllers/OAuthController";
const router = express.Router();

router.get('/googleLogin', OAuthController.googleLogin);
router.get('/googleCallback', OAuthController.googleCallback);
router.get('/appleLogin', OAuthController.appleLogin);
router.get('/appleCallback', OAuthController.appleCallback);

export const OAuthRouter = router;