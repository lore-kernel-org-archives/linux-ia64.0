From: Erich Focht <focht@ess.nec.de>
Date: Mon, 04 Mar 2002 11:41:40 +0000
Subject: Re: [Linux-ia64] O(1) scheduler K3+ for IA64
Message-Id: <marc-linux-ia64-105590701905213@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905201@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905201@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jesse,

On Fri, 1 Mar 2002, Jesse Barnes wrote:

> Hey Erich, I've been testing out your latest K3+ patch (along with
> yours and Mike's NUMA scheduler changes) and found that it seems less
> stable than the old version that used locking for the tlb flush stuff.
> I think there's a deadlock somewhere in the new code since
> 2.4.17 + kdb + ia64 + Ingo K3 + old K3+: rock solid
> 2.4.17 + kdb + ia64 + Ingo K3 + new K3+: sometimes hangs at boot,

please find attached a fix the should help for the K3+ scheduler. I had
this fixed in the NUMA patch I've sent out...

The NUMA patch can have similar problems, there I needed to eliminate the
idle checks in scan_pools().

Best regards,
Erich

--- 2.4.17-ia64-kdbv2.1-K3+/kernel/sched.c.~1~	Mon Mar  4 11:39:18 2002
+++ 2.4.17-ia64-kdbv2.1-K3+/kernel/sched.c	Mon Mar  4 11:54:01 2002
@@ -1539,7 +1539,8 @@
 
 	for (;;) {
 		if (test_and_clear_bit(smp_processor_id(), &migration_mask))
-			current->cpus_allowed = 1 << smp_processor_id();
+                        printk("migration_task on cpu=%d mask=%lx\n",
+                               cpu(),current->cpus_allowed);
 		if (current->need_resched)
 			schedule();
 		if (!migration_mask)




