import db from '../modules/utils/DB.js';

export class Exercise {
    constructor({ user_id, name, mets, code }) {
        this.id = null; // DB에 저장되면 설정됨
        this.userId = user_id; // null이면 기본구성, 값이 있으면 유저귀속
        this.name = name;
        this.mets = mets;
        this.code = code;
    }

    async save() {
        const conn = await db.getConnection();
        try {
            const [result] = await conn.query(
                'INSERT INTO exercises (user_id, name, mets, code) VALUES (?, ?, ?, ?)',
                [this.userId, this.name, this.mets, this.code]
            );
            this.id = result.insertId;
            return this;
        } finally {
            conn.release();
        }
    }

    static async getById(id) {
        const conn = await db.getConnection();
        try {
            const [rows] = await conn.query('SELECT * FROM exercises WHERE id = ?', [id]);
            if (rows.length > 0) {
                return new Exercise(rows[0]);
            }
            return null;
        } finally {
            conn.release();
        }
    }

    // 기본구성 전체
    static async getStaticAll() {
        const conn = await db.getConnection();
        try {
            const [rows] = await conn.query('SELECT * FROM exercises WHERE user_id IS NULL');
            return rows.map(row => new Exercise(row));
        } finally {
            conn.release();
        }
    }

    // 유저 귀속 운동 전체
    static async getAllByUserId(userId) {
        const conn = await db.getConnection();
        try {
            const [rows] = await conn.query('SELECT * FROM exercises WHERE user_id = ?', [userId]);
            return rows.map(row => new Exercise(row));
        } finally {
            conn.release();
        }
    }

    static async getByQuery(query) {
        const conn = await db.getConnection();
        try {
            const searchQuery = `%${query}%`;
            const [rows] = await conn.query('SELECT * FROM exercises WHERE name LIKE ?', [searchQuery]);
            return rows.map(row => new Exercise(row));
        } finally {
            conn.release();
        }
    }

    static async create({ user_id, name, mets, code }) {
        const exercise = new Exercise({ user_id, name, mets, code });
        return await exercise.save();
    }

    static async update(id, updatedExercise) {
        const { name, mets, code } = updatedExercise;
        const conn = await db.getConnection();
        try {
            const [result] = await conn.query(
                'UPDATE exercises SET name = ?, mets = ?, code = ? WHERE id = ?',
                [name, mets, code, id]
            );
            return result.affectedRows > 0;
        } finally {
            conn.release();
        }
    }

    static async delete(id) {
        const conn = await db.getConnection();
        try {
            const [result] = await conn.query('DELETE FROM exercises WHERE id = ?', [id]);
            return result.affectedRows > 0;
        } finally {
            conn.release();
        }
    }
}