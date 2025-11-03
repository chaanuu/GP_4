import { ExerciseLogController } from '../controllers/Exercise/ExerciseLogController.js';

import express from 'express';
const router = express.Router();

router.get('/user/:uid', ExerciseLogController.getAllExerciseLogsByUserId);
router.post('/', ExerciseLogController.createExerciseLog);
router.delete('/:id', ExerciseLogController.deleteExerciseLogById);
router.delete('/user/:userid', ExerciseLogController.deleteAllExerciseLogsByUserId);
router.get('/user/:uid/date/:date', ExerciseLogController.getAllExerciseLogsByDate);
router.get('/user/:uid/daterange/:startDate/:endDate', ExerciseLogController.getExerciseLogsByDateRange);


export const exerciseLogRouter = router;
