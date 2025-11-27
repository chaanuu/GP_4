import { ExerciseLogService } from '../../services/Exercise/ExerciseLogService.js';

function toMySQLDateKST(date) {
  const KST_OFFSET = 9 * 60 * 60 * 1000; // +9시간
  return new Date(date.getTime() + KST_OFFSET)
    .toISOString()
    .slice(0, 19)
    .replace('T', ' ');
}

// 이번 주 월요일 구하기
function getMonday(date) {
  const day = date.getDay();       // 0:일요일, 1:월요일 ...
  const diff = day === 0 ? -6 : 1 - day;
  const monday = new Date(date);
  monday.setDate(date.getDate() + diff);
  monday.setHours(0, 0, 0, 0);
  return monday;
}

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

  static async getMuscleTirednessSummary(req, res) {
    try {
      const userId = req.params.uid;
      const today = new Date();

      // 이번주 월요일
      const monday = getMonday(today);

      // MySQL DATETIME 문자열 변환
      const startStr = toMySQLDateKST(monday);
      const endStr = toMySQLDateKST(new Date());

      console.log("📌 이번 주 범위:", startStr, "→", endStr);

      // 근육 매핑
      const muscleGroups = {
        chest: ['chest'],
        back: ['back', 'rear_delts'],
        shoulder: ['shoulders', 'traps'],
        arm: ['biceps', 'triceps', 'forearms'],
        leg: ['legs', 'glutes', 'hamstrings'],
        core: ['core', 'hip_flexors'],
      };

      const results = [];

      for (const [groupKey, dbMuscleList] of Object.entries(muscleGroups)) {
        let total = 0;

        for (const dbMuscle of dbMuscleList) {
          const value = await ExerciseLogService.getTotalTirednessOfUsedMuscles(
            userId,
            startStr,
            endStr,
            [dbMuscle]   // 단일 값 배열
          );

          // value는 { muscleName: score } 형태
          const muscleValue = Object.values(value)[0] ?? 0;
          total += Number(muscleValue);
        }

        results.push({
          muscle: groupKey,
          label: toKoreanLabel(groupKey),
          tiredness: total,
        });
      }

      res.json({
        userId,
        startDate: startStr,
        endDate: endStr,
        muscles: results,
      });

    } catch (err) {
      console.error('[getMuscleTirednessSummary Error]', err);
      res.status(500).json({ message: 'Failed to get muscle tiredness summary' });
    }
  }

}

// ⭐ 클래스 밖에 두는 것이 정석
function toKoreanLabel(key) {
  const map = {
    chest: '가슴',
    back: '등',
    shoulder: '어깨',
    arm: '팔',
    leg: '하체',
    core: '코어',
  };
  return map[key] || key;
}
