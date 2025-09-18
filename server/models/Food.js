import db from '../modules/utils/DB.js';

export class Food {
    constructor({ userId, name, kcal, carb, protein, fat }) {
        this.id = null; // DB에 저장되면 설정됨
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
        const conn = await db.getConnection();
        try {
            const [result] = await conn.query(
                'INSERT INTO foods (user_id, name, kcal, carb, protein, fat) VALUES (?, ?, ?, ?, ?, ?)',
                [this.userId, this.name, this.kcal, this.carb, this.protein, this.fat]
            );
            this.id = result.insertId;
            return this;
        } finally {
            conn.release();
        }
    }

    /**
     * 
     * @param {number} id
     * @returns {Promise<Food|null>} id에 해당하는 Food 객체 반환, 없으면 null 반환
     */

    static async getById(id) {
        const conn = await db.getConnection();
        try {
            const [rows] = await conn.query('SELECT * FROM foods WHERE id = ?', [id]);
            if (rows.length > 0) {
                return new Food(rows[0]);
            }
            return null;
        } finally {
            conn.release();
        }
    }


    /**
     * 
     * @param   {Object} opt 
     * @returns {Promise<Array<Food>>} 이름에 query가 포함된 Food 객체 배열 반환
     */
    static async getByQuery(opt) {
        const conn = await db.getConnection();
        try {
            const searchQuery = `%${query}%`;
            const [rows] = await conn.query('SELECT * FROM foods WHERE name LIKE ?', [searchQuery]);
            return rows.map(row => new Food(row));
        } finally {
            conn.release();
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
        const conn = await db.getConnection();
        try {
            const [result] = await conn.query(
                'UPDATE foods SET name = ?, kcal = ?, carb = ?, protein = ?, fat = ? WHERE id = ?',
                [name, kcal, carb, protein, fat, id]
            );
            return result.affectedRows > 0;
        } finally {
            conn.release();
        }
    }


    /**
     * 
     * @param {number} id    
     * @returns {Promise<boolean>} 삭제 성공 여부 반환
     */
    static async delete(id) {
        const conn = await db.getConnection();
        try {
            const [result] = await conn.query('DELETE FROM foods WHERE id = ?', [id]);
            return result.affectedRows > 0;
        } finally {
            conn.release();
        }
    }


    /**
     * 
     * @param {number} userId 
     * @returns {Promise<Array<Food>>} userId에 해당하는 Food 객체 배열 반환
     * 
     */
    static async getAllByUserId(userId) {
        const conn = await db.getConnection();
        try {
            const [rows] = await conn.query('SELECT * FROM foods WHERE user_id = ?', [userId]);
            return rows.map(row => new Food(row));
        } finally {
            conn.release();
        }
    }
}
