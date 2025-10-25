import { db } from '../utils/DB.js';

import { DuplicateEntryError, NotFoundError } from '../utils/errors.js';

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
        const data = {
            name: this.name,
            kcal: this.kcal,
            carb: this.carb,
            protein: this.protein,
            fat: this.fat,
            imgUrl: this.imgUrl,
            userId: this.userId
        };

        try {
            if (this.id) {
                // ID가 있으면 UPDATE
                const result = await db.update('foods', data, { id: this.id });
                if (result.affectedRows === 0) {
                    // 업데이트할 대상이 없음 (존재하지 않는 ID)
                    throw new NotFoundError('Food not found during update');
                }
            } else {
                // ID가 없으면 INSERT
                const result = await db.create('foods', data);
                this.id = result.insertId;
            }
            return this;

        } catch (error) {
            // DB 에러가 "중복 키" 에러일 경우, 애플리케이션 에러로 변환
            if (error.code === 'ER_DUP_ENTRY') {
                throw new DuplicateEntryError('This food entry already exists.');
            }
            // 그 외 DB 에러는 그대로 상위로 전파
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
            const rows = await db.read('foods', { id: id });

            if (rows.length === 0) {
                // "못 찾음"은 에러가 아니므로, null을 반환합니다.
                // 서비스 계층이 이 null을 보고 NotFoundError를 throw할 것입니다.
                return null;
            }
            return new Food(rows[0]);
        } catch (error) {
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
        const { query } = opt;
        try {
            const rows = await db.query('foods', [`name LIKE ?`, [`%${query}%`]]);
            return rows.map(row => new Food(row));
        } catch (error) {
            console.error('Error getting foods by query from DB :', error);
            throw error;
        }

    }


    /**
     * 
     * @param {number} id    
     * @returns {Promise<boolean>} 삭제 성공 여부 반환
     */
    static async deleteById(id) {
        try {
            const result = await db.delete('foods', { id: id });

            if (result.affectedRows === 0) {
                // 삭제할 대상이 없음 (존재하지 않는 ID)
                throw new NotFoundError('Food not found, delete failed.');
            }
            return true;
        } catch (error) {
            console.error('Error deleting food by ID from DB :', error);
            throw error;
        }
    }

    static async getAllByUserId(userId) {
        const rows = await db.read('foods', { userId: userId });
        return rows.map(row => new Food(row));
    }

    static async deleteAllByUserId(userId) {
        db.delete('foods', { userId: userId });
        return true;
    }


}
