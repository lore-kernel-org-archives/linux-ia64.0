From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 13 Jan 2005 19:11:08 +0000
Subject: Re: fixing 2.6.10 UP builds
Message-Id: <Pine.LNX.4.58.0501131110120.19097@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050106201427.GA6009@jale>
In-Reply-To: <20050106201427.GA6009@jale>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 13 Jan 2005, Christoph Hellwig wrote:

> On Wed, Jan 12, 2005 at 04:20:43PM -0800, Jesse Barnes wrote:
> > >   CC      drivers/char/mmtimer.o
> > > drivers/char/mmtimer.c: In function `mmtimer_tasklet':
> > > drivers/char/mmtimer.c:502: structure has no member named `write_lock'
> > > make[1]: *** [drivers/char/mmtimer.o] Error 1
> > > make: *** [drivers/char/mmtimer.o] Error 2
> >
> > Looks like we need rwlock_is_write_locked for this one.  Christoph?
>
> Looks like the driver is doing something completely bogus which it should
> stop ASAP.

Here is the fix:

Index: linux-2.6.10/drivers/char/mmtimer.c
=================================--- linux-2.6.10.orig/drivers/char/mmtimer.c	2004-12-24 13:35:20.000000000 -0800
+++ linux-2.6.10/drivers/char/mmtimer.c	2005-01-13 09:46:10.000000000 -0800
@@ -494,17 +494,15 @@ void mmtimer_tasklet(unsigned long data)
 	/* Send signal and deal with periodic signals */
 	spin_lock_irqsave(&t->it_lock, flags);
 	spin_lock(&x->lock);
+
 	/* If timer was deleted between interrupt and here, leave */
 	if (t != x->timer)
 		goto out;
 	t->it_overrun = 0;

-	if (tasklist_lock.write_lock || posix_timer_event(t, 0) != 0) {
-
-		// printk(KERN_WARNING "mmtimer: cannot deliver signal.\n");
-
+	if (posix_timer_event(t, 0) != 0)
 		t->it_overrun++;
-	}
+
 	if(t->it_incr) {
 		/* Periodic timer */
 		if (reschedule_periodic_timer(x)) {
@@ -512,7 +510,7 @@ void mmtimer_tasklet(unsigned long data)
 			x->timer = NULL;
 		}
 	} else {
-		/* Ensure we don't false trigger in mmtimer_interrupt */
+		/* Ensure we do not trigger another tasklet run from mmtimer_interrupt */
 		t->it_timer.expires = 0;
 	}
 	t->it_overrun_last = t->it_overrun;
