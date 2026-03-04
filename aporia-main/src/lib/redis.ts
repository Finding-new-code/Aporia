import Redis from 'ioredis';

const SESSION_TTL_1D = 1 * 24 * 60 * 60;  // 1 day
const SESSION_TTL_3D = 3 * 24 * 60 * 60;  // 3 days

const getRedis = (): Redis => {
  if ((global as any)._redis) return (global as any)._redis;
  const client = new Redis(process.env.REDIS_URL!, {
    maxRetriesPerRequest: 3,
    lazyConnect: false,
  });
  client.on('error', (err) => console.error('[Redis]', err));
  (global as any)._redis = client;
  return client;
};

export const redis = getRedis();

const key = (jti: string) => `session:${jti}`;

export async function storeSession(jti: string, userId: string, rememberMe: boolean): Promise<void> {
  const ttl = rememberMe ? SESSION_TTL_3D : SESSION_TTL_1D;
  await redis.set(key(jti), userId, 'EX', ttl);
}

export async function sessionExists(jti: string): Promise<boolean> {
  const val = await redis.exists(key(jti));
  return val === 1;
}

export async function deleteSession(jti: string): Promise<void> {
  await redis.del(key(jti));
}
