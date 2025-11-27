import { WorkoutProgram } from "../models/Program/WorkoutProgram.js";
import { WorkoutProgramItem } from "../models/Program/WorkoutProgramItem.js";

export class ProgramService {
  static async createProgram(data) {
    const program = new WorkoutProgram({
      userId: data.userId,
      title: data.title,
    });

    const programId = await program.save();

    for (let i = 0; i < data.items.length; i++) {
      const item = data.items[i];
      const programItem = new WorkoutProgramItem({
        programId,
        exerciseId: item.exerciseId,
        sets: item.sets,
        reps: item.reps,
        weight: item.weight || 0,
        sequence: i,
      });
      await programItem.save();
    }

    return programId;
  }

  static async getProgramList(userId) {
    return WorkoutProgram.getByUser(userId);
  }

  static async getProgramDetail(programId) {
    const program = await WorkoutProgram.getById(programId);
    const items = await WorkoutProgramItem.getByProgram(programId);

    return { program, items };
  }
  
  static async deleteProgram(programId) {
    return await WorkoutProgram.deleteById(programId);
  }
}
