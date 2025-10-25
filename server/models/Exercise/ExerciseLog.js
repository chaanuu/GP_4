import { db } from '../../utils/DB.js';

import { DuplicateEntryError, NotFoundError } from '../../utils/errors.js';

export class ExerciseLog {
    constructor({ userId, exerciseId, reps, sets, dateExecuted, durationMinutes, caloriesBurned }) {
        this.id = null; // DB에 저장되면 설정됨
        this.userId = userId;
        this.exerciseId = exerciseId;
        this.reps = reps; // 반복 횟수
        this.sets = sets; // 세트 수
        this.dateExecuted = dateExecuted; // 운동 수행 날짜
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
            dateExecuted: this.dateExecuted,
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
        exerciseLog.dateExecuted = updateData.dateExecuted || exerciseLog.dateExecuted;
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

    static async getAllByUserIdAndDate(userId, dateExecuted) {
        const query = 'SELECT * FROM exercise_logs WHERE userId = ? AND dateExecuted = ?';
        const rows = await db.query(query, [userId, dateExecuted]);
        if (!rows || rows.length === 0) {
            return [];
        }
        return rows.map(row => new ExerciseLog(row));

    }

    static async getAllByUserIdAndDateRange(userId, startDate, endDate) {
        const query = 'SELECT * FROM exercise_logs WHERE userId = ? AND dateExecuted BETWEEN ? AND ?';
        const rows = await db.query(query, [userId, startDate, endDate]);
        if (!rows || rows.length === 0) {
            return [];
        }
        return rows.map(row => new ExerciseLog(row));
    }

    static async calculateTotalCaloriesBurned(userId, startDate, endDate) {
        const query = 'SELECT SUM(caloriesBurned) AS totalCalories FROM exercise_logs WHERE userId = ? AND dateExecuted BETWEEN ? AND ?';
        const rows = await db.query(query, [userId, startDate, endDate]);
        if (!rows || rows.length === 0 || rows[0].totalCalories === null) {
            return 0;
        }
        return rows[0].totalCalories;
    }

    static async calculateTotalTirednessOfUsedMuscles(userId, startDate, endDate, muscles) {
        // Mainmuscle과 Submuscle의 tiredness 합산
        // Log의 Mainmuscle과 Submuscle이 나타나는 빈도의 계산
        // Mainmuscle 은 2 배, Submuscle 은 1 배 가중치 적용
        // 근육 : 최종 가중치 반환

        if (!muscles || muscles.length === 0) {
            return {};
        }

        const query = `
            SELECT 
                muscle,
                SUM(tiredness) AS totalTiredness
            FROM (
                SELECT mainMuscle AS muscle, 2 AS tiredness
                FROM exercise_logs el
                JOIN exercises e ON el.exerciseId = e.id
                WHERE el.userId = ? AND el.dateExecuted BETWEEN ? AND ?
                
                UNION ALL
                
                SELECT subMuscle AS muscle, 1 AS tiredness
                FROM exercise_logs el
                JOIN exercises e ON el.exerciseId = e.id
                WHERE el.userId = ? AND el.dateExecuted BETWEEN ? AND ?
            ) AS muscle_tiredness
            WHERE muscle IN (?)
            GROUP BY muscle;
        `;

        const params = [userId, startDate, endDate, userId, startDate, endDate, muscles];
        const rows = await db.query(query, params);

        const muscleWeights = {};
        // 요청된 모든 근육에 대해 0으로 초기화
        for (const muscle of muscles) {
            muscleWeights[muscle] = 0;
        }

        // DB에서 계산된 값으로 업데이트
        for (const row of rows) {
            muscleWeights[row.muscle] = row.totalTiredness;
        }

        return muscleWeights;
    }
}
