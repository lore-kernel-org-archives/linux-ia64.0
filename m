From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 01 Mar 2001 07:12:35 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.2)
Message-Id: <marc-linux-ia64-105590693005226@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The latest IA-64 patch is now available at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

in file linux-2.4.2-ia64-010228.diff*

What's in this patch:

	- everything that was in the previous test patch, including:
		o cpu-state clearing on execve()
		o virtually mapped per-CPU data
		o clearing of "invalid partition" when lowering privilege level

	- sync with kernel v2.4.2

	- CONFIG_ITANIUM_PTCG is now turned on automatically for CPUs
	  newer than B2

	- lots of SN1 updates from Kanoj

	- add support for multiple interrupt domains (i.e., systems
	  where the interrupt vectors are not necessarily shared by
	  all CPUs)

	- perfmon update from Stephane

	- add Jack's ptc.g workaround fix and increase the ptc.g timeout
	  value

Note: since there were non-trivial changes to the kernel exit path, I
still consider this patch somewhat experimental.  It has worked very
well for me so far, but as always, ymmv and you may want to give it a
good workout before burning it on a cd or similar...

This kernel has been tested on 4-way Lion, 2-way Big Sur, and 1-way
Ski simulator.

Enjoy,

	--david

diff -urN --ignore-all-space linux-davidm/arch/ia64/config.in linux-2.4.2-l=
ia/arch/ia64/config.in
--- linux-davidm/arch/ia64/config.in	Wed Feb 28 22:20:34 2001
+++ linux-2.4.2-lia/arch/ia64/config.in	Wed Feb 28 14:43:27 2001
@@ -18,7 +18,6 @@
 comment 'General setup'
=20
 define_bool CONFIG_IA64 y
-define_int  CONFIG_IA64_L1_CACHE_SHIFT	6	# align cache-sensitive data stru=
cture to 64 bytes
=20
 define_bool CONFIG_ISA n
 define_bool CONFIG_EISA n
@@ -58,7 +57,12 @@
 	if [ "$CONFIG_ITANIUM_CSTEP_SPECIFIC" =3D "y" ]; then
 	  bool '   Enable Itanium C0-step specific code' CONFIG_ITANIUM_C0_SPECIF=
IC
 	fi
-	bool '  Enable use of global TLB purge instruction (ptc.g)' CONFIG_ITANIU=
M_PTCG
+	if [ "$CONFIG_ITANIUM_ASTEP_SPECIFIC" =3D "y" -o "$CONFIG_ITANIUM_B0_SPEC=
IFIC" =3D "y"
+	     -o "$CONFIG_ITANIUM_B1_SPECIFIC" =3D "y" -o "$CONFIG_ITANIUM_B2_SPEC=
IFIC" =3D "y" ]; then
+	  define_bool CONFIG_ITANIUM_PTCG n
+	else
+	  define_bool CONFIG_ITANIUM_PTCG y
+	fi
 fi
=20
 if [ "$CONFIG_IA64_DIG" =3D "y" ]; then
@@ -70,15 +74,11 @@
 	  define_bool CONFIG_PM y
 	  define_bool CONFIG_ACPI y
 	  define_bool CONFIG_ACPI_INTERPRETER y
+	define_int  CONFIG_IA64_L1_CACHE_SHIFT	6	# align cache-sensitive data str=
ucture to 64 bytes
 	fi
 fi
=20
 if [ "$CONFIG_IA64_SGI_SN1" =3D "y" ]; then
-	bool '  Enable use of global TLB purge instruction (ptc.g)' CONFIG_ITANIU=
M_PTCG
-	bool '  Enable Itanium B-step specific code' CONFIG_ITANIUM_BSTEP_SPECIFIC
-	if [ "$CONFIG_ITANIUM_BSTEP_SPECIFIC" =3D "y" ]; then
-	  bool '    Enable Itanium B0-step specific code' CONFIG_ITANIUM_B0_SPECI=
FIC
-	fi
 	bool '  Enable SGI Medusa Simulator Support' CONFIG_IA64_SGI_SN1_SIM
 	define_bool CONFIG_DEVFS_DEBUG y
 	define_bool CONFIG_DEVFS_FS y
@@ -90,6 +90,7 @@
 	define_int  CONFIG_CACHE_LINE_SHIFT 7
 	bool '  Enable DISCONTIGMEM support' CONFIG_DISCONTIGMEM
 	bool '	Enable NUMA support' CONFIG_NUMA
+	define_int  CONFIG_IA64_L1_CACHE_SHIFT	7	# align cache-sensitive data str=
ucture to 64 bytes
 fi
=20
 define_bool CONFIG_KCORE_ELF y	# On IA-64, we always want an ELF /proc/kco=
re.
@@ -242,6 +243,7 @@
   if [ "$CONFIG_SCSI" !=3D "n" ]; then
     bool 'Simulated SCSI disk' CONFIG_SCSI_SIM
   fi
+  define_int  CONFIG_IA64_L1_CACHE_SHIFT	6	# align cache-sensitive data st=
ructure to 64 bytes
   endmenu
 fi
=20
diff -urN --ignore-all-space linux-davidm/arch/ia64/hp/hpsim_irq.c linux-2.=
4.2-lia/arch/ia64/hp/hpsim_irq.c
--- linux-davidm/arch/ia64/hp/hpsim_irq.c	Thu Jun 22 07:09:44 2000
+++ linux-2.4.2-lia/arch/ia64/hp/hpsim_irq.c	Wed Feb 28 14:43:45 2001
@@ -1,8 +1,8 @@
 /*
  * Platform dependent support for HP simulator.
  *
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 #include <linux/init.h>
@@ -35,10 +35,12 @@
 void __init
 hpsim_irq_init (void)
 {
+	irq_desc_t *idesc;
 	int i;
=20
-	for (i =3D IA64_MIN_VECTORED_IRQ; i <=3D IA64_MAX_VECTORED_IRQ; ++i) {
-		if (irq_desc[i].handler =3D &no_irq_type)
-			irq_desc[i].handler =3D &irq_type_hp_sim;
+	for (i =3D 0; i < NR_IRQS; ++i) {
+		idesc =3D irq_desc(i);
+		if (idesc->handler =3D &no_irq_type)
+			idesc->handler =3D &irq_type_hp_sim;
 	}
 }
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/brl_emu.c linux-=
2.4.2-lia/arch/ia64/kernel/brl_emu.c
--- linux-davidm/arch/ia64/kernel/brl_emu.c	Wed Feb 28 22:20:35 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/brl_emu.c	Wed Feb 28 14:44:20 2001
@@ -24,8 +24,8 @@
  *  or all 1's for the address to be valid.
  */
 #define unimplemented_virtual_address(va) (						\
-	((va) & current_cpu_data->unimpl_va_mask) !=3D 0 &&				\
-	((va) & current_cpu_data->unimpl_va_mask) !=3D current_cpu_data->unimpl_v=
a_mask	\
+	((va) & local_cpu_data->unimpl_va_mask) !=3D 0 &&					\
+	((va) & local_cpu_data->unimpl_va_mask) !=3D local_cpu_data->unimpl_va_ma=
sk	\
 )
=20
 /*
@@ -35,7 +35,7 @@
  *  address to be valid.
  */
 #define unimplemented_physical_address(pa) (		\
-	((pa) & current_cpu_data->unimpl_pa_mask) !=3D 0	\
+	((pa) & local_cpu_data->unimpl_pa_mask) !=3D 0	\
 )
=20
 /*
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/ia64_ksyms.c lin=
ux-2.4.2-lia/arch/ia64/kernel/ia64_ksyms.c
--- linux-davidm/arch/ia64/kernel/ia64_ksyms.c	Wed Feb 28 22:20:35 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/ia64_ksyms.c	Wed Feb 28 14:44:41 2001
@@ -24,8 +24,11 @@
 EXPORT_SYMBOL(strstr);
 EXPORT_SYMBOL(strtok);
=20
-#include <asm/hw_irq.h>
+#include <linux/irq.h>
 EXPORT_SYMBOL(isa_irq_to_vector_map);
+EXPORT_SYMBOL(enable_irq);
+EXPORT_SYMBOL(disable_irq);
+EXPORT_SYMBOL(disable_irq_nosync);
=20
 #include <linux/in6.h>
 #include <asm/checksum.h>
@@ -39,11 +42,6 @@
 EXPORT_SYMBOL(__ia64_memcpy_fromio);
 EXPORT_SYMBOL(__ia64_memcpy_toio);
 EXPORT_SYMBOL(__ia64_memset_c_io);
-
-#include <asm/irq.h>
-EXPORT_SYMBOL(enable_irq);
-EXPORT_SYMBOL(disable_irq);
-EXPORT_SYMBOL(disable_irq_nosync);
=20
 #include <asm/semaphore.h>
 EXPORT_SYMBOL_NOVERS(__down);
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/iosapic.c linux-=
2.4.2-lia/arch/ia64/kernel/iosapic.c
--- linux-davidm/arch/ia64/kernel/iosapic.c	Wed Feb 28 22:20:35 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/iosapic.c	Wed Feb 28 14:44:51 2001
@@ -83,7 +83,7 @@
 	unsigned char dmode 	: 3;	/* delivery mode (see iosapic.h) */
 	unsigned char polarity	: 1;	/* interrupt polarity (see iosapic.h) */
 	unsigned char trigger	: 1;	/* trigger mode (see iosapic.h) */
-} iosapic_irq[NR_IRQS];
+} iosapic_irq[IA64_NUM_VECTORS];
=20
 /*
  * Translate IOSAPIC irq number to the corresponding IA-64 interrupt vecto=
r.  If no
@@ -94,7 +94,7 @@
 {
 	int vector;
=20
-	for (vector =3D 0; vector < NR_IRQS; ++vector)
+	for (vector =3D 0; vector < IA64_NUM_VECTORS; ++vector)
 		if (iosapic_irq[vector].base_irq + iosapic_irq[vector].pin =3D irq)
 			return vector;
 	return -1;
@@ -153,15 +153,16 @@
 }
=20
 static void=20
-mask_irq (unsigned int vector)
+mask_irq (unsigned int irq)
 {
 	unsigned long flags;
 	char *addr;
 	u32 low32;
 	int pin;
+	ia64_vector vec =3D irq_to_vector(irq);
=20
-	addr =3D iosapic_irq[vector].addr;
-	pin =3D iosapic_irq[vector].pin;
+	addr =3D iosapic_irq[vec].addr;
+	pin =3D iosapic_irq[vec].pin;
=20
 	if (pin < 0)
 		return;			/* not an IOSAPIC interrupt! */
@@ -178,15 +179,16 @@
 }
=20
 static void=20
