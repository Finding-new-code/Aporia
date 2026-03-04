import { SignJWT, jwtVerify } from 'jose';

const getSecret = () =>
  new TextEncoder().encode(process.env.AUTH_SECRET!);

export interface JWTPayload {
  userId: string;
  email: string;
  jti: string;
}

export async function signToken(
  payload: Omit<JWTPayload, 'jti'>,
  expiresIn: '1d' | '3d' = '1d',
): Promise<{ token: string; jti: string }> {
  const jti = crypto.randomUUID();
  const token = await new SignJWT({ ...payload, jti } as any)
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime(expiresIn)
    .setJti(jti)
    .sign(getSecret());
  return { token, jti };
}

export async function verifyToken(token: string): Promise<JWTPayload | null> {
  try {
    const { payload } = await jwtVerify(token, getSecret());
    return payload as unknown as JWTPayload;
  } catch {
    return null;
  }
}
