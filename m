From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 08 Aug 2002 05:08:30 +0000
Subject: [Linux-ia64] Re: A comment on the 2.5.29 patch
Message-Id: <marc-linux-ia64-105590701905925@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905924@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905924@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On Thu, 8 Aug 2002 13:38:03 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:
Peter> Hi David,

Peter> I can't see the point of moving the declaration of extern
Peter> irq_desc_t irq_desc [NR_IRQS]; from include/linux/irq.h into
Peter> asm-i386/hw_irq.,

David> The idea is simple: remove irq_desc[] and replace it with an
David> irq_desc() macro, so that platforms have the option to
David> implement the table any way they see fit (e.g., distributed
David> across NUMA nodes).

I see...  but then the change is more pervasive than here

Peter> And my remaining comment is that I'm not sure why the changes
Peter> to the softirq() names were made.  A rose by any name would
Peter> smell as sweet...

David> Specifics please?  There are no just-for-fun renames, but
David> again, it could be a bad merge or something along those lines.

sorry, I meant changes in softirq.c to yhe
softirq_pending(cpu)->local_softirq_pending(). 

diff -Nru a/include/linux/irq_cpustat.h b/include/linux/irq_cpustat.h
--- a/include/linux/irq_cpustat.h	Thu Aug  1 01:08:13 2002
+++ b/include/linux/irq_cpustat.h	Thu Aug  1 01:08:13 2002
@@ -33,5 +33,12 @@
 #define ksoftirqd_task(cpu)	__IRQ_STAT((cpu), __ksoftirqd_task)
   /* arch dependent irq_stat fields */
 #define nmi_count(cpu)		__IRQ_STAT((cpu), __nmi_count)		/* i386, ia64 */
+
+#define local_hardirq_trylock()	hardirq_trylock(smp_processor_id())
+#define local_hardirq_endlock()	hardirq_trylock(smp_processor_id())
+#define local_irq_enter(irq)	irq_enter(smp_processor_id(), (irq))
+#define local_irq_exit(irq)	irq_exit(smp_processor_id(), (irq))
+#define local_softirq_pending()	softirq_pending(smp_processor_id())
+#define local_ksoftirqd_task()	ksoftirqd_task(smp_processor_id())

----


* local_hardirq_{end,try}lock() are not used anywhere (yet) although
they used to be.
* local_irq_{enter,exit}() is not used anywhere I could find.
* In kernel/softirq.c smp_processor_id() is already assigned to a
local variable

@@ -69,7 +72,7 @@
 	local_irq_save(flags);
 	cpu = smp_processor_id();
 
-	pending = softirq_pending(cpu);
+	pending = local_softirq_pending();
 
 	if (pending) {
 		struct softirq_action *h;

etc.

There's another definition of local_softirq_pending() at
./include/asm-ia64/hardirq.h:24:#define local_softirq_pending() \
         (local_cpu_data->softirq_pending)

likewise for local_ksoftirqd_task().

There's a chance that the vesion in hardirq.h could be more efficient,
but it won't necessarily work on other architectures.

Anyway, I *know* that the patch is WIP -- that's why I thought it was
worth giving some feedback early (before the kernel has moved on
another 10 versions, and the patch is no longer relevant)

--
Dr Peter Chubb				    peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories, all almost the same.


