import { Exercise } from "../models/Exercise.js";

export class ExerciseController {

    static async getUserExercises(req, res) {
        try {
            const Exercises = await Exercise.getAllByUserId(req.params.uid);
            if (Exercises) {
                res.status(200).json(Exercises);
            } else {
                res.status(404).json({ error: 'Exercises not found' });
            }
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }

    static async addExercise(req, res) {
        try {
            const newExercise = new Exercise(
                req.body.userId,
                req.body.name,
                req.body.kcal,
                req.body.carb,
                req.body.protein,
                req.body.fat
            );
            const savedExercise = await newExercise.save();
            res.status(201).json(savedExercise);
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }

    static async updateExercise(req, res) {
        try {
            const Exercise = await Exercise.getById(req.params.id);
            if (Exercise) {
                Exercise.name = req.body.name || Exercise.name;
                Exercise.kcal = req.body.kcal || Exercise.kcal;
                Exercise.carb = req.body.carb || Exercise.carb;
                Exercise.protein = req.body.protein || Exercise.protein;
                Exercise.fat = req.body.fat || Exercise.fat;
                const updatedExercise = await Exercise.save();
                res.status(200).json(updatedExercise);
            } else {
                res.status(404).json({ error: 'Exercise not found' });
            }
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }
    static async deleteExercise(req, res) {
        try {
            const Exercise = await Exercise.getById(req.params.id);
            if (Exercise) {
                await Exercise.delete();
                res.sendStatus(204);
            } else {
                res.status(404).json({ error: 'Exercise not found' });
            }
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }

    static async readExerciseFromQR(req, res) {
        try {
            const exercise = await Exercise.getByCode(req.params.code);
            if (exercise) {
                res.status(200).json(exercise);
            } else {
                res.status(404).json({ error: 'Exercise not found' });
            }
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }
}