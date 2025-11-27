import { JwtService } from '../services/Auth/JwtService.js';
import { OAuthVerifyService } from '../services/Auth/OAuthVerifyService.js';
import { UserService } from '../services/User/UserService.js';

import { GoogleOAuthError, AppleOAuthError, InternalServerError, NotFoundError, ValidationError }
    from '../utils/errors.js';

import { AuthService } from '../services/Auth/AuthService.js';

export class AuthController {
    static async login(req, res) {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ message: 'Email and password are required' });
        }

        // 이메일로 사용자 조회
        const user = await UserService.getUserByEmail(email);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // 비밀번호 검증
        const isPasswordValid = await UserService.comparePassword(password, user.password_hash);
        if (!isPasswordValid) {
            return res.status(401).json({ message: 'Invalid password' });
        }

        const userId = user.id;

        // 정상 토큰 생성
        const tokens = await JwtService.generateTokens(userId);

        return res.status(200).json({ token: tokens });

    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: error.message || 'Internal server error' });
    }
}

    static async logout(req, res) {
        const refreshToken = req.cookies.refreshToken;
        await AuthService.logout(refreshToken);
        res.clearCookie('refreshToken');
        return res.status(200).json({ message: 'Logged out successfully' });

    }

    static async registerUser(req, res) {
    	try {
        	const { email, password, name } = req.body;

        	if (!email || !password) {
            		return res.status(400).json({ message: 'Email and password are required' });
        	}

        	// 이메일 중복 체크 (await 필수)
        	const existingUser = await UserService.getUserByEmail(email).catch(() => null);
        	if (existingUser) {
            		return res.status(400).json({ message: 'Email already in use' });
        	}

        	// 사용자 생성 (await 필수)
        	const newUser = await UserService.registerUser(email, password, name);

        	return res.status(201).json({
            		message: 'User registered successfully',
            		user: newUser,
        	});

    	} catch (error) {
        	console.error(error);
        	return res.status(500).json({ message: 'Internal server error' });
    	}
}



    static async refreshToken(req, res) {
        const oldRefreshToken = req.cookies.refreshToken;
        AuthService.refreshTokens(oldRefreshToken).then(({ accessToken, refreshToken }) => {
            res.cookie('refreshToken', refreshToken, {
                httpOnly: true,
                secure: process.env.NODE_ENV === 'production',
                sameSite: 'Strict',
            });
            return res.status(200).json({ accessToken });
        }).catch((error) => {
            console.error('Error refreshing tokens:', error);
            return res.status(401).json({ message: 'Invalid refresh token' });
        });
    }

}
