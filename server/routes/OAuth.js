import express from 'express';
import { OAuthController } from "../controllers/OAuthController";
const router = express.Router();

router.get('/googleLogin', OAuthController.googleLogin);
router.get('/appleLogin', OAuthController.appleLogin);

export const OAuthRouter = router;