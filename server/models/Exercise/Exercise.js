import { db } from '../../utils/DB.js';

import { DuplicateEntryError, NotFoundError } from '../../utils/errors.js';

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
        const data = {
            userId: this.userId,
            name: this.name,
            mets: this.mets,
            code: this.code,
            mainMuscle: this.mainMuscle,
            subMuscle: this.subMuscle,
            dateExecuted: this.dateExecuted
        };

        try {
            if (this.id) {
                // ID가 있으면 UPDATE
                const result = await db.update('exercises', data, { id: this.id });
                if (result.affectedRows === 0) {
                    // 업데이트할 대상이 없음 (존재하지 않는 ID)
                    throw new NotFoundError('Exercise not found during update');
                }
            } else {
                // ID가 없으면 INSERT
                const result = await db.create('exercises', data);
                this.id = result.insertId;
            }
            return this;

        } catch (error) {
            // DB 에러가 "중복 키" 에러일 경우, 애플리케이션 에러로 변환
            if (error.code === 'ER_DUP_ENTRY') {
                throw new DuplicateEntryError('This exercise entry already exists.');
            }
            // 그 외 DB 에러는 그대로 상위로 전파
            throw error;
        }
    }

    static async getByCode(code) {
        const rows = await db.read('exercises', { code: code });
        if (rows.length === 0) {
            return null;
        }
        return new Exercise(rows[0]);
    }

    static async getById(id) {
        const rows = await db.read('exercises', { id: id });
        if (rows.length === 0) {
            return null;
        }
        return new Exercise(rows[0]);
    }

    // 기본구성 전체
    static async getAllStatic() {
        const rows = await db.read('exercises', { userId: null });
        return rows.map(row => new Exercise(row));
    }

    // 유저 귀속 운동 전체
    static async getAllByUserId(userId) {
        const rows = await db.read('exercises', { userId: userId });
        return rows.map(row => new Exercise(row));
    }

    // 잘 안 쓸듯.
    static async getByQuery(query) {
        const rows = await db.query('exercises', [`name LIKE ?`, [`%${query}%`]]);
        return rows.map(row => new Exercise(row));
    }

    static async deleteById(id) {
        const result = await db.delete('exercises', { id: id });
        if (result.affectedRows === 0) {
            throw new NotFoundError('Exercise not found during delete');
        }
        return true;
    }

    static async deleteAllByUserId(userId) {
        await db.delete('exercises', { userId: userId });
        return true;
    }

}