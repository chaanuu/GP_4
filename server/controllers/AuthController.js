import { JwtService } from '../services/Auth/JwtService.js';
import { OAuthVerifyService } from '../services/Auth/OAuthVerifyService.js';
import { UserService } from '../services/User/UserService.js';

import { GoogleOAuthError, AppleOAuthError, InternalServerError, NotFoundError, ValidationError }
    from '../utils/errors.js';

import { AuthService } from '../services/Auth/AuthService.js';

export class AuthController {
    static async localLogin(req, res) {
        const { email } = req.body;

        // TODO: 실제 검증 로직 추가해서 미들웨어로 분리할 것
        if (!email) {
            return res.status(400).json({ message: 'email is required' });
        }

        const user = await UserService.getUserByEmail(email);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }


        const userId = user.id;

        // JWT 토큰 생성
        const token = JwtService.generateTokens({ userId });

        // 응답으로 토큰 반환
        return res.status(200).json({ token });

    }

    static async logout(req, res) {
        const refreshToken = req.cookies.refreshToken;
        await AuthService.logout(refreshToken);
        res.clearCookie('refreshToken');
        return res.status(200).json({ message: 'Logged out successfully' });

    }

    static registerUser(req, res) {
        const { email, password, name } = req.body;

        // TODO : 미들웨어로 뺄 것
        if (!email || !password) {
            return res.status(400).json({ message: 'Email and password are required' });
        }
        if (UserService.getUserByEmail(email)) {
            return res.status(400).json({ message: 'Email already in use' });
        }


        const newUser = UserService.registerUser(email, password, name);
        return res.status(201).json({ message: 'User registered successfully', user: newUser });
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

    static async logout(req, res) {
        const refreshToken = req.cookies.refreshToken;
        if (!refreshToken) {
            return res.status(400).json({ message: 'Refresh token is required' });
        }

        try {
            await sessionClient.del(refreshToken);
            res.clearCookie('refreshToken');

            return res.status(200).json({ message: 'Logged out successfully' });
        } catch (error) {
            console.error('Error during logout:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }
    }


    static async googleLogin(req, res) {
        const { idToken } = req.body;
        const newTokens = await AuthService.googleLogin(idToken);
        return res.status(200).json({ message: "Google Login successful", newTokens });
    }


    static async appleLogin(req, res) {
        const { idToken } = req.body;
        const newTokens = await AuthService.appleLogin(idToken);
        return res.status(200).json({ message: "Apple Login successful", newTokens });
    }

}