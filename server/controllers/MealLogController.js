import { MealLog } from "../models/MealLog";

export class MealLogController {

    static async getUserMealLogs(req, res) {
        try {
            const mealLogs = await MealLog.getAllByUserId(req.params.uid);
            if (mealLogs) {
                res.status(200).json(mealLogs);
            } else {
                res.status(404).json({ error: 'Meal logs not found' });
            }
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }

    static async addMealLog(req, res) {
        try {
            const newMealLog = new MealLog({
                userId: req.body.userId,
                foodId: req.body.foodId,
                quantity: req.body.quantity,
                timeConsumed: req.body.timeConsumed
            });
            const savedMealLog = await newMealLog.save();
            res.status(201).json(savedMealLog);
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }

    static async deleteMealLog(req, res) {
        try {
            const mealLog = await MealLog.getById(req.params.id);
            if (mealLog) {
                await MealLog.deleteById(req.params.id);
                res.sendStatus(204);
            } else {
                res.status(404).json({ error: 'Meal log not found' });
            }
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }

    static async deleteUserMealLogs(req, res) {
        try {
            await MealLog.deleteAllByUserId(req.params.userid);
            res.sendStatus(204);
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }
}