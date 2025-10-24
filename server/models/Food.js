import { db } from '../modules/utils/DB.js';

export class Food {
    constructor({ name, kcal, carb, protein, fat, imgUrl, userId = null }) {
        this.id = null; // DB에 저장되면 설정됨
        this.name = name;
        this.imgUrl = imgUrl || null;

        this.userId = userId; // null이면 기본구성, 값이 있으면 유저귀속

        // 영양성분 (100g 기준)
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
                name: this.name,
                kcal: this.kcal,
                carb: this.carb,
                protein: this.protein,
                fat: this.fat,
                userId: this.userId
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

    static async getAllByUserId(userId) {
        try {
            const rows = await db.read('foods', { userId: userId });
            return rows.map(row => new Food(row));
        } catch (error) {
            console.error('Error getting foods by user ID from DB :', error);
            throw error;
        }
    }

    static async deleteAllByUserId(userId) {
        try {
            return db.delete('foods', { userId: userId });
        } catch (error) {
            console.error('Error deleting foods by user ID from DB :', error);
            throw error;
        }
    }


}
