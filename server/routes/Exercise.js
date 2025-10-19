import { ExerciseController } from "../controllers/ExerciseController";
import express from 'express';
const router = express.Router();

router.post('/QRread', ExerciseController.readExerciseFromQR);

export const exerciseRouter = router;