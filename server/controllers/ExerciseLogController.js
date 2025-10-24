import { ExerciseLog } from "../models/ExerciseLog";

export class ExerciseLogController {

    static async getExerciseLog(req, res) {
        try {
            const exerciseLog = await ExerciseLog.getById(req.params.id);
            if (exerciseLog) {
                res.status(200).json(exerciseLog);
            } else {
                res.status(404).json({ error: 'Exercise log not found' });
            }
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }

    static async getAllUserExerciseLogs(req, res) {
        try {
            const exerciseLogs = await ExerciseLog.getAllByUserId(req.params.uid);
            if (exerciseLogs) {
                res.status(200).json(exerciseLogs);
            } else {
                res.status(404).json({ error: 'Exercise logs not found' });
            }
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }

    static async getAllUserExerciseLogsByDate(req, res) {
        try {
            const exerciseLogs = await ExerciseLog.getAllByUserIdAndDate(req.params.uid, req.params.date);
            if (exerciseLogs) {
                res.status(200).json(exerciseLogs);
            } else {
                res.status(404).json({ error: 'Exercise logs not found for the specified date' });
            }
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }

    static async getAllUserExerciseLogsByDateRange(req, res) {
        try {
            const exerciseLogs = await ExerciseLog.getAllByUserIdAndDateRange(req.params.uid, req.params.startDate, req.params.endDate);
            if (exerciseLogs) {
                res.status(200).json(exerciseLogs);
            } else {
                res.status(404).json({ error: 'Exercise logs not found for the specified date range' });
            }
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }



    static async addExerciseLog(req, res) {
        try {
            const newExerciseLog = new ExerciseLog({
                userId: req.body.userId,
                exerciseId: req.body.exerciseId,
                reps: req.body.reps,
                sets: req.body.sets,
                dateExecuted: req.body.dateExecuted,
                durationMinutes: req.body.durationMinutes,
                caloriesBurned: req.body.caloriesBurned
            });
            const savedExerciseLog = await newExerciseLog.save();
            res.status(201).json(savedExerciseLog);
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }

    static async deleteExerciseLog(req, res) {
        try {
            const exerciseLog = await ExerciseLog.getById(req.params.id);
            if (exerciseLog) {
                await ExerciseLog.deleteById(req.params.id);
                res.sendStatus(204);
            } else {
                res.status(404).json({ error: 'Exercise log not found' });
            }
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }

    static async deleteUserExerciseLogs(req, res) {
        try {
            await ExerciseLog.deleteAllByUserId(req.params.userid);
            res.sendStatus(204);
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }




    static async updateExerciseLog(req, res) {
        try {
            const exerciseLog = await ExerciseLog.getById(req.params.id);
            if (exerciseLog) {
                exerciseLog.exerciseId = req.body.exerciseId || exerciseLog.exerciseId;
                exerciseLog.reps = req.body.reps || exerciseLog.reps;
                exerciseLog.sets = req.body.sets || exerciseLog.sets;
                exerciseLog.dateExecuted = req.body.dateExecuted || exerciseLog.dateExecuted;
                exerciseLog.durationMinutes = req.body.durationMinutes || exerciseLog.durationMinutes;
                exerciseLog.caloriesBurned = req.body.caloriesBurned || exerciseLog.caloriesBurned;
                const updatedExerciseLog = await exerciseLog.save();
                res.status(200).json(updatedExerciseLog);
            } else {
                res.status(404).json({ error: 'Exercise log not found' });
            }
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }
}