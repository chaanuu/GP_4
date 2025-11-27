import { db } from "../../utils/DB.js";

export class WorkoutProgramItem {
  constructor({ programId, exerciseId, sets, reps, weight, sequence }) {
    this.programId = programId;
    this.exerciseId = exerciseId;
    this.sets = sets;
    this.reps = reps;
    this.weight = weight;
    this.sequence = sequence;
  }

  async save() {
    const sql = `
      INSERT INTO workout_program_item (programId, exerciseId, sets, reps, weight, sequence)
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    return db.query(sql, [
      this.programId,
      this.exerciseId,
      this.sets,
      this.reps,
      this.weight,
      this.sequence,
    ]);
  }

  static async getByProgram(programId) {
    const sql = `
      SELECT p.*, e.name AS exerciseName
      FROM workout_program_item p
      JOIN exercise e ON p.exerciseId = e.id
      WHERE programId = ?
      ORDER BY sequence ASC
    `;
    const [rows] = await db.query(sql, [programId]);
    return rows;
  }
}
