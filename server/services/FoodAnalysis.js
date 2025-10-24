import { Food } from '../models/Food.js'
import { PythonProcess } from '../utils/PythonProcess.js';

export class FoodAnalysis {

    // TODO : 인자 수정 필요
    static newFood(userId, name, kcal, carb, protein, fat) {
        const food = new Food(userId, name, kcal, carb, protein, fat);
        return food.save();
    }

    // TODO : OCR 이 아닌 실제 음식 인식 모델로 교체 필요
    static getOCR(foodImg) {
        return new Promise(async (resolve, reject) => {
            try {
                const ocrResult = await PythonProcess.executePython('ocr.py', [foodImg]);
                resolve(ocrResult);
            } catch (error) {
                reject(error);
            }
        });
    };



}