import { NextRequest, NextResponse } from 'next/server';
import { compare } from 'bcryptjs';
import { eq } from 'drizzle-orm';
import { z } from 'zod';
import db from '@/lib/db';
import { users } from '@/lib/db/schema';
import { signToken } from '@/lib/auth/jwt';
import { storeSession } from '@/lib/redis';

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
  rememberMe: z.boolean().optional().default(false),
});

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const parsed = schema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: 'Invalid input' }, { status: 400 });
    }

    const { email, password, rememberMe } = parsed.data;

    const [user] = await db
      .select()
      .from(users)
      .where(eq(users.email, email));

    // Use constant-time comparison to avoid timing attacks
    const validPassword =
      user ? await compare(password, user.passwordHash) : false;

    if (!user || !validPassword) {
      return NextResponse.json(
        { error: 'Invalid email or password' },
        { status: 401 },
      );
    }

    if (!user.emailVerified) {
      return NextResponse.json(
        { error: 'Please verify your email before signing in' },
        { status: 403 },
      );
    }

    const expiresIn = rememberMe ? '3d' : '1d';
    const { token, jti } = await signToken({ userId: user.id, email: user.email }, expiresIn);
    await storeSession(jti, user.id, rememberMe);

    const response = NextResponse.json({
      message: 'Signed in successfully',
      user: { name: user.name, email: user.email },
    });

    const cookieMaxAge = rememberMe ? 3 * 24 * 60 * 60 : 1 * 24 * 60 * 60;
    response.cookies.set('auth-token', token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge: cookieMaxAge,
      path: '/',
    });

    return response;
  } catch (err) {
    console.error('[login]', err);
    return NextResponse.json(
      { error: 'Something went wrong. Please try again.' },
      { status: 500 },
    );
  }
}
