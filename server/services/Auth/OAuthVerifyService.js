import { OAuth2Client } from 'google-auth-library';
import appleSignin from 'apple-signin-auth';
import config from '../../config.js';
import { UnauthorizedError, ValidationError } from '../../utils/errors.js';


const oauthConfig = config.oauth;

// .env 파일 등에 환경 변수를 설정해야 합니다.
// 예: GOOGLE_CLIENT_ID=your_google_client_id
const googleClient = new OAuth2Client(config.GOOGLE_CLIENT_ID);

/**
 * Google ID 토큰을 검증하고 사용자 정보를 반환합니다.
 * @param {string} idToken - 클라이언트로부터 받은 Google ID 토큰
 * @returns {Promise<{email: string, name: string, picture: string}>} Google 사용자 정보
 */

export class OAuthVerifyService {
    static async verifyGoogleToken(idToken) {
        const ticket = await googleClient.verifyIdToken({
            idToken,
            audience: oauthConfig.googleClientId,
        });
        const payload = ticket.getPayload();
        if (!payload) {
            throw new UnauthorizedError('유효하지 않은 Google 토큰입니다.');
        }
        return {
            email: payload.email,
            name: payload.name,
            picture: payload.picture,
            sub: payload.sub, // 사용자의 고유 식별자
        };
    };

    /**
     * Apple ID 토큰을 검증하고 사용자 정보를 반환합니다.
     * @param {string} idToken - 클라이언트로부터 받은 Apple ID 토큰
     * @returns {Promise<{sub: string, email: string}>} Apple 사용자 정보
     */
    static async verifyAppleToken(idToken) {
        // .env 파일 등에 환경 변수를 설정해야 합니다.
        // APPLE_CLIENT_ID는 Apple Developer에서 설정한 앱의 Bundle ID입니다.
        const appleClientId = process.env.APPLE_CLIENT_ID;
        if (!appleClientId) {
            throw new ValidationError('APPLE_CLIENT_ID가 설정되지 않았습니다.');
        }

        const payload = await appleSignin.verifyIdToken(idToken, {
            audience: appleClientId,
        });

        if (!payload) {
            throw new UnauthorizedError('유효하지 않은 Apple 토큰입니다.');
        }

        return {
            sub: payload.sub, // 사용자의 고유 식별자
            email: payload.email,
            name: payload.name || 'Apple User', // Apple은 이름을 항상 제공하지 않을 수 있음
        };

    }
}
