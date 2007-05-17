From: Robin Holt <holt@sgi.com>
Date: Thu, 17 May 2007 11:16:52 +0000
Subject: [PATCH] get_wchan on running task sometimes MCAs the machine.
Message-Id: <20070517111651.GA760@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Make ia64's get_wchan safer by not unwinding a running tasks stack.
Stolen from i386's get_wchan.

Signed-off-by: Robin Holt <holt@sgi.com>

---

We have seen one customer machine experience four MCAs in the last
13 days.  All have a similar failure in that the processor is trying to
access some hardware reserved memory.  I believe this is occurring because
the unwind code called from get_wchan references some memory from another
task while it is being changed by that task.  One factor may be the large
number of I/O adapters spread throughout the system with the enormous
number of disks on the back side.  IIRC, we have six dual-port FC HBAs
connecting via multiple paths to more than 6,000 disks.  The machine is
under heavy I/O load.  The customer application seems to fork one task
for each MPI rank (16) and then each of those creates 30+ pthreads.
The parent process then seems to be calling through proc_tgid_stat
... get_wchan, unw_unwind where it references an illegal address.
Of the four failures I have looked at, only one had a value similar to
the illegal address.  The other three appear may have been overwritten.
In all cases, the reference appears to be within a few cache lines of
the end of physical memory.

I am speculating that this is due to get_wchan operating on a running
task.  If I wave my hands enough, I can make this feel like it makes
sense.  That is, until you realize that this most recent failure (the
one with the similar value still in the stack page) was when this
task was unwinding its own stack.  I can see some evidence we _MAY_
have taken an interrupt recently, but I still have not found a way to
explain this failure.

Any suggestions would be greatly appreciated.

All that said, I have put together the following simple patch stolen
directly from i386's get_wchan.  If the task is running, why even try.


Index: linux-tot-20070517/arch/ia64/kernel/process.c
=================================--- linux-tot-20070517.orig/arch/ia64/kernel/process.c	2007-05-17 05:39:54.000000000 -0500
+++ linux-tot-20070517/arch/ia64/kernel/process.c	2007-05-17 05:44:26.820535382 -0500
@@ -763,6 +763,9 @@ get_wchan (struct task_struct *p)
 	unsigned long ip;
 	int count = 0;
 
+	if (!p || p = current || p->state = TASK_RUNNING)
+		return 0;
+
 	/*
 	 * Note: p may not be a blocked task (it could be current or
 	 * another process running on some other CPU.  Rather than
