import { AuthController } from "../controllers/AuthController";
import express from 'express';
const router = express.Router();

router.post('/login', AuthController.localLogin);
router.post('/refresh', AuthController.refreshToken);
router.post('/logout', AuthController.logout);
router.post('/register', AuthController.registerUser);

export const authRouter = router;
