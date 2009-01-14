From: Mike Travis <travis@sgi.com>
Date: Wed, 14 Jan 2009 23:43:54 +0000
Subject: Re: crash: IP: [<ffffffff80478092>] __bitmap_intersects+0x48/0x73
Message-Id: <496E78BA.5040609@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <496BF6D5.9030403@sgi.com> <20090113130048.GB31147@elte.hu> <496CAF5A.3010304@sgi.com> <496D0F46.2010907@sgi.com> <496D2172.6030608@sgi.com> <20090114165431.GA18826@elte.hu> <20090114165524.GA21742@elte.hu> <20090114175126.GA21078@elte.hu>
In-Reply-To: <20090114175126.GA21078@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Yinghai Lu <yinghai@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tony Luck <tony.luck@intel.com>, IA64 <linux-ia64@vger.kernel.org>, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org, David Howells <dhowells@redhat.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, linux-am33-list@redhat.com, "David S. Miller" <davem@davemloft.net>, SPARC <sparclinux@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

Ingo Molnar wrote:
> also, with latest tip/master the ia64 cross-build still fails:
> 
> /home/mingo/tip/arch/ia64/kernel/irq_ia64.c: In function `ia64_handle_irq':
> /home/mingo/tip/arch/ia64/kernel/irq_ia64.c:498: error: structure has no member named `irqs'
> /home/mingo/tip/arch/ia64/kernel/irq_ia64.c:500: error: structure has no member named `irqs'
> /home/mingo/tip/arch/ia64/kernel/irq_ia64.c: In function `ia64_process_pending_intr':
> /home/mingo/tip/arch/ia64/kernel/irq_ia64.c:556: error: structure has no member named `irqs'
> /home/mingo/tip/arch/ia64/kernel/irq_ia64.c:558: error: structure has no member named `irqs'
> make[2]: *** [arch/ia64/kernel/irq_ia64.o] Error 1
> make[2]: *** Waiting for unfinished jobs....
> 
> and so does the MIPS build:
> 
> /home/mingo/tip/arch/mips/sgi-ip22/ip22-int.c: In function 'indy_buserror_irq':
> /home/mingo/tip/arch/mips/sgi-ip22/ip22-int.c:158: error: 'struct kernel_stat' has no member named 'irqs'
> make[2]: *** [arch/mips/sgi-ip22/ip22-int.o] Error 1
> make[2]: *** Waiting for unfinished jobs....
> /home/mingo/tip/arch/mips/sgi-ip22/ip22-time.c: In function 'indy_8254timer_irq':
> /home/mingo/tip/arch/mips/sgi-ip22/ip22-time.c:125: error: 'struct kernel_stat' has no member named 'irqs'
> make[2]: *** [arch/mips/sgi-ip22/ip22-time.o] Error 1
> make[1]: *** [arch/mips/sgi-ip22] Error 2
> make[1]: *** Waiting for unfinished jobs....
> 
> 	Ingo

Hi Ingo,

This appears to be a fallout of the sparse irqs changes.  Here is a suggested patch.

Btw, my ia64 build fails under tip/cpus4096 because this commit is not present:

commit e65e49d0f3714f4a6a42f6f6a19926ba33fcda75
Author: Mike Travis <travis@sgi.com>
Date:   Mon Jan 12 15:27:13 2009 -0800

    irq: update all arches for new irq_desc

With that patch also applied, the defconfig for ia64 builds correctly.

(Sorry, cannot test build the others right now.)

Thanks,
Mike
---
Subject: irq: fix build errors referencing old kstat.irqs array

Impact: fix build error

Since the SPARSE IRQS changes redefined how the kstat irqs are
organized, arch's must use the new accessor function:

	kstat_incr_irqs_this_cpu(irq, DESC);

If CONFIG_SPARSE_IRQS is set, then DESC is a pointer to the
irq_desc which has a pointer to the kstat_irqs.  If not, then
the .irqs field of struct kernel_stat is used instead.

Signed-off-by: Mike Travis <travis@sgi.com>

# IA64
Cc: Tony Luck <tony.luck@intel.com>
Cc: <linux-ia64@vger.kernel.org>