-unmask_irq (unsigned int vector)
+unmask_irq (unsigned int irq)
 {
 	unsigned long flags;
 	char *addr;
 	u32 low32;
 	int pin;
+	ia64_vector vec =3D irq_to_vector(irq);
=20
-	addr =3D iosapic_irq[vector].addr;
-	pin =3D iosapic_irq[vector].pin;
+	addr =3D iosapic_irq[vec].addr;
+	pin =3D iosapic_irq[vec].pin;
 	if (pin < 0)
 		return;			/* not an IOSAPIC interrupt! */
=20
@@ -203,7 +205,7 @@
=20
=20
 static void
-iosapic_set_affinity (unsigned int vector, unsigned long mask)
+iosapic_set_affinity (unsigned int irq, unsigned long mask)
 {
 	printk("iosapic_set_affinity: not implemented yet\n");
 }
@@ -213,16 +215,18 @@
  */
=20
 static unsigned int
-iosapic_startup_level_irq (unsigned int vector)
+iosapic_startup_level_irq (unsigned int irq)
 {
-	unmask_irq(vector);
+	unmask_irq(irq);
 	return 0;
 }
=20
 static void
-iosapic_end_level_irq (unsigned int vector)
+iosapic_end_level_irq (unsigned int irq)
 {
-	writel(vector, iosapic_irq[vector].addr + IOSAPIC_EOI);
+	ia64_vector vec =3D irq_to_vector(irq);
+
+	writel(vec, iosapic_irq[vec].addr + IOSAPIC_EOI);
 }
=20
 #define iosapic_shutdown_level_irq	mask_irq
@@ -246,9 +250,9 @@
  */
=20
 static unsigned int
-iosapic_startup_edge_irq (unsigned int vector)
+iosapic_startup_edge_irq (unsigned int irq)
 {
-	unmask_irq(vector);
+	unmask_irq(irq);
 	/*
 	 * IOSAPIC simply drops interrupts pended while the
 	 * corresponding pin was masked, so we can't know if an
@@ -258,15 +262,16 @@
 }
=20
 static void
-iosapic_ack_edge_irq (unsigned int vector)
+iosapic_ack_edge_irq (unsigned int irq)
 {
+	irq_desc_t *idesc =3D irq_desc(irq);
 	/*
 	 * Once we have recorded IRQ_PENDING already, we can mask the
 	 * interrupt for real. This prevents IRQ storms from unhandled
 	 * devices.
 	 */
-	if ((irq_desc[vector].status & (IRQ_PENDING|IRQ_DISABLED)) =3D (IRQ_PENDI=
NG|IRQ_DISABLED))
-		mask_irq(vector);
+	if ((idesc->status & (IRQ_PENDING|IRQ_DISABLED)) =3D (IRQ_PENDING|IRQ_DIS=
ABLED))
+		mask_irq(irq);
 }
=20
 #define iosapic_enable_edge_irq		unmask_irq
@@ -329,6 +334,7 @@
 {
 	struct hw_interrupt_type *irq_type;
 	int i, irq, max_pin, vector;
+	irq_desc_t *idesc;
 	unsigned int ver;
 	char *addr;
 	static int first_time =3D 1;
@@ -336,7 +342,7 @@
 	if (first_time) {
 		first_time =3D 0;
=20
-		for (vector =3D 0; vector < NR_IRQS; ++vector)
+		for (vector =3D 0; vector < IA64_NUM_VECTORS; ++vector)
 			iosapic_irq[vector].pin =3D -1;	/* mark as unused */
=20
 		/*=20
@@ -380,12 +386,13 @@
 			       vector);
 #endif
 		  	irq_type =3D &irq_type_iosapic_edge;
-			if (irq_desc[vector].handler !=3D irq_type) {
-				if (irq_desc[vector].handler !=3D &no_irq_type)
+			idesc =3D irq_desc(vector);
+			if (idesc->handler !=3D irq_type) {
+				if (idesc->handler !=3D &no_irq_type)
 					printk("iosapic_init: changing vector 0x%02x from %s to "
-					       "%s\n", irq, irq_desc[vector].handler->typename,
+					       "%s\n", irq, idesc->handler->typename,
 					       irq_type->typename);
-				irq_desc[vector].handler =3D irq_type;
+				idesc->handler =3D irq_type;
 			}
=20
 			/* program the IOSAPIC routing table: */
@@ -421,12 +428,12 @@
 		       iosapic_irq[vector].base_irq + iosapic_irq[vector].pin, vector);
 # endif
 		irq_type =3D &irq_type_iosapic_level;
-		if (irq_desc[vector].handler !=3D irq_type){
-			if (irq_desc[vector].handler !=3D &no_irq_type)
+		idesc =3D irq_desc(vector);
+		if (idesc->handler !=3D irq_type){
+			if (idesc->handler !=3D &no_irq_type)
 				printk("iosapic_init: changing vector 0x%02x from %s to %s\n",
-				       vector, irq_desc[vector].handler->typename,
-				       irq_type->typename);
-			irq_desc[vector].handler =3D irq_type;
+				       vector, idesc->handler->typename, irq_type->typename);
+			idesc->handler =3D irq_type;
 		}
=20
 		/* program the IOSAPIC routing table: */
@@ -484,7 +491,7 @@
 		 * Nothing to fixup
 		 * Fix out-of-range IRQ numbers
 		 */
-		if (dev->irq >=3D NR_IRQS)
+		if (dev->irq >=3D IA64_NUM_VECTORS)
 			dev->irq =3D 15;	/* Spurious interrupts */
 	}
 }
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/irq.c linux-2.4.=
2-lia/arch/ia64/kernel/irq.c
--- linux-davidm/arch/ia64/kernel/irq.c	Wed Feb 28 12:57:33 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/irq.c	Wed Feb 28 14:45:11 2001
@@ -63,7 +63,7 @@
 /*
  * Controller mappings for all interrupt sources:
  */
-irq_desc_t irq_desc[NR_IRQS] __cacheline_aligned +irq_desc_t _irq_desc[NR_=
IRQS] __cacheline_aligned  	{ [0 ... NR_IRQS-1] =3D { IRQ_DISABLED, &no_irq=
_type, NULL, 0, SPIN_LOCK_UNLOCKED}};
=20
 static void register_irq_proc (unsigned int irq);
@@ -131,6 +131,7 @@
 {
 	int i, j;
 	struct irqaction * action;
+	irq_desc_t *idesc;
 	char *p =3D buf;
=20
 	p +=3D sprintf(p, "           ");
@@ -139,7 +140,8 @@
 	*p++ =3D '\n';
=20
 	for (i =3D 0 ; i < NR_IRQS ; i++) {
-		action =3D irq_desc[i].action;
+		idesc =3D irq_desc(i);
+		action =3D idesc->action;
 		if (!action)=20
 			continue;
 		p +=3D sprintf(p, "%3d: ",i);
@@ -150,7 +152,7 @@
 			p +=3D sprintf(p, "%10u ",
 				kstat.irqs[cpu_logical_map(j)][i]);
 #endif
-		p +=3D sprintf(p, " %14s", irq_desc[i].handler->typename);
+		p +=3D sprintf(p, " %14s", idesc->handler->typename);
 		p +=3D sprintf(p, "  %s", action->name);
=20
 		for (action=ACtion->next; action; action =3D action->next)
@@ -193,10 +195,10 @@
 	printk("\n%s, CPU %d:\n", str, cpu);
 	printk("irq:  %d [",irqs_running());
 	for(i=3D0;i < smp_num_cpus;i++)
-		printk(" %d",local_irq_count(i));
+		printk(" %d",irq_count(i));
 	printk(" ]\nbh:   %d [",spin_is_locked(&global_bh_lock) ? 1 : 0);
 	for(i=3D0;i < smp_num_cpus;i++)
-		printk(" %d",local_bh_count(i));
+		printk(" %d",bh_count(i));
=20
 	printk(" ]\nStack dumps:");
 #if defined(__ia64__)
@@ -266,7 +268,7 @@
 # endif
 #endif
=20
-static inline void wait_on_irq(int cpu)
+static inline void wait_on_irq(void)
 {
 	int count =3D MAXCOUNT;
=20
@@ -278,7 +280,7 @@
 		 * already executing in one..
 		 */
 		if (!irqs_running())
-			if (local_bh_count(cpu) || !spin_is_locked(&global_bh_lock))
+			if (local_bh_count() || !spin_is_locked(&global_bh_lock))
 				break;
=20
 		/* Duh, we have to loop. Release the lock to avoid deadlocks */
@@ -290,13 +292,13 @@
 				count =3D ~0;
 			}
 			__sti();
-			SYNC_OTHER_CORES(cpu);
+			SYNC_OTHER_CORES(smp_processor_id());
 			__cli();
 			if (irqs_running())
 				continue;
 			if (global_irq_lock)
 				continue;
-			if (!local_bh_count(cpu) && spin_is_locked(&global_bh_lock))
+			if (!local_bh_count() && spin_is_locked(&global_bh_lock))
 				continue;
 			if (!test_and_set_bit(0,&global_irq_lock))
 				break;
@@ -320,11 +322,11 @@
 	}
 }
