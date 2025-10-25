import { FoodService } from "../../services/Food/FoodService.js";
import { PythonProcess } from '../../utils/PythonProcess.js';

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

    static async getFoodById(req, res) {
        const food = await FoodService.getFoodById(req.params.id);
        res.status(200).json(food);
    }

    static async getAllFoods(req, res) {
        const foods = await FoodService.getAllFoods();
        res.status(200).json(foods);
    }

    static async createFood(req, res) {
        const newFood = await FoodService.createFood(req.body);
        res.status(201).json(newFood);
    }

    static async updateFood(req, res) {
        const updatedFood = await FoodService.updateFood(req.params.id, req.body);
        res.status(200).json(updatedFood);
    }

    static async deleteFood(req, res) {
        await FoodService.deleteFood(req.params.id);
        res.sendStatus(204);
    }




}