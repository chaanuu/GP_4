import { PythonProcess } from "../utils/PythonProcess";

export class MeasureController {
    static async measureCircumference(req, res) {
        // multer로 업로드된 파일 경로 가져오기
        const orgImagePath = req.files[0].path;
        const dstImagePath = req.files[1].path;

        try {
            // Python 스크립트 실행
            const result = await PythonProcess.runScript('measure_circumference.py', [imagePath]);
            return res.status(200).json({ measurements: result });
        }
        catch (error) {
            console.error('Error measuring circumference:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }

    }
}
