import { db } from '../modules/utils/DB.js';

export class Exercise {
    constructor({ userId, name, mets, code, mainMuscle, subMuscle, dateExecuted }) {
        this.id = null; // DB에 저장되면 설정됨
        this.userId = userId; // null이면 기본구성, 값이 있으면 유저귀속
        this.name = name;
        this.mets = mets;
        this.code = code;
        this.mainMuscle = mainMuscle; // 주운동근
        this.subMuscle = subMuscle;   // 보조운동근
        this.dateExecuted = dateExecuted; // 운동 수행 날짜
    }


    /**
     * 
     * @returns  {Promise<Exercise>} 저장된 Exercise 객체 반환
     * 
     */
    async save() {
        try {
            await db.save('exercises', {
                userId: this.userId,
                name: this.name,
                mets: this.mets,
                code: this.code
            }).then((result) => { this.id = result.insertId; });
        } catch (error) {
            console.error('Error saving exercise on DB :', error);
            throw error;
        }
        return this;
    }

    static async getByCode(code) {
        try {
            return new Exercise(await db.read('exercises', { code: code }));
        } catch (error) {
            console.error('Error getting exercise by code from DB :', error);
            throw error;
        }
    }

    static async getById(id) {
        try {
            return new Exercise(await db.read('exercises', { id: id }));
        } catch (error) {
            console.error('Error getting exercise by ID from DB :', error);
            throw error;
        }
    }

    // 기본구성 전체
    static async getStaticAll() {
        try {
            const rows = await db.read('exercises', { userId: null });
            return rows.map(row => new Exercise(row));
        } catch (error) {
            console.error('Error getting static exercises from DB :', error);
            throw error;
        }
    }

    // 유저 귀속 운동 전체
    static async getAllByUserId(userId) {
        try {
            const [rows] = await db.read('exercises', { userId: userId });
            return rows.map(row => new Exercise(row));
        } catch (error) {
            console.error('Error getting user exercises from DB :', error);
            throw error;
        }
    }

    // 잘 안 쓸듯.
    static async getByQuery(query) {
        const conn = await db.getConnection();
        try {
            const searchQuery = `${query}`;
            const [rows] = await conn.query('SELECT * FROM exercises WHERE name LIKE ?', [searchQuery]);
            return rows.map(row => new Exercise(row));
        } finally {
            conn.release();
        }
    }

    static async create({ userId, name, mets, code }) {
        const exercise = new Exercise({ userId, name, mets, code });
        return await exercise.save();
    }

    static async update(id, updatedExercise) {
        const { name, mets, code } = updatedExercise;
        try {
            await db.update('exercises', {
                name: name,
                mets: mets,
                code: code
            }, { id: id });
        } catch (error) {
            console.error('Error updating exercise on DB :', error);
            throw error;
        }
    }

    static async delete(id) {
        try {
            await db.delete('exercises', { id: id });
        } catch (error) {
            console.error('Error deleting exercise on DB :', error);
            throw error;
        }
    }
}