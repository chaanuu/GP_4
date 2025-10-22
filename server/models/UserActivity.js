import { db } from '../modules/utils/DB.js';

export class UserActivity {
    constructor(userId, walkSteps, kcalBurned, date = new Date()) {
        this.userId = userId;               // 사용자 고유 ID
        this.walkSteps = walkSteps;         // 걸음 수
        this.kcalBurned = kcalBurned;       // 소모 칼로리
        this.date = date;                   // 활동 날짜
        this.id = null;                     // DB에 저장되면 설정됨
    }
    /**
     * 
     * @returns  {Promise<UserActivity>} 저장된 UserActivity 객체 반환
     * 
     */
    async save() {
        try {
            await db.create('user_activities', {
                user_id: this.userId,
                walk_steps: this.walkSteps,
                kcal_burned: this.kcalBurned,
                date: this.date.getTime()
            }).then((result) => { this.id = result.insertId; });
        } catch (error) {
            console.error('Error saving user activity on DB :', error);
            throw error;
        }
        return this;

    }

    async remove() {
        try {
            return await db.delete('user_activities', { id: this.id });
        } catch (error) {
            console.error('Error deleting user activity from DB :', error);
            throw error;
        }
    }

    /**
     * 
     * @param {number} id
     * @returns {Promise<UserActivity|null>} id에 해당하는 UserActivity 객체 반환, 없으면 null 반환
     */
    static async getById(id) {
        try {
            return new UserActivity(await db.read('user_activities', { id: id }));
        }
        catch (error) {
            console.error('Error getting user activity by ID from DB :', error);
            throw error;
        }
    }

    static async removeById(id) {
        try {
            return await db.delete('user_activities', { id: id });
        } catch (error) {
            console.error('Error deleting user activity by ID from DB :', error);
            throw error;
        }
    }

    static async getAllByUserId(userId) {
        try {
            const rows = await db.read('user_activities', { user_id: userId });
            return rows.map(row => new UserActivity(row));
        } catch (error) {
            console.error('Error getting user activities by user ID from DB :', error);
            throw error;
        }
    }

    static async removeAllByUserId(userId) {
        try {
            return await db.delete('user_activities', { user_id: userId });
        } catch (error) {
            console.error('Error deleting user activities by user ID from DB :', error);
            throw error;
        }
    }


}