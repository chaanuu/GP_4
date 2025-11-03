import { ExerciseLogService } from "../../services/Exercise/ExerciseLogService";

export class ExerciseLogController {

    static async createExerciseLog(req, res) {
        const newExerciseLog = await ExerciseLogService.createExerciseLog(req.body);
        res.status(201).json(newExerciseLog);
    }

    static async getExerciseLogById(req, res) {
        const exerciseLog = await ExerciseLogService.getExerciseLogById(req.params.id);
        res.status(200).json(exerciseLog);
    }

    static async updateExerciseLog(req, res) {
        const updatedExerciseLog = await ExerciseLogService.updateExerciseLog(req.params.id, req.body);
        res.status(200).json(updatedExerciseLog);
    }

    static async deleteExerciseLogById(req, res) {
        await ExerciseLogService.deleteExerciseLog(req.params.id);
        res.sendStatus(204);
    }

    static async deleteAllExerciseLogsByUserId(req, res) {
        await ExerciseLogService.deleteAllExerciseLogsByUserId(req.params.userId);
        res.sendStatus(204);
    }

    static async getAllExerciseLogsByUserId(req, res) {
        const exerciseLogs = await ExerciseLogService.getExerciseLogsByUserId(req.params.userId);
        res.status(200).json(exerciseLogs);
    }

    static async getAllExerciseLogsByDate(req, res) {
        const exerciseLogs = await ExerciseLogService.getExerciseLogsByDate(
            req.params.userId,
            req.params.date
        );
        res.status(200).json(exerciseLogs);
    }


    static async getExerciseLogsByDateRange(req, res) {
        const exerciseLogs = await ExerciseLogService.getExerciseLogsByDateRange(
            req.params.userId,
            req.params.startDate,
            req.params.endDate
        );
        res.status(200).json(exerciseLogs);
    }

}