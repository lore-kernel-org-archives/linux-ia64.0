From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 25 Apr 2000 03:31:50 +0000
Subject: [Linux-ia64] new kernel diff (relative to 2.3.99-pre5)
Message-Id: <marc-linux-ia64-105590678205032@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A new IA-64 kernel diff is now available at:

 ftp://ftp.kernel.org/linux/kernel/ports/ia64/

in files linux-2.3.99-pre5-ia64-000424.diff*.  This diff is relative
to 2.3.99-pre5 and should work reasonably well on SMP (much better
than the previous patch, for sure...).  The changes since the previous
patch are below. In summary:

 - Don't prevent concurrent execution of IPI and timer interrupts.
   This gets rid of the extremely frequent "ITM in past" messages we
   were seeing.  Thanks to Asit for pointing this out.  Apparently,
   this bug was fixed a while ago already and got re-introduced when
   we switched to the new irq code (based on the x86 code).  My bad.

 - Put the itm[cpu].next value in a separate cachline for each CPU.
   This ain't pretty and I think we'll want a separate global variable
   (perhaps cpu[NUM_CPUS]) instead so we can collect (small) variables
   that need to be per-CPU so that we don't waste most of a cache-line
   for each such variable.  But for now, this will do.

 - Disable the gettimeoffset() code for SMP.  That code doesn't work
   _unless_ the ITC on all CPUs are in perfect synchrony.  The effect
   of this is that gettimeofday() will return values with timer-tick
   (currently 10ms) resolution only.  If someone has a smart idea on
   how to do this properly on an SMP without assuming the presence of
   an external timer chip and without causing extra IPIs, I'm all
   ears. ;-)

 - Various minor updates to sync up with 2.3.99-pre5.  A noteworthy
   change that the glibc folks should pay attention to: there are two
   new system calls: madvise() and mincore().  We should add glibc
   stubs for these (perhaps they're in glibc-2.2 already?).

 - Some minor spinlock fixes.

Enjoy,

	--david

diff -urN linux-davidm/arch/ia64/kernel/irq.c linux-2.3.99-pre5-lia/arch/ia64/kernel/irq.c
--- linux-davidm/arch/ia64/kernel/irq.c	Fri Apr 21 18:50:34 2000
+++ linux-2.3.99-pre5-lia/arch/ia64/kernel/irq.c	Mon Apr 24 17:12:22 2000
@@ -582,7 +582,8 @@
 	if (!(status & (IRQ_DISABLED | IRQ_INPROGRESS))) {
 		action = desc->action;
 		status &= ~IRQ_PENDING; /* we commit to handling */
-		status |= IRQ_INPROGRESS; /* we are handling it */
+		if (!(status & IRQ_PER_CPU))
+			status |= IRQ_INPROGRESS; /* we are handling it */
 	}
 	desc->status = status;
 
diff -urN linux-davidm/arch/ia64/kernel/irq_ia64.c linux-2.3.99-pre5-lia/arch/ia64/kernel/irq_ia64.c
--- linux-davidm/arch/ia64/kernel/irq_ia64.c	Fri Apr 21 18:50:34 2000
+++ linux-2.3.99-pre5-lia/arch/ia64/kernel/irq_ia64.c	Mon Apr 24 19:00:21 2000
@@ -210,12 +210,12 @@
 	ia64_set_lrr0(0, 1);	
 	ia64_set_lrr1(0, 1);	
 
-	irq_desc[TIMER_IRQ].handler	    = &irq_type_ia64_sapic;
 	irq_desc[IA64_SPURIOUS_INT].handler = &irq_type_ia64_sapic;
 #ifdef CONFIG_SMP
 	/* 
 	 * Configure the IPI vector and handler
 	 */
+	irq_desc[IPI_IRQ].status |= IRQ_PER_CPU;
 	irq_desc[IPI_IRQ].handler = &irq_type_ia64_sapic;
 	setup_irq(IPI_IRQ, &ipi_irqaction);
 #endif
diff -urN linux-davidm/arch/ia64/kernel/ivt.S linux-2.3.99-pre5-lia/arch/ia64/kernel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Fri Apr 21 18:50:34 2000
+++ linux-2.3.99-pre5-lia/arch/ia64/kernel/ivt.S	Fri Apr 21 20:18:50 2000
@@ -441,9 +441,6 @@
 	tbit.z p6,p0=r17,IA64_PSR_IS_BIT	// IA64 instruction set?
 	;;
 (p6)	mov r16=r18				// if so, use cr.iip instead of cr.ifa
-#if 0
-	;;
-#endif
 	mov pr=r31,-1
 #endif /* CONFIG_ITANIUM */
 	movl r30				// load continuation point in case of nested fault
@@ -581,7 +578,7 @@
 	SAVE_REST
 	;;
 	alloc r14=ar.pfs,0,0,2,0 // must be first in an insn group
-#ifdef	CONFIG_ITANIUM_ASTEP_SPECIFIC
+#ifdef CONFIG_ITANIUM_ASTEP_SPECIFIC
 	mov out0=r0		// defer reading of cr.ivr to handle_irq...
 #else
 	mov out0=cr.ivr		// pass cr.ivr as first arg
diff -urN linux-davidm/arch/ia64/kernel/process.c linux-2.3.99-pre5-lia/arch/ia64/kernel/process.c
--- linux-davidm/arch/ia64/kernel/process.c	Fri Mar 10 15:24:02 2000
+++ linux-2.3.99-pre5-lia/arch/ia64/kernel/process.c	Fri Apr 21 21:53:49 2000
@@ -98,11 +98,18 @@
 		if (pm_idle)
 			(*pm_idle)();
 #ifdef CONFIG_ITANIUM_ASTEP_SPECIFIC
-		if (ia64_get_itm() < ia64_get_itc()) {
-			extern void ia64_reset_itm (void);
+		{
+			u64 itc, itm;
 
-			printk("cpu_idle: ITM in past, resetting it...\n");
-			ia64_reset_itm();
+			itc = ia64_get_itc();
+			itm = ia64_get_itm();
+			if (time_after(itc, itm)) {
+				extern void ia64_reset_itm (void);
+
+				printk("cpu_idle: ITM in past, resetting it (itc=%lx,itm=%lx:%lums)...\n",
+				       itc, itm, (itc - itm)/500000);
+				ia64_reset_itm();
+			}
 		}
 #endif
 	}
diff -urN linux-davidm/arch/ia64/kernel/time.c linux-2.3.99-pre5-lia/arch/ia64/kernel/time.c
--- linux-davidm/arch/ia64/kernel/time.c	Fri Apr 21 18:50:34 2000
+++ linux-2.3.99-pre5-lia/arch/ia64/kernel/time.c	Mon Apr 24 18:58:49 2000
@@ -34,7 +34,10 @@
 
 static struct {
 	unsigned long delta;
-	unsigned long next[NR_CPUS];
+	union {
+		unsigned long count;
+		unsigned char pad[SMP_CACHE_BYTES];
+	} next[NR_CPUS];
 } itm;
 
 static void
@@ -69,16 +72,24 @@
 static inline unsigned long
 gettimeoffset (void)
 {
+#ifdef CONFIG_SMP
+	/*
+	 * The code below doesn't work for SMP because only CPU 0
+	 * keeps track of the time.
+	 */
+	return 0;
+#else
 	unsigned long now = ia64_get_itc();
 	unsigned long elapsed_cycles, lost;
 
-	elapsed_cycles = now - (itm.next[smp_processor_id()] - itm.delta);
+	elapsed_cycles = now - (itm.next[smp_processor_id()].count - itm.delta);
 
 	lost = lost_ticks;
 	if (lost)
 		elapsed_cycles += lost*itm.delta;
 
 	return (elapsed_cycles*my_cpu_data.usec_per_cyc) >> IA64_USEC_PER_CYC_SHIFT;
+#endif
 }
 
 void
@@ -164,7 +175,7 @@
 		do_timer(regs);
 #endif
 
-		itm.next[cpu] += itm.delta;
+		itm.next[cpu].count += itm.delta;
 		/*
 		 * There is a race condition here: to be on the "safe"
 		 * side, we process timer ticks until itm.next is
@@ -172,8 +183,8 @@
 		 * interval.  This should give us enough time to set
 		 * the new itm value without losing a timer tick.
 		 */
-		if (time_after(itm.next[cpu], ia64_get_itc() + itm.delta/2)) {
-			ia64_set_itm(itm.next[cpu]);
+		if (time_after(itm.next[cpu].count, ia64_get_itc() + itm.delta/2)) {
+			ia64_set_itm(itm.next[cpu].count);
 			break;
 		}
 
@@ -182,19 +193,21 @@
 		 * SoftSDV in SMP mode is _slow_, so we do "lose" ticks, 
 		 * but it's really OK...
 		 */
+		write_unlock(&xtime_lock);
 		if (count > 0 && jiffies - last_time > 5*HZ)
 			count = 0;
 		if (count++ = 0) {
 			last_time = jiffies;
 			if (!printed) {
 				printk("Lost clock tick on CPU %d (now=%lx, next=%lx)!!\n",
-				       cpu, ia64_get_itc(), itm.next[cpu]);
+				       cpu, ia64_get_itc(), itm.next[cpu].count);
 				printed = 1;
-			}
 # ifdef CONFIG_IA64_DEBUG_IRQ
-			printk("last_cli_ip=%lx\n", last_cli_ip);
+				printk("last_cli_ip=%lx\n", last_cli_ip);
 # endif
+			}
 		}
