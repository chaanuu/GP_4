import Redis from 'ioredis';

let cacheClient;
let sessionClient;

/**
 * Redis 관리 클래스.
 * 일반 캐시용과 세션 관리용으로 클라이언트를 분리하여 관리합니다.
 * 각 클라이언트는 싱글톤 패턴을 사용하여 애플리케이션 전역에서 하나의 인스턴스를 공유합니다.
 */
export class RedisClient {
    /**
     * RedisClient 클래스의 생성자.
     * 직접적인 인스턴스화를 방지합니다.
     */
    constructor() { }

    /**
     * 일반 캐시용 Redis 클라이언트 인스턴스를 반환합니다.
     * 인스턴스가 없으면 설정 객체를 사용하여 새로 생성합니다.
     * @param {object} [config] - Redis 연결 설정 객체. 최초 연결 시에만 필요합니다.
     * @returns {Redis} 캐시용 Redis 클라이언트 인스턴스.
     */
    static getCacheClient(config) {
        if (!cacheClient) {
            if (!config) {
                throw new Error("캐시용 Redis 설정 객체가 필요합니다.");
            }
            // 설정 객체를 기반으로 Redis 클라이언트를 생성합니다.
            cacheClient = new Redis(config);
            cacheClient.on("error", (error) => {
                console.error(`[Redis Cache Client Error] ${error.message}`);
            });
        }
        return cacheClient;
    }

    /**
     * 세션 관리용 Redis 클라이언트 인스턴스를 반환합니다.
     * 인스턴스가 없으면 설정 객체를 사용하여 새로 생성합니다.
     * @param {object} [config] - Redis 연결 설정 객체. 최초 연결 시에만 필요합니다.
     * @returns {Redis} 세션용 Redis 클라이언트 인스턴스.
     */
    static getSessionClient(config) {
        if (!sessionClient) {
            if (!config) {
                throw new Error("세션용 Redis 설정 객체가 필요합니다.");
            }
            // 설정 객체를 기반으로 Redis 클라이언트를 생성합니다.
            sessionClient = new Redis(config);
            sessionClient.on("error", (error) => {
                console.error(`[Redis Session Client Error] ${error.message}`);
            });
        }
        return sessionClient;
    }
}
