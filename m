From: Martin Hicks <mort@sgi.com>
Date: Wed, 11 Feb 2004 21:19:46 +0000
Subject: Re: [PATCH] turn off irqdebug by default on Altix
Message-Id: <20040211211946.GM12142@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="XRI2XbIfl/05pQwm"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040204152841.GB3387@localhost>
In-Reply-To: <20040204152841.GB3387@localhost>
To: linux-ia64@vger.kernel.org


--XRI2XbIfl/05pQwm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline



On Tue, Feb 10, 2004 at 02:43:14PM -0800, David Mosberger wrote:
> >>>>> On Thu, 5 Feb 2004 13:37:28 -0500, Martin Hicks <mort@sgi.com> said:
> 
>   Martin> How about this patch?  I just tested it on a 512p machine
>   Martin> and it booted.
> 
> I suspect a better fix would be to change do_IRQ() such that it
> doesn't call note_interrupt() for IRQ_PER_CPU interrupts.  For per-CPU
> interrupts, the note_interrupt() code is racy and rather bogus anyhow.

Okay....Here it is.

I didn't test it on a big machine yet, but it certainly seems like it
takes care of the problem.

mh

-- 
Martin Hicks || mort@bork.org || PGP/GnuPG: 0x4C7F2BEE

--XRI2XbIfl/05pQwm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="no-note-interrupt.patch"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1609  -> 1.1610 
#	arch/ia64/kernel/irq.c	1.34    -> 1.35   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/02/11	mort@green.i.bork.org	1.1610
# Don't call note_interrupt() for per-cpu interrupts.
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/irq.c b/arch/ia64/kernel/irq.c
--- a/arch/ia64/kernel/irq.c	Wed Feb 11 16:17:22 2004
+++ b/arch/ia64/kernel/irq.c	Wed Feb 11 16:17:22 2004
@@ -465,8 +465,6 @@
 		desc->handler->ack(irq);
 		action_ret = handle_IRQ_event(irq, regs, desc->action);
 		desc->handler->end(irq);
-		if (!noirqdebug)
-			note_interrupt(irq, desc, action_ret);
 	} else {
 		spin_lock(&desc->lock);
 		desc->handler->ack(irq);

--XRI2XbIfl/05pQwm--