+		write_lock(&xtime_lock);
 #endif
 	}
 	write_unlock(&xtime_lock);
@@ -202,7 +215,7 @@
 
 #ifdef CONFIG_ITANIUM_ASTEP_SPECIFIC
 
-void 
+void
 ia64_reset_itm (void)
 {
 	unsigned long flags;
@@ -220,11 +233,14 @@
 void __init
 ia64_cpu_local_tick(void)
 {
+#ifdef CONFIG_IA64_SOFTSDV_HACKS
+	ia64_set_itc(0);
+#endif
+
 	/* arrange for the cycle counter to generate a timer interrupt: */
 	ia64_set_itv(TIMER_IRQ, 0);
-	ia64_set_itc(0);
-	itm.next[smp_processor_id()] = ia64_get_itc() + itm.delta;
-	ia64_set_itm(itm.next[smp_processor_id()]);
+	itm.next[smp_processor_id()].count = ia64_get_itc() + itm.delta;
+	ia64_set_itm(itm.next[smp_processor_id()].count);
 }
 
 void __init
@@ -313,6 +329,8 @@
 time_init (void)
 {
 	/* we can't do request_irq() here because the kmalloc() would fail... */
+	irq_desc[TIMER_IRQ].status |= IRQ_PER_CPU;
+	irq_desc[TIMER_IRQ].handler = &irq_type_ia64_sapic;
 	setup_irq(TIMER_IRQ, &timer_irqaction);
 
 	efi_gettimeofday(&xtime);
diff -urN linux-davidm/drivers/ide/piix.c linux-2.3.99-pre5-lia/drivers/ide/piix.c
--- linux-davidm/drivers/ide/piix.c	Wed Mar 22 17:18:44 2000
+++ linux-2.3.99-pre5-lia/drivers/ide/piix.c	Fri Apr 21 00:00:32 2000
@@ -396,8 +396,11 @@
 
 void __init ide_init_piix (ide_hwif_t *hwif)
 {
+#if 0
+	/* autoprobe instead... --davidm 00/04/20 */
 	if (!hwif->irq)
 		hwif->irq = hwif->channel ? 15 : 14;
+#endif
 
 	hwif->tuneproc = &piix_tune_drive;
 	hwif->drives[0].autotune = 1;
diff -urN linux-davidm/fs/binfmt_elf.c linux-2.3.99-pre5-lia/fs/binfmt_elf.c
--- linux-davidm/fs/binfmt_elf.c	Fri Apr 21 18:50:35 2000
+++ linux-2.3.99-pre5-lia/fs/binfmt_elf.c	Thu Apr 20 17:43:21 2000
@@ -282,8 +282,8 @@
 	    set_brk(ia32_mm_addr(vaddr + load_addr), vaddr + load_addr + eppnt->p_memsz);
 	    memset((char *) vaddr + load_addr + eppnt->p_filesz, 0,
 		   eppnt->p_memsz - eppnt->p_filesz);
-	    read_exec(interpreter->f_dentry, eppnt->p_offset,
-		      (char *)(vaddr + load_addr), eppnt->p_filesz, 0);
+	    kernel_read(interpreter, eppnt->p_offset, (char *)(vaddr + load_addr),
+			eppnt->p_filesz);
 	    map_addr = vaddr + load_addr;
 #else /* !CONFIG_BINFMT_ELF32 */
 	    map_addr = do_mmap(interpreter,
@@ -299,9 +299,8 @@
 			   (unsigned long) eppnt->p_memsz, (unsigned long) eppnt->p_filesz);
 		    map_addr = vaddr + load_addr;
 		    do_brk(map_addr & PAGE_MASK, eppnt->p_filesz);
-		    if (read_exec(file->f_dentry, eppnt->p_offset, (char *) map_addr,
-				  eppnt->p_filesz, 0)
-			< 0)
+		    if (kernel_read(interpreter, eppnt->p_offset, (char *) map_addr,
+				    eppnt->p_filesz) < 0)
 			    goto out_close;
 	    }
 
@@ -650,8 +649,8 @@
 		set_brk(ia32_mm_addr(vaddr + load_bias), vaddr + load_bias + elf_ppnt->p_memsz);
 		memset((char *) vaddr + load_bias + elf_ppnt->p_filesz, 0,
 		       elf_ppnt->p_memsz - elf_ppnt->p_filesz);
-		read_exec(bprm->dentry, elf_ppnt->p_offset,
-			  (char *)(vaddr + load_bias), elf_ppnt->p_filesz, 0);
+		kernel_read(bprm->file, elf_ppnt->p_offset, (char *) (vaddr + load_bias),
+			    elf_ppnt->p_filesz);
 		error = vaddr + load_bias;
 #else /* CONFIG_BINFMT_ELF32 */
 		error = do_mmap(bprm->file, ELF_PAGESTART(load_bias + vaddr),
@@ -667,8 +666,8 @@
 			       (unsigned long)elf_ppnt->p_filesz);
 			error = vaddr + load_bias;
 			do_brk(error & PAGE_MASK, elf_ppnt->p_filesz);
-			error = read_exec(bprm->dentry, elf_ppnt->p_offset, (char *) error,
-					  elf_ppnt->p_filesz, 0);
+			error = kernel_read(bprm->file, elf_ppnt->p_offset, (char *) error,
+					    elf_ppnt->p_filesz);
 		}
 
 		if (!load_addr_set) {
diff -urN linux-davidm/include/asm-ia64/spinlock.h linux-2.3.99-pre5-lia/include/asm-ia64/spinlock.h
--- linux-davidm/include/asm-ia64/spinlock.h	Fri Apr 21 18:50:35 2000
+++ linux-2.3.99-pre5-lia/include/asm-ia64/spinlock.h	Mon Apr 24 17:17:15 2000
@@ -9,6 +9,8 @@
  * This file is used for SMP configurations only.
  */
 
+#include <linux/kernel.h>
+
 #include <asm/system.h>
 #include <asm/bitops.h>
 #include <asm/atomic.h>
@@ -40,7 +42,7 @@
        "cmp4.eq p0,p7 = r0, r2\n" \
        "(p7) br.cond.spnt.few 1b\n" \
        ";;\n" \
-       :: "m" __atomic_fool_gcc((x)) : "r2", "r29")
+       :: "m" __atomic_fool_gcc((x)) : "r2", "r29", "memory")
  
 #else 
 #define spin_lock(x)					\
