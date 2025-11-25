import express from 'express';
import { OAuthController } from '../controllers/OAuthController.js';
const router = express.Router();

router.get('/googleLogin', OAuthController.googleLogin);
router.get('/googleCallback', OAuthController.googleCallback);
router.get('/appleLogin', OAuthController.appleLogin);

// 미구현 : 애플 디벨로퍼 계정 필요
//router.get('/appleCallback', OAuthController.appleCallback);

export const OAuthRouter = router;