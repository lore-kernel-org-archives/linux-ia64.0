From: Martin Hicks <mort@sgi.com>
Date: Thu, 05 Feb 2004 18:37:28 +0000
Subject: Re: [PATCH] turn off irqdebug by default on Altix
Message-Id: <20040205183728.GC19025@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="OgqxwSJOaUobr8KG"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040204152841.GB3387@localhost>
In-Reply-To: <20040204152841.GB3387@localhost>
To: linux-ia64@vger.kernel.org


--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline



On Wed, Feb 04, 2004 at 01:40:47PM -0600, Jack Steiner wrote:
> On Wed, Feb 04, 2004 at 02:08:05PM -0500, Martin Hicks wrote:
> > 
> > 
> > On Wed, Feb 04, 2004 at 11:04:43AM -0800, Chen, Kenneth W wrote:
> > > This is really confusing with two parameters that do the same thing.
> > > What will happen if someone pass noirqdebug and irqdebug at the same
> > > time?
> > > 
> > > What's wrong with boot time parameter of noirqdebug?
> > 
> > It just means that if you forget to pass this option then your machine
> > never boots.  Well, it will boot.  Eventually.  Jack is a patient man,
> > and he said he never waited long enough for it to boot.
> 
> Actually, I determined that a big system would never boot. Each cpu would have to
> do about 1500usec of work every 1000usec.  (highly dependent on the
> system interconnect).
> 
> Each clock tick, the desc->irq_count is incremented by each cpu. On a big
> system, this creates an incredibly hot cache line. On a big system, it takes
> more than a millisecond to do the update. At that point, another clock
> interrupt is already pending. Forward progress stops.
> 
> Another possible approach might be to special case note_interrupt() to
> skip the update for the timer tick. (I havent actually looked at the code, but
> this should be possible). 

Okay.  This is certainly less messy, and is IA64 specific.

How about this patch?  I just tested it on a 512p machine and it booted.

mh

-- 
Martin Hicks   ||   Silicon Graphics Inc.   ||   mort@sgi.com

--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="no-timer-interrupt-in-note-interrupt.diff"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1543  -> 1.1544 
#	arch/ia64/kernel/irq.c	1.34    -> 1.35   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/02/04	mort@green.i.bork.org	1.1544
# Don't debug the timer interrupt in note_interrupt().  This
# should allow forward progress on large machine with irqdebug
# enabled.
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/irq.c b/arch/ia64/kernel/irq.c
--- a/arch/ia64/kernel/irq.c	Wed Feb  4 15:43:12 2004
+++ b/arch/ia64/kernel/irq.c	Wed Feb  4 15:43:12 2004
@@ -311,6 +311,10 @@
  */
 static void note_interrupt(int irq, irq_desc_t *desc, irqreturn_t action_ret)
 {
+	/* Don't debug the timer interrupt */
+	if (irq == IA64_TIMER_VECTOR)
+		return;
+
 	if (action_ret != IRQ_HANDLED) {
 		desc->irqs_unhandled++;
 		if (action_ret != IRQ_NONE)

--OgqxwSJOaUobr8KG--
