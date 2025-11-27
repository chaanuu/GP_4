import express from 'express';
import { ExerciseLogController } from '../controllers/Exercise/ExerciseLogController.js';

const router = express.Router();

// 유저 ID 파라미터는 :userId로 통일하는 것이 중요!!
router.get('/user/:userId', ExerciseLogController.getAllExerciseLogsByUserId);
router.post('/', ExerciseLogController.createExerciseLog);
router.delete('/:id', ExerciseLogController.deleteExerciseLogById);
router.delete('/user/:userId', ExerciseLogController.deleteAllExerciseLogsByUserId);
router.get('/user/:userId/date/:date', ExerciseLogController.getAllExerciseLogsByDate);
router.get('/user/:userId/daterange/:startDate/:endDate', ExerciseLogController.getExerciseLogsByDateRange);

// 근육 피로도 summary
router.get('/user/:userId/muscles/summary', ExerciseLogController.getMuscleTirednessSummary);

export const exerciseLogRouter = router;
