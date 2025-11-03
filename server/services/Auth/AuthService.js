import { OAuthVerifyService } from './OAuthVerifyService.js';
import { JwtService } from './JwtService.js';
import config from '../../config.js';
import { UserService } from '../User/UserService.js';
import { NotFoundError, UnauthorizedError, ValidationError } from '../../utils/errors.js';


const jwtConfig = config.jwt;

export class AuthService {
    static async localLogin(email, password) {
        // 로컬 로그인 로직 구현 (예: UserService 사용)
        if (!email || !password) {
            throw new ValidationError('Email and password are required');
        }
        const user = await UserService.getUserByEmail(email);
        if (!user) {
            throw new NotFoundError('User with Email not found');
        }
        const isPasswordValid = await UserService.comparePassword(password, user.password_hash);
        if (!isPasswordValid) {
            throw new UnauthorizedError('Invalid password');
        }
        if (user.provider != 'local') {
            throw new UnauthorizedError(`${user.provider} 소셜 로그인을 사용해주세요.`);
        }

        return JwtService.generateTokens({ userId: user.id });
    }


    /**
     *  Google 소셜 로그인
     *  첫 로그인 시 가입 처리
     * @param {string} idToken
     * @returns {Promise<{accessToken: string, refreshToken: string}>}
     * 
     */
    static async googleLogin(idToken) {
        const payload = await OAuthVerifyService.verifyGoogleToken(idToken);
        const user = await UserService.getUserByEmail(payload.email).catch((error) => {
            if (error instanceof NotFoundError) {
                return null;
            }
            throw error;
        });

        if (user) {
            // 기존 사용자
            if (user.provider !== 'google') {
                throw new UnauthorizedError(`${user.provider} 소셜 로그인을 사용해주세요.`);
            }
            return JwtService.generateTokens({ userId: user.id });
        }

        // 신규 사용자
        const newUser = await UserService.registerUser(
            payload.email,
            null,
            payload.name,
            'google',
            payload.sub
        );
        return JwtService.generateTokens({ userId: newUser.id });

    }


    /**
     * Apple 소셜 로그인
     * 첫 로그인 시 가입 처리
     * @param {string} idToken
     * @returns {Promise<{accessToken: string, refreshToken: string}>}
     * 
     */
    static async appleLogin(idToken) {
        const payload = await OAuthVerifyService.verifyAppleToken(idToken);
        const user = await UserService.getUserByEmail(payload.email).catch((error) => {
            if (error instanceof NotFoundError) {
                return null;
            }
            throw error;
        });

        if (user) {
            // 기존 사용자
            if (user.provider !== 'apple') {
                throw new UnauthorizedError(`${user.provider} 소셜 로그인을 사용해주세요.`);
            }
            return JwtService.generateTokens({ userId: user.id });
        }

        // 신규 사용자
        const newUser = await UserService.registerUser(
            payload.email,
            null,
            payload.name,
            'apple',
            payload.sub
        );
        return JwtService.generateTokens({ userId: newUser.id });
    }

    static async logout(refreshToken) {
        if (!refreshToken) {
            throw new ValidationError('Refresh token is required');
        }
        await JwtService.revokeRefreshToken(refreshToken);
    }

    static async registerUser(email, password, name) {
        return await UserService.registerUser(email, password, name);
    }

    static async registerOAuthUser(email, name, provider, provider_id) {
        return await UserService.registerUser(email, null, name, provider, provider_id);
    }


}
