import { ExerciseController } from "../controllers/ExerciseController";
import express from 'express';
const router = express.Router();

router.get('/user/:uid', ExerciseController.getAllUserExercises);
router.post('/', ExerciseController.addExercise);
router.delete('/:id', ExerciseController.deleteExercise);
router.delete('/user/:userid', ExerciseController.deleteUserExercises);
router.get('/user/:uid/date/:date', ExerciseController.getAllUserExercisesByDate);
router.get('/user/:uid/daterange/:startDate/:endDate', ExerciseController.getAllUserExercisesByDateRange);


export const exerciseRouter = router;