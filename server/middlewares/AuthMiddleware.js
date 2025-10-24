import { JwtService } from "../services/JwtService.js";

export const authMiddleware = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            // 401 에러 객체를 생성하여 next로 전달
            const error = new Error('Authorization header missing or malformed');
            error.status = 401; // 에러 핸들러가 참조할 상태 코드
            error.code = 'AUTH_HEADER_MISSING';
            return next(error);
        }

        const token = authHeader.split(' ')[1];

        // JwtService가 에러를 throw하면 catch 블록으로 이동
        const decoded = await JwtService.verifyAccessToken(token);

        req.user = { userId: decoded.userId };
        next(); // 성공 시 다음 미들웨어로

    } catch (error) {
        // JwtService에서 발생한 에러(TokenExpiredError 등)를
        // 중앙 에러 핸들러로 전달
        next(error);
    }
}