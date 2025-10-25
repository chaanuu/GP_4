import { MealLogService } from "../../services/Food/MealLogService";

export class MealLogController {

    static async createMealLog(req, res) {
        const newMealLog = await MealLogService.createMealLog(req.body);
        res.status(201).json(newMealLog);
    }

    static async getMealLogById(req, res) {
        const mealLog = await MealLogService.getMealLogById(req.params.id);
        res.status(200).json(mealLog);
    }

    static async updateMealLog(req, res) {
        const updatedMealLog = await MealLogService.updateMealLog(req.params.id, req.body);
        res.status(200).json(updatedMealLog);
    }

    static async deleteMealLog(req, res) {
        await MealLogService.deleteMealLog(req.params.id);
        res.sendStatus(204);
    }

    static async getAllMealLogsByUserId(req, res) {
        const mealLogs = await MealLogService.getAllMealLogsByUserId(req.params.userId);
        res.status(200).json(mealLogs);
    }

    static async getMealLogsByDateRange(req, res) {
        const mealLogs = await MealLogService.getMealLogsByDateRange(
            req.params.userId,
            req.params.startDate,
            req.params.endDate
        );
        res.status(200).json(mealLogs);
    }


}