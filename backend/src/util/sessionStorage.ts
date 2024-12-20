import Redis from 'ioredis';

interface ISessionStorage<T> {
    set(key: string, value: T, ttl: number): Promise<void>;
    get(key: string): Promise<T | null>;
    delete(key: string): Promise<void>;
    renewTTL(key: string, ttl: number): Promise<void>;
}

export class SessionStorage<T> implements ISessionStorage<T> {
    private client: Redis;
    private sessionType: string;

    constructor(sessionType: string) {
        this.sessionType = sessionType;
        let redisUrl:string = process.env.REDIS_URL || 'redis://localhost:6379';
        this.client = new Redis(redisUrl);
    }

    async set(key: string, value: T, ttl: number): Promise<void> {
        const data = JSON.stringify(value);
        await this.client.set(`${this.sessionType}:${key}`, data, 'EX', ttl);
    }

    async get(key: string): Promise<T | null> {
        const data = await this.client.get(`${this.sessionType}:${key}`);
        if (!data) {
            return null;
        }
    
        // Parse o JSON e converta datas automaticamente
        const parsedData = JSON.parse(data, (key, value) => {
            if (typeof value === 'string' && /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/.test(value)) {
                return new Date(value);
            }
            return value;
        });
    
        return parsedData;
    }

    async delete(key: string): Promise<void> {
        await this.client.del(`${this.sessionType}:${key}`);
    }

    async renewTTL(key: string, ttl: number): Promise<void> {
        await this.client.expire(`${this.sessionType}:${key}`, ttl);
    }

    async update(key: string, value: T, ttl:number): Promise<void> {
        const currentData = await this.get(key);
        if (!currentData) {
            return
        }
        await this.set(key, value , ttl);
    }
}