import { Food } from '../../models/Food/Food.js';

import { NotFoundError } from '../../utils/errors.js';

export class FoodService {
    static async createFood(data) {
        const food = new Food(data.userId, data.name, data.kcal, data.carb, data.protein, data.fat);
        return await food.save();
    }

    static async getFoodById(id) {
        const food = await Food.getById(id);
        if (!food) {
            throw new NotFoundError('Food not found');
        }
        return food;
    }

    static async updateFood(id, data) {
        const food = await this.getFoodById(id);

        food.name = data.name || food.name;
        food.kcal = data.kcal || food.kcal;
        food.carb = data.carb || food.carb;
        food.protein = data.protein || food.protein;
        food.fat = data.fat || food.fat;

        return await food.save();
    }

    static async deleteFoodById(id) {
        const food = await this.getFoodById(id);
        return await food.delete();
    }

    static async getAllFoodsByUserId(userId) {
        return await Food.getAllByUserId(userId);
    }

    static async deleteAllFoodsByUserId(userId) {
        return await Food.deleteAllByUserId(userId);
    }


}