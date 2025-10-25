import { MealLogController } from "../controllers/Food/MealLogController";

import express from 'express';
const router = express.Router();

router.get('/user/:uid', MealLogController.getAllUserMealLogs);
router.post('/', MealLogController.addMealLog);
router.delete('/:id', MealLogController.deleteMealLog);
router.delete('/user/:userid', MealLogController.deleteUserMealLogs);
router.get('/user/:uid/date/:date', MealLogController.getAllUserMealLogsByDate);
router.get('/user/:uid/daterange/:startDate/:endDate', MealLogController.getAllUserMealLogsByDateRange);

export const mealLogRouter = router;
