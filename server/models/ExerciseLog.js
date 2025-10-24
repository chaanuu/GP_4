import { db } from '../utils/DB.js';

export class ExerciseLog {
    constructor({ userId, exerciseId, reps, sets, dateExecuted, durationMinutes, caloriesBurned }) {
        this.id = id; // DB에 저장되면 설정됨
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
        try {
            await db.save('exercise_logs', {
                userId: this.userId,
                exerciseId: this.exerciseId,
                reps: this.reps,
                sets: this.sets,
                dateExecuted: this.dateExecuted,
                durationMinutes: this.durationMinutes,
                caloriesBurned: this.caloriesBurned
            }).then((result) => { this.id = result.insertId; });
        } catch (error) {
            console.error('Error saving exercise log on DB :', error);
            throw error;
        }
        return this;
    }


    static async getById(id) {
        try {
            return new ExerciseLog(await db.read('exercise_logs', { id: id }));
        } catch (error) {
            console.error('Error getting exercise log by ID from DB :', error);
            throw error;
        }
    }

    static async getAllByUserId(userId) {
        try {
            const rows = await db.read('exercise_logs', { userId: userId });
            return rows.map(row => new ExerciseLog(row));
        } catch (error) {
            console.error('Error getting exercise logs by user ID from DB :', error);
            throw error;
        }
    }

    static async deleteById(id) {
        try {
            return db.delete('exercise_logs', { id: id });
        } catch (error) {
            console.error('Error deleting exercise log by ID from DB :', error);
            throw error;
        }
    }

    static async deleteAllByUserId(userId) {
        try {
            return db.delete('exercise_logs', { userId: userId });
        } catch (error) {
            console.error('Error deleting exercise logs by user ID from DB :', error);
            throw error;
        }
    }




}
