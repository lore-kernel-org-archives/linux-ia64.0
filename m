From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 21 Nov 2003 08:19:59 +0000
Subject: speeding up thread-creation
Message-Id: <marc-linux-ia64-106940282522654@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It occurred to me that at present, we're copying lots of state on a
clone2() for absolutely no reason.  Not only that, but the large size
of the "thread_struct" probably also causes poor cache-locality since
the task-structure is effectively split in two, with a large unused
gap in between.  I think it might make sense to move all the large
thread_struct-state (IA-32 registers, pmcs[], pmds[], dbr[], ibr[],
and fph[]) into a separate "thread_lazy" structure and then put that
structure at a place where it doesn't hurt (perhaps above the
thread_info structure).  If I counted right, this state accounts for
2KB so not copying it in copy_process() ought to speed up
thread-creation significantly and avoid stomping needlessly on the L1
d-cache.

Anyone interested in playing with this idea?

	--david
