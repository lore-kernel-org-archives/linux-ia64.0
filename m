From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 17 Jul 2007 19:38:03 +0000
Subject: Re: [PATCH take3 0/12] Support vector domain on ia64
Message-Id: <m1d4yq4y90.fsf@ebiederm.dsl.xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <469CB3FA.7010301@jp.fujitsu.com>
In-Reply-To: <469CB3FA.7010301@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> writes:

> - define NR_IRQS as follow:
>
>   Vector domain can provide the number of irqs being proportional to the
>   number of CPUs theoretically. However, the relation between them is
>   actually not linear, especially in large system. To avoid the memory
>   consumption derived from too many irqs, I define NR_IRQS as follows:
>
>   #if (NR_VECTORS + 32 * NR_CPUS) < 1024
>   #define NR_IRQS (NR_VECTORS + 32 * NR_CPUS)
>   #else
>   #define NR_IRQS 1024
>   #endif


Below is my old patch to address this in a different way.
Basically this moves the per cpu counter of the number of
times an irq has happened on an individual cpu out of the
per cpu area.  Honestly I think this might even have better
cache performance.

Anyway something to think about.

Eric



From e02f708c0eca6708c8f79824717705379e982fe3 Mon Sep 17 00:00:00 2001
From: Eric W. Biederman <ebiederm@xmission.com>
Date: Tue, 13 Feb 2007 02:42:50 -0700
Subject: [PATCH] genirq: Kill the percpu NR_IRQS sized array in kstat.

In struct kernel_stat which has one instance per cpu we keep a
count of how many times each irq has occured on that cpu.  Given
that we don't usually use all of our irqs this is very wasteful
of space and in particular percpu space.

This patch replaces that array on all architectures that use
GENERIC_HARD_IRQS with a point to a array of cpus in struct irq_desc.
This allocates the array at boot time after we have generated the
cpu_possible_map and is only large enough to hold the largest possible
cpu index.

Assuming the common case of dense cpu numbers this consumes roughly the
same amount of space as the current mechanism and removes the NR_IRQS
sized array.

The only immediate win is to get these counts out of the limited size
percpu areas.

Shortly I will make the need for NR_IRQS sized arrays obsolete, allowing
a single kernel to support huge numbers of irqs and still be efficient
on small machines.

With the removal of the NR_IRQS sized arrays this patch will be a clear
size win in space consumption for small machines.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 arch/alpha/kernel/irq.c           |    2 +-
 arch/alpha/kernel/irq_alpha.c     |    2 +-
 arch/arm/kernel/irq.c             |    2 +-
 arch/avr32/kernel/irq.c           |    2 +-
 arch/cris/kernel/irq.c            |    2 +-
 arch/frv/kernel/irq.c             |    2 +-
 arch/i386/kernel/io_apic.c        |    2 +-
 arch/i386/kernel/irq.c            |    2 +-
 arch/i386/mach-visws/visws_apic.c |    2 +-
 arch/ia64/kernel/irq.c            |    2 +-
 arch/ia64/kernel/irq_ia64.c       |    4 ++--
 arch/m32r/kernel/irq.c            |    2 +-
 arch/mips/au1000/common/time.c    |    4 ++--
 arch/mips/kernel/irq.c            |    2 +-
 arch/mips/kernel/time.c           |    4 ++--
 arch/mips/sgi-ip22/ip22-int.c     |    2 +-
 arch/mips/sgi-ip22/ip22-time.c    |    4 ++--
 arch/mips/sgi-ip27/ip27-timer.c   |    2 +-
 arch/mips/sibyte/bcm1480/smp.c    |    2 +-
 arch/mips/sibyte/sb1250/irq.c     |    2 +-
 arch/mips/sibyte/sb1250/smp.c     |    2 +-
 arch/parisc/kernel/irq.c          |    2 +-
 arch/powerpc/kernel/irq.c         |    2 +-
 arch/ppc/amiga/amiints.c          |    4 ++--
 arch/ppc/amiga/cia.c              |    2 +-
 arch/ppc/amiga/ints.c             |    4 ++--
 arch/sh/kernel/irq.c              |    2 +-
 arch/sparc64/kernel/irq.c         |    4 ++--
 arch/sparc64/kernel/smp.c         |    2 +-
 arch/um/kernel/irq.c              |    2 +-
 arch/x86_64/kernel/irq.c          |    6 +-----
 arch/xtensa/kernel/irq.c          |    2 +-
 fs/proc/proc_misc.c               |    2 +-
 include/linux/irq.h               |    4 ++++
 include/linux/kernel_stat.h       |   20 +++++++++++++++++---
 init/main.c                       |    1 +
 kernel/irq/chip.c                 |   15 +++++----------
 kernel/irq/handle.c               |   29 +++++++++++++++++++++++++++--
 38 files changed, 94 insertions(+), 59 deletions(-)

