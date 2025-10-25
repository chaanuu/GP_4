import { db } from '../utils/DB.js';

import { DuplicateEntryError, NotFoundError } from '../utils/errors.js';

export class UserActivityLog {
    constructor(userId, walkSteps, kcalBurned, date = new Date()) {
        this.userId = userId;               // 사용자 고유 ID
        this.walkSteps = walkSteps;         // 걸음 수
        this.kcalBurned = kcalBurned;       // 소모 칼로리
        this.date = date;                   // 활동 날짜
        this.id = null;                     // DB에 저장되면 설정됨
    }
    /**
     * 
     * @returns  {Promise<UserActivityLog>} 저장된 UserActivity 객체 반환
     * 
     */
    async save() {
        const data = {
            user_id: this.userId,
            walk_steps: this.walkSteps,
            kcal_burned: this.kcalBurned,
            date: this.date
        };

        try {
            if (this.id) {
                // ID가 있으면 UPDATE
                const result = await db.update('user_activity_logs', data, { id: this.id });
                if (result.affectedRows === 0) {
                    // 업데이트할 대상이 없음 (존재하지 않는 ID)
                    throw new NotFoundError('UserActivityLog not found during update');
                }
            } else {
                // ID가 없으면 INSERT
                const result = await db.create('user_activity_logs', data);
                this.id = result.insertId;
            }
            return this;

        } catch (error) {
            // DB 에러가 "중복 키" 에러일 경우, 애플리케이션 에러로 변환
            if (error.code === 'ER_DUP_ENTRY') {
                throw new DuplicateEntryError('This user activity log entry already exists.');
            }
            // 그 외 DB 에러는 그대로 상위로 전파
            throw error;
        }

    }


    /**
     * 
     * @param {number} id
     * @returns {Promise<UserActivityLog|null>} id에 해당하는 UserActivity 객체 반환, 없으면 null 반환
     */
    static async getById(id) {
        const rows = await db.read('user_activity_logs', { id: id });
        if (rows.length === 0) {
            return null;
        }
        return new UserActivityLog(rows[0]);
    }

    static async deleteById(id) {
        const result = await db.delete('user_activity_logs', { id: id });
        if (result.affectedRows === 0) {
            throw new NotFoundError('UserActivityLog not found during delete');
        }
        return true;
    }

    static async getAllByUserId(userId) {
        const rows = await db.read('user_activity_logs', { user_id: userId });
        return rows.map(row => new UserActivityLog(row.user_id, row.walk_steps, row.kcal_burned, row.date));
    }

    static async deleteAllByUserId(userId) {
        await db.delete('user_activity_logs', { user_id: userId });
        return true;
    }

    static async getAllByDateRange(userId, startDate, endDate) {
        const query = `SELECT * FROM user_activity_logs WHERE user_id = ? AND date BETWEEN ? AND ?`;
        const rows = await db.query(query, [userId, startDate, endDate]);
        if (rows.length === 0) {
            return [];
        }
        return rows.map(row => new UserActivityLog(row.user_id, row.walk_steps, row.kcal_burned, row.date));
    }

}