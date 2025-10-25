import { db } from "../../utils/DB.js";

import { DuplicateEntryError, NotFoundError } from "../../utils/errors.js";

export class MealLog {
    constructor({ userId, foodId, quantity, timeConsumed }) {
        this.id = null; // DB에 저장되면 설정됨
        this.userId = userId;
        this.foodId = foodId;
        this.quantity = quantity; // 섭취량 (g)
        this.timeConsumed = timeConsumed; // 섭취 날짜
    }

    static #fromDB(row) {
        if (!row) return null;

        const mealLog = new MealLog({
            userId: row.userId,
            foodId: row.foodId,
            quantity: row.quantity,
            timeConsumed: row.timeConsumed
        });
        mealLog.id = row.id;
        return mealLog;
    }

    /**
     *
     * @returns  {Promise<MealLog>} 저장된 MealLog 객체 반환
     *
     */
    async save() {
        const data = {
            userId: this.userId,
            foodId: this.foodId,
            quantity: this.quantity,
            timeConsumed: this.timeConsumed
        };

        try {
            if (this.id) {
                // ID가 있으면 UPDATE
                const result = await db.update('meal_logs', data, { id: this.id });
                if (result.affectedRows === 0) {
                    // 업데이트할 대상이 없음 (존재하지 않는 ID)
                    throw new NotFoundError('MealLog not found during update');
                }
            } else {
                // ID가 없으면 INSERT
                const result = await db.create('meal_logs', data);
                this.id = result.insertId;
            }
            return this;

        } catch (error) {
            // DB 에러가 "중복 키" 에러일 경우, 애플리케이션 에러로 변환
            if (error.code === 'ER_DUP_ENTRY') {
                throw new DuplicateEntryError('This meal log entry already exists.');
            }
            // 그 외 DB 에러는 그대로 상위로 전파
            throw error;
        }

    }

    static async getById(id) {
        const rows = await db.read('meal_logs', { id: id });
        if (rows.length === 0) {
            return null;
        }
        return MealLog.#fromDB(rows[0]);

    }

    static async deleteById(id) {
        const result = await db.delete('meal_logs', { id: id });
        if (result.affectedRows === 0) {
            throw new NotFoundError('MealLog not found during delete');
        }
        return true;
    }

    static async getAllByUserId(userId) {
        const rows = await db.read('meal_logs', { userId: userId });
        return rows.map(row => MealLog.#fromDB(row));
    }

    static async deleteAllByUserId(userId) {
        await db.delete('meal_logs', { userId: userId });
        return true;
    }
}