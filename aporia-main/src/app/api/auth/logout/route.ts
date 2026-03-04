import { NextRequest, NextResponse } from 'next/server';
import { cookies } from 'next/headers';
import { verifyToken } from '@/lib/auth/jwt';
import { deleteSession } from '@/lib/redis';

export async function POST(req: NextRequest) {
  // Invalidate the Redis session so the token can't be reused
  const cookieStore = await cookies();
  const token = cookieStore.get('auth-token')?.value;
  if (token) {
    const payload = await verifyToken(token);
    if (payload?.jti) {
      await deleteSession(payload.jti);
    }
  }

  const response = NextResponse.json({ message: 'Signed out' });
  response.cookies.set('auth-token', '', {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    maxAge: 0,
    path: '/',
  });
  return response;
}
