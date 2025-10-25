import { UserActivityLog } from '../../models/User/UserActivityLog.js';

import { NotFoundError } from '../../utils/errors.js';

export class UserActivityLogService {
    static async createUserActivityLog(data) {
        const userActivityLog = new UserActivityLog(data.userId, data.activityType, data.activityDetails, data.dateLogged);
        return await userActivityLog.save();
    }

    static async getById(id) {
        const userActivityLog = await UserActivityLog.getById(id);
        if (!userActivityLog) {
            throw new NotFoundError('UserActivityLog not found');
        }
        return userActivityLog;
    }

    static async updateUserActivityLog(id, data) {
        const userActivityLog = await this.getById(id);

        userActivityLog.activityType = data.activityType || userActivityLog.activityType;
        userActivityLog.activityDetails = data.activityDetails || userActivityLog.activityDetails;
        userActivityLog.dateLogged = data.dateLogged || userActivityLog.dateLogged;

        return await userActivityLog.save();
    }

    static async deleteUserActivityLog(id) {
        const userActivityLog = await this.getById(id);
        return await userActivityLog.delete();
    }

    static async getAllUserActivityLogsByUserId(userId) {
        return await UserActivityLog.getAllByUserId(userId);
    }

    static async getUserActivityLogsByDateRange(userId, startDate, endDate) {
        return await UserActivityLog.getAllByDateRange(userId, startDate, endDate);
    }

}
