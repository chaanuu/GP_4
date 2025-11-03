import { ExerciseController } from '../controllers/Exercise/ExerciseController.js';
import express from 'express';
const router = express.Router();

router.get('/user/:uid', ExerciseController.getAllExercisesByUserId);
router.post('/', ExerciseController.createExercise);
router.delete('/:id', ExerciseController.deleteExercise);
router.put('/:id', ExerciseController.updateExercise);
router.get('/static', ExerciseController.getAllStaticExercises);
router.get('/code/:code', ExerciseController.getExerciseByCode);
router.get('/:id', ExerciseController.getExerciseById);

export const exerciseRouter = router;