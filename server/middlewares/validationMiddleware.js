
// middlewares/validationMiddleware.js
import { BadRequestError } from "../utils/errors.js";

export const validationMiddleware = (req, res, next) => {
    const errors = [];

    // 예시: 필수 필드 검증
    if (!req.body.username) {
        errors.push({ field: 'username', message: 'Username is required' });
    }
    if (!req.body.password) {
        errors.push({ field: 'password', message: 'Password is required' });
    }

    if (errors.length > 0) {
        const error = new BadRequestError('Validation failed');
        error.status = 400; // 에러 핸들러가 참조할 상태 코드
        error.code = 'VALIDATION_ERROR';
        error.details = errors; // 추가적인 에러 정보 포함
        return next(error);
    }

    next(); // 검증 통과 시 다음 미들웨어로
}
