import { UserActivityLogService } from "../services/UserActivityLogService";

export class UserActivityLogController {
    static async createUserActivityLog(req, res) {
        const newLog = await UserActivityLogService.createUserActivityLog(req.body);
        res.status(201).json(newLog);
    }

    static async getUserActivityLogById(req, res) {
        const log = await UserActivityLogService.getById(req.params.id);
        res.status(200).json(log);
    }

    static async updateUserActivityLog(req, res) {
        const updatedLog = await UserActivityLogService.updateUserActivityLog(req.params.id, req.body);
        res.status(200).json(updatedLog);
    }

    static async deleteUserActivityLog(req, res) {
        await UserActivityLogService.deleteUserActivityLog(req.params.id);
        res.sendStatus(204);
    }

    static async getAllUserActivityLogsByUserId(req, res) {
        const logs = await UserActivityLogService.getAllUserActivityLogsByUserId(req.params.userId);
        res.status(200).json(logs);
    }

    static async getUserActivityLogsByDateRange(req, res) {
        const logs = await UserActivityLogService.getUserActivityLogsByDateRange(
            req.params.userId,
            req.params.startDate,
            req.params.endDate
        );
        res.status(200).json(logs);
    }
}
