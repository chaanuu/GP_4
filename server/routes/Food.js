import express from 'express';
import { FoodController } from '../controllers/Food/FoodController.js';
import { upload } from '../middlewares/uploadMiddleware.js';

const router = express.Router();

router.post('/img_anlysis', FoodController.analyzeFoodImage);

router.get('/:uid', FoodController.getAllFoodsByUserId);

router.post('/', FoodController.createFood);

router.put('/:id', FoodController.updateFood);

router.delete('/:id', FoodController.deleteFood);

router.delete('/user/:userid', FoodController.deleteAllFoodsByUserId);

router.post('/img_upload', upload.single('foodImg'), FoodController.uploadFoodImage);

export const foodRouter = router;
