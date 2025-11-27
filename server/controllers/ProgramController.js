import { ProgramService } from "../services/ProgramService.js";

export class ProgramController {
  static async createProgram(req, res) {
    try {
      const programId = await ProgramService.createProgram(req.body);
      res.status(201).json({ programId });
    } catch (err) {
      console.error("Program Create Error", err);
      res.status(500).json({ message: "Failed to create program" });
    }
  }

  static async getProgramList(req, res) {
    try {
      const { uid } = req.params;
      const list = await ProgramService.getProgramList(uid);
      res.json(list);
    } catch (err) {
      res.status(500).json({ message: "Failed to load program list" });
    }
  }

  static async getProgramDetail(req, res) {
    try {
      const { pid } = req.params;
      const data = await ProgramService.getProgramDetail(pid);
      res.json(data);
    } catch (err) {
      res.status(500).json({ message: "Failed to load program detail" });
    }
  }
  static async deleteProgram(req, res) {
    const deleted = await ProgramService.deleteProgram(req.params.programId);

    if (deleted) {
      return res.sendStatus(204); // No Content
    } else {
      return res.status(404).json({ message: "Program not found" });
    }
  }

}
