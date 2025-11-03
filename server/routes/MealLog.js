import { MealLogController } from '../controllers/Food/MealLogController.js';

import express from 'express';
const router = express.Router();

router.get('/user/:uid', MealLogController.getAllMealLogsByUserId);
router.post('/', MealLogController.createMealLog);
router.delete('/:id', MealLogController.deleteMealLog);
router.delete('/user/:userid', MealLogController.getMealLogsByDate);
router.get('/user/:uid/date/:date', MealLogController.getMealLogsByDateRange);
router.get('/user/:uid/daterange/:startDate/:endDate', MealLogController.getMealLogsByDateRange);

export const mealLogRouter = router;
