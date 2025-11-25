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

    static async getAllFoodsByUserId(req, res) {
        const foods = await FoodService.getAllFoodsByUserId(req.params.userId);
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
        await FoodService.deleteFoodById(req.params.id);
        res.sendStatus(204);
    }

    static async deleteAllFoodsByUserId(req, res) {
        await FoodService.deleteAllFoodsByUserId(req.params.userId);
        res.sendStatus(204);
    }

    static async uploadFoodImage(req, res) {
        try {
            const imagePath = req.file.path; // Assuming you're using multer for file uploads
            res.status(200).json({ message: 'Image uploaded successfully', path: imagePath });
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }


}