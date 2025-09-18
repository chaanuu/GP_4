import express from 'express';
import { FoodController } from '../controllers/FoodController';
export const router = express.Router();

router.post('/img_anlysis', (req, res) => {
    /*  
        { img , usrData }
    */

    // 메뉴 데이터 지정 
    res.send({
        menu: '메뉴이름',
        kcal: 560,
        carb: 75,
        protein: 18,
        fat: 18
    })
});

router.get('/:uid', FoodController.getUserFoods);

router.post('/', FoodController.addFood);

router.put('/:id', FoodController.updateFood);

router.delete('/:id', FoodController.deleteFood);