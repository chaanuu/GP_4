import { ExerciseLogController } from "../controllers/Exercise/ExerciseController";

import express from 'express';
const router = express.Router();

router.get('/user/:uid', ExerciseLogController.getAllUserExerciseLogs);
router.post('/', ExerciseLogController.addExerciseLog);
router.delete('/:id', ExerciseLogController.deleteExerciseLog);
router.delete('/user/:userid', ExerciseLogController.deleteUserExerciseLogs);
router.get('/user/:uid/date/:date', ExerciseLogController.getAllUserExerciseLogsByDate);
router.get('/user/:uid/daterange/:startDate/:endDate', ExerciseLogController.getAllUserExerciseLogsByDateRange);


export const exerciseLogRouter = router;
