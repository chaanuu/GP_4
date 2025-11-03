import { db } from '../../utils/DB.js';

import { DuplicateEntryError, NotFoundError } from '../../utils/errors.js';

export class ExerciseLog {
    constructor({ userId, exerciseId, reps, sets, timeExecuted, durationMinutes, caloriesBurned }) {
        this.id = null; // DB에 저장되면 설정됨
        this.userId = userId;
        this.exerciseId = exerciseId;
        this.reps = reps; // 반복 횟수
        this.sets = sets; // 세트 수
        this.timeExecuted = timeExecuted; // 운동 수행 시각
        this.durationMinutes = durationMinutes; // 운동 지속 시간 (분)
        this.caloriesBurned = caloriesBurned; // 소모 칼로리
    }

    /**
     * 
     * @returns  {Promise<ExerciseLog>} 저장된 ExerciseLog 객체 반환
     * 
     */
    async save() {
        const data = {
            userId: this.userId,
            exerciseId: this.exerciseId,
            reps: this.reps,
            sets: this.sets,
            timeExecuted: this.timeExecuted,
            durationMinutes: this.durationMinutes,
            caloriesBurned: this.caloriesBurned
        };

        try {
            if (this.id) {
                // ID가 있으면 UPDATE
                const result = await db.update('exercise_logs', data, { id: this.id });
                if (result.affectedRows === 0) {
                    // 업데이트할 대상이 없음 (존재하지 않는 ID)
                    throw new NotFoundError('ExerciseLog not found during update');
                }
            } else {
                // ID가 없으면 INSERT
                const result = await db.create('exercise_logs', data);
                this.id = result.insertId;
            }
            return this;

        } catch (error) {
            // DB 에러가 "중복 키" 에러일 경우, 애플리케이션 에러로 변환
            if (error.code === 'ER_DUP_ENTRY') {
                throw new DuplicateEntryError('This exercise log entry already exists.');
            }
            // 그 외 DB 에러는 그대로 상위로 전파
            throw error;
        }
    }


    static async getById(id) {
        const rows = await db.read('exercise_logs', { id: id });
        if (rows.length === 0) {
            throw new NotFoundError('ExerciseLog not found');
        }
        return new ExerciseLog(rows[0]);

    }

    static async updateById(id, updateData) {
        const exerciseLog = await this.getById(id);
        exerciseLog.userId = updateData.userId || exerciseLog.userId;
        exerciseLog.exerciseId = updateData.exerciseId || exerciseLog.exerciseId;
        exerciseLog.reps = updateData.reps || exerciseLog.reps;
        exerciseLog.sets = updateData.sets || exerciseLog.sets;
        exerciseLog.timeExecuted = updateData.timeExecuted || exerciseLog.timeExecuted;
        exerciseLog.durationMinutes = updateData.durationMinutes || exerciseLog.durationMinutes;
        exerciseLog.caloriesBurned = updateData.caloriesBurned || exerciseLog.caloriesBurned;
        return await exerciseLog.save();
    }


    static async deleteById(id) {
        try {
            const result = await db.delete('exercise_logs', { id: id });
            if (result.affectedRows === 0) {
                throw new NotFoundError('ExerciseLog not found during deletion');
            }
        } catch (error) {
            console.error('Error deleting exercise log by ID from DB :', error);
            throw error;
        }
    }

    static async getAllByUserId(userId) {
        const rows = await db.read('exercise_logs', { userId: userId });
        return rows.map(row => new ExerciseLog(row));
    }

    static async deleteAllByUserId(userId) {
        await db.delete('exercise_logs', { userId: userId });
        return true;
    }

    static async getAllByUserIdAndDate(userId, date) {
        const startOfDay = new Date(date);
        startOfDay.setHours(0, 0, 0, 0);

        const endOfDay = new Date(date);
        endOfDay.setHours(23, 59, 59, 999);

        const query = 'SELECT * FROM exercise_logs WHERE userId = ? AND timeExecuted BETWEEN ? AND ?';
        const rows = await db.query(query, [userId, startOfDay, endOfDay]);
        if (!rows || rows.length === 0) {
            return [];
        }
        return rows.map(row => new ExerciseLog(row));
    }

    static async getAllByUserIdAndDateRange(userId, startDate, endDate) {
        const start = new Date(startDate);
        start.setHours(0, 0, 0, 0);

        const end = new Date(endDate);
        end.setHours(23, 59, 59, 999);

        const query = 'SELECT * FROM exercise_logs WHERE userId = ? AND timeExecuted BETWEEN ? AND ?';
        const rows = await db.query(query, [userId, start, end]);
        if (!rows || rows.length === 0) {
            return [];
        }
        return rows.map(row => new ExerciseLog(row));
    }

    static async calculateTotalCaloriesBurned(userId, startDate, endDate) {
        const start = new Date(startDate);
        start.setHours(0, 0, 0, 0);

        const end = new Date(endDate);
        end.setHours(23, 59, 59, 999);

        const query = 'SELECT SUM(caloriesBurned) AS totalCalories FROM exercise_logs WHERE userId = ? AND timeExecuted BETWEEN ? AND ?';
        const rows = await db.query(query, [userId, start, end]);
        if (!rows || rows.length === 0 || rows[0].totalCalories === null) {
            return 0;
        }
        return rows[0].totalCalories;
    }

    static async calculateTotalTirednessOfUsedMuscles(userId, startDate, endDate, muscles) {
        if (!muscles || muscles.length === 0) {
            return {};
        }

        const start = new Date(startDate);
        start.setHours(0, 0, 0, 0);

        const end = new Date(endDate);
        end.setHours(23, 59, 59, 999);

        const query = `
            SELECT 
                muscle,
                SUM(tiredness) AS totalTiredness
            FROM (
                SELECT mainMuscle AS muscle, 2 AS tiredness
                FROM exercise_logs el
                JOIN exercises e ON el.exerciseId = e.id
                WHERE el.userId = ? AND el.timeExecuted BETWEEN ? AND ?
                
                UNION ALL
                
                SELECT subMuscle AS muscle, 1 AS tiredness
                FROM exercise_logs el
                JOIN exercises e ON el.exerciseId = e.id
                WHERE el.userId = ? AND el.timeExecuted BETWEEN ? AND ?
            ) AS muscle_tiredness
            WHERE muscle IN (?)
            GROUP BY muscle;
        `;

        const params = [userId, start, end, userId, start, end, muscles];
        const rows = await db.query(query, params);

        const muscleWeights = {};
        for (const muscle of muscles) {
            muscleWeights[muscle] = 0;
        }

        for (const row of rows) {
            muscleWeights[row.muscle] = row.totalTiredness;
        }

        return muscleWeights;
    }
}
