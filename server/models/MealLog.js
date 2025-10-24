import { db } from "../utils/DB";

export class MealLog {
    constructor({ userId, foodId, quantity, timeConsumed }) {
        this.id = null; // DB에 저장되면 설정됨
        this.userId = userId;
        this.foodId = foodId;
        this.quantity = quantity; // 섭취량 (g)
        this.timeConsumed = timeConsumed; // 섭취 날짜
    }

    /**
     *
     * @returns  {Promise<MealLog>} 저장된 MealLog 객체 반환
     *
     */
    async save() {
        try {
            await db.save('meal_logs', {
                userId: this.userId,
                foodId: this.foodId,
                quantity: this.quantity,
                timeConsumed: this.timeConsumed
            }).then((result) => { this.id = result.insertId; });
        } catch (error) {
            console.error('Error saving meal log on DB :', error);
            throw error;
        }
        return this;

    }

    static async getById(id) {
        try {
            return new MealLog(await db.read('meal_logs', { id: id }));
        } catch (error) {
            console.error('Error getting meal log by ID from DB :', error);
            throw error;
        }
    }

    static async getAllByUserId(userId) {
        try {
            const rows = await db.read('meal_logs', { userId: userId });
            return rows.map(row => new MealLog(row));
        } catch (error) {
            console.error('Error getting meal logs by user ID from DB :', error);
            throw error;
        }
    }

    static async deleteById(id) {
        try {
            return db.delete('meal_logs', { id: id });
        } catch (error) {
            console.error('Error deleting meal log by ID from DB :', error);
            throw error;
        }
    }

    static async deleteAllByUserId(userId) {
        try {
            return db.delete('meal_logs', { userId: userId });
        } catch (error) {
            console.error('Error deleting meal logs by user ID from DB :', error);
            throw error;
        }
    }
}