diff --git a/arch/alpha/kernel/irq.c b/arch/alpha/kernel/irq.c
index 3659af8..8e0af05 100644
--- a/arch/alpha/kernel/irq.c
+++ b/arch/alpha/kernel/irq.c
@@ -88,7 +88,7 @@ show_interrupts(struct seq_file *p, void *v)
 		seq_printf(p, "%10u ", kstat_irqs(irq));
 #else
 		for_each_online_cpu(j)
-			seq_printf(p, "%10u ", kstat_cpu(j).irqs[irq]);
+			seq_printf(p, "%10u ", kstat_irqs_cpu(i, j));
 #endif
 		seq_printf(p, " %14s", irq_desc[irq].chip->typename);
 		seq_printf(p, "  %c%s",
diff --git a/arch/alpha/kernel/irq_alpha.c b/arch/alpha/kernel/irq_alpha.c
index e16aeb6..2c0852c 100644
--- a/arch/alpha/kernel/irq_alpha.c
+++ b/arch/alpha/kernel/irq_alpha.c
@@ -64,7 +64,7 @@ do_entInt(unsigned long type, unsigned long vector,
 		smp_percpu_timer_interrupt(regs);
 		cpu = smp_processor_id();
 		if (cpu != boot_cpuid) {
-		        kstat_cpu(cpu).irqs[RTC_IRQ]++;
+			irq_desc[RTC_IRQ].kstat_irqs[cpu]++;
 		} else {
 			handle_irq(RTC_IRQ);
 		}
diff --git a/arch/arm/kernel/irq.c b/arch/arm/kernel/irq.c
index e101846..db79c4c 100644
--- a/arch/arm/kernel/irq.c
+++ b/arch/arm/kernel/irq.c
@@ -76,7 +76,7 @@ int show_interrupts(struct seq_file *p, void *v)
 
 		seq_printf(p, "%3d: ", i);
 		for_each_present_cpu(cpu)
-			seq_printf(p, "%10u ", kstat_cpu(cpu).irqs[i]);
+			seq_printf(p, "%10u ", kstat_irqs_cpu(i, cpu));
 		seq_printf(p, " %10s", irq_desc[i].chip->name ? : "-");
 		seq_printf(p, "  %s", action->name);
 		for (action = action->next; action; action = action->next)
diff --git a/arch/avr32/kernel/irq.c b/arch/avr32/kernel/irq.c
index fd31124..7cddf0a 100644
--- a/arch/avr32/kernel/irq.c
+++ b/arch/avr32/kernel/irq.c
@@ -56,7 +56,7 @@ int show_interrupts(struct seq_file *p, void *v)
 
 		seq_printf(p, "%3d: ", i);
 		for_each_online_cpu(cpu)
-			seq_printf(p, "%10u ", kstat_cpu(cpu).irqs[i]);
+			seq_printf(p, "%10u ", kstat_irqs_cpu(i, cpu));
 		seq_printf(p, " %8s", irq_desc[i].chip->name ? : "-");
 		seq_printf(p, "  %s", action->name);
 		for (action = action->next; action; action = action->next)
diff --git a/arch/cris/kernel/irq.c b/arch/cris/kernel/irq.c
index 903ea62..9d7c1d7 100644
--- a/arch/cris/kernel/irq.c
+++ b/arch/cris/kernel/irq.c
@@ -66,7 +66,7 @@ int show_interrupts(struct seq_file *p, void *v)
 		seq_printf(p, "%10u ", kstat_irqs(i));
 #else
 		for_each_online_cpu(j)
-			seq_printf(p, "%10u ", kstat_cpu(j).irqs[i]);
+			seq_printf(p, "%10u ", kstat_irqs_cpu(i, j));
 #endif
 		seq_printf(p, " %14s", irq_desc[i].chip->typename);
 		seq_printf(p, "  %s", action->name);
diff --git a/arch/frv/kernel/irq.c b/arch/frv/kernel/irq.c
index 87f360a..ff6579f 100644
--- a/arch/frv/kernel/irq.c
+++ b/arch/frv/kernel/irq.c
@@ -75,7 +75,7 @@ int show_interrupts(struct seq_file *p, void *v)
 		if (action) {
 			seq_printf(p, "%3d: ", i);
 			for_each_present_cpu(cpu)
-				seq_printf(p, "%10u ", kstat_cpu(cpu).irqs[i]);
+				seq_printf(p, "%10u ", kstat_irqs_cpu(i, cpu));
 			seq_printf(p, " %10s", irq_desc[i].chip->name ? : "-");
 			seq_printf(p, "  %s", action->name);
 			for (action = action->next;
diff --git a/arch/i386/kernel/io_apic.c b/arch/i386/kernel/io_apic.c
index edcc849..c660c8b 100644
--- a/arch/i386/kernel/io_apic.c
+++ b/arch/i386/kernel/io_apic.c
@@ -488,7 +488,7 @@ static void do_irq_balance(void)
 			if ( package_index = i )
 				IRQ_DELTA(package_index,j) = 0;
 			/* Determine the total count per processor per IRQ */
-			value_now = (unsigned long) kstat_cpu(i).irqs[j];
+			value_now = (unsigned long) kstat_irqs_cpu(j, i);
 
 			/* Determine the activity per processor per IRQ */
 			delta = value_now - LAST_CPU_IRQ(i,j);
diff --git a/arch/i386/kernel/irq.c b/arch/i386/kernel/irq.c
index eeb29af..0a30abc 100644
--- a/arch/i386/kernel/irq.c
+++ b/arch/i386/kernel/irq.c
@@ -279,7 +279,7 @@ int show_interrupts(struct seq_file *p, void *v)
 		seq_printf(p, "%10u ", kstat_irqs(i));
 #else
 		for_each_online_cpu(j)
-			seq_printf(p, "%10u ", kstat_cpu(j).irqs[i]);
+			seq_printf(p, "%10u ", kstat_irqs_cpu(i, j));
 #endif
 		seq_printf(p, " %8s", irq_desc[i].chip->name);
 		seq_printf(p, "-%-8s", irq_desc[i].name);
diff --git a/arch/i386/mach-visws/visws_apic.c b/arch/i386/mach-visws/visws_apic.c
index 38c2b13..0d153eb 100644
--- a/arch/i386/mach-visws/visws_apic.c
+++ b/arch/i386/mach-visws/visws_apic.c
@@ -240,7 +240,7 @@ static irqreturn_t piix4_master_intr(int irq, void *dev_id)
 	/*
 	 * handle this 'virtual interrupt' as a Cobalt one now.
 	 */
-	kstat_cpu(smp_processor_id()).irqs[realirq]++;
+	desc->kstat_irqs[smp_processor_id()]++;
 
 	if (likely(desc->action != NULL))
 		handle_IRQ_event(realirq, desc->action);
diff --git a/arch/ia64/kernel/irq.c b/arch/ia64/kernel/irq.c
index ce49c85..06edbb8 100644
--- a/arch/ia64/kernel/irq.c
+++ b/arch/ia64/kernel/irq.c
@@ -73,7 +73,7 @@ int show_interrupts(struct seq_file *p, void *v)
 		seq_printf(p, "%10u ", kstat_irqs(i));
 #else
 		for_each_online_cpu(j) {
-			seq_printf(p, "%10u ", kstat_cpu(j).irqs[i]);
+			seq_printf(p, "%10u ", kstat_irqs_cpu(i, j));
 		}
 #endif
 		seq_printf(p, " %14s", irq_desc[i].chip->name);
diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 456f57b..be1dd6e 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -181,7 +181,7 @@ ia64_handle_irq (ia64_vector vector, struct pt_regs *regs)
 	ia64_srlz_d();
 	while (vector != IA64_SPURIOUS_INT_VECTOR) {
 		if (unlikely(IS_RESCHEDULE(vector)))
-			 kstat_this_cpu.irqs[vector]++;
+			kstat_irqs_this_cpu(&irq_desc[vector])++;
 		else {
 			ia64_setreg(_IA64_REG_CR_TPR, vector);
 			ia64_srlz_d();
@@ -228,7 +228,7 @@ void ia64_process_pending_intr(void)
 	  */
 	while (vector != IA64_SPURIOUS_INT_VECTOR) {
 		if (unlikely(IS_RESCHEDULE(vector)))
-			 kstat_this_cpu.irqs[vector]++;
+			kstat_irqs_this_cpu(&irq_desc[vector])++;
 		else {
 			struct pt_regs *old_regs = set_irq_regs(NULL);
 
diff --git a/arch/m32r/kernel/irq.c b/arch/m32r/kernel/irq.c
index f8d8650..4fb85b2 100644
--- a/arch/m32r/kernel/irq.c
+++ b/arch/m32r/kernel/irq.c
@@ -52,7 +52,7 @@ int show_interrupts(struct seq_file *p, void *v)
 		seq_printf(p, "%10u ", kstat_irqs(i));
 #else
 		for_each_online_cpu(j)
-			seq_printf(p, "%10u ", kstat_cpu(j).irqs[i]);
+			seq_printf(p, "%10u ", kstat_irqs_cpu(i, j));
 #endif
 		seq_printf(p, " %14s", irq_desc[i].chip->typename);
 		seq_printf(p, "  %s", action->name);
diff --git a/arch/mips/au1000/common/time.c b/arch/mips/au1000/common/time.c
index fa1c62f..c2a084e 100644
--- a/arch/mips/au1000/common/time.c
+++ b/arch/mips/au1000/common/time.c
@@ -81,13 +81,13 @@ void mips_timer_interrupt(void)
 	int irq = 63;
 
 	irq_enter();
-	kstat_this_cpu.irqs[irq]++;
+	kstat_irqs_this_cpu(&irq_desc[irq])++;
 
 	if (r4k_offset = 0)
 		goto null;
 
 	do {
-		kstat_this_cpu.irqs[irq]++;
+		kstat_irqs_this_cpu(&irq_desc[irq])++;
 		do_timer(1);
 #ifndef CONFIG_SMP
 		update_process_times(user_mode(get_irq_regs()));
diff --git a/arch/mips/kernel/irq.c b/arch/mips/kernel/irq.c
index 2fe4c86..c2cae91 100644
--- a/arch/mips/kernel/irq.c
+++ b/arch/mips/kernel/irq.c
@@ -115,7 +115,7 @@ int show_interrupts(struct seq_file *p, void *v)
 		seq_printf(p, "%10u ", kstat_irqs(i));
 #else
 		for_each_online_cpu(j)
-			seq_printf(p, "%10u ", kstat_cpu(j).irqs[i]);
+			seq_printf(p, "%10u ", kstat_irqs_cpu(i, j));
 #endif
 		seq_printf(p, " %14s", irq_desc[i].chip->name);
 		seq_printf(p, "  %s", action->name);
diff --git a/arch/mips/kernel/time.c b/arch/mips/kernel/time.c
index e5e56bd..0a829e2 100644
--- a/arch/mips/kernel/time.c
+++ b/arch/mips/kernel/time.c
@@ -204,7 +204,7 @@ asmlinkage void ll_timer_interrupt(int irq)
 	int r2 = cpu_has_mips_r2;
 
 	irq_enter();
-	kstat_this_cpu.irqs[irq]++;
+	kstat_irqs_this_cpu(&irq_desc[irq])++;
 
 	/*
 	 * Suckage alert:
@@ -228,7 +228,7 @@ asmlinkage void ll_local_timer_interrupt(int irq)
 {
 	irq_enter();
 	if (smp_processor_id() != 0)
-		kstat_this_cpu.irqs[irq]++;
+		kstat_irqs_this_cpu(&irq_desc[irq])++;
 
 	/* we keep interrupt disabled all the time */
 	local_timer_interrupt(irq, NULL);
diff --git a/arch/mips/sgi-ip22/ip22-int.c b/arch/mips/sgi-ip22/ip22-int.c
index b454924..382a8a5 100644
--- a/arch/mips/sgi-ip22/ip22-int.c
+++ b/arch/mips/sgi-ip22/ip22-int.c
@@ -164,7 +164,7 @@ static void indy_buserror_irq(void)
 	int irq = SGI_BUSERR_IRQ;
 
 	irq_enter();
-	kstat_this_cpu.irqs[irq]++;
+	kstat_irqs_this_cpu(&irq_desc[irq])++;
 	ip22_be_interrupt(irq);
 	irq_exit();
 }
diff --git a/arch/mips/sgi-ip22/ip22-time.c b/arch/mips/sgi-ip22/ip22-time.c
index 2055547..0cd6887 100644
--- a/arch/mips/sgi-ip22/ip22-time.c
+++ b/arch/mips/sgi-ip22/ip22-time.c
@@ -182,7 +182,7 @@ void indy_8254timer_irq(void)
 	char c;
 
 	irq_enter();
-	kstat_this_cpu.irqs[irq]++;
+	kstat_irqs_this_cpu(&irq_desc[irq])++;
 	printk(KERN_ALERT "Oops, got 8254 interrupt.\n");
 	ArcRead(0, &c, 1, &cnt);
 	ArcEnterInteractiveMode();
@@ -194,7 +194,7 @@ void indy_r4k_timer_interrupt(void)
 	int irq = SGI_TIMER_IRQ;
 
 	irq_enter();
-	kstat_this_cpu.irqs[irq]++;
+	kstat_irqs_this_cpu(&irq_desc[irq])++;
 	timer_interrupt(irq, NULL);
 	irq_exit();
 }
diff --git a/arch/mips/sgi-ip27/ip27-timer.c b/arch/mips/sgi-ip27/ip27-timer.c
index 8c3c78c..592449c 100644
--- a/arch/mips/sgi-ip27/ip27-timer.c
+++ b/arch/mips/sgi-ip27/ip27-timer.c
@@ -106,7 +106,7 @@ again:
 	if (LOCAL_HUB_L(PI_RT_COUNT) >= ct_cur[cpu])
 		goto again;
 
-	kstat_this_cpu.irqs[irq]++;		/* kstat only for bootcpu? */
+	irq_desc[irq].kstat_irqs[cpu]++;	/* kstat only for bootcpu? */
 
 	if (cpu = 0)
 		do_timer(1);
diff --git a/arch/mips/sibyte/bcm1480/smp.c b/arch/mips/sibyte/bcm1480/smp.c
index bf32827..a070238 100644
--- a/arch/mips/sibyte/bcm1480/smp.c
+++ b/arch/mips/sibyte/bcm1480/smp.c
@@ -93,7 +93,7 @@ void bcm1480_mailbox_interrupt(void)
 	int cpu = smp_processor_id();
 	unsigned int action;
 
-	kstat_this_cpu.irqs[K_BCM1480_INT_MBOX_0_0]++;
+	irq_desc[K_BCM1480_INT_MBOX_0_0].kstat_irqs[cpu]++;
 	/* Load the mailbox register to figure out what we're supposed to do */
 	action = (__raw_readq(mailbox_0_regs[cpu]) >> 48) & 0xffff;
 
diff --git a/arch/mips/sibyte/sb1250/irq.c b/arch/mips/sibyte/sb1250/irq.c
index 1482394..fb7d77f 100644
--- a/arch/mips/sibyte/sb1250/irq.c
+++ b/arch/mips/sibyte/sb1250/irq.c
@@ -390,7 +390,7 @@ static void sb1250_kgdb_interrupt(void)
 	 * host to stop the break, since we would see another
 	 * interrupt on the end-of-break too)
 	 */
-	kstat_this_cpu.irqs[kgdb_irq]++;
+	kstat_irqs_this_cpu(&irq_desc[kgdb_irq])++;
 	mdelay(500);
 	duart_out(R_DUART_CMD, V_DUART_MISC_CMD_RESET_BREAK_INT |
 				M_DUART_RX_EN | M_DUART_TX_EN);
diff --git a/arch/mips/sibyte/sb1250/smp.c b/arch/mips/sibyte/sb1250/smp.c
index c38e1f3..54c6164 100644
--- a/arch/mips/sibyte/sb1250/smp.c
+++ b/arch/mips/sibyte/sb1250/smp.c
@@ -81,7 +81,7 @@ void sb1250_mailbox_interrupt(void)
 	int cpu = smp_processor_id();
 	unsigned int action;
 
-	kstat_this_cpu.irqs[K_INT_MBOX_0]++;
+	irq_desc[K_INT_MBOX_0].kstat_irqs[cpu]++;
 	/* Load the mailbox register to figure out what we're supposed to do */
 	action = (____raw_readq(mailbox_regs[cpu]) >> 48) & 0xffff;
 
diff --git a/arch/parisc/kernel/irq.c b/arch/parisc/kernel/irq.c
index b39c5b9..c222bbd 100644
--- a/arch/parisc/kernel/irq.c
+++ b/arch/parisc/kernel/irq.c
@@ -192,7 +192,7 @@ int show_interrupts(struct seq_file *p, void *v)
 		seq_printf(p, "%3d: ", i);
 #ifdef CONFIG_SMP
 		for_each_online_cpu(j)
-			seq_printf(p, "%10u ", kstat_cpu(j).irqs[i]);
+			seq_printf(p, "%10u ", kstat_irqs_cpu(i, j));
 #else
 		seq_printf(p, "%10u ", kstat_irqs(i));
 #endif
diff --git a/arch/powerpc/kernel/irq.c b/arch/powerpc/kernel/irq.c
index 919fbf5..0be818a 100644
--- a/arch/powerpc/kernel/irq.c
+++ b/arch/powerpc/kernel/irq.c
@@ -189,7 +189,7 @@ int show_interrupts(struct seq_file *p, void *v)
 		seq_printf(p, "%3d: ", i);
 #ifdef CONFIG_SMP
 		for_each_online_cpu(j)
-			seq_printf(p, "%10u ", kstat_cpu(j).irqs[i]);
+			seq_printf(p, "%10u ", kstat_irqs_cpu(i, j));
 #else
 		seq_printf(p, "%10u ", kstat_irqs(i));
 #endif /* CONFIG_SMP */
diff --git a/arch/ppc/amiga/amiints.c b/arch/ppc/amiga/amiints.c
index 265fcd3..3dc8651 100644
--- a/arch/ppc/amiga/amiints.c
+++ b/arch/ppc/amiga/amiints.c
@@ -184,7 +184,7 @@ inline void amiga_do_irq(int irq, struct pt_regs *fp)
 	irq_desc_t *desc = irq_desc + irq;
 	struct irqaction *action = desc->action;
 
-	kstat_cpu(0).irqs[irq]++;
+	desc->kstat_irqs[0]++;
 	action->handler(irq, action->dev_id, fp);
 }
 
@@ -193,7 +193,7 @@ void amiga_do_irq_list(int irq, struct pt_regs *fp)
 	irq_desc_t *desc = irq_desc + irq;
 	struct irqaction *action;
 
-	kstat_cpu(0).irqs[irq]++;
+	desc->kstat_irqs[0]++;
 
 	amiga_custom.intreq = ami_intena_vals[irq];
 
diff --git a/arch/ppc/amiga/cia.c b/arch/ppc/amiga/cia.c
index 9558f2f..33faf2d 100644
--- a/arch/ppc/amiga/cia.c
+++ b/arch/ppc/amiga/cia.c
@@ -146,7 +146,7 @@ static void cia_handler(int irq, void *dev_id, struct pt_regs *fp)
 	amiga_custom.intreq = base->int_mask;
 	for (i = 0; i < CIA_IRQS; i++, irq++) {
 		if (ints & 1) {
-			kstat_cpu(0).irqs[irq]++;
+			desc->kstat_irqs[0]++;
 			action = desc->action;
 			action->handler(irq, action->dev_id, fp);
 		}
diff --git a/arch/ppc/amiga/ints.c b/arch/ppc/amiga/ints.c
index 083a174..84ec6cb 100644
--- a/arch/ppc/amiga/ints.c
+++ b/arch/ppc/amiga/ints.c
@@ -128,7 +128,7 @@ asmlinkage void process_int(unsigned long vec, struct pt_regs *fp)
 {
 	if (vec >= VEC_INT1 && vec <= VEC_INT7 && !MACH_IS_BVME6000) {
 		vec -= VEC_SPUR;
-		kstat_cpu(0).irqs[vec]++;
+		irq_desc[vec].kstat_irqs[0]++;
 		irq_list[vec].handler(vec, irq_list[vec].dev_id, fp);
 	} else {
 		if (mach_process_int)
@@ -147,7 +147,7 @@ int m68k_get_irq_list(struct seq_file *p, void *v)
 	if (mach_default_handler) {
 		for (i = 0; i < SYS_IRQS; i++) {
 			seq_printf(p, "auto %2d: %10u ", i,
-			               i ? kstat_cpu(0).irqs[i] : num_spurious);
+			               i ? kstat_irqs_cpu(i, 0) : num_spurious);
 			seq_puts(p, "  ");
 			seq_printf(p, "%s\n", irq_list[i].devname);
 		}
diff --git a/arch/sh/kernel/irq.c b/arch/sh/kernel/irq.c
index 67be2b6..e9c739a 100644
--- a/arch/sh/kernel/irq.c
+++ b/arch/sh/kernel/irq.c
@@ -52,7 +52,7 @@ int show_interrupts(struct seq_file *p, void *v)
 			goto unlock;
 		seq_printf(p, "%3d: ",i);
 		for_each_online_cpu(j)
-			seq_printf(p, "%10u ", kstat_cpu(j).irqs[i]);
+			seq_printf(p, "%10u ", kstat_cpu(i, j));
 		seq_printf(p, " %14s", irq_desc[i].chip->name);
 		seq_printf(p, "-%-8s", irq_desc[i].name);
 		seq_printf(p, "  %s", action->name);
diff --git a/arch/sparc64/kernel/irq.c b/arch/sparc64/kernel/irq.c
index b5ff3ee..4a436a7 100644
--- a/arch/sparc64/kernel/irq.c
+++ b/arch/sparc64/kernel/irq.c
@@ -154,7 +154,7 @@ int show_interrupts(struct seq_file *p, void *v)
 		seq_printf(p, "%10u ", kstat_irqs(i));
 #else
 		for_each_online_cpu(j)
-			seq_printf(p, "%10u ", kstat_cpu(j).irqs[i]);
+			seq_printf(p, "%10u ", kstat_irqs_cpu(i, j));
 #endif
 		seq_printf(p, " %9s", irq_desc[i].chip->typename);
 		seq_printf(p, "  %s", action->name);
@@ -605,7 +605,7 @@ void timer_irq(int irq, struct pt_regs *regs)
 	old_regs = set_irq_regs(regs);
 	irq_enter();
 
-	kstat_this_cpu.irqs[0]++;
+	irq_desc[0].kstat_irqs[0]++;
 	timer_interrupt(irq, NULL);
 
 	irq_exit();
diff --git a/arch/sparc64/kernel/smp.c b/arch/sparc64/kernel/smp.c
index fc99f7b..155703b 100644
--- a/arch/sparc64/kernel/smp.c
+++ b/arch/sparc64/kernel/smp.c
@@ -1212,7 +1212,7 @@ void smp_percpu_timer_interrupt(struct pt_regs *regs)
 			irq_enter();
 
 			if (cpu = boot_cpu_id) {
-				kstat_this_cpu.irqs[0]++;
+				irq_desc[0].kstat_irqs[cpu]++;
 				timer_tick_interrupt(regs);
 			}
 
diff --git a/arch/um/kernel/irq.c b/arch/um/kernel/irq.c
index 50a288b..fa16410 100644
--- a/arch/um/kernel/irq.c
+++ b/arch/um/kernel/irq.c
@@ -61,7 +61,7 @@ int show_interrupts(struct seq_file *p, void *v)
 		seq_printf(p, "%10u ", kstat_irqs(i));
 #else
 		for_each_online_cpu(j)
-			seq_printf(p, "%10u ", kstat_cpu(j).irqs[i]);
+			seq_printf(p, "%10u ", kstat_irqs_cpu(i, j));
 #endif
 		seq_printf(p, " %14s", irq_desc[i].chip->typename);
 		seq_printf(p, "  %s", action->name);
diff --git a/arch/x86_64/kernel/irq.c b/arch/x86_64/kernel/irq.c
index 9fe2e28..beefb89 100644
--- a/arch/x86_64/kernel/irq.c
+++ b/arch/x86_64/kernel/irq.c
@@ -69,12 +69,8 @@ int show_interrupts(struct seq_file *p, void *v)
 		if (!action) 
 			goto skip;
 		seq_printf(p, "%3d: ",i);
-#ifndef CONFIG_SMP
-		seq_printf(p, "%10u ", kstat_irqs(i));
-#else
 		for_each_online_cpu(j)
-			seq_printf(p, "%10u ", kstat_cpu(j).irqs[i]);
-#endif
+			seq_printf(p, "%10u ", kstat_irqs_cpu(i, j));
 		seq_printf(p, " %8s", irq_desc[i].chip->name);
 		seq_printf(p, "-%-8s", irq_desc[i].name);
 
diff --git a/arch/xtensa/kernel/irq.c b/arch/xtensa/kernel/irq.c
index c9ea73b..c35e271 100644
--- a/arch/xtensa/kernel/irq.c
+++ b/arch/xtensa/kernel/irq.c
@@ -99,7 +99,7 @@ int show_interrupts(struct seq_file *p, void *v)
 		seq_printf(p, "%10u ", kstat_irqs(i));
 #else
 		for_each_online_cpu(j)
-			seq_printf(p, "%10u ", kstat_cpu(j).irqs[i]);
+			seq_printf(p, "%10u ", kstat_irqs_cpu(i, j));
 #endif
 		seq_printf(p, " %14s", irq_desc[i].chip->typename);
 		seq_printf(p, "  %s", action->name);
diff --git a/fs/proc/proc_misc.c b/fs/proc/proc_misc.c
index e2c4c0a..21be453 100644
--- a/fs/proc/proc_misc.c
+++ b/fs/proc/proc_misc.c
@@ -472,7 +472,7 @@ static int show_stat(struct seq_file *p, void *v)
 		softirq = cputime64_add(softirq, kstat_cpu(i).cpustat.softirq);
 		steal = cputime64_add(steal, kstat_cpu(i).cpustat.steal);
 		for (j = 0 ; j < NR_IRQS ; j++)
-			sum += kstat_cpu(i).irqs[j];
+			sum += kstat_irqs_cpu(j, i);
 	}
 
 	seq_printf(p, "cpu  %llu %llu %llu %llu %llu %llu %llu %llu\n",
diff --git a/include/linux/irq.h b/include/linux/irq.h
index bb78ab9..9c61fd7 100644
--- a/include/linux/irq.h
+++ b/include/linux/irq.h
@@ -156,6 +156,7 @@ struct irq_desc {
 	void			*handler_data;
 	void			*chip_data;
 	struct irqaction	*action;	/* IRQ action list */
+	unsigned int		*kstat_irqs;
 	unsigned int		status;		/* IRQ status */
 
 	unsigned int		depth;		/* nested irq disables */
@@ -178,6 +179,9 @@ struct irq_desc {
 
 extern struct irq_desc irq_desc[NR_IRQS];
 
+#define kstat_irqs_this_cpu(DESC) \
+	((DESC)->kstat_irqs[smp_processor_id()])
+
 /*
  * Migration helpers for obsolete names, they will go away:
  */
diff --git a/include/linux/kernel_stat.h b/include/linux/kernel_stat.h
index 43e895f..0c8f650 100644
--- a/include/linux/kernel_stat.h
+++ b/include/linux/kernel_stat.h
@@ -27,7 +27,9 @@ struct cpu_usage_stat {
 
 struct kernel_stat {
 	struct cpu_usage_stat	cpustat;
+#ifndef CONFIG_GENERIC_HARDIRQS
 	unsigned int irqs[NR_IRQS];
+#endif
 };
 
 DECLARE_PER_CPU(struct kernel_stat, kstat);
@@ -38,15 +40,27 @@ DECLARE_PER_CPU(struct kernel_stat, kstat);
 
 extern unsigned long long nr_context_switches(void);
 
+#ifndef CONFIG_GENERIC_HARDIRQS
+static inline unsigned int kstat_irqs_cpu(unsigned int irq, int cpu)
+{
+	return kstat_cpu(cpu).irqs[irq];
+}
+static inline void init_kstat_irqs(void) {}
+#else
+extern unsigned int kstat_irqs_cpu(unsigned int irq, int cpu);
+extern void init_kstat_irqs(void);
+#endif /* CONFIG_GENERIC_HARDIRQS */
+
 /*
  * Number of interrupts per specific IRQ source, since bootup
  */
-static inline int kstat_irqs(int irq)
+static inline unsigned int kstat_irqs(unsigned int irq)
 {
-	int cpu, sum = 0;
+	unsigned int sum = 0;
+	int cpu;
 
 	for_each_possible_cpu(cpu)
-		sum += kstat_cpu(cpu).irqs[irq];
+		sum += kstat_irqs_cpu(irq, cpu);
 
 	return sum;
 }
diff --git a/init/main.c b/init/main.c
index a92989e..23f1c64 100644
--- a/init/main.c
+++ b/init/main.c
@@ -559,6 +559,7 @@ asmlinkage void __init start_kernel(void)
 	sort_main_extable();
 	trap_init();
 	rcu_init();
+	init_kstat_irqs();
 	init_IRQ();
 	pidhash_init();
 	init_timers();
diff --git a/kernel/irq/chip.c b/kernel/irq/chip.c
index f83d691..7896286 100644
--- a/kernel/irq/chip.c
+++ b/kernel/irq/chip.c
@@ -288,13 +288,12 @@ handle_simple_irq(unsigned int irq, struct irq_desc *desc)
 {
 	struct irqaction *action;
 	irqreturn_t action_ret;
-	const unsigned int cpu = smp_processor_id();
 
 	spin_lock(&desc->lock);
 
 	if (unlikely(desc->status & IRQ_INPROGRESS))
 		goto out_unlock;
-	kstat_cpu(cpu).irqs[irq]++;
+	kstat_irqs_this_cpu(desc)++;
 
 	action = desc->action;
 	if (unlikely(!action || (desc->status & IRQ_DISABLED))) {
@@ -332,7 +331,6 @@ out_unlock:
 void fastcall
 handle_level_irq(unsigned int irq, struct irq_desc *desc)
 {
-	unsigned int cpu = smp_processor_id();
 	struct irqaction *action;
 	irqreturn_t action_ret;
 
@@ -342,7 +340,7 @@ handle_level_irq(unsigned int irq, struct irq_desc *desc)
 	if (unlikely(desc->status & IRQ_INPROGRESS))
 		goto out_unlock;
 	desc->status &= ~(IRQ_REPLAY | IRQ_WAITING);
-	kstat_cpu(cpu).irqs[irq]++;
+	kstat_irqs_this_cpu(desc)++;
 
 	/*
 	 * If its disabled or no action available
@@ -383,7 +381,6 @@ out_unlock:
 void fastcall
 handle_fasteoi_irq(unsigned int irq, struct irq_desc *desc)
 {
-	unsigned int cpu = smp_processor_id();
 	struct irqaction *action;
 	irqreturn_t action_ret;
 
@@ -393,7 +390,7 @@ handle_fasteoi_irq(unsigned int irq, struct irq_desc *desc)
 		goto out;
 
 	desc->status &= ~(IRQ_REPLAY | IRQ_WAITING);
-	kstat_cpu(cpu).irqs[irq]++;
+	kstat_irqs_this_cpu(desc)++;
 
 	/*
 	 * If its disabled or no action available
@@ -442,8 +439,6 @@ out:
 void fastcall
 handle_edge_irq(unsigned int irq, struct irq_desc *desc)
 {
-	const unsigned int cpu = smp_processor_id();
-
 	spin_lock(&desc->lock);
 
 	desc->status &= ~(IRQ_REPLAY | IRQ_WAITING);
@@ -460,7 +455,7 @@ handle_edge_irq(unsigned int irq, struct irq_desc *desc)
 		goto out_unlock;
 	}
 
-	kstat_cpu(cpu).irqs[irq]++;
+	kstat_irqs_this_cpu(desc)++;
 
 	/* Start handling the irq */
 	desc->chip->ack(irq);
@@ -516,7 +511,7 @@ handle_percpu_irq(unsigned int irq, struct irq_desc *desc)
 {
 	irqreturn_t action_ret;
 
-	kstat_this_cpu.irqs[irq]++;
+	kstat_irqs_this_cpu(desc)++;
 
 	if (desc->chip->ack)
 		desc->chip->ack(irq);
diff --git a/kernel/irq/handle.c b/kernel/irq/handle.c
index aff1f0f..27cf665 100644
--- a/kernel/irq/handle.c
+++ b/kernel/irq/handle.c
@@ -15,6 +15,7 @@
 #include <linux/random.h>
 #include <linux/interrupt.h>
 #include <linux/kernel_stat.h>
+#include <linux/bootmem.h>
 
 #include "internals.h"
 
@@ -30,7 +31,7 @@ void fastcall
 handle_bad_irq(unsigned int irq, struct irq_desc *desc)
 {
 	print_irq_desc(irq, desc);
-	kstat_this_cpu.irqs[irq]++;
+	kstat_irqs_this_cpu(desc)++;
 	ack_bad_irq(irq);
 }
 
@@ -170,7 +171,7 @@ fastcall unsigned int __do_IRQ(unsigned int irq)
 	struct irqaction *action;
 	unsigned int status;
 
-	kstat_this_cpu.irqs[irq]++;
+	kstat_irqs_this_cpu(desc)++;
 	if (CHECK_IRQ_PER_CPU(desc->status)) {
 		irqreturn_t action_ret;
 
@@ -269,3 +270,27 @@ void early_init_irq_lock_class(void)
 }
 
 #endif
+
+__init void init_kstat_irqs(void)
+{
+	unsigned entries = 0, cpu;
+	unsigned int irq;
+	unsigned bytes;
+
+	/* Compute the worst case size of a per cpu array */
+	for_each_possible_cpu(cpu)
+		if (cpu >= entries)
+			entries = cpu + 1;
+
+	/* Compute how many bytes we need per irq and allocate them */
+	bytes = entries*sizeof(unsigned int);
+	for (irq = 0; irq < NR_IRQS; irq++)
+		irq_desc[irq].kstat_irqs = alloc_bootmem(bytes);
+}
+
+unsigned int kstat_irqs_cpu(unsigned int irq, int cpu)
+{
+	struct irq_desc *desc = irq_desc + irq;
+	return desc->kstat_irqs[cpu];
+}
+EXPORT_SYMBOL(kstat_irqs_cpu);
-- 
1.5.0.g53756
