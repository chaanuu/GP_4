import { db } from '../modules/utils/DB.js';
import User from './User.js';

export class Food {
    constructor({ userId, name, kcal, carb, protein, fat, date = new Date(), id = null }) {
        this.userId = userId;
        this.name = name;
        this.kcal = kcal;
        this.carb = carb;
        this.protein = protein;
        this.fat = fat;
    }


    /**
     * 
     * @returns  {Promise<Food>} 저장된 Food 객체 반환
     * 
     */
    async save() {
        try {
            await db.create('foods', {
                user_id: this.userId,
                name: this.name,
                kcal: this.kcal,
                carb: this.carb,
                protein: this.protein,
                fat: this.fat
            });
        } catch (error) {
            console.error('Error saving food on DB :', error);
            throw error;
        }
    }

    /**
     * 
     * @param {number} id
     * @returns {Promise<Food|null>} id에 해당하는 Food 객체 반환, 없으면 null 반환
     */

    static async getById(id) {
        try {
            return new Food(await db.read('foods', { id: id }));
        }
        catch (error) {
            console.error('Error getting food by ID from DB :', error);
            throw error;
        }
    }


    /**
     * 
     * @param   {Object} opt 
     * @returns {Promise<Array<Food>>} 이름에 query가 포함된 Food 객체 배열 반환
     */
    static async getByQuery(opt) {
        try {
            return new Food(await db.query('foods', opt));
        } catch (error) {
            console.error('Error getting foods by query from DB :', error);
            throw error;
        }

    }



    /**
     * 
     * @param {number} id
     * @param {Food} updatedFood 
     * @returns  {Promise<boolean>} 수정 성공 여부 반환
     */
    static async update(id, updatedFood) {
        const { name, kcal, carb, protein, fat } = updatedFood;
        try {
            await db.update('foods', { name, kcal, carb, protein, fat }, { id: id });
        } catch (error) {
            console.error('Error updating food on DB :', error);
            throw error;
        }
    }


    /**
     * 
     * @param {number} id    
     * @returns {Promise<boolean>} 삭제 성공 여부 반환
     */
    static async delete(id) {
        try {
            await db.delete('foods', { id: id });
        } catch (error) {
            console.error('Error deleting food on DB :', error);
            throw error;
        }
    }


    /**
     * 
     * @param {number} userId 
     * @returns {Promise<Array<Food>>} userId에 해당하는 Food 객체 배열 반환
     * 
     */
    static async getAllByUserId(userId) {
        try {
            rows = await db.read('foods', { userId: userId });
            return rows.map(row => new Food(row));
        } catch (error) {
            console.error('Error getting foods by userId from DB :', error);
            throw error;
        }
    }

}
