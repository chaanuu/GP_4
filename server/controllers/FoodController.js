import { Food } from "../models/Food";

export class FoodController {

    static async getUserFoods(req, res) {
        try {
            const foods = await Food.getAllByUserId(req.params.uid);
            if (foods) {
                res.status(200).json(foods);
            } else {
                res.status(404).json({ error: 'Foods not found' });
            }
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }

    static async addFood(req, res) {
        try {
            const newFood = new Food(
                req.body.userId,
                req.body.name,
                req.body.kcal,
                req.body.carb,
                req.body.protein,
                req.body.fat
            );
            const savedFood = await newFood.save();
            res.status(201).json(savedFood);
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }

    static async updateFood(req, res) {
        try {
            const food = await Food.getById(req.params.id);
            if (food) {
                food.name = req.body.name || food.name;
                food.kcal = req.body.kcal || food.kcal;
                food.carb = req.body.carb || food.carb;
                food.protein = req.body.protein || food.protein;
                food.fat = req.body.fat || food.fat;
                const updatedFood = await food.save();
                res.status(200).json(updatedFood);
            } else {
                res.status(404).json({ error: 'Food not found' });
            }
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }
    static async deleteFood(req, res) {
        try {
            const food = await Food.getById(req.params.id);
            if (food) {
                await food.delete();
                res.sendStatus(204);
            } else {
                res.status(404).json({ error: 'Food not found' });
            }
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }
}