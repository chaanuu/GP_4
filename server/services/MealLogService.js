import { MealLog } from '../models/MealLog';

import { NotFoundError } from '../utils/errors.js';

export class MealLogService {
    static async createMealLog(data) {
        const mealLog = new MealLog(data.userId, data.foodId, data.mealType, data.quantity, data.dateConsumed);
        return await mealLog.save();
    }

    static async getMealLogById(id) {
        const mealLog = await MealLog.getById(id);
        if (!mealLog) {
            throw new NotFoundError('MealLog not found');
        }
        return mealLog;
    }


    static async updateMealLog(id, data) {
        const mealLog = await this.getMealLogById(id);

        mealLog.foodId = data.foodId || mealLog.foodId;
        mealLog.mealType = data.mealType || mealLog.mealType;
        mealLog.quantity = data.quantity || mealLog.quantity;
        mealLog.timeConsumed = data.timeConsumed || mealLog.timeConsumed;

        return await mealLog.save();
    }

    static async deleteMealLog(id) {
        const mealLog = await this.getMealLogById(id);
        return await mealLog.delete();
    }

    static async getAllMealLogsByUserId(userId) {
        return await MealLog.getAllByUserId(userId);
    }

    static async getMealLogsByDateRange(userId, startDate, endDate) {
        return await MealLog.getByDateRange(userId, startDate, endDate);
    }

}
