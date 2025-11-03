import { PythonProcess } from '../../utils/PythonProcess.js';


export class FoodAnalysisService {

    static async analyzeFoodImage(food) {
        const analysisResult = await PythonProcess.executePython('food_recog_kaggle.py', [food.imgUrl]);
        return analysisResult;
    }

}