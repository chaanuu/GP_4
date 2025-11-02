/**
 * 기본 애플리케이션 에러 클래스
 * 모든 커스텀 에러의 부모 역할을 하며, HTTP 상태 코드를 포함할 수 있습니다.
 */
class AppError extends Error {
    constructor(message, status) {
        // 'Error' 부모 클래스의 생성자 호출
        super(message);

        // 에러 이름을 클래스 이름으로 설정 (catch 블록에서 구분하기 위함)
        this.name = this.constructor.name;

        // HTTP 상태 코드 (기본값 500)
        this.status = status || 500;

        // V8 엔진 스택 트레이스 캡처 (선택 사항이지만 권장됨)
        if (Error.captureStackTrace) {
            Error.captureStackTrace(this, this.constructor);
        }
    }
}

/**
 * 404 Not Found 에러
 * 리소스를 찾을 수 없을 때 (예: getById) 사용합니다.
 */
export class NotFoundError extends AppError {
    constructor(message = 'Resource not found') {
        super(message, 404);
    }
}

/**
 * 409 Conflict 에러
 * 데이터 충돌 시 (예: 중복된 이메일) 사용합니다.
 */
export class DuplicateEntryError extends AppError {
    constructor(message = 'Duplicate entry or conflict') {
        super(message, 409); // 409 Conflict
    }
}

/**
 * 400 Bad Request 에러
 * 사용자 입력값이 유효하지 않을 때 (예: Validation 실패) 사용합니다.
 */
export class ValidationError extends AppError {
    constructor(message = 'Invalid input data') {
        super(message, 400);
    }
}

/**
 * 401 Unauthorized 에러
 * 인증이 필요하거나 실패했을 때 (예: 토큰 만료/무효) 사용합니다.
 */
export class UnauthorizedError extends AppError {
    constructor(message = 'Authentication failed') {
        super(message, 401);
    }
}


/**
 * 
 * 401 Unauthorized 에러
 * Google OAuth 인증 실패 시 사용합니다.
 */
export class GoogleOAuthError extends AppError {
    constructor(message = 'Google authentication failed') {
        super(message, 401);
    }
}


/**
 * 
 * 401 Unauthorized 에러
 * 토큰 만료 시 사용합니다.
 */
export class TokenExpiredError extends AppError {
    constructor(message = 'Token has expired') {
        super(message, 401);
    }
}

/**
 * 
 * 401 Unauthorized 에러
 * 토큰이 유효하지 않을 때 사용합니다.
 */
export class TokenInvalidError extends AppError {
    constructor(message = 'Token is invalid') {
        super(message, 401);
    }
}

/**
 * 403 Forbidden 에러
 * 권한이 없을 때 사용합니다.
 */
export class ForbiddenError extends AppError {
    constructor(message = 'Access forbidden') {
        super(message, 403);
    }
}

/**
 * 500 Internal Server Error
 * 서버 내부 오류가 발생했을 때 사용합니다.
 */
export class InternalServerError extends AppError {
    constructor(message = 'Internal server error') {
        super(message, 500);
    }
}

/**
 * 503 Service Unavailable 에러
 * 외부 서비스 장애 시 사용합니다.
 */
export class ServiceUnavailableError extends AppError {
    constructor(message = 'Service unavailable') {
        super(message, 503);
    }
}
