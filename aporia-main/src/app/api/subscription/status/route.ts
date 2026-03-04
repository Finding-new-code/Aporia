import { NextResponse } from 'next/server';
import { getSession } from '@/lib/auth/session';
import { getRazorpay } from '@/lib/razorpay';
import db from '@/lib/db';
import { subscriptions } from '@/lib/db/schema';
import { eq } from 'drizzle-orm';

export const GET = async () => {
  const session = await getSession();
  if (!session) {
    return NextResponse.json({ isPremium: false });
  }

  const [sub] = await db
    .select()
    .from(subscriptions)
    .where(eq(subscriptions.userId, session.userId));

  if (!sub) {
    return NextResponse.json({ isPremium: false, status: null });
  }

  // If not yet active, do a live fetch from Razorpay to catch payments
  // that came in before the webhook fired.
  if (sub.status !== 'active' && sub.razorpaySubscriptionId) {
    try {
      const razorpay = getRazorpay();
      const live = await (razorpay.subscriptions as any).fetch(
        sub.razorpaySubscriptionId,
      );
      if (live && live.status && live.status !== sub.status) {
        const currentPeriodEnd = live.current_end
          ? new Date(live.current_end * 1000)
          : undefined;
        await db
          .update(subscriptions)
          .set({
            status: live.status as any,
            ...(currentPeriodEnd ? { currentPeriodEnd } : {}),
            updatedAt: new Date(),
          })
          .where(eq(subscriptions.razorpaySubscriptionId, sub.razorpaySubscriptionId));
        sub.status = live.status as any;
        if (currentPeriodEnd) sub.currentPeriodEnd = currentPeriodEnd;
      }
    } catch {
      // Razorpay fetch failed — fall back to DB value
    }
  }

  const isPremium =
    sub.status === 'active' &&
    (!sub.currentPeriodEnd || sub.currentPeriodEnd > new Date());

  return NextResponse.json({
    isPremium,
    status: sub.status,
    currentPeriodEnd: sub.currentPeriodEnd ?? null,
  });
};
