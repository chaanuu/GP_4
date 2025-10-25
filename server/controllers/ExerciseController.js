import { ExerciseService } from '../services/ExerciseService.js';

import { } from '../utils/errors.js';

export class ExerciseController {

    static async getExerciseById(req, res) {
        const exercise = await ExerciseService.getExerciseById(req.params.id);
        res.status(200).json(exercise);
    }

    static async getAllExercisesByUserId(req, res) {
        const exercises = await ExerciseService.getAllExercisesByUserId(req.params.userId);
        res.status(200).json(exercises);
    }

    static async createExercise(req, res) {
        const newExercise = await ExerciseService.createExercise(req.body);
        res.status(201).json(newExercise);
    }

    static async updateExercise(req, res) {
        const updatedExercise = await ExerciseService.updateExercise(req.params.id, req.body);
        res.status(200).json(updatedExercise);
    }

    static async deleteExercise(req, res) {
        await ExerciseService.deleteExercise(req.params.id);
        res.sendStatus(204);
    }

    static async getAllExercisesByUserId(req, res) {
        const exercises = await ExerciseService.getAllExercisesByUserId(req.params.userId);
        res.status(200).json(exercises);
    }

    static async getAllStaticExercises(req, res) {
        const exercises = await ExerciseService.getAllStaticExercises();
        res.status(200).json(exercises);
    }

    static async getExerciseByCode(req, res) {
        const exercise = await ExerciseService.getExerciseByCode(req.params.code);
        res.status(200).json(exercise);
    }
}