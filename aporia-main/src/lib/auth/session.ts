import { cookies } from 'next/headers';
import { verifyToken, type JWTPayload } from './jwt';
import { sessionExists } from '@/lib/redis';

export async function getSession(): Promise<JWTPayload | null> {
  const cookieStore = await cookies();
  const token = cookieStore.get('auth-token')?.value;
  if (!token) return null;
  const payload = await verifyToken(token);
  if (!payload) return null;
  // Validate session exists in Redis (catches logouts and expired sessions)
  const valid = await sessionExists(payload.jti);
  if (!valid) return null;
  return payload;
}
