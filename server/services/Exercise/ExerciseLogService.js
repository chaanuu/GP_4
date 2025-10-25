import { ExerciseLog } from '../../models/Exercise/ExerciseLog.js';

import { NotFoundError } from '../../utils/errors.js';

export class ExerciseLogService {

    static async createExerciseLog({
        userId,
        exerciseId,
        reps,
        sets,
        dateExecuted,
        durationMinutes,
        caloriesBurned
    }) {
        const exerciseLog = new ExerciseLog(data);
        return await exerciseLog.save();
    }

    static async getExerciseLogById(id) {
        const exerciseLog = await ExerciseLog.getById(id);
        if (!exerciseLog) {
            throw new NotFoundError('ExerciseLog not found');
        }
        return exerciseLog;
    }


    static async updateExerciseLog(id, data) {
        const exerciseLog = await this.getExerciseLogById(id);

        exerciseLog.reps = data.reps || exerciseLog.reps;
        exerciseLog.sets = data.sets || exerciseLog.sets;
        exerciseLog.dateExecuted = data.dateExecuted || exerciseLog.dateExecuted;
        exerciseLog.durationMinutes = data.durationMinutes || exerciseLog.durationMinutes;
        exerciseLog.caloriesBurned = data.caloriesBurned || exerciseLog.caloriesBurned;

        return await exerciseLog.save();
    }
    static async deleteExerciseLog(id) {
        const exerciseLog = await this.getExerciseLogById(id);
        return await exerciseLog.delete();
    }

    static async getAllExerciseLogs() {
        return await ExerciseLog.getAll();
    }

    static async getExerciseLogsByUserId(userId) {
        return await ExerciseLog.getAllByUserId(userId);
    }

    static async deleteAllExerciseLogsByUserId(userId) {
        return await ExerciseLog.deleteAllByUserId(userId);
    }

    static async getExerciseLogsByDateRange(userId, startDate, endDate) {
        return await ExerciseLog.getByDateRange(userId, startDate, endDate);
    }

    static async getTotalCaloriesBurned(userId, startDate, endDate) {
        return await ExerciseLog.calculateTotalCaloriesBurned(userId, startDate, endDate);
    }

    static async getTotalTirednessOfUsedMuscles(userId, startDate, endDate, muscle) {
        return await ExerciseLog.calculateTotalTirednessOfUsedMuscles(userId, startDate, endDate, muscle);
    }



}