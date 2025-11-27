import { db } from "../../utils/DB.js";

export class WorkoutProgram {
  constructor({ id, userId, title }) {
    this.id = id;
    this.userId = userId;
    this.title = title;
  }

  async save() {
    const sql = `
      INSERT INTO workout_program (userId, title)
      VALUES (?, ?)
    `;
    // mysql2/promise의 query()는 단일 rows만 반환함
    const result = await db.query(sql, [this.userId, this.title]);

    // insertId는 바로 rows.insertId로 접근해야 함
    return result.insertId;
  }

  static async getByUser(userId) {
    const sql = `
      SELECT * FROM workout_program
      WHERE userId = ?
      ORDER BY createdAt DESC
    `;
    const rows = await db.query(sql, [userId]);
    return rows;
  }

  static async getById(id) {
    const sql = `SELECT * FROM workout_program WHERE id = ?`;
    const rows = await db.query(sql, [id]);
    return rows[0];
  }

  static async deleteById(id) {
    const sql = `DELETE FROM workout_program WHERE id = ?`;
    const result = await db.query(sql, [id]);
    return result.affectedRows > 0;
  }
}
