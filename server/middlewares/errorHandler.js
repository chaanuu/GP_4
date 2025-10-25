import { NotFoundError, DuplicateEntryError, ValidationError, UnauthorizedError } from "../utils/errors";

/**
 * Express 중앙 에러 핸들러
 * * 모든 next(error) 호출은 이 미들웨어로 전달됩니다.
 * 이 핸들러는 항상 4개의 인자(err, req, res, next)를 가져야 합니다.
 */
export const centralErrorHandler = (err, req, res, next) => {
    // 1. 서버 콘솔에 에러 로그 기록 (운영 환경에서는 파일/외부 로깅 시스템 사용)
    console.error(err.stack);

    // 2. 커스텀 에러 유형에 따라 응답 분기
    if (err instanceof NotFoundError) {
        return res.status(404).json({
            success: false,
            error: { message: err.message || '리소스를 찾을 수 없습니다.' }
        });
    }

    if (err instanceof DuplicateEntryError) {
        return res.status(409).json({
            success: false,
            error: { message: err.message || '이미 존재하는 데이터입니다.' }
        });
    }

    if (err instanceof ValidationError) {
        return res.status(400).json({
            success: false,
            error: {
                message: err.message || '입력 값에 오류가 있습니다.',
                details: err.errors // Joi 또는 다른 검증 라이브러리의 상세 오류 내용
            }
        });
    }

    if (err instanceof UnauthorizedError) {
        return res.status(401).json({
            success: false,
            error: { message: err.message || '인증되지 않은 사용자입니다.' }
        });
    }

    // 3. 그 외 모든 에러 (500 Internal Server Error) 처리
    //    보안상 프로덕션 환경에서는 상세 에러 메시지를 클라이언트에 노출하지 않습니다.
    const message = process.env.NODE_ENV === 'production'
        ? '서버 내부 오류가 발생했습니다.'
        : err.message || '서버 내부 오류가 발생했습니다.';

    res.status(500).json({
        success: false,
        error: { message }
    });
};