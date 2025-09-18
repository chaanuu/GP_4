import db from '../modules/utils/DB.js';

// { name, id, {inbodys}, nutrition }
export class User {
    constructor(name) {
        this.name = name;
        this.id = null; // DB에 저장되면 설정됨
        this.inbodys = []; // Inbody 객체 데이터 (미정)
        this.nutrition = {}; // {kcal, carb, protein, fat} TODO : 인자 수정 필요
    }


    /**
     * 
     * @returns {Promise<User>} 저장된 User 객체 반환
     */
    async save() {
        const conn = await db.getConnection();
        try {
            const [result] = await conn.query(
                'INSERT INTO users (name) VALUES (?)',
                [this.name]
            );
            this.id = result.insertId;
        } finally {
            conn.release();
        }
        return this;
    }

    /**
     * 
     * @returns {Promise<Array<User>>} 모든 User 객체 배열 반환
     */
    static async getAll() {
        const conn = await db.getConnection();
        try {
            const [rows] = await conn.query('SELECT * FROM users');
            return rows.map(row => new User(row));
        } finally {
            conn.release();
        }

    }


    /**
     * 
     * @param {number} id 
     * @returns {Promise<User|null>} id에 해당하는 User 객체 반환, 없으면 null 반환
     */
    static async getById(id) {
        const conn = await db.getConnection();
        try {
            const [rows] = await conn.query('SELECT * FROM users WHERE id = ?', [id]);
            if (rows.length > 0) {
                return new User(rows[0]);
            }
            return null;
        } finally {
            conn.release();
        }

    }


    /**
     * 
     * @param {string} query 
     * @returns  {Promise<Array<User>>} 이름에 query가 포함된 User 객체 배열 반환
     */
    static async getByQuery(query) {
        const conn = await db.getConnection();
        try {
            const searchQuery = `%${query}%`;
            const [rows] = await conn.query('SELECT * FROM users WHERE name LIKE ?', [searchQuery]);
            return rows.map(row => new User(row));
        } finally {
            conn.release();
        }

    }

    /**
     * 
     * @param {number} id
     * @param {User} updatedUser
     * @returns  {Promise<boolean>} 수정 성공 여부 반환
     */
    static async update(id, updatedUser) {
        const { name } = updatedUser;
        const conn = await db.getConnection();
        try {
            const [result] = await conn.query(
                'UPDATE users SET name = ? WHERE id = ?',
                [name, id]
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
            const [result] = await conn.query('DELETE FROM users WHERE id = ?', [id]);
            return result.affectedRows > 0;
        } finally {
            conn.release();
        }

    }
}