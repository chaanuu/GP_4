import { AuthService } from "../services/Auth/AuthService";

export class OAuthController {
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