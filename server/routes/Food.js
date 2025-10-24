import express from 'express';
import { FoodController } from '../controllers/FoodController';
const router = express.Router();

router.post('/img_anlysis', FoodController.analyzeFoodImage);

router.get('/:uid', FoodController.getUserFoods);

router.post('/', FoodController.addFood);

router.put('/:id', FoodController.updateFood);

router.delete('/:id', FoodController.deleteFood);

router.delete('/user/:userid', FoodController.deleteUserFoods);


export const foodRouter = router;
