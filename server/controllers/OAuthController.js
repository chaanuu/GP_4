import { AuthService } from '../services/Auth/AuthService.js';
import { ValidationError } from '../utils/errors.js'

export class OAuthController {
    static async googleLogin(req, res) {
        const { idToken } = req.body;
        const tokens = await AuthService.googleLogin(idToken);

        return res.status(200).json({
            message: "Google Login successful",
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
            userId: tokens.userId
        });
    }

    static async googleCallback(req, res) {
        const { code } = req.body;
        if (!code) {
            throw new ValidationError('Authorization code is required');
        }

        const jwtTokens = await AuthService.googleCallback(code);

        return res.status(200).json({ message: "Google Login successful", jwtTokens });
    }



    static async appleLogin(req, res) {
        const { idToken } = req.body;
        const newTokens = await AuthService.appleLogin(idToken);
        return res.status(200).json({ message: "Apple Login successful", newTokens });
    }

}
