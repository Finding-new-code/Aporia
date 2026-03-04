import db from '@/lib/db';
import { chats } from '@/lib/db/schema';
import { eq } from 'drizzle-orm';
import { getSession } from '@/lib/auth/session';

export const GET = async (req: Request) => {
  try {
    const session = await getSession();
    if (!session) {
      return Response.json({ message: 'Unauthorized' }, { status: 401 });
    }

    let userChats = await db.query.chats.findMany({
      where: eq(chats.userId, session.userId),
    });
    userChats = userChats.reverse();
    return Response.json({ chats: userChats }, { status: 200 });
  } catch (err) {
    console.error('Error in getting chats: ', err);
    return Response.json(
      { message: 'An error has occurred.' },
      { status: 500 },
    );
  }
};