=20
-static inline void get_irqlock(int cpu)
+static inline void get_irqlock(void)
 {
 	if (test_and_set_bit(0,&global_irq_lock)) {
 		/* do we already hold the lock? */
-		if (cpu =3D global_irq_holder)
+		if (smp_processor_id() =3D global_irq_holder)
 			return;
 		/* Uhhuh.. Somebody else got it. Wait.. */
 		do {
@@ -336,12 +338,12 @@
 	 * We also to make sure that nobody else is running
 	 * in an interrupt context.=20
 	 */
-	wait_on_irq(cpu);
+	wait_on_irq();
=20
 	/*
 	 * Ok, finally..
 	 */
-	global_irq_holder =3D cpu;
+	global_irq_holder =3D smp_processor_id();
 }
=20
 #define EFLAGS_IF_SHIFT 9
@@ -365,28 +367,24 @@
 #ifdef __ia64__
 	__save_flags(flags);
 	if (flags & IA64_PSR_I) {
-		int cpu =3D smp_processor_id();
 		__cli();
-		if (!local_irq_count(cpu))
-			get_irqlock(cpu);
+		if (!local_irq_count())
+			get_irqlock();
 	}
 #else
 	__save_flags(flags);
 	if (flags & (1 << EFLAGS_IF_SHIFT)) {
-		int cpu =3D smp_processor_id();
 		__cli();
-		if (!local_irq_count(cpu))
-			get_irqlock(cpu);
+		if (!local_irq_count())
+			get_irqlock();
 	}
 #endif
 }
=20
 void __global_sti(void)
 {
-	int cpu =3D smp_processor_id();
-
-	if (!local_irq_count(cpu))
-		release_irqlock(cpu);
+	if (!local_irq_count())
+		release_irqlock(smp_processor_id());
 	__sti();
 }
=20
@@ -414,7 +412,7 @@
 	retval =3D 2 + local_enabled;
=20
 	/* check for global flags if we're not in an interrupt */
-	if (!local_irq_count(cpu)) {
+	if (!local_irq_count()) {
 		if (local_enabled)
 			retval =3D 1;
 		if (global_irq_holder =3D cpu)
@@ -456,9 +454,8 @@
 int handle_IRQ_event(unsigned int irq, struct pt_regs * regs, struct irqac=
tion * action)
 {
 	int status;
-	int cpu =3D smp_processor_id();
=20
-	irq_enter(cpu, irq);
+	local_irq_enter(irq);
=20
 	status =3D 1;	/* Force the "do bottom halves" bit */
=20
@@ -474,7 +471,7 @@
 		add_interrupt_randomness(irq);
 	__cli();
=20
-	irq_exit(cpu, irq);
+	local_irq_exit(irq);
=20
 	return status;
 }
@@ -487,7 +484,7 @@
  */
 void inline disable_irq_nosync(unsigned int irq)
 {
-	irq_desc_t *desc =3D irq_desc + irq;
+	irq_desc_t *desc =3D irq_desc(irq);
 	unsigned long flags;
=20
 	spin_lock_irqsave(&desc->lock, flags);
@@ -507,17 +504,17 @@
 	disable_irq_nosync(irq);
=20
 #ifdef CONFIG_SMP
-	if (!local_irq_count(smp_processor_id())) {
+	if (!local_irq_count()) {
 		do {
 			barrier();
-		} while (irq_desc[irq].status & IRQ_INPROGRESS);
+		} while (irq_desc(irq)->status & IRQ_INPROGRESS);
 	}
 #endif
 }
=20
 void enable_irq(unsigned int irq)
 {
-	irq_desc_t *desc =3D irq_desc + irq;
+	irq_desc_t *desc =3D irq_desc(irq);
 	unsigned long flags;
=20
 	spin_lock_irqsave(&desc->lock, flags);
@@ -541,18 +538,6 @@
 	spin_unlock_irqrestore(&desc->lock, flags);
 }
=20
-void do_IRQ_per_cpu(unsigned long irq, struct pt_regs *regs)
-{
-	irq_desc_t *desc =3D irq_desc + irq;
-	int cpu =3D smp_processor_id();
-
-	kstat.irqs[cpu][irq]++;
-
-	desc->handler->ack(irq);
-	handle_IRQ_event(irq, regs, desc->action);
-	desc->handler->end(irq);
-}
-
 /*
  * do_IRQ handles all normal device IRQ's (the special
  * SMP cross-CPU interrupts have their own specific
@@ -571,16 +556,23 @@
 	 * handled by some other CPU. (or is disabled)
 	 */
 	int cpu =3D smp_processor_id();
-	irq_desc_t *desc =3D irq_desc + irq;
+	irq_desc_t *desc =3D irq_desc(irq);
 	struct irqaction * action;
 	unsigned int status;
=20
 	kstat.irqs[cpu][irq]++;
+
+	if (desc->status & IRQ_PER_CPU) {
+		/* no locking required for CPU-local interrupts: */
+		desc->handler->ack(irq);
+		handle_IRQ_event(irq, regs, desc->action);
+		desc->handler->end(irq);
+	} else {
 	spin_lock(&desc->lock);
 	desc->handler->ack(irq);
 	/*
-	   REPLAY is when Linux resends an IRQ that was dropped earlier
-	   WAITING is used by probe to mark irqs that are being tested
+		 * REPLAY is when Linux resends an IRQ that was dropped earlier
+		 * WAITING is used by probe to mark irqs that are being tested
 	   */
 	status =3D desc->status & ~(IRQ_REPLAY | IRQ_WAITING);
 	status |=3D IRQ_PENDING; /* we _want_ to handle it */
@@ -633,7 +625,7 @@
 	 */
 	desc->handler->end(irq);
 	spin_unlock(&desc->lock);
-
+	}
 	return 1;
 }
=20
@@ -655,7 +647,7 @@
 	 */
 	if (irqflags & SA_SHIRQ) {
 		if (!dev_id)
-			printk("Bad boy: %s (at 0x%x) called us without a dev_id!\n", devname, =
(&irq)[-1]);
+			printk("Bad boy: %s called us without a dev_id!\n", devname);
 	}
 #endif
=20
@@ -691,7 +683,7 @@
 	if (irq >=3D NR_IRQS)
 		return;
=20
-	desc =3D irq_desc + irq;
+	desc =3D irq_desc(irq);
 	spin_lock_irqsave(&desc->lock,flags);
 	p =3D &desc->action;
 	for (;;) {
@@ -744,11 +736,11 @@
 	 * flush such a longstanding irq before considering it as spurious.=20
 	 */
 	for (i =3D NR_IRQS-1; i > 0; i--)  {
-		desc =3D irq_desc + i;
+		desc =3D irq_desc(i);
=20
 		spin_lock_irq(&desc->lock);
-		if (!irq_desc[i].action)=20
-			irq_desc[i].handler->startup(i);
+		if (!desc->action)
+			desc->handler->startup(i);
 		spin_unlock_irq(&desc->lock);
 	}
=20
@@ -762,7 +754,7 @@
 	 * happened in the previous stage, it may have masked itself)
 	 */
 	for (i =3D NR_IRQS-1; i > 0; i--) {
-		desc =3D irq_desc + i;
+		desc =3D irq_desc(i);
=20
 		spin_lock_irq(&desc->lock);
 		if (!desc->action) {
@@ -784,7 +776,7 @@
 	 */
 	val =3D 0;
 	for (i =3D 0; i < NR_IRQS; i++) {
-		irq_desc_t *desc =3D irq_desc + i;
+		irq_desc_t *desc =3D irq_desc(i);
 		unsigned int status;
=20
 		spin_lock_irq(&desc->lock);
@@ -816,7 +808,7 @@
=20
 	mask =3D 0;
 	for (i =3D 0; i < 16; i++) {
-		irq_desc_t *desc =3D irq_desc + i;
+		irq_desc_t *desc =3D irq_desc(i);
 		unsigned int status;
=20
 		spin_lock_irq(&desc->lock);
@@ -846,7 +838,7 @@
 	nr_irqs =3D 0;
 	irq_found =3D 0;
 	for (i =3D 0; i < NR_IRQS; i++) {
-		irq_desc_t *desc =3D irq_desc + i;
+		irq_desc_t *desc =3D irq_desc(i);
 		unsigned int status;
=20
 		spin_lock_irq(&desc->lock);
@@ -869,13 +861,12 @@
 	return irq_found;
 }
=20
-/* this was setup_x86_irq but it seems pretty generic */
 int setup_irq(unsigned int irq, struct irqaction * new)
 {
 	int shared =3D 0;
 	unsigned long flags;
 	struct irqaction *old, **p;
-	irq_desc_t *desc =3D irq_desc + irq;
+	irq_desc_t *desc =3D irq_desc(irq);
=20
 	/*
 	 * Some drivers like serial.c use request_irq() heavily,
@@ -986,7 +977,7 @@
 	int irq =3D (long) data, full_count =3D count, err;
 	unsigned long new_value;
=20
-	if (!irq_desc[irq].handler->set_affinity)
+	if (!irq_desc(irq)->handler->set_affinity)
 		return -EIO;
=20
 	err =3D parse_hex_value(buffer, count, &new_value);
@@ -1002,7 +993,7 @@
 #endif
=20
 	irq_affinity[irq] =3D new_value;
-	irq_desc[irq].handler->set_affinity(irq, new_value);
+	irq_desc(irq)->handler->set_affinity(irq, new_value);
=20
 	return full_count;
 }
@@ -1037,7 +1028,7 @@
 	struct proc_dir_entry *entry;
 	char name [MAX_NAMELEN];
=20
-	if (!root_irq_dir || (irq_desc[irq].handler =3D &no_irq_type))
+	if (!root_irq_dir || (irq_desc(irq)->handler =3D &no_irq_type))
 		return;
=20
 	memset(name, 0, MAX_NAMELEN);
@@ -1079,9 +1070,8 @@
 	 * Create entries for all existing IRQs.
 	 */
 	for (i =3D 0; i < NR_IRQS; i++) {
-		if (irq_desc[i].handler =3D &no_irq_type)
+		if (irq_desc(i)->handler =3D &no_irq_type)
 			continue;
 		register_irq_proc(i);
 	}
 }
-
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/irq_ia64.c linux=
-2.4.2-lia/arch/ia64/kernel/irq_ia64.c
--- linux-davidm/arch/ia64/kernel/irq_ia64.c	Wed Feb 28 22:20:35 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/irq_ia64.c	Wed Feb 28 14:45:47 2001
@@ -39,7 +39,7 @@
 #define IRQ_DEBUG	0
=20
 /* default base addr of IPI table */
-unsigned long ipi_base_addr =3D (__IA64_UNCACHED_OFFSET | IPI_DEFAULT_BASE=
_ADDR);=09
+unsigned long ipi_base_addr =3D (__IA64_UNCACHED_OFFSET | IA64_IPI_DEFAULT=
_BASE_ADDR);
=20
 /*
  * Legacy IRQ to IA-64 vector translation table.
@@ -53,9 +53,9 @@
 int
 ia64_alloc_irq (void)
 {
-	static int next_irq =3D FIRST_DEVICE_IRQ;
+	static int next_irq =3D IA64_FIRST_DEVICE_VECTOR;
=20
-	if (next_irq > LAST_DEVICE_IRQ)
+	if (next_irq > IA64_LAST_DEVICE_VECTOR)
 		/* XXX could look for sharable vectors instead of panic'ing... */
 		panic("ia64_alloc_irq: out of interrupt vectors!");
 	return next_irq++;
@@ -67,7 +67,7 @@
  * function ptr.
  */
 void
-ia64_handle_irq (unsigned long vector, struct pt_regs *regs)
+ia64_handle_irq (ia64_vector vector, struct pt_regs *regs)
 {
 	unsigned long saved_tpr;
=20
@@ -109,19 +109,10 @@
 	saved_tpr =3D ia64_get_tpr();
 	ia64_srlz_d();
 	do {
-		if (vector >=3D NR_IRQS) {
-			printk("handle_irq: invalid vector %lu\n", vector);
-			ia64_set_tpr(saved_tpr);
-			ia64_srlz_d();
-			return;
-		}
 		ia64_set_tpr(vector);
 		ia64_srlz_d();
=20
-		if ((irq_desc[vector].status & IRQ_PER_CPU) !=3D 0)
-			do_IRQ_per_cpu(vector, regs);
-		else
-			do_IRQ(vector, regs);
+		do_IRQ(local_vector_to_irq(vector), regs);
=20
 		/*
 		 * Disable interrupts and send EOI:
@@ -130,7 +121,7 @@
 		ia64_set_tpr(saved_tpr);
 		ia64_eoi();
 		vector =3D ia64_get_ivr();
-	} while (vector !=3D IA64_SPURIOUS_INT);
+	} while (vector !=3D IA64_SPURIOUS_INT_VECTOR);
 }
=20
 #ifdef CONFIG_SMP
@@ -144,18 +135,27 @@
 };
 #endif
=20
+void
+register_percpu_irq (ia64_vector vec, struct irqaction *action)
+{
+	irq_desc_t *desc;
+	unsigned int irq;
+
+	for (irq =3D 0; irq < NR_IRQS; ++irq)
+		if (irq_to_vector(irq) =3D vec) {
+			desc =3D irq_desc(irq);
+			desc->status |=3D IRQ_PER_CPU;
+			desc->handler =3D &irq_type_ia64_sapic;
+			if (action)
+				setup_irq(irq, action);
+		}
+}
+
 void __init
 init_IRQ (void)
 {
-	irq_desc[IA64_SPURIOUS_INT].handler =3D &irq_type_ia64_sapic;
-#ifdef CONFIG_SMP
-	/*=20
-	 * Configure the IPI vector and handler
-	 */
-	irq_desc[IPI_IRQ].status |=3D IRQ_PER_CPU;
-	irq_desc[IPI_IRQ].handler =3D &irq_type_ia64_sapic;
-	setup_irq(IPI_IRQ, &ipi_irqaction);
-#endif
+	register_percpu_irq(IA64_SPURIOUS_INT_VECTOR, NULL);
+	register_percpu_irq(IA64_IPI_VECTOR, &ipi_irqaction);
 	platform_irq_init();
 }
=20
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/mca.c linux-2.4.=
2-lia/arch/ia64/kernel/mca.c
--- linux-davidm/arch/ia64/kernel/mca.c	Wed Feb 28 22:20:35 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/mca.c	Wed Feb 28 14:46:08 2001
@@ -235,7 +235,7 @@
 	/* Register the rendezvous interrupt vector with SAL */
 	if (ia64_sal_mc_set_params(SAL_MC_PARAM_RENDEZ_INT,
 				   SAL_MC_PARAM_MECHANISM_INT,
-				   IA64_MCA_RENDEZ_INT_VECTOR,
+				   IA64_MCA_RENDEZ_VECTOR,
 				   IA64_MCA_RENDEZ_TIMEOUT,
 				   0))
 		return;
@@ -243,7 +243,7 @@
 	/* Register the wakeup interrupt vector with SAL */
 	if (ia64_sal_mc_set_params(SAL_MC_PARAM_RENDEZ_WAKEUP,
 				   SAL_MC_PARAM_MECHANISM_INT,
-				   IA64_MCA_WAKEUP_INT_VECTOR,
+				   IA64_MCA_WAKEUP_VECTOR,
 				   0,
 				   0))
 		return;
@@ -252,8 +252,7 @@
 	/*
 	 * Setup the correctable machine check vector
 	 */
-	ia64_mca_cmc_vector_setup(IA64_CMC_INT_ENABLE,=20
-				  IA64_MCA_CMC_INT_VECTOR);
+	ia64_mca_cmc_vector_setup(IA64_CMC_INT_ENABLE, IA64_CMC_VECTOR);
=20
 	IA64_MCA_DEBUG("ia64_mca_init : correctable mca vector setup done\n");
=20
@@ -334,8 +333,8 @@
 void
 ia64_mca_wakeup_ipi_wait(void)
 {
-	int	irr_num =3D (IA64_MCA_WAKEUP_INT_VECTOR >> 6);
-	int	irr_bit =3D (IA64_MCA_WAKEUP_INT_VECTOR & 0x3f);
+	int	irr_num =3D (IA64_MCA_WAKEUP_VECTOR >> 6);
+	int	irr_bit =3D (IA64_MCA_WAKEUP_VECTOR & 0x3f);
 	u64	irr =3D 0;
=20
 	do {
@@ -368,9 +367,8 @@
 void
 ia64_mca_wakeup(int cpu)
 {
-	platform_send_ipi(cpu, IA64_MCA_WAKEUP_INT_VECTOR, IA64_IPI_DM_INT, 0);
+	platform_send_ipi(cpu, IA64_MCA_WAKEUP_VECTOR, IA64_IPI_DM_INT, 0);
 	ia64_mc_info.imi_rendez_checkin[cpu] =3D IA64_MCA_RENDEZ_CHECKIN_NOTDONE;
-=09
 }
 /*
  * ia64_mca_wakeup_all
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/perfmon.c linux-=
2.4.2-lia/arch/ia64/kernel/perfmon.c
--- linux-davidm/arch/ia64/kernel/perfmon.c	Wed Feb 28 22:20:36 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/perfmon.c	Wed Feb 28 14:46:32 2001
@@ -7,7 +7,7 @@
  * Modifications by Stephane Eranian, Hewlett-Packard Co.
  * Copyright (C) 1999 Ganesh Venkitachalam <venkitac@us.ibm.com>
  * Copyright (C) 1999 David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 2000 Stephane Eranian <eranian@hpl.hp.com>
+ * Copyright (C) 2000-2001 Stephane Eranian <eranian@hpl.hp.com>
  */
=20
 #include <linux/config.h>
@@ -34,6 +34,7 @@
 #include <asm/system.h>
 #include <asm/system.h>
 #include <asm/uaccess.h>
+#include <asm/delay.h> /* for ia64_get_itc() */
=20
 #ifdef CONFIG_PERFMON
=20
@@ -299,12 +300,10 @@
 static inline unsigned long
 perfmon_get_stamp(void)
 {
-	unsigned long tmp;
-
-	/* XXX: need more to adjust for Itanium itc bug */
-	__asm__ __volatile__("mov %0=3Dar.itc" : "=3Dr"(tmp) :: "memory");
-
-	return tmp;
+	/*
+	 * XXX: maybe find something more efficient
+	 */
+	return ia64_get_itc();
 }
=20
 /* Given PGD from the address space's page table, return the kernel
@@ -340,16 +339,12 @@
 static inline unsigned long=20
 kvirt_to_pa(unsigned long adr)
 {
-	unsigned long va, kva, ret;
-
-	va =3D VMALLOC_VMADDR(adr);
-	kva =3D uvirt_to_kva(pgd_offset_k(va), va);
-	ret =3D __pa(kva);
-	DBprintk(("kv2pa(%lx-->%lx)\n", adr, ret));
-	return ret;
+	__u64 pa;
+	__asm__ __volatile__ ("tpa %0 =3D %1" : "=3Dr"(pa) : "r"(adr) : "memory");
+	DBprintk(("kv2pa(%lx-->%lx)\n", adr, pa));
+	return pa;
 }
=20
-
 static void *
 rvmalloc(unsigned long size)
 {
@@ -456,13 +451,11 @@
 	pfm_smpl_buffer_desc_t *psb;
=20
 	regcount =3D pfm_smpl_entry_size(&which_pmds, 1);
-	/*
-	 * ask for a sampling buffer but nothing to record !
+
+	/* note that regcount might be 0, in this case only the header for each
+	 * entry will be recorded.
 	 */
-	if (regcount =3D 0) {
-		DBprintk((" no pmds to record\n"));
-		return -EINVAL;
-	}
+
 	/*
 	 * 1 buffer hdr and for each entry a header + regcount PMDs to save
 	 */
@@ -509,7 +502,7 @@
=20
 	psb->psb_entry_size =3D sizeof(perfmon_smpl_entry_t) + regcount*sizeof(u6=
4);
=20
-	DBprintk((" psb @%p entry_size=3D%ld hdr=3D%p addr=3D%p\n", psb,psb->psb_=
entry_size, psb->psb_hdr, psb->psb_addr));=20
+	DBprintk((" psb @%p entry_size=3D%ld hdr=3D%p addr=3D%p\n", (void *)psb,p=
sb->psb_entry_size, (void *)psb->psb_hdr, (void *)psb->psb_addr));
=20
 	/* initialize some of the fields of header */
 	psb->psb_hdr->hdr_version    =3D PFM_SMPL_HDR_VERSION;
@@ -596,7 +589,7 @@
 	pfm_context_t *ctx;
         perfmon_req_t tmp;
 	void *uaddr =3D NULL;
-	int ret =3D -EINVAL;
+	int ret =3D -EFAULT;
 	int ctx_flags;
=20
 	/* to go away */
@@ -604,7 +597,7 @@
 		printk("perfmon: use context flags instead of perfmon() flags. Obsoleted=
 API\n");
 	}
=20
-	copy_from_user(&tmp, req, sizeof(tmp));
+	if (copy_from_user(&tmp, req, sizeof(tmp))) return -EFAULT;
=20
 	ctx_flags =3D tmp.pfr_ctx.flags;
=20
@@ -635,11 +628,10 @@
=20
 	sema_init(&ctx->ctx_restart_sem, 0); /* init this semaphore to locked */ =

=20
-	/* XXX fixme take care of errors here */
-	copy_to_user(req, &tmp, sizeof(tmp));
+	if (copy_to_user(req, &tmp, sizeof(tmp))) goto buffer_error;
=20
-	DBprintk((" context=3D%p, pid=3D%d notify_sig %d notify_pid=3D%d\n",ctx, =
task->pid, ctx->ctx_notify_sig, ctx->ctx_notify_pid));
-	DBprintk((" context=3D%p, pid=3D%d flags=3D0x%x inherit=3D%d noblock=3D%d=
 system=3D%d\n",ctx, task->pid, ctx_flags, ctx->ctx_fl_inherit, ctx->ctx_fl=
_noblock, ctx->ctx_fl_system));
+	DBprintk((" context=3D%p, pid=3D%d notify_sig %d notify_pid=3D%d\n",(void=
 *)ctx, task->pid, ctx->ctx_notify_sig, ctx->ctx_notify_pid));
+	DBprintk((" context=3D%p, pid=3D%d flags=3D0x%x inherit=3D%d noblock=3D%d=
 system=3D%d\n",(void *)ctx, task->pid, ctx_flags, ctx->ctx_fl_inherit, ctx=
->ctx_fl_noblock, ctx->ctx_fl_system));
=20
 	/* link with task */
 	task->thread.pfm_context =3D ctx;
@@ -685,7 +677,7 @@
=20
 	for (i =3D 0; i < count; i++, req++) {
=20
-		copy_from_user(&tmp, req, sizeof(tmp));
+		if (copy_from_user(&tmp, req, sizeof(tmp))) return -EFAULT;
=20
 		cnum =3D tmp.pfr_reg.reg_num;
=20
@@ -739,7 +731,7 @@
 	for (i =3D 0; i < count; i++, req++) {
 		int k;
=20
-		copy_from_user(&tmp, req, sizeof(tmp));
+		if (copy_from_user(&tmp, req, sizeof(tmp))) return -EFAULT;
=20
 		cnum =3D tmp.pfr_reg.reg_num;
=20
@@ -797,7 +789,7 @@
 	for (i =3D 0; i < count; i++, req++) {
 		int k;
=20
-		copy_from_user(&tmp, req, sizeof(tmp));
+		if (copy_from_user(&tmp, req, sizeof(tmp))) return -EFAULT;
=20
 		if (!PMD_IS_IMPL(tmp.pfr_reg.reg_num)) return -EINVAL;
=20
@@ -1124,8 +1116,13 @@
  * which can be restarted. That's why it's declared as a system call and a=
ll 8 possible args
  * are declared even though not used.
  */
+#if __GNUC__ >=3D 3
+void asmlinkage
+pfm_overflow_notify(void)
+#else
 void asmlinkage
 pfm_overflow_notify(u64 arg0, u64 arg1, u64 arg2, u64 arg3, u64 arg4, u64 =
arg5, u64 arg6, u64 arg7)
+#endif
 {
 	struct task_struct *task;
 	struct thread_struct *th =3D &current->thread;
@@ -1145,7 +1142,7 @@
 		return;
 	}
=20
-	DBprintk((" current=3D%d ctx=3D%p bv=3D0%lx\n", current->pid, ctx, ctx->c=
tx_ovfl_regs));
+	DBprintk((" current=3D%d ctx=3D%p bv=3D0%lx\n", current->pid, (void *)ctx=
, ctx->ctx_ovfl_regs));
 	/*
 	 * NO matter what notify_pid is,=20
 	 * we clear overflow, won't notify again
@@ -1179,7 +1176,7 @@
 		si.si_pid      =3D current->pid; /* who is sending */
 		si.si_pfm_ovfl =3D ctx->ctx_ovfl_regs;
=20
-		DBprintk((" SIGPROF to %d @ %p\n", task->pid, task));
+		DBprintk((" SIGPROF to %d @ %p\n", task->pid, (void *)task));
=20
 		/* must be done with tasklist_lock locked */
 		ret =3D send_sig_info(ctx->ctx_notify_sig, &si, task);
@@ -1279,7 +1276,7 @@
=20
 	task =3D find_task_by_pid(info->to_pid);
=20
-	DBprintk((" after find %p\n", task));
+	DBprintk((" after find %p\n", (void *)task));
=20
 	if (task) {
 		int ret;
@@ -1291,7 +1288,7 @@
 		si.si_pid      =3D info->from_pid; /* who is sending */
 		si.si_pfm_ovfl =3D info->bitvect;
=20
-		DBprintk((" SIGPROF to %d @ %p\n", task->pid, task));
+		DBprintk((" SIGPROF to %d @ %p\n", task->pid, (void *)task));
=20
 		/* must be done with tasklist_lock locked */
 		ret =3D send_sig_info(SIGPROF, &si, task);
@@ -1305,7 +1302,7 @@
=20
 	read_unlock(&tasklist_lock);
=20
-	DBprintk((" after unlock %p\n", task));
+	DBprintk((" after unlock %p\n", (void *)task));
=20
 	if (!task) {=20
 		printk("perfmon: CPU%d cannot find process %d\n", smp_processor_id(), in=
fo->to_pid);
@@ -1419,7 +1416,7 @@
 					    + (ia64_get_pmd(j) & pmu_conf.perf_ovfl_val);
 				else
 					*e =3D ia64_get_pmd(j); /* slow */
-				DBprintk((" e=3D%p pmd%d =3D0x%lx\n", e, j, *e));=20
+				DBprintk((" e=3D%p pmd%d =3D0x%lx\n", (void *)e, j, *e));
 				e++;
 			}
 		}
@@ -1594,7 +1591,7 @@
 		ia64_set_pmc(0, pmc0);
 		ia64_srlz_d();
 	} else {
-		printk("perfmon: Spurious PMU overflow interrupt: pmc0=3D0x%lx owner=3D%=
p\n", pmc0, PMU_OWNER());
+		printk("perfmon: Spurious PMU overflow interrupt: pmc0=3D0x%lx owner=3D%=
p\n", pmc0, (void *)PMU_OWNER());
 	}
 }
=20
@@ -1643,17 +1640,15 @@
 	pal_perf_mon_info_u_t pm_info;
 	s64 status;
 =09
-	irq_desc[PERFMON_IRQ].status |=3D IRQ_PER_CPU;
-	irq_desc[PERFMON_IRQ].handler =3D &irq_type_ia64_sapic;
-	setup_irq(PERFMON_IRQ, &perfmon_irqaction);
+	register_percpu_irq(IA64_PERFMON_VECTOR, &perfmon_irqaction);
=20
-	ia64_set_pmv(PERFMON_IRQ);
+	ia64_set_pmv(IA64_PERFMON_VECTOR);
 	ia64_srlz_d();
=20
 	pmu_conf.pfm_is_disabled =3D 1;
=20
 	printk("perfmon: version %s\n", PFM_VERSION);
-	printk("perfmon: Interrupt vectored to %u\n", PERFMON_IRQ);
+	printk("perfmon: Interrupt vectored to %u\n", IA64_PERFMON_VECTOR);
=20
 	if ((status=3Dia64_pal_perf_mon_info(pmu_conf.impl_regs, &pm_info)) !=3D =
0) {
 		printk("perfmon: PAL call failed (%ld)\n", status);
@@ -1693,7 +1688,7 @@
 void
 perfmon_init_percpu (void)
 {
-	ia64_set_pmv(PERFMON_IRQ);
+	ia64_set_pmv(IA64_PERFMON_VECTOR);
 	ia64_srlz_d();
 }
=20
@@ -1738,7 +1733,7 @@
 	 * This will cause the interrupt handler to do nothing in case an overflow
 	 * interrupt was in-flight
 	 * This also guarantees that pmc0 will contain the final state=20
-	 * It virtually gives us full control on overflow processing from that po=
int
+	 * It virtually gives us full control over overflow processing from that =
point
 	 * on.
 	 * It must be an atomic operation.
 	 */
@@ -1771,7 +1766,7 @@
 	 * next time the task exits from the kernel.=20
 	 */
 	if (pmc0 & ~0x1) {
-		if (owner !=3D ta) printk(__FUNCTION__" owner=3D%p task=3D%p\n", owner, =
ta);
+		if (owner !=3D ta) printk(__FUNCTION__" owner=3D%p task=3D%p\n", (void *=
)owner, (void *)ta);
 		printk(__FUNCTION__" Warning: pmc[0]=3D0x%lx explicit call\n", pmc0);
=20
 		pmc0 =3D update_counters(owner, pmc0, NULL);
@@ -1931,7 +1926,7 @@
 	/*
 	 * restore PSR for context switch to save
 	 */
-	__asm__ __volatile__ ("mov psr.l=3D%0;;"::"r"(psr): "memory");
+	__asm__ __volatile__ ("mov psr.l=3D%0;;srlz.i;"::"r"(psr): "memory");
=20
 	/*=20
 	 * This loop flushes the PMD into the PFM context.
@@ -2054,7 +2049,7 @@
 	/* link with new task */
 	th->pfm_context     =3D nctx;
=20
-	DBprintk((" nctx=3D%p for process %d\n", nctx, task->pid));
+	DBprintk((" nctx=3D%p for process %d\n", (void *)nctx, task->pid));
=20
 	/*
 	 * the copy_thread routine automatically clears
@@ -2092,7 +2087,7 @@
 			DBprintk((" pid %d: cleaning task %d sampling buffer\n", current->pid, =
task->pid ));=20
 		}
 	}
-	DBprintk((" pid %d: task %d pfm_context is freed @%p\n", current->pid, ta=
sk->pid, ctx));=20
+	DBprintk((" pid %d: task %d pfm_context is freed @%p\n", current->pid, ta=
sk->pid, (void *)ctx));
 	pfm_context_free(ctx);
 }
=20
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/setup.c linux-2.=
4.2-lia/arch/ia64/kernel/setup.c
--- linux-davidm/arch/ia64/kernel/setup.c	Wed Feb 28 22:20:36 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/setup.c	Wed Feb 28 14:46:42 2001
@@ -263,8 +263,8 @@
 	ia64_mca_init();
 #endif
=20
-	paging_init();
 	platform_setup(cmdline_p);
+	paging_init();
 }
=20
 /*
@@ -417,7 +417,7 @@
=20
 	ia64_mmu_init();
=20
-	identify_cpu(current_cpu_data);
+	identify_cpu(local_cpu_data);
=20
 #ifdef	CONFIG_IA32_SUPPORT
 	/* initialize global ia32 state - CR0 and CR4 */
@@ -456,5 +456,5 @@
 		printk ("cpu_init: PAL RSE info failed, assuming 96 physical stacked reg=
s\n");
 		num_phys_stacked =3D 96;
 	}
-	current_cpu_data->phys_stacked_size_p8 =3D num_phys_stacked*8 + 8;
+	local_cpu_data->phys_stacked_size_p8 =3D num_phys_stacked*8 + 8;
 }
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/smp.c linux-2.4.=
2-lia/arch/ia64/kernel/smp.c
--- linux-davidm/arch/ia64/kernel/smp.c	Wed Feb 28 22:20:36 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/smp.c	Wed Feb 28 14:47:26 2001
@@ -159,11 +159,11 @@
 void
 handle_IPI (int irq, void *dev_id, struct pt_regs *regs)
 {
-	unsigned long *pending_ipis =3D &current_cpu_data->ipi_operation;
+	unsigned long *pending_ipis =3D &local_cpu_data->ipi_operation;
 	unsigned long ops;
=20
 	/* Count this now; we may make a call that never returns. */
-	current_cpu_data->ipi_count++;
+	local_cpu_data->ipi_count++;
=20
 	mb();	/* Order interrupt and bit testing. */
 	while ((ops =3D xchg(pending_ipis, 0)) !=3D 0) {
@@ -278,7 +278,7 @@
 		return;
=20
 	set_bit(op, &cpu_data[dest_cpu].ipi_operation);
-	platform_send_ipi(dest_cpu, IPI_IRQ, IA64_IPI_DM_INT, 0);
+	platform_send_ipi(dest_cpu, IA64_IPI_VECTOR, IA64_IPI_DM_INT, 0);
 }
=20
 static inline void
@@ -320,11 +320,23 @@
 }
=20
 #ifndef CONFIG_ITANIUM_PTCG
+
 void
 smp_send_flush_tlb (void)
 {
 	send_IPI_allbutself(IPI_FLUSH_TLB);
 }
+
+void
+smp_resend_flush_tlb(void)
+{
+	/*
+	 * Really need a null IPI but since this rarely should happen & since thi=
s code
+	 * will go away, lets not add one.
+	 */
+	send_IPI_allbutself(IPI_RESCHEDULE);
+}
+
 #endif /* !CONFIG_ITANIUM_PTCG */
=20
 /*
@@ -427,7 +439,7 @@
 		int i;
 		for (i =3D 0; i < smp_num_cpus; i++) {
 			if (i !=3D smp_processor_id())
-				platform_send_ipi(i, IPI_IRQ, IA64_IPI_DM_INT, 0);
+				platform_send_ipi(i, IA64_IPI_VECTOR, IA64_IPI_DM_INT, 0);
 		}
 		goto retry;
 #else
@@ -460,8 +472,8 @@
 static inline void __init
 smp_setup_percpu_timer(void)
 {
-	current_cpu_data->prof_counter =3D 1;
-	current_cpu_data->prof_multiplier =3D 1;
+	local_cpu_data->prof_counter =3D 1;
+	local_cpu_data->prof_multiplier =3D 1;
 }
=20
 void
@@ -469,8 +481,8 @@
 {
 	int user =3D user_mode(regs);
=20
-	if (--current_cpu_data->prof_counter <=3D 0) {
-		current_cpu_data->prof_counter =3D current_cpu_data->prof_multiplier;
+	if (--local_cpu_data->prof_counter <=3D 0) {
+		local_cpu_data->prof_counter =3D local_cpu_data->prof_multiplier;
 		update_process_times(user);
 	}
 }
@@ -506,11 +518,10 @@
 #ifdef CONFIG_PERFMON
 	perfmon_init_percpu();
 #endif
-
 	local_irq_enable();		/* Interrupts have been off until now */
=20
 	calibrate_delay();
-	current_cpu_data->loops_per_jiffy =3D loops_per_jiffy;
+	local_cpu_data->loops_per_jiffy =3D loops_per_jiffy;
=20
 	/* allow the master to continue */
 	set_bit(cpu, &cpu_callin_map);
@@ -602,7 +613,7 @@
 	unsigned long bogosum;
=20
 	/* on the BP, the kernel already called calibrate_delay_loop() in init/ma=
in.c */
-	current_cpu_data->loops_per_jiffy =3D loops_per_jiffy;
+	local_cpu_data->loops_per_jiffy =3D loops_per_jiffy;
 #if 0
 	smp_tune_scheduling();
 #endif
@@ -680,7 +691,7 @@
  * Assume that CPU's have been discovered by some platform-dependant
  * interface.  For SoftSDV/Lion, that would be ACPI.
  *
- * Setup of the IPI irq handler is done in irq.c:init_IRQ_SMP().
+ * Setup of the IPI irq handler is done in irq.c:init_IRQ().
  *
  * This also registers the AP OS_MC_REDVEZ address with SAL.
  */
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/time.c linux-2.4=
.2-lia/arch/ia64/kernel/time.c
--- linux-davidm/arch/ia64/kernel/time.c	Wed Feb 28 22:20:36 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/time.c	Wed Feb 28 14:47:38 2001
@@ -74,7 +74,7 @@
 	unsigned long now =3D ia64_get_itc(), last_tick;
 	unsigned long elapsed_cycles, lost =3D jiffies - wall_jiffies;
=20
-	last_tick =3D (current_cpu_data->itm_next - (lost+1)*current_cpu_data->it=
m_delta);
+	last_tick =3D (local_cpu_data->itm_next - (lost+1)*local_cpu_data->itm_de=
lta);
 # if 1
 	if ((long) (now - last_tick) < 0) {
 		printk("Yikes: now < last_tick (now=3D0x%lx,last_tick=3D%lx)!  No can do=
.\n",
@@ -83,7 +83,7 @@
 	}
 # endif
 	elapsed_cycles =3D now - last_tick;
-	return (elapsed_cycles*current_cpu_data->usec_per_cyc) >> IA64_USEC_PER_C=
YC_SHIFT;
+	return (elapsed_cycles*local_cpu_data->usec_per_cyc) >> IA64_USEC_PER_CYC=
_SHIFT;
 #endif
 }
=20
@@ -144,7 +144,7 @@
 {
 	unsigned long new_itm;
=20
-	new_itm =3D current_cpu_data->itm_next;
+	new_itm =3D local_cpu_data->itm_next;
=20
 	if (!time_after(ia64_get_itc(), new_itm))
 		printk("Oops: timer tick before it's due (itc=3D%lx,itm=3D%lx)\n",
@@ -174,8 +174,8 @@
 			write_unlock(&xtime_lock);
 		}
=20
-		new_itm +=3D current_cpu_data->itm_delta;
-		current_cpu_data->itm_next =3D new_itm;
+		new_itm +=3D local_cpu_data->itm_delta;
+		local_cpu_data->itm_next =3D new_itm;
 		if (time_after(new_itm, ia64_get_itc()))
 			break;
 	}
@@ -188,8 +188,8 @@
 	     * let our clock run too fast (with the potentially devastating effec=
t of
 	     * losing monotony of time).
 	     */
-	    while (!time_after(new_itm, ia64_get_itc() + current_cpu_data->itm_de=
lta/2))
-	      new_itm +=3D current_cpu_data->itm_delta;
+	    while (!time_after(new_itm, ia64_get_itc() + local_cpu_data->itm_delt=
a/2))
+	      new_itm +=3D local_cpu_data->itm_delta;
 	    ia64_set_itm(new_itm);
 	    /* double check, in case we got hit by a (slow) PMI: */
 	} while (time_after_eq(ia64_get_itc(), new_itm));
@@ -205,9 +205,9 @@
 	unsigned long shift =3D 0, delta;
=20
 	/* arrange for the cycle counter to generate a timer interrupt: */
-	ia64_set_itv(TIMER_IRQ);
+	ia64_set_itv(IA64_TIMER_VECTOR);
=20
-	delta =3D current_cpu_data->itm_delta;
+	delta =3D local_cpu_data->itm_delta;
 	/*
 	 * Stagger the timer tick for each CPU so they don't occur all at (almost=
) the
 	 * same time:
@@ -216,8 +216,8 @@
 		unsigned long hi =3D 1UL << ia64_fls(cpu);
 		shift =3D (2*(cpu - hi) + 1) * delta/hi/2;
 	}
-	current_cpu_data->itm_next =3D ia64_get_itc() + delta + shift;
-	ia64_set_itm(current_cpu_data->itm_next);
+	local_cpu_data->itm_next =3D ia64_get_itc() + delta + shift;
+	ia64_set_itm(local_cpu_data->itm_next);
 }
=20
 void __init
@@ -258,16 +258,16 @@
 		itc_ratio.den =3D 1;	/* avoid division by zero */
=20
 	itc_freq =3D (platform_base_freq*itc_ratio.num)/itc_ratio.den;
-	current_cpu_data->itm_delta =3D (itc_freq + HZ/2) / HZ;
+	local_cpu_data->itm_delta =3D (itc_freq + HZ/2) / HZ;
 	printk("CPU %d: base freq=3D%lu.%03luMHz, ITC ratio=3D%lu/%lu, ITC freq=
=3D%lu.%03luMHz\n",
 	       smp_processor_id(),
 	       platform_base_freq / 1000000, (platform_base_freq / 1000) % 1000,
 	       itc_ratio.num, itc_ratio.den, itc_freq / 1000000, (itc_freq / 1000=
) % 1000);
=20
-	current_cpu_data->proc_freq =3D (platform_base_freq*proc_ratio.num)/proc_=
ratio.den;
-	current_cpu_data->itc_freq =3D itc_freq;
-	current_cpu_data->cyc_per_usec =3D (itc_freq + 500000) / 1000000;
-	current_cpu_data->usec_per_cyc =3D ((1000000UL<<IA64_USEC_PER_CYC_SHIFT)
+	local_cpu_data->proc_freq =3D (platform_base_freq*proc_ratio.num)/proc_ra=
tio.den;
+	local_cpu_data->itc_freq =3D itc_freq;
+	local_cpu_data->cyc_per_usec =3D (itc_freq + 500000) / 1000000;
+	local_cpu_data->usec_per_cyc =3D ((1000000UL<<IA64_USEC_PER_CYC_SHIFT)
 					  + itc_freq/2)/itc_freq;
=20
 	/* Setup the CPU local timer tick */
@@ -283,11 +283,7 @@
 void __init
 time_init (void)
 {
-	/* we can't do request_irq() here because the kmalloc() would fail... */
-	irq_desc[TIMER_IRQ].status |=3D IRQ_PER_CPU;
-	irq_desc[TIMER_IRQ].handler =3D &irq_type_ia64_sapic;
-	setup_irq(TIMER_IRQ, &timer_irqaction);
-
+	register_percpu_irq(IA64_TIMER_VECTOR, &timer_irqaction);
 	efi_gettimeofday(&xtime);
 	ia64_init_itm();
 }
diff -urN --ignore-all-space linux-davidm/arch/ia64/kernel/unwind.c linux-2=
.4.2-lia/arch/ia64/kernel/unwind.c
--- linux-davidm/arch/ia64/kernel/unwind.c	Wed Feb 28 22:20:36 2001
+++ linux-2.4.2-lia/arch/ia64/kernel/unwind.c	Wed Feb 28 14:48:03 2001
@@ -1613,7 +1613,7 @@
=20
 		      case UNW_INSN_LOAD:
 #if UNW_DEBUG
-			if ((s[val] & (current_cpu_data->unimpl_va_mask | 0x7)) !=3D 0
+			if ((s[val] & (local_cpu_data->unimpl_va_mask | 0x7)) !=3D 0
 			    || s[val] < TASK_SIZE)
 			{
 				debug(1, "unwind: rejecting bad psp=3D0x%lx\n", s[val]);
@@ -1647,7 +1647,7 @@
 	int have_write_lock =3D 0;
 	struct unw_script *scr;
=20
-	if ((info->ip & (current_cpu_data->unimpl_va_mask | 0xf)) || info->ip < T=
ASK_SIZE) {
+	if ((info->ip & (local_cpu_data->unimpl_va_mask | 0xf)) || info->ip < TAS=
K_SIZE) {
 		/* don't let obviously bad addresses pollute the cache */
 		debug(1, "unwind: rejecting bad ip=3D0x%lx\n", info->ip);
 		info->rp_loc =3D 0;
@@ -1945,7 +1945,7 @@
 		return -1;
=20
 	info->ip =3D read_reg(info, sol - 2, &is_nat);
-	if (is_nat || (info->ip & (current_cpu_data->unimpl_va_mask | 0xf)))
+	if (is_nat || (info->ip & (local_cpu_data->unimpl_va_mask | 0xf)))
 		/* reject let obviously bad addresses */
 		return -1;
=20
diff -urN --ignore-all-space linux-davidm/arch/ia64/mm/init.c linux-2.4.2-l=
ia/arch/ia64/mm/init.c
--- linux-davidm/arch/ia64/mm/init.c	Wed Feb 28 22:20:36 2001
+++ linux-2.4.2-lia/arch/ia64/mm/init.c	Wed Feb 28 14:48:13 2001
@@ -1,8 +1,8 @@
 /*
  * Initialize MMU support.
  *
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #include <linux/config.h>
 #include <linux/kernel.h>
@@ -368,7 +368,7 @@
 #	define vmlpt_bits		(impl_va_bits - PAGE_SHIFT + pte_bits)
 #	define POW2(n)			(1ULL << (n))
=20
-	impl_va_bits =3D ffz(~(current_cpu_data->unimpl_va_mask | (7UL << 61)));
+	impl_va_bits =3D ffz(~(local_cpu_data->unimpl_va_mask | (7UL << 61)));
=20
 	if (impl_va_bits < 51 || impl_va_bits > 61)
 		panic("CPU has bogus IMPL_VA_MSB value of %lu!\n", impl_va_bits - 1);
diff -urN --ignore-all-space linux-davidm/arch/ia64/mm/tlb.c linux-2.4.2-li=
a/arch/ia64/mm/tlb.c
--- linux-davidm/arch/ia64/mm/tlb.c	Wed Feb 28 22:20:36 2001
+++ linux-2.4.2-lia/arch/ia64/mm/tlb.c	Wed Feb 28 14:48:23 2001
@@ -71,7 +71,7 @@
 	if (!(flags & IA64_PSR_I)) {
 		saved_tpr =3D ia64_get_tpr();
 		ia64_srlz_d();
-		ia64_set_tpr(IPI_IRQ - 16);
+		ia64_set_tpr(IA64_IPI_VECTOR - 16);
 		ia64_srlz_d();
 		local_irq_enable();
 	}
@@ -97,13 +97,14 @@
 	/*
 	 * Wait for other CPUs to finish purging entries.
 	 */
-#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTE=
P_SPECIFIC))
+#if defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP=
_SPECIFIC)
 	{
+		extern void smp_resend_flush_tlb (void);
 		unsigned long start =3D ia64_get_itc();
+
 		while (atomic_read(&flush_cpu_count) > 0) {
-			if ((ia64_get_itc() - start) > 40000UL) {
-				atomic_set(&flush_cpu_count, smp_num_cpus - 1);
-				smp_send_flush_tlb();
+			if ((ia64_get_itc() - start) > 400000UL) {
+				smp_resend_flush_tlb();
 				start =3D ia64_get_itc();
 			}
 		}
@@ -166,11 +167,11 @@
 {
 	unsigned long i, j, flags, count0, count1, stride0, stride1, addr;
=20
-	addr    =3D current_cpu_data->ptce_base;
-	count0  =3D current_cpu_data->ptce_count[0];
-	count1  =3D current_cpu_data->ptce_count[1];
-	stride0 =3D current_cpu_data->ptce_stride[0];
-	stride1 =3D current_cpu_data->ptce_stride[1];
+	addr    =3D local_cpu_data->ptce_base;
+	count0  =3D local_cpu_data->ptce_count[0];
+	count1  =3D local_cpu_data->ptce_count[1];
+	stride0 =3D local_cpu_data->ptce_stride[0];
+	stride1 =3D local_cpu_data->ptce_stride[1];
=20
 	local_irq_save(flags);
 	for (i =3D 0; i < count0; ++i) {
@@ -249,11 +250,11 @@
 	ia64_ptce_info_t ptce_info;
=20
 	ia64_get_ptce(&ptce_info);
-	current_cpu_data->ptce_base =3D ptce_info.base;
-	current_cpu_data->ptce_count[0] =3D ptce_info.count[0];
-	current_cpu_data->ptce_count[1] =3D ptce_info.count[1];
-	current_cpu_data->ptce_stride[0] =3D ptce_info.stride[0];
-	current_cpu_data->ptce_stride[1] =3D ptce_info.stride[1];
+	local_cpu_data->ptce_base =3D ptce_info.base;
+	local_cpu_data->ptce_count[0] =3D ptce_info.count[0];
+	local_cpu_data->ptce_count[1] =3D ptce_info.count[1];
+	local_cpu_data->ptce_stride[0] =3D ptce_info.stride[0];
+	local_cpu_data->ptce_stride[1] =3D ptce_info.stride[1];
=20
 	__flush_tlb_all();		/* nuke left overs from bootstrapping... */
 }
diff -urN --ignore-all-space linux-davidm/drivers/acpi/acpiconf.c linux-2.4=
.2-lia/drivers/acpi/acpiconf.c
--- linux-davidm/drivers/acpi/acpiconf.c	Wed Feb 28 22:20:36 2001
+++ linux-2.4.2-lia/drivers/acpi/acpiconf.c	Wed Feb 28 20:54:48 2001
@@ -353,9 +353,9 @@
 		if (prt) {
 			for ( ; prt->length > 0; pvec++) {
 				pvec->bus	=3D (UINT16)i;
-				pvec->pci_id	=3D prt->data.address;
-				pvec->pin	=3D (UINT8)prt->data.pin;
-				pvec->irq	=3D (UINT8)prt->data.source_index;
+				pvec->pci_id	=3D prt->address;
+				pvec->pin	=3D (UINT8)prt->pin;
+				pvec->irq	=3D (UINT8)prt->source_index;
=20
 				prt =3D (PCI_ROUTING_TABLE *) ((NATIVE_UINT)prt + (NATIVE_UINT)prt->le=
ngth);
 				//prt =3D ROUND_PTR_UP_TO_4(prt, PCI_ROUTING_TABLE);
diff -urN --ignore-all-space linux-davidm/drivers/acpi/os.c linux-2.4.2-lia=
/drivers/acpi/os.c
--- linux-davidm/drivers/acpi/os.c	Wed Feb 28 22:20:36 2001
+++ linux-2.4.2-lia/drivers/acpi/os.c	Wed Feb 28 20:54:33 2001
@@ -244,7 +244,7 @@
=20
 	acpi_irq_handler =3D NULL;
=20
-	desc =3D irq_desc + irq;
+	desc =3D irq_desc(irq);
 	spin_lock_irqsave(&desc->lock,flags);
 	p =3D &desc->action;
 	for (;;) {
diff -urN --ignore-all-space linux-davidm/drivers/char/simserial.c linux-2.=
4.2-lia/drivers/char/simserial.c
--- linux-davidm/drivers/char/simserial.c	Wed Feb 28 22:20:37 2001
+++ linux-2.4.2-lia/drivers/char/simserial.c	Wed Feb 28 20:54:05 2001
@@ -153,6 +153,7 @@
 			} else if ( seen_esc =3D 2 ) {
 				if ( ch =3D 'P' ) show_state();		/* F1 key */
 				if ( ch =3D 'Q' ) show_buffers();	/* F2 key */
+
 				seen_esc =3D 0;
 				continue;
 			}
diff -urN --ignore-all-space linux-davidm/fs/proc/base.c linux-2.4.2-lia/fs=
/proc/base.c
--- linux-davidm/fs/proc/base.c	Wed Feb 28 22:20:39 2001
+++ linux-2.4.2-lia/fs/proc/base.c	Wed Feb 28 20:52:18 2001
@@ -400,8 +400,10 @@
 	switch (orig) {
 	      case 0:
 		file->f_pos =3D offset;
+		break;
 	      case 1:
 		file->f_pos +=3D offset;
+		break;
 	      default:
 		return -EINVAL;
 	}
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/delay.h linux-2.=
4.2-lia/include/asm-ia64/delay.h
--- linux-davidm/include/asm-ia64/delay.h	Wed Feb 28 22:20:39 2001
+++ linux-2.4.2-lia/include/asm-ia64/delay.h	Wed Feb 28 20:52:04 2001
@@ -76,7 +76,7 @@
 udelay (unsigned long usecs)
 {
 	unsigned long start =3D ia64_get_itc();
-	unsigned long cycles =3D usecs*current_cpu_data->cyc_per_usec;
+	unsigned long cycles =3D usecs*local_cpu_data->cyc_per_usec;
=20
 	while (ia64_get_itc() - start < cycles)
 		/* skip */;
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/hardirq.h linux-=
2.4.2-lia/include/asm-ia64/hardirq.h
--- linux-davidm/include/asm-ia64/hardirq.h	Wed Feb 28 22:20:39 2001
+++ linux-2.4.2-lia/include/asm-ia64/hardirq.h	Wed Feb 28 20:51:49 2001
@@ -18,24 +18,31 @@
  */
 #define softirq_active(cpu)	(cpu_data[cpu].softirq.active)
 #define softirq_mask(cpu)	(cpu_data[cpu].softirq.mask)
-#define local_irq_count(cpu)	(cpu_data[cpu].irq_stat.f.irq_count)
-#define local_bh_count(cpu)	(cpu_data[cpu].irq_stat.f.bh_count)
+#define irq_count(cpu)			(cpu_data[cpu].irq_stat.f.irq_count)
+#define bh_count(cpu)			(cpu_data[cpu].irq_stat.f.bh_count)
 #define syscall_count(cpu)	/* unused on IA-64 */
 #define nmi_count(cpu)		0
=20
+#define local_softirq_active()		(local_cpu_data->softirq.active)
+#define local_softirq_mask()		(local_cpu_data->softirq.mask)
+#define local_irq_count()		(local_cpu_data->irq_stat.f.irq_count)
+#define local_bh_count()		(local_cpu_data->irq_stat.f.bh_count)
+#define local_syscall_count()		/* unused on IA-64 */
+#define local_nmi_count()		0
+
 /*
  * Are we in an interrupt context? Either doing bottom half or hardware in=
terrupt
  * processing?
  */
-#define in_interrupt()		(current_cpu_data->irq_stat.irq_and_bh_counts !=3D=
 0)
-#define in_irq()		(current_cpu_data->irq_stat.f.irq_count !=3D 0)
+#define in_interrupt()			(local_cpu_data->irq_stat.irq_and_bh_counts !=3D =
0)
+#define in_irq()			(local_cpu_data->irq_stat.f.irq_count !=3D 0)
=20
 #ifndef CONFIG_SMP
-# define hardirq_trylock(cpu)		(local_irq_count(cpu) =3D 0)
-# define hardirq_endlock(cpu)		do { } while (0)
+# define local_hardirq_trylock()	(local_irq_count() =3D 0)
+# define local_hardirq_endlock()	do { } while (0)
=20
-# define irq_enter(cpu, irq)		(local_irq_count(cpu)++)
-# define irq_exit(cpu, irq)		(local_irq_count(cpu)--)
+# define local_irq_enter(irq)		(local_irq_count(cpu)++)
+# define local_irq_exit(irq)		(local_irq_count(cpu)--)
=20
 # define synchronize_irq()		barrier()
 #else
@@ -52,7 +59,7 @@
 	int i;
=20
 	for (i =3D 0; i < smp_num_cpus; i++)
-		if (local_irq_count(i))
+		if (irq_count(i))
 			return 1;
 	return 0;
 }
@@ -68,9 +75,9 @@
 }
=20
 static inline void
-irq_enter (int cpu, int irq)
+local_irq_enter (int irq)
 {
-	local_irq_count(cpu)++;
+	local_irq_count()++;
=20
 	while (test_bit(0,&global_irq_lock)) {
 		/* nothing */;
@@ -78,18 +85,18 @@
 }
=20
 static inline void
-irq_exit (int cpu, int irq)
+local_irq_exit (int irq)
 {
-	local_irq_count(cpu)--;
+	local_irq_count()--;
 }
=20
 static inline int
-hardirq_trylock (int cpu)
+local_hardirq_trylock (void)
 {
-	return !local_irq_count(cpu) && !test_bit(0,&global_irq_lock);
+	return !local_irq_count() && !test_bit(0,&global_irq_lock);
 }
=20
-#define hardirq_endlock(cpu)	do { } while (0)
+#define local_hardirq_endlock()		do { } while (0)
=20
 extern void synchronize_irq (void);
=20
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/hw_irq.h linux-2=
.4.2-lia/include/asm-ia64/hw_irq.h
--- linux-davidm/include/asm-ia64/hw_irq.h	Wed Feb 28 22:20:39 2001
+++ linux-2.4.2-lia/include/asm-ia64/hw_irq.h	Wed Feb 28 20:51:32 2001
@@ -13,6 +13,8 @@
 #include <asm/ptrace.h>
 #include <asm/smp.h>
=20
+typedef u8 ia64_vector;
+
 /*
  * 0 special
  *
@@ -28,29 +30,30 @@
  */
 #define IA64_MIN_VECTORED_IRQ	 16
 #define IA64_MAX_VECTORED_IRQ	255
+#define IA64_NUM_VECTORS		256
=20
-#define IA64_SPURIOUS_INT	0x0f
+#define IA64_SPURIOUS_INT_VECTOR	0x0f
=20
 /*
  * Vectors 0x10-0x1f are used for low priority interrupts, e.g. CMCI.
  */
-#define PCE_IRQ			0x1e	/* platform corrected error interrupt vector */
-#define CMC_IRQ			0x1f	/* correctable machine-check interrupt vector */
+#define IA64_PCE_VECTOR			0x1e	/* platform corrected error interrupt vecto=
r */
+#define IA64_CMC_VECTOR			0x1f	/* correctable machine-check interrupt vect=
or */
 /*
  * Vectors 0x20-0x2f are reserved for legacy ISA IRQs.
  */
-#define FIRST_DEVICE_IRQ	0x30
-#define LAST_DEVICE_IRQ		0xe7
+#define IA64_FIRST_DEVICE_VECTOR	0x30
+#define IA64_LAST_DEVICE_VECTOR		0xe7
=20
-#define MCA_RENDEZ_IRQ		0xe8	/* MCA rendez interrupt */
-#define PERFMON_IRQ		0xee	/* performanc monitor interrupt vector */
-#define TIMER_IRQ		0xef	/* use highest-prio group 15 interrupt for timer */
-#define	MCA_WAKEUP_IRQ		0xf0	/* MCA wakeup interrupt (must be >MCA_RENDEZ_=
IRQ) */
-#define IPI_IRQ			0xfe	/* inter-processor interrupt vector */
+#define IA64_MCA_RENDEZ_VECTOR		0xe8	/* MCA rendez interrupt */
+#define IA64_PERFMON_VECTOR		0xee	/* performanc monitor interrupt vector */
+#define IA64_TIMER_VECTOR		0xef	/* use highest-prio group 15 interrupt for=
 timer */
+#define	IA64_MCA_WAKEUP_VECTOR		0xf0	/* MCA wakeup (must be >MCA_RENDEZ_VE=
CTOR) */
+#define IA64_IPI_VECTOR			0xfe	/* inter-processor interrupt vector */
=20
 /* IA64 inter-cpu interrupt related definitions */
=20
-#define IPI_DEFAULT_BASE_ADDR	0xfee00000
+#define IA64_IPI_DEFAULT_BASE_ADDR	0xfee00000
=20
 /* Delivery modes for inter-cpu interrupts */
 enum {
@@ -70,11 +73,71 @@
=20
 extern int ia64_alloc_irq (void);	/* allocate a free irq */
 extern void ia64_send_ipi (int cpu, int vector, int delivery_mode, int red=
irect);
+extern void register_percpu_irq (ia64_vector vec, struct irqaction *action=
);
=20
 static inline void
 hw_resend_irq (struct hw_interrupt_type *h, unsigned int vector)
 {
 	platform_send_ipi(smp_processor_id(), vector, IA64_IPI_DM_INT, 0);
+}
+
+/*
+ * Default implementations for the irq-descriptor API:
+ */
+
+extern struct irq_desc _irq_desc[NR_IRQS];
+
+static inline struct irq_desc *
+__ia64_irq_desc (unsigned int irq)
+{
+	return _irq_desc + irq;
+}
+
+static inline ia64_vector
+__ia64_irq_to_vector (unsigned int irq)
+{
+	return (ia64_vector) irq;
+}
+
+static inline unsigned int
+__ia64_local_vector_to_irq (ia64_vector vec)
+{
+	return (unsigned int) vec;
+}
+
+/*
+ * Next follows the irq descriptor interface.  On IA-64, each CPU supports=
 256 interrupt
+ * vectors.  On smaller systems, there is a one-to-one correspondence betw=
een interrupt
+ * vectors and the Linux irq numbers.  However, larger systems may have mu=
ltiple interrupt
+ * domains meaning that the translation from vector number to irq number d=
epends on the
+ * interrupt domain that a CPU belongs to.  This API abstracts such platfo=
rm-dependent
+ * differences and provides a uniform means to translate between vector an=
d irq numbers
+ * and to obtain the irq descriptor for a given irq number.
+ */
+
+/* Return a pointer to the irq descriptor for IRQ.  */
+static inline struct irq_desc *
+irq_desc (int irq)
+{
+	return platform_irq_desc(irq);
+}
+
+/* Extract the IA-64 vector that corresponds to IRQ.  */
+static inline ia64_vector
+irq_to_vector (int irq)
+{
+	return platform_irq_to_vector(irq);
+}
+
+/*
+ * Convert the local IA-64 vector to the corresponding irq number.  This t=
ranslation is
+ * done in the context of the interrupt domain that the currently executin=
g CPU belongs
+ * to.
+ */
+static inline unsigned int
+local_vector_to_irq (ia64_vector vec)
+{
+	return platform_local_vector_to_irq(vec);
 }
=20
 #endif /* _ASM_IA64_HW_IRQ_H */
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/machvec.h linux-=
2.4.2-lia/include/asm-ia64/machvec.h
--- linux-davidm/include/asm-ia64/machvec.h	Thu Jan  4 22:40:20 2001
+++ linux-2.4.2-lia/include/asm-ia64/machvec.h	Wed Feb 28 20:51:15 2001
@@ -4,8 +4,8 @@
  * Copyright (C) 1999 Silicon Graphics, Inc.
  * Copyright (C) Srinivasa Thirumalachar <sprasad@engr.sgi.com>
  * Copyright (C) Vijay Chander <vijay@engr.sgi.com>
- * Copyright (C) 1999-2000 Hewlett-Packard Co.
- * Copyright (C) 1999-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999-2001 Hewlett-Packard Co.
+ * Copyright (C) 1999-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #ifndef _ASM_IA64_MACHVEC_H
 #define _ASM_IA64_MACHVEC_H
@@ -17,6 +17,7 @@
 struct pci_dev;
 struct pt_regs;
 struct scatterlist;
+struct irq_desc;
=20
 typedef void ia64_mv_setup_t (char **);
 typedef void ia64_mv_irq_init_t (void);
@@ -27,6 +28,9 @@
 typedef void ia64_mv_cmci_handler_t (int, void *, struct pt_regs *);
 typedef void ia64_mv_log_print_t (void);
 typedef void ia64_mv_send_ipi_t (int, int, int, int);
+typedef struct irq_desc *ia64_mv_irq_desc (unsigned int);
+typedef u8 ia64_mv_irq_to_vector (u8);
+typedef unsigned int ia64_mv_local_vector_to_irq (u8 vector);
=20
 /* PCI-DMA interface: */
 typedef void ia64_mv_pci_dma_init (void);
@@ -88,6 +92,9 @@
 #  define platform_pci_dma_sync_single	ia64_mv.sync_single
 #  define platform_pci_dma_sync_sg	ia64_mv.sync_sg
 #  define platform_pci_dma_address	ia64_mv.dma_address
+#  define platform_irq_desc		ia64_mv.irq_desc
+#  define platform_irq_to_vector	ia64_mv.irq_to_vector
+#  define platform_local_vector_to_irq	ia64_mv.local_vector_to_irq
 #  define platform_inb		ia64_mv.inb
 #  define platform_inw		ia64_mv.inw
 #  define platform_inl		ia64_mv.inl
@@ -117,6 +124,9 @@
 	ia64_mv_pci_dma_sync_single *sync_single;
 	ia64_mv_pci_dma_sync_sg *sync_sg;
 	ia64_mv_pci_dma_address *dma_address;
+	ia64_mv_irq_desc *irq_desc;
+	ia64_mv_irq_to_vector *irq_to_vector;
+	ia64_mv_local_vector_to_irq *local_vector_to_irq;
 	ia64_mv_inb_t *inb;
 	ia64_mv_inw_t *inw;
 	ia64_mv_inl_t *inl;
@@ -147,6 +157,9 @@
 	platform_pci_dma_sync_single,		\
 	platform_pci_dma_sync_sg,		\
 	platform_pci_dma_address,		\
+	platform_irq_desc,			\
+	platform_irq_to_vector,			\
+	platform_local_vector_to_irq,		\
 	platform_inb,				\
 	platform_inw,				\
 	platform_inl,				\
@@ -233,6 +246,15 @@
 #endif
 #ifndef platform_pci_dma_address
 # define  platform_pci_dma_address	swiotlb_dma_address
+#endif
+#ifndef platform_irq_desc
+# define platform_irq_desc		__ia64_irq_desc
+#endif
+#ifndef platform_irq_to_vector
+# define platform_irq_to_vector		__ia64_irq_to_vector
+#endif
+#ifndef platform_local_vector_to_irq
+# define platform_local_vector_to_irq	__ia64_local_vector_to_irq
 #endif
 #ifndef platform_inb
 # define platform_inb		__ia64_inb
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/machvec_sn1.h li=
nux-2.4.2-lia/include/asm-ia64/machvec_sn1.h
--- linux-davidm/include/asm-ia64/machvec_sn1.h	Thu Jan  4 22:40:20 2001
+++ linux-2.4.2-lia/include/asm-ia64/machvec_sn1.h	Wed Feb 28 20:50:55 2001
@@ -41,6 +41,7 @@
 #define platform_outb		sn1_outb
 #define platform_outw		sn1_outw
 #define platform_outl		sn1_outl
+#define platform_pci_dma_init	machvec_noop
 #define platform_pci_alloc_consistent	sn1_pci_alloc_consistent
 #define platform_pci_free_consistent	sn1_pci_free_consistent
 #define platform_pci_map_single		sn1_pci_map_single
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/mca.h linux-2.4.=
2-lia/include/asm-ia64/mca.h
--- linux-davidm/include/asm-ia64/mca.h	Thu Jan  4 22:40:20 2001
+++ linux-2.4.2-lia/include/asm-ia64/mca.h	Wed Feb 28 20:50:44 2001
@@ -18,7 +18,6 @@
 #include <asm/param.h>
 #include <asm/sal.h>
 #include <asm/processor.h>
-#include <asm/hw_irq.h>
=20
 /* These are the return codes from all the IA64_MCA specific interfaces */
 typedef	int ia64_mca_return_code_t;
@@ -30,11 +29,6 @@
=20
 #define IA64_MCA_RENDEZ_TIMEOUT		(100 * HZ)	/* 1000 milliseconds */
=20
-/* Interrupt vectors reserved for MC handling. */
-#define IA64_MCA_RENDEZ_INT_VECTOR	MCA_RENDEZ_IRQ	/* Rendez interrupt */
-#define IA64_MCA_WAKEUP_INT_VECTOR	MCA_WAKEUP_IRQ	/* Wakeup interrupt */
-#define IA64_MCA_CMC_INT_VECTOR		CMC_IRQ	/* Correctable machine check inte=
rrupt */
-
 #define IA64_CMC_INT_DISABLE		0
 #define IA64_CMC_INT_ENABLE		1
=20
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/offsets.h linux-=
2.4.2-lia/include/asm-ia64/offsets.h
--- linux-davidm/include/asm-ia64/offsets.h	Wed Feb 28 22:20:39 2001
+++ linux-2.4.2-lia/include/asm-ia64/offsets.h	Wed Feb 28 20:50:30 2001
@@ -11,7 +11,7 @@
 #define PT_PTRACED_BIT			0
 #define PT_TRACESYS_BIT			1
=20
-#define IA64_TASK_SIZE			3376	/* 0xd30 */
+#define IA64_TASK_SIZE			3904	/* 0xf40 */
 #define IA64_PT_REGS_SIZE		400	/* 0x190 */
 #define IA64_SWITCH_STACK_SIZE		560	/* 0x230 */
 #define IA64_SIGINFO_SIZE		128	/* 0x80 */
@@ -24,7 +24,8 @@
 #define IA64_TASK_PROCESSOR_OFFSET	100	/* 0x64 */
 #define IA64_TASK_THREAD_OFFSET		1456	/* 0x5b0 */
 #define IA64_TASK_THREAD_KSP_OFFSET	1456	/* 0x5b0 */
-#define IA64_TASK_THREAD_SIGMASK_OFFSET	3224	/* 0xc98 */
+#define IA64_TASK_THREAD_SIGMASK_OFFSET	3752	/* 0xea8 */
+#define IA64_TASK_PFM_NOTIFY_OFFSET	3648	/* 0xe40 */
 #define IA64_TASK_PID_OFFSET		196	/* 0xc4 */
 #define IA64_TASK_MM_OFFSET		88	/* 0x58 */
 #define IA64_PT_REGS_CR_IPSR_OFFSET	0	/* 0x0 */
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/pgalloc.h linux-=
2.4.2-lia/include/asm-ia64/pgalloc.h
--- linux-davidm/include/asm-ia64/pgalloc.h	Wed Feb 28 22:20:40 2001
+++ linux-2.4.2-lia/include/asm-ia64/pgalloc.h	Wed Feb 28 20:50:15 2001
@@ -8,8 +8,8 @@
  * This hopefully works with any (fixed) ia-64 page-size, as defined
  * in <asm/page.h> (currently 8192).
  *
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 2000, Goutham Rao <goutham.rao@intel.com>
  */
=20
@@ -28,10 +28,10 @@
  * a lot of work and caused unnecessary memory traffic.  How broken...
  * We fix this by caching them.
  */
-#define pgd_quicklist		(current_cpu_data->pgd_quick)
-#define pmd_quicklist		(current_cpu_data->pmd_quick)
-#define pte_quicklist		(current_cpu_data->pte_quick)
-#define pgtable_cache_size	(current_cpu_data->pgtable_cache_sz)
+#define pgd_quicklist		(local_cpu_data->pgd_quick)
+#define pmd_quicklist		(local_cpu_data->pmd_quick)
+#define pte_quicklist		(local_cpu_data->pte_quick)
+#define pgtable_cache_size	(local_cpu_data->pgtable_cache_sz)
=20
 static __inline__ pgd_t*
 get_pgd_slow (void)
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/pgtable.h linux-=
2.4.2-lia/include/asm-ia64/pgtable.h
--- linux-davidm/include/asm-ia64/pgtable.h	Wed Feb 28 22:20:40 2001
+++ linux-2.4.2-lia/include/asm-ia64/pgtable.h	Wed Feb 28 20:49:58 2001
@@ -175,7 +175,7 @@
 static inline long
 ia64_phys_addr_valid (unsigned long addr)
 {
-	return (addr & (current_cpu_data->unimpl_pa_mask)) =3D 0;
+	return (addr & (local_cpu_data->unimpl_pa_mask)) =3D 0;
 }
=20
 /*
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/processor.h linu=
x-2.4.2-lia/include/asm-ia64/processor.h
--- linux-davidm/include/asm-ia64/processor.h	Wed Feb 28 22:20:40 2001
+++ linux-2.4.2-lia/include/asm-ia64/processor.h	Wed Feb 28 20:49:47 2001
@@ -283,7 +283,11 @@
 #endif
 } __attribute__ ((aligned (PAGE_SIZE))) ;
=20
-#define current_cpu_data		((struct cpuinfo_ia64 *) PERCPU_ADDR)
+/*
+ * The "local" data pointer.  It points to the per-CPU data of the current=
ly executing
+ * CPU, much like "current" points to the per-task data of the currently e=
xecuting task.
+ */
+#define local_cpu_data		((struct cpuinfo_ia64 *) PERCPU_ADDR)
=20
 extern struct cpuinfo_ia64 cpu_data[NR_CPUS];
=20
diff -urN --ignore-all-space linux-davidm/include/asm-ia64/softirq.h linux-=
2.4.2-lia/include/asm-ia64/softirq.h
--- linux-davidm/include/asm-ia64/softirq.h	Fri Mar 10 15:24:02 2000
+++ linux-2.4.2-lia/include/asm-ia64/softirq.h	Wed Feb 28 20:47:06 2001
@@ -2,17 +2,14 @@
 #define _ASM_IA64_SOFTIRQ_H
=20
 /*
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #include <asm/hardirq.h>
=20
-#define cpu_bh_disable(cpu)	do { local_bh_count(cpu)++; barrier(); } while=
 (0)
-#define cpu_bh_enable(cpu)	do { barrier(); local_bh_count(cpu)--; } while =
(0)
+#define local_bh_disable()	do { local_bh_count()++; barrier(); } while (0)
+#define local_bh_enable()	do { barrier(); local_bh_count()--; } while (0)
=20
-#define local_bh_disable()	cpu_bh_disable(smp_processor_id())
-#define local_bh_enable()	cpu_bh_enable(smp_processor_id())
-
-#define in_softirq()		(local_bh_count(smp_processor_id()) !=3D 0)
+#define in_softirq()		(local_bh_count() !=3D 0)
=20
 #endif /* _ASM_IA64_SOFTIRQ_H */
diff -urN --ignore-all-space linux-davidm/include/linux/irq.h linux-2.4.2-l=
ia/include/linux/irq.h
--- linux-davidm/include/linux/irq.h	Wed Feb 28 22:20:40 2001
+++ linux-2.4.2-lia/include/linux/irq.h	Wed Feb 28 20:46:15 2001
@@ -44,15 +44,13 @@
  *
  * Pad this out to 32 bytes for cache and indexing reasons.
  */
-typedef struct {
+typedef struct irq_desc {
 	unsigned int status;		/* IRQ status */
 	hw_irq_controller *handler;
 	struct irqaction *action;	/* IRQ action list */
 	unsigned int depth;		/* nested irq disables */
 	spinlock_t lock;
 } ____cacheline_aligned irq_desc_t;
-
-extern irq_desc_t irq_desc [NR_IRQS];
=20
 #include <asm/hw_irq.h> /* the arch dependent stuff */
=20
diff -urN --ignore-all-space linux-davidm/include/linux/irq_cpustat.h linux=
-2.4.2-lia/include/linux/irq_cpustat.h
--- linux-davidm/include/linux/irq_cpustat.h	Sun Dec 31 11:10:16 2000
+++ linux-2.4.2-lia/include/linux/irq_cpustat.h	Wed Feb 28 20:46:00 2001
@@ -28,8 +28,8 @@
   /* arch independent irq_stat fields */
 #define softirq_active(cpu)	__IRQ_STAT((cpu), __softirq_active)
 #define softirq_mask(cpu)	__IRQ_STAT((cpu), __softirq_mask)
-#define local_irq_count(cpu)	__IRQ_STAT((cpu), __local_irq_count)
-#define local_bh_count(cpu)	__IRQ_STAT((cpu), __local_bh_count)
+#define irq_count(cpu)		__IRQ_STAT((cpu), __irq_count)
+#define bh_count(cpu)		__IRQ_STAT((cpu), __bh_count)
 #define syscall_count(cpu)	__IRQ_STAT((cpu), __syscall_count)
   /* arch dependent irq_stat fields */
 #define nmi_count(cpu)		__IRQ_STAT((cpu), __nmi_count)		/* i386, ia64 */
diff -urN --ignore-all-space linux-davidm/kernel/softirq.c linux-2.4.2-lia/=
kernel/softirq.c
--- linux-davidm/kernel/softirq.c	Wed Feb 28 22:20:48 2001
+++ linux-2.4.2-lia/kernel/softirq.c	Wed Feb 28 20:45:09 2001
@@ -245,18 +245,16 @@
=20
 static void bh_action(unsigned long nr)
 {
-	int cpu =3D smp_processor_id();
-
 	if (!spin_trylock(&global_bh_lock))
 		goto resched;
=20
-	if (!hardirq_trylock(cpu))
+	if (!local_hardirq_trylock())
 		goto resched_unlock;
=20
 	if (bh_base[nr])
 		bh_base[nr]();
=20
-	hardirq_endlock(cpu);
+	local_hardirq_endlock();
 	spin_unlock(&global_bh_lock);
 	return;
=20
diff -urN --ignore-all-space linux-davidm/kernel/timer.c linux-2.4.2-lia/ke=
rnel/timer.c
--- linux-davidm/kernel/timer.c	Wed Feb 28 22:20:48 2001
+++ linux-2.4.2-lia/kernel/timer.c	Wed Feb 28 20:44:50 2001
@@ -592,7 +592,7 @@
 		else
 			kstat.per_cpu_user[cpu] +=3D user_tick;
 		kstat.per_cpu_system[cpu] +=3D system;
-	} else if (local_bh_count(cpu) || local_irq_count(cpu) > 1)
+	} else if (local_bh_count() || local_irq_count() > 1)
 		kstat.per_cpu_system[cpu] +=3D system;
 }
=20