@@ -55,22 +57,12 @@
 
 #define spin_is_locked(x)	((x)->lock != 0)
 
-#define spin_unlock(x)		(((spinlock_t *) x)->lock = 0)
+#define spin_unlock(x)		({((spinlock_t *) x)->lock = 0; barrier();})
 
 /* Streamlined !test_and_set_bit(0, (x)) */
-#define spin_trylock(x)						\
-({								\
-	spinlock_t *__x = (x);					\
-	__u32 old;						\
-								\
-	do {							\
-		old = __x->lock;				\
-	} while (cmpxchg_acq(&__x->lock, old, 1) != old);	\
-	old = 0;						\
-})
+#define spin_trylock(x)		(cmpxchg_acq(&(x)->lock, 0, 1) = 0)
 
-#define spin_unlock_wait(x) \
-	({ do { barrier(); } while(((volatile spinlock_t *)x)->lock); })
+#define spin_unlock_wait(x)	({ do { barrier(); } while ((x)->lock); })
 
 typedef struct {
 	volatile int read_counter:31;
@@ -78,45 +70,49 @@
 } rwlock_t;
 #define RW_LOCK_UNLOCKED (rwlock_t) { 0, 0 }
 
-#define read_lock(rw)									\
-do {											\
-	int tmp = 0;									\
-	__asm__ __volatile__ ("1:\tfetchadd4.acq %0 = %1, 1\n"				\
-			      ";;\n"							\
-			      "tbit.nz p6,p0 = %0, 31\n"				\
-			      "(p6) br.cond.sptk.few 2f\n"				\
-			      ".section .text.lock,\"ax\"\n"				\
-			      "2:\tfetchadd4.rel %0 = %1, -1\n"				\
-			      ";;\n"							\
-			      "3:\tld4.acq %0 = %1\n"					\
-			      ";;\n"							\
-			      "tbit.nz p6,p0 = %0, 31\n"				\
-			      "(p6) br.cond.sptk.few 3b\n"				\
-			      "br.cond.sptk.few 1b\n"					\
-			      ";;\n"							\
-			      ".previous\n": "=r" (tmp), "=m" (__atomic_fool_gcc(rw)));	\
+#define read_lock(rw)							 \
+do {									 \
+	int tmp = 0;							 \
+	__asm__ __volatile__ ("1:\tfetchadd4.acq %0 = %1, 1\n"		 \
+			      ";;\n"					 \
+			      "tbit.nz p6,p0 = %0, 31\n"		 \
+			      "(p6) br.cond.sptk.few 2f\n"		 \
+			      ".section .text.lock,\"ax\"\n"		 \
+			      "2:\tfetchadd4.rel %0 = %1, -1\n"		 \
+			      ";;\n"					 \
+			      "3:\tld4.acq %0 = %1\n"			 \
+			      ";;\n"					 \
+			      "tbit.nz p6,p0 = %0, 31\n"		 \
+			      "(p6) br.cond.sptk.few 3b\n"		 \
+			      "br.cond.sptk.few 1b\n"			 \
+			      ";;\n"					 \
+			      ".previous\n"				 \
+			      : "=r" (tmp), "=m" (__atomic_fool_gcc(rw)) \
+			      :: "memory");				 \
 } while(0)
 
-#define read_unlock(rw)								\
-do {										\
-	int tmp = 0;								\
-	__asm__ __volatile__ ("fetchadd4.rel %0 = %1, -1\n"			\
-			      : "=r" (tmp) : "m" (__atomic_fool_gcc(rw)));	\
+#define read_unlock(rw)						\
+do {								\
+	int tmp = 0;						\
+	__asm__ __volatile__ ("fetchadd4.rel %0 = %1, -1\n"	\
+			      : "=r" (tmp)			\
+			      : "m" (__atomic_fool_gcc(rw))	\
+			      : "memory");			\
 } while(0)
 
 #define write_lock(rw)				\
-while(1) {					\
+do {						\
 	do {					\
-	} while (!test_and_set_bit(31, (rw)));	\
-	if ((rw)->read_counter) {		\
-		clear_bit(31, (rw));		\
-		while ((rw)->read_counter)	\
-			;			\
-	} else {				\
-		break;				\
-	}					\
-}
+		while ((rw)->write_lock);	\
+	} while (test_and_set_bit(31, (rw)));	\
+	while ((rw)->read_counter);		\
+	barrier();				\
+} while (0)
 
-#define write_unlock(x)				(clear_bit(31, (x)))
+/*
+ * clear_bit() has "acq" semantics; we're really need "rel" semantics,
+ * but for simplicity, we simply do a fence for now...
+ */
+#define write_unlock(x)				({clear_bit(31, (x)); mb();})
 
 #endif /*  _ASM_IA64_SPINLOCK_H */
diff -urN linux-davidm/include/linux/irq.h linux-2.3.99-pre5-lia/include/linux/irq.h
--- linux-davidm/include/linux/irq.h	Fri Apr 21 18:50:35 2000
+++ linux-2.3.99-pre5-lia/include/linux/irq.h	Mon Apr 24 17:17:24 2000
@@ -18,6 +18,7 @@
 #define IRQ_WAITING	32	/* IRQ not yet seen - for autodetection */
 #define IRQ_LEVEL	64	/* IRQ level triggered */
 #define IRQ_MASKED	128	/* IRQ masked - shouldn't be seen again */
+#define IRQ_PER_CPU	256	/* IRQ is per CPU */
 
 /*
  * Interrupt controller descriptor. This is all we need
diff -urN linux-davidm/kernel/module.c linux-2.3.99-pre5-lia/kernel/module.c
--- linux-davidm/kernel/module.c	Fri Apr 21 18:50:35 2000
+++ linux-2.3.99-pre5-lia/kernel/module.c	Thu Apr 20 10:28:24 2000
@@ -800,6 +800,7 @@
 {
 	struct module_ref *dep;
 	unsigned i;
+
 	/* Let the module clean up.  */
 
 	if (mod->flags & MOD_RUNNING) 
@@ -1000,12 +1001,6 @@
 #else		/* CONFIG_MODULES */
 
 /* Dummy syscalls for people who don't want modules */
-
-int
-try_inc_mod_count (struct module *mod)
-{
-	return 1;
-}
 
 asmlinkage unsigned long
 sys_create_module(const char *name_user, size_t size)
diff -urN linux-davidm/kernel/printk.c linux-2.3.99-pre5-lia/kernel/printk.c
--- linux-davidm/kernel/printk.c	Fri Apr 21 18:50:35 2000
+++ linux-2.3.99-pre5-lia/kernel/printk.c	Fri Apr 21 18:29:29 2000
@@ -14,6 +14,8 @@
  *     manfreds@colorfullife.com
  */
 
+#include <linux/config.h>
+
 #include <linux/mm.h>
 #include <linux/tty_driver.h>
 #include <linux/smp_lock.h>
@@ -504,7 +506,7 @@
 
 #define VGABASE		((char *)0x00000000000b8000)
 
-static int current_ypos = 0, current_xpos = 0;
+static int current_ypos = 50, current_xpos = 0;
 
 void
 early_printk (const char *str)
@@ -515,13 +517,13 @@
 	while ((c = *str++) != '\0') {
 		if (current_ypos >= 50) {
 			/* scroll 1 line up */
-			for(k = 1, j = 0; k < 50; k++, j++) {
-				for(i = 0; i < 80; i++) {
+			for (k = 1, j = 0; k < 50; k++, j++) {
+				for (i = 0; i < 80; i++) {
 					writew(readw(VGABASE + 2*(80*k + i)),
 					       VGABASE + 2*(80*j + i));
 				}
 			}
-			for(i = 0; i < 80; i++) {
+			for (i = 0; i < 80; i++) {
 				writew(0x720, VGABASE + 2*(80*j + i));
 			}
 			current_ypos = 49;



