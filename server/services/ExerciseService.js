import { Exercise } from '../models/Exercise.js';

import { NotFoundError } from '../utils/errors.js';

export class ExerciseService {
    static async createExercise(data) {
        const exercise = new Exercise(data.name, data.duration, data.caloriesBurned);
        return await exercise.save();
    }

    static async getExerciseById(id) {
        const exercise = await Exercise.getById(id);
        if (!exercise) {
            throw new NotFoundError('Exercise not found');
        }
        return exercise;
    }

    static async getExerciseByCode(code) {
        const exercise = await Exercise.getByCode(code);
        if (!exercise) {
            throw new NotFoundError('Exercise not found by code');
        }
        return exercise;
    }


    static async updateExercise(id, data) {
        const exercise = await this.getExerciseById(id);

        exercise.name = data.name || exercise.name;
        exercise.mets = data.mets || exercise.mets;
        exercise.code = data.code || exercise.code;
        exercise.mainMuscle = data.mainMuscle || exercise.mainMuscle;
        exercise.subMuscle = data.subMuscle || exercise.subMuscle;
        exercise.dateExecuted = data.dateExecuted || exercise.dateExecuted;

        return await exercise.save();
    }

    static async deleteExerciseById(id) {
        const exercise = await this.getExerciseById(id);
        return await exercise.delete();
    }

    static async deleteExerciseByCode(code) {
        const exercise = await this.getExerciseByCode(code);
        return await exercise.delete();
    }

    static async getAllExercisesByUserId(userId) {
        return await Exercise.getAllByUserId(userId);
    }

    static async getAllStaticExercises() {
        return await Exercise.getAllStatic();
    }

    static async deleteAllExercisesByUserId(userId) {
        return await Exercise.deleteAllByUserId(userId);
    }









}