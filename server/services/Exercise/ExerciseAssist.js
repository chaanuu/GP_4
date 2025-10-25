import { PythonProcess } from '../../utils/PythonProcess.js';

export class ExerciseAssist {



    static getYolo(img) {
        // PythonProcess를 이용해 YOLO 모델을 호출하는 로직 작성
        return new Promise(async (resolve, reject) => {
            try {
                const yoloResult = await PythonProcess.executePython('yolo.py', [img]);
                resolve(yoloResult);
            } catch (error) {
                reject(error);
            }
        });
    }

    static getExerciseRecommendations(userId, physiqueId) {
        // DB에서 userId와 physiqueId에 맞는 운동 추천을 조회하는 로직 작성
    }

    static addExerciseRecommendation(userId, physiqueId, exerciseData) {
        // DB에 새로운 운동 추천을 추가하는 로직 작성
    }

    static updateExerciseRecommendation(recommendationId, updatedData) {
        // DB에서 recommendationId에 맞는 운동 추천을 업데이트하는 로직 작성
    }

    static deleteExerciseRecommendation(recommendationId) {
        // DB에서 recommendationId에 맞는 운동 추천을 삭제하는 로직 작성
    }


}
