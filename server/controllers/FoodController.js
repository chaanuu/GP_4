import { Food } from "../models/Food.js";
import { PythonProcess } from "../utils/PythonProcess.js";

export class FoodController {

    static async analyzeFoodImage(req, res) {
        try {
            const imagePath = req.file.path; // Assuming you're using multer for file uploads
            const pythonProcess = new PythonProcess('food_analysis.py', [imagePath]);
            const result = await pythonProcess.run();
            res.status(200).json({ analysis: result });
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }


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
                req.body.name,
                req.body.kcal,
                req.body.carb,
                req.body.protein,
                req.body.fat,
                req.body.userId
            );
            const savedFood = await newFood.save();
            res.status(201).json(savedFood);
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

    static async deleteUserFoods(req, res) {
        try {
            await Food.deleteAllByUserId(req.params.userid);
            res.sendStatus(204);
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }
}