# MIPS
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: <linux-mips@linux-mips.org>

# MN10300
Cc: David Howells <dhowells@redhat.com>
Cc: Koichi Yasutake <yasutake.koichi@jp.panasonic.com>
Cc: <linux-am33-list@redhat.com>

# SPARC
Cc: David S. Miller <davem@davemloft.net>
Cc: <sparclinux@vger.kernel.org>
---
 arch/ia64/kernel/irq_ia64.c            |   12 ++++++++----
 arch/mips/kernel/smtc.c                |    4 +++-
 arch/mips/sgi-ip22/ip22-int.c          |    2 +-
 arch/mips/sgi-ip22/ip22-time.c         |    2 +-
 arch/mips/sibyte/bcm1480/smp.c         |    3 ++-
 arch/mips/sibyte/sb1250/smp.c          |    3 ++-
 arch/mn10300/kernel/mn10300-watchdog.c |    3 ++-
 arch/sparc/kernel/time_64.c            |    2 +-
 8 files changed, 20 insertions(+), 11 deletions(-)

--- linux-2.6-for-ingo.orig/arch/ia64/kernel/irq_ia64.c
+++ linux-2.6-for-ingo/arch/ia64/kernel/irq_ia64.c
@@ -493,11 +493,13 @@ ia64_handle_irq (ia64_vector vector, str
 	saved_tpr = ia64_getreg(_IA64_REG_CR_TPR);
 	ia64_srlz_d();
 	while (vector != IA64_SPURIOUS_INT_VECTOR) {
+		struct irq_desc *desc = irq_to_desc(vector);
+
 		if (unlikely(IS_LOCAL_TLB_FLUSH(vector))) {
 			smp_local_flush_tlb();
-			kstat_this_cpu.irqs[vector]++;
+			kstat_incr_irqs_this_cpu(vector, desc);
 		} else if (unlikely(IS_RESCHEDULE(vector)))
-			kstat_this_cpu.irqs[vector]++;
+			kstat_incr_irqs_this_cpu(vector, desc);
 		else {
 			int irq = local_vector_to_irq(vector);
 
@@ -551,11 +553,13 @@ void ia64_process_pending_intr(void)
 	  * Perform normal interrupt style processing
 	  */
 	while (vector != IA64_SPURIOUS_INT_VECTOR) {
+		struct irq_desc *desc = irq_to_desc(vector);
+
 		if (unlikely(IS_LOCAL_TLB_FLUSH(vector))) {
 			smp_local_flush_tlb();
-			kstat_this_cpu.irqs[vector]++;
+			kstat_incr_irqs_this_cpu(vector, desc);
 		} else if (unlikely(IS_RESCHEDULE(vector)))
-			kstat_this_cpu.irqs[vector]++;
+			kstat_incr_irqs_this_cpu(vector, desc);
 		else {
 			struct pt_regs *old_regs = set_irq_regs(NULL);
 			int irq = local_vector_to_irq(vector);
--- linux-2.6-for-ingo.orig/arch/mips/kernel/smtc.c
+++ linux-2.6-for-ingo/arch/mips/kernel/smtc.c
@@ -921,11 +921,13 @@ void ipi_decode(struct smtc_ipi *pipi)
 	struct clock_event_device *cd;
 	void *arg_copy = pipi->arg;
 	int type_copy = pipi->type;
+	int irq = MIPS_CPU_IRQ_BASE + 1;
+
 	smtc_ipi_nq(&freeIPIq, pipi);
 	switch (type_copy) {
 	case SMTC_CLOCK_TICK:
 		irq_enter();
-		kstat_this_cpu.irqs[MIPS_CPU_IRQ_BASE + 1]++;
+		kstat_incr_irqs_this_cpu(irq, irq_to_desc(irq));
 		cd = &per_cpu(mips_clockevent_device, cpu);
 		cd->event_handler(cd);
 		irq_exit();
--- linux-2.6-for-ingo.orig/arch/mips/sgi-ip22/ip22-int.c
+++ linux-2.6-for-ingo/arch/mips/sgi-ip22/ip22-int.c
@@ -155,7 +155,7 @@ static void indy_buserror_irq(void)
 	int irq = SGI_BUSERR_IRQ;
 
 	irq_enter();
-	kstat_this_cpu.irqs[irq]++;
+	kstat_incr_irqs_this_cpu(irq, irq_to_desc(irq));
 	ip22_be_interrupt(irq);
 	irq_exit();
 }
--- linux-2.6-for-ingo.orig/arch/mips/sgi-ip22/ip22-time.c
+++ linux-2.6-for-ingo/arch/mips/sgi-ip22/ip22-time.c
@@ -122,7 +122,7 @@ void indy_8254timer_irq(void)
 	char c;
 
 	irq_enter();
-	kstat_this_cpu.irqs[irq]++;
+	kstat_incr_irqs_this_cpu(irq, irq_to_desc(irq));
 	printk(KERN_ALERT "Oops, got 8254 interrupt.\n");
 	ArcRead(0, &c, 1, &cnt);
 	ArcEnterInteractiveMode();
--- linux-2.6-for-ingo.orig/arch/mips/sibyte/bcm1480/smp.c
+++ linux-2.6-for-ingo/arch/mips/sibyte/bcm1480/smp.c
@@ -178,9 +178,10 @@ struct plat_smp_ops bcm1480_smp_ops = {
 void bcm1480_mailbox_interrupt(void)
 {
 	int cpu = smp_processor_id();
+	int irq = K_BCM1480_INT_MBOX_0_0;
 	unsigned int action;
 
-	kstat_this_cpu.irqs[K_BCM1480_INT_MBOX_0_0]++;
+	kstat_incr_irqs_this_cpu(irq, irq_to_desc(irq));
 	/* Load the mailbox register to figure out what we're supposed to do */
 	action = (__raw_readq(mailbox_0_regs[cpu]) >> 48) & 0xffff;
 
--- linux-2.6-for-ingo.orig/arch/mips/sibyte/sb1250/smp.c
+++ linux-2.6-for-ingo/arch/mips/sibyte/sb1250/smp.c
@@ -166,9 +166,10 @@ struct plat_smp_ops sb_smp_ops = {
 void sb1250_mailbox_interrupt(void)
 {
 	int cpu = smp_processor_id();
+	int irq = K_INT_MBOX_0;
 	unsigned int action;
 
-	kstat_this_cpu.irqs[K_INT_MBOX_0]++;
+	kstat_incr_irqs_this_cpu(irq, irq_to_desc(irq));
 	/* Load the mailbox register to figure out what we're supposed to do */
 	action = (____raw_readq(mailbox_regs[cpu]) >> 48) & 0xffff;
 
--- linux-2.6-for-ingo.orig/arch/mn10300/kernel/mn10300-watchdog.c
+++ linux-2.6-for-ingo/arch/mn10300/kernel/mn10300-watchdog.c
@@ -130,6 +130,7 @@ void watchdog_interrupt(struct pt_regs *
 	 * the stack NMI-atomically, it's safe to use smp_processor_id().
 	 */
 	int sum, cpu = smp_processor_id();
+	int irq = NMIIRQ;
 	u8 wdt, tmp;
 
 	wdt = WDCTR & ~WDCTR_WDCNE;
@@ -138,7 +139,7 @@ void watchdog_interrupt(struct pt_regs *
 	NMICR = NMICR_WDIF;
 
 	nmi_count(cpu)++;
-	kstat_this_cpu.irqs[NMIIRQ]++;
+	kstat_incr_irqs_this_cpu(irq, irq_to_desc(irq));
 	sum = irq_stat[cpu].__irq_count;
 
 	if (last_irq_sums[cpu] = sum) {
--- linux-2.6-for-ingo.orig/arch/sparc/kernel/time_64.c
+++ linux-2.6-for-ingo/arch/sparc/kernel/time_64.c
@@ -727,7 +727,7 @@ void timer_interrupt(int irq, struct pt_
 
 	irq_enter();
 
-	kstat_this_cpu.irqs[0]++;
+	kstat_incr_irqs_this_cpu(0, irq_to_desc(0));
 
 	if (unlikely(!evt->event_handler)) {
 		printk(KERN_WARNING
