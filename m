From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 05 Oct 2000 19:01:10 +0000
Subject: [Linux-ia64] kernel update (relative to v2.4.0-test9)
Message-Id: <marc-linux-ia64-105590678205548@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest IA-64 Linux kernel diff is now available at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

in file linux-2.4.0-test9-ia64-001004.diff.  Actually, it has been
available since last night, but I ran into some problems booting the
new kernel remotely so I couldn't actually test it until this morning.

Here is a summary of what changed since the last kernel:

 - Stephane's perfmon updates (warning: this is works in progress;
   especially the changes to ptrace will disappear so don't write user
   apps that depend on this way of accessing the PMU...)
 - SGI SN1 updates (Kanoj); also stash away coherence domain info
   in global variable "ia64_ptc_domain_info"
 - Asit's patch to support running with VHPT disabled; this is for
   kernel hacking only and should not be used for normal operation.
   This patch uncovered some bad kernel references which were also
   fixed.
 - With SMP, do sync.i in context switch to ensure "fc"s are visible
   on all CPUs (Asit)
 - TLB handler fixes by Patrick and yours truly.
 - qlogic SCSI driver update (BJ).
 - Remove IA-64 version of ioperm syscall and fix vt.c to not
   support the ioctl that used this call
 - Added 32-bit division routines required by latest CVS compiler.
   32-bit division can get away with one fewer iteration and also
   uses few enough fp registers that we don't need to save/restore
   anything.
 - Fix SMP BogoMIPS calculation and printing; the BogoMIPS values
   are now really per-CPU
 - Various minor and not so minor updates to the kernel unwinder.
 - Fixed SCSI disk driver so it works when compiled into the kernel
   (yes, this is a generic test9 bug; Linus must have been in a hurry
    to catch that plane to Germany... ;-).
 - __atomic_fool_gcc() disappeared.  It shouldn't be necessary with
   the compilers available for IA-64 Linux.
 - Replace "extern inline" with "static inline".
 - Change HZ for simulator to 32 Hz; the kernel time-of-day code is
   more accurate if HZ is an integer power of two.
 - Add parport.h needed by some kernel modules.
 - Various updates to get things in sync with 2.4.0-test9

That should be it.  This kernel is known to boot fine on 4-way Lion,
2-way and 1-way Big Sur, as well as the HP Ski simulator.

Enjoy,

	--david

diff -urN linux-davidm/arch/ia64/Makefile linux-2.4.0-test9-lia/arch/ia64/Makefile
--- linux-davidm/arch/ia64/Makefile	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/arch/ia64/Makefile	Wed Oct  4 21:32:24 2000
@@ -46,11 +46,18 @@
                                 $(CORE_FILES)
 endif
 
-ifdef CONFIG_IA64_SGI_SN1_SIM
+ifdef CONFIG_IA64_SGI_SN1
+CFLAGS := $(CFLAGS) -DSN -I. -DBRINGUP -DDIRECT_L1_CONSOLE \
+		-DNUMA_BASE -DSIMULATED_KLGRAPH -DNUMA_MIGR_CONTROL  \
+		-DLITTLE_ENDIAN -DREAL_HARDWARE -DLANGUAGE_C=1 	     \
+		-D_LANGUAGE_C=1
         SUBDIRS         :=      arch/$(ARCH)/sn/sn1	\
 				arch/$(ARCH)/sn		\
+				arch/$(ARCH)/sn/io	\
+				arch/$(ARCH)/sn/fprom	\
 				$(SUBDIRS)
         CORE_FILES      :=      arch/$(ARCH)/sn/sn.a	\
+				arch/$(ARCH)/sn/io/sgiio.o\
 				$(CORE_FILES)
 endif
 
diff -urN linux-davidm/arch/ia64/config.in linux-2.4.0-test9-lia/arch/ia64/config.in
--- linux-davidm/arch/ia64/config.in	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/arch/ia64/config.in	Wed Oct  4 21:32:56 2000
@@ -27,7 +27,7 @@
 	"generic		CONFIG_IA64_GENERIC		\
 	 DIG-compliant		CONFIG_IA64_DIG			\
 	 HP-simulator		CONFIG_IA64_HP_SIM		\
-	 SN1-simulator		CONFIG_IA64_SGI_SN1_SIM" generic
+	 SGI-SN1		CONFIG_IA64_SGI_SN1" generic
 
 choice 'Kernel page size'						\
 	"4KB			CONFIG_IA64_PAGE_SIZE_4KB		\
@@ -61,9 +61,20 @@
 	fi
 fi
 
-if [ "$CONFIG_IA64_SGI_SN1_SIM" = "y" ]; then
-	define_bool CONFIG_NUMA y
-	define_bool CONFIG_IA64_SOFTSDV_HACKS y
+if [ "$CONFIG_IA64_SGI_SN1" = "y" ]; then
+	bool '  Enable use of global TLB purge instruction (ptc.g)' CONFIG_ITANIUM_PTCG
+	bool '  Enable Itanium B-step specific code' CONFIG_ITANIUM_BSTEP_SPECIFIC
+	if [ "$CONFIG_ITANIUM_BSTEP_SPECIFIC" = "y" ]; then
+	  bool '    Enable Itanium B0-step specific code' CONFIG_ITANIUM_B0_SPECIFIC
+	fi
+	bool '  Enable SGI Medusa Simulator Support' CONFIG_IA64_SGI_SN1_SIM n
+        bool '  Enable SGI hack for version 1.0 syngery bugs' CONFIG_IA64_SGI_SYNERGY_1_0_HACKS n
+	define_bool CONFIG_DEVFS_DEBUG y
+	define_bool CONFIG_DEVFS_FS y
+	define_bool CONFIG_IA64_BRL_EMU y
+	define_bool CONFIG_IA64_MCA y
+	define_bool CONFIG_IA64_SGI_IO y
+	define_bool CONFIG_ITANIUM y
 fi
 
 define_bool CONFIG_KCORE_ELF y	# On IA-64, we always want an ELF /proc/kcore.
@@ -237,5 +248,6 @@
 bool 'Turn on irq debug checks (slow!)' CONFIG_IA64_DEBUG_IRQ
 bool 'Print possible IA64 hazards to console' CONFIG_IA64_PRINT_HAZARDS
 bool 'Enable new unwind support' CONFIG_IA64_NEW_UNWIND
+bool 'Disable VHPT' CONFIG_DISABLE_VHPT
 
 endmenu
diff -urN linux-davidm/arch/ia64/dig/iosapic.c linux-2.4.0-test9-lia/arch/ia64/dig/iosapic.c
--- linux-davidm/arch/ia64/dig/iosapic.c	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/arch/ia64/dig/iosapic.c	Wed Oct  4 21:33:55 2000
@@ -386,7 +386,7 @@
 	unsigned int ver, v;
 	int l, max_pin;
 
-	ver = iosapic_version(iosapic->address);
+	ver = iosapic_version((unsigned long) ioremap(iosapic->address, 0));
 	max_pin = (ver >> 16) & 0xff;
 	
 	printk("IOSAPIC Version %x.%x: address 0x%lx IRQs 0x%x - 0x%x\n", 
diff -urN linux-davidm/arch/ia64/kernel/Makefile linux-2.4.0-test9-lia/arch/ia64/kernel/Makefile
--- linux-davidm/arch/ia64/kernel/Makefile	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/arch/ia64/kernel/Makefile	Wed Oct  4 21:34:23 2000
@@ -16,7 +16,7 @@
 obj-$(CONFIG_IA64_GENERIC) += machvec.o
 obj-$(CONFIG_IA64_PALINFO) += palinfo.o
 obj-$(CONFIG_PCI) += pci.o
-obj-$(CONFIG_SMP) += smp.o
+obj-$(CONFIG_SMP) += smp.o smpboot.o
 obj-$(CONFIG_IA64_MCA) += mca.o mca_asm.o
 obj-$(CONFIG_IA64_BRL_EMU) += brl_emu.o
 
diff -urN linux-davidm/arch/ia64/kernel/acpi.c linux-2.4.0-test9-lia/arch/ia64/kernel/acpi.c
--- linux-davidm/arch/ia64/kernel/acpi.c	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/arch/ia64/kernel/acpi.c	Wed Oct  4 21:34:32 2000
@@ -136,13 +136,12 @@
 		break;
 	}
 
-#if 1/*def ACPI_DEBUG*/
+# ifdef ACPI_DEBUG
 	printk("Legacy ISA IRQ %x -> IA64 Vector %x IOSAPIC Pin %x Active %s %s Trigger\n", 
 	       legacy->isa_irq, vector, iosapic_pin(vector), 
 	       ((iosapic_polarity(vector) = IO_SAPIC_POL_LOW) ? "Low" : "High"),
 	       ((iosapic_trigger(vector) = IO_SAPIC_LEVEL) ? "Level" : "Edge"));
-#endif /* ACPI_DEBUG */
-
+# endif /* ACPI_DEBUG */
 #endif /* CONFIG_IA64_IRQ_ACPI */
 }
 
@@ -279,7 +278,7 @@
 #else
 # if defined (CONFIG_IA64_HP_SIM)
 	return "hpsim";
-# elif defined (CONFIG_IA64_SGI_SN1_SIM)
+# elif defined (CONFIG_IA64_SGI_SN1)
 	return "sn1";
 # elif defined (CONFIG_IA64_DIG)
 	return "dig";
diff -urN linux-davidm/arch/ia64/kernel/efi.c linux-2.4.0-test9-lia/arch/ia64/kernel/efi.c
--- linux-davidm/arch/ia64/kernel/efi.c	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/arch/ia64/kernel/efi.c	Wed Oct  4 21:34:44 2000
@@ -376,6 +376,16 @@
 #endif
 
 	efi_map_pal_code();
+
+#ifndef CONFIG_IA64_SOFTSDV_HACKS
+	/*
+	 * (Some) SoftSDVs seem to have a problem with this call.
+	 * Since it's mostly a performance optimization, just don't do
+	 * it for now...  --davidm 99/12/6
+	 */
+	efi_enter_virtual_mode();
+#endif
+
 }
 
 void
diff -urN linux-davidm/arch/ia64/kernel/entry.S linux-2.4.0-test9-lia/arch/ia64/kernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Fri Sep  8 14:34:53 2000
+++ linux-2.4.0-test9-lia/arch/ia64/kernel/entry.S	Wed Oct  4 23:08:09 2000
@@ -120,6 +120,9 @@
 	mov r13=in0		// set "current" pointer
 	;;
 	DO_LOAD_SWITCH_STACK( )
+#ifdef CONFIG_SMP
+	sync.i			// ensure "fc"s done by this CPU are visible on other CPUs
+#endif
 	br.ret.sptk.few rp
 END(ia64_switch_to)
 
@@ -1088,7 +1091,7 @@
 	data8 sys_setpriority
 	data8 sys_statfs
 	data8 sys_fstatfs
-	data8 sys_ioperm			// 1105
+	data8 ia64_ni_syscall
 	data8 sys_semget
 	data8 sys_semop
 	data8 sys_semctl
diff -urN linux-davidm/arch/ia64/kernel/ia64_ksyms.c linux-2.4.0-test9-lia/arch/ia64/kernel/ia64_ksyms.c
--- linux-davidm/arch/ia64/kernel/ia64_ksyms.c	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/arch/ia64/kernel/ia64_ksyms.c	Wed Oct  4 21:35:21 2000
@@ -97,13 +97,23 @@
 EXPORT_SYMBOL(__ia64_syscall);
 
 /* from arch/ia64/lib */
+extern void __divsi3(void);
+extern void __udivsi3(void);
+extern void __modsi3(void);
+extern void __umodsi3(void);
 extern void __divdi3(void);
 extern void __udivdi3(void);
 extern void __moddi3(void);
 extern void __umoddi3(void);
 
+EXPORT_SYMBOL_NOVERS(__divsi3);
+EXPORT_SYMBOL_NOVERS(__udivsi3);
+EXPORT_SYMBOL_NOVERS(__modsi3);
+EXPORT_SYMBOL_NOVERS(__umodsi3);
 EXPORT_SYMBOL_NOVERS(__divdi3);
 EXPORT_SYMBOL_NOVERS(__udivdi3);
 EXPORT_SYMBOL_NOVERS(__moddi3);
 EXPORT_SYMBOL_NOVERS(__umoddi3);
 
+extern unsigned long ia64_iobase;
+EXPORT_SYMBOL(ia64_iobase);
diff -urN linux-davidm/arch/ia64/kernel/irq_ia64.c linux-2.4.0-test9-lia/arch/ia64/kernel/irq_ia64.c
--- linux-davidm/arch/ia64/kernel/irq_ia64.c	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/arch/ia64/kernel/irq_ia64.c	Wed Oct  4 21:35:32 2000
@@ -39,7 +39,8 @@
 spinlock_t ivr_read_lock;
 #endif
 
-unsigned long ipi_base_addr = IPI_DEFAULT_BASE_ADDR;	/* default base addr of IPI table */
+/* default base addr of IPI table */
+unsigned long ipi_base_addr = (__IA64_UNCACHED_OFFSET | IPI_DEFAULT_BASE_ADDR);	
 
 /*
  * Legacy IRQ to IA-64 vector translation table.  Any vector not in
diff -urN linux-davidm/arch/ia64/kernel/ivt.S linux-2.4.0-test9-lia/arch/ia64/kernel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/arch/ia64/kernel/ivt.S	Wed Oct  4 21:36:12 2000
@@ -196,32 +196,32 @@
 	 * The speculative access will fail if there is no TLB entry
 	 * for the L3 page table page we're trying to access.
 	 */
-	mov r16=cr.iha				// get virtual address of L3 PTE
-	mov r19=cr.ifa				// get virtual address
+	mov r16=cr.ifa				// get virtual address
+	mov r19=cr.iha				// get virtual address of L3 PTE
 	;;
-	ld8.s r17=[r16]				// try to read L3 PTE
+	ld8.s r17=[r19]				// try to read L3 PTE
 	mov r31=pr				// save predicates
 	;;
-	tnat.nz p6,p0=r16			// did read succeed?
+	tnat.nz p6,p0=r17			// did read succeed?
 (p6)	br.cond.spnt.many 1f
 	;;
 	itc.i r17
 	;;
 #ifdef CONFIG_SMP
-	ld8.s r18=[r16]				// try to read L3 PTE again and see if same
+	ld8.s r18=[r19]				// try to read L3 PTE again and see if same
 	mov r20=PAGE_SHIFT<<2			// setup page size for purge
 	;;
 	cmp.eq p6,p7=r17,r18
 	;;
-(p7)	ptc.l r19,r20	
+(p7)	ptc.l r16,r20
 #endif
-
 	mov pr=r31,-1
 	rfi
 
-1:	mov r16=cr.ifa				// get address that caused the TLB miss
-	;;
-	rsm psr.dt				// use physical addressing for data
+#ifdef CONFIG_DISABLE_VHPT
+itlb_fault:
+#endif
+1:	rsm psr.dt				// use physical addressing for data
 	mov r19=ar.k7				// get page table base address
 	shl r21=r16,3				// shift bit 60 into sign bit
 	shr.u r17=r16,61			// get the region number into r17
@@ -283,31 +283,32 @@
 	 * The speculative access will fail if there is no TLB entry
 	 * for the L3 page table page we're trying to access.
 	 */
-	mov r16=cr.iha				// get virtual address of L3 PTE
-	mov r19=cr.ifa				// get virtual address
+	mov r16=cr.ifa				// get virtual address
+	mov r19=cr.iha				// get virtual address of L3 PTE
 	;;
-	ld8.s r17=[r16]				// try to read L3 PTE
+	ld8.s r17=[r19]				// try to read L3 PTE
 	mov r31=pr				// save predicates
 	;;
-	tnat.nz p6,p0=r16			// did read succeed?
+	tnat.nz p6,p0=r17			// did read succeed?
 (p6)	br.cond.spnt.many 1f
 	;;
 	itc.d r17
 	;;
 #ifdef CONFIG_SMP
-	ld8.s r18=[r16]				// try to read L3 PTE again and see if same
+	ld8.s r18=[r19]				// try to read L3 PTE again and see if same
 	mov r20=PAGE_SHIFT<<2			// setup page size for purge
 	;;
 	cmp.eq p6,p7=r17,r18
 	;;
-(p7)	ptc.l r19,r20	
+(p7)	ptc.l r16,r20
 #endif
 	mov pr=r31,-1
 	rfi
 
-1:	mov r16=cr.ifa				// get address that caused the TLB miss
-	;;
-	rsm psr.dt				// use physical addressing for data
+#ifdef CONFIG_DISABLE_VHPT
+dtlb_fault:
+#endif
+1:	rsm psr.dt				// use physical addressing for data
 	mov r19=ar.k7				// get page table base address
 	shl r21=r16,3				// shift bit 60 into sign bit
 	shr.u r17=r16,61			// get the region number into r17
@@ -360,6 +361,16 @@
 /////////////////////////////////////////////////////////////////////////////////////////
 // 0x0c00 Entry 3 (size 64 bundles) Alt ITLB (19)
 	mov r16=cr.ifa		// get address that caused the TLB miss
+#ifdef CONFIG_DISABLE_VHPT
+	mov r31=pr
+	;;
+	shr.u r21=r16,61			// get the region number into r21
+	;;
+	cmp.gt p6,p0=6,r21			// user mode 
+(p6)	br.cond.dptk.many itlb_fault
+	;;
+	mov pr=r31,-1
+#endif
 	movl r17=__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RX
 	;;
 	shr.u r18=r16,57	// move address bit 61 to bit 4
@@ -380,8 +391,14 @@
 	movl r17=__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RW
 	mov r20=cr.isr
 	mov r21=cr.ipsr
-	mov r19=pr
+	mov r31=pr
 	;;
+#ifdef CONFIG_DISABLE_VHPT
+	shr.u r22=r16,61			// get the region number into r21
+	;;
+	cmp.gt p8,p0=6,r22			// user mode
+(p8)	br.cond.dptk.many dtlb_fault
+#endif
 	tbit.nz p6,p7=r20,IA64_ISR_SP_BIT	// is speculation bit on?
 	shr.u r18=r16,57	// move address bit 61 to bit 4
 	dep r16=0,r16,IA64_MAX_PHYS_BITS,(64-IA64_MAX_PHYS_BITS) // clear ed & reserved bits
@@ -394,7 +411,7 @@
 (p6)	mov cr.ipsr=r21
 	;;
 (p7)	itc.d r16		// insert the TLB entry
-	mov pr=r19,-1
+	mov pr=r31,-1
 	rfi
 
 	;;
diff -urN linux-davidm/arch/ia64/kernel/mca.c linux-2.4.0-test9-lia/arch/ia64/kernel/mca.c
--- linux-davidm/arch/ia64/kernel/mca.c	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/arch/ia64/kernel/mca.c	Wed Oct  4 21:36:32 2000
@@ -255,8 +255,11 @@
 	IA64_MCA_DEBUG("ia64_mca_init : correctable mca vector setup done\n");
 
 	ia64_mc_info.imi_mca_handler 		= __pa(ia64_os_mca_dispatch);
-	ia64_mc_info.imi_mca_handler_size	= 
-		__pa(ia64_os_mca_dispatch_end) - __pa(ia64_os_mca_dispatch);
+	/*
+	 * XXX - disable SAL checksum by setting size to 0; should be
+	 *	__pa(ia64_os_mca_dispatch_end) - __pa(ia64_os_mca_dispatch);
+	 */
+	ia64_mc_info.imi_mca_handler_size	= 0; 
 	/* Register the os mca handler with SAL */
 	if (ia64_sal_set_vectors(SAL_VECTOR_OS_MCA,
 				 ia64_mc_info.imi_mca_handler,
@@ -268,10 +271,14 @@
 
 	IA64_MCA_DEBUG("ia64_mca_init : registered os mca handler with SAL\n");
 
+	/* 
+	 * XXX - disable SAL checksum by setting size to 0, should be
+	 * IA64_INIT_HANDLER_SIZE 
+	 */
 	ia64_mc_info.imi_monarch_init_handler 		= __pa(mon_init_ptr->fp);
-	ia64_mc_info.imi_monarch_init_handler_size	= IA64_INIT_HANDLER_SIZE;
+	ia64_mc_info.imi_monarch_init_handler_size	= 0;
 	ia64_mc_info.imi_slave_init_handler 		= __pa(slave_init_ptr->fp);
-	ia64_mc_info.imi_slave_init_handler_size	= IA64_INIT_HANDLER_SIZE;
+	ia64_mc_info.imi_slave_init_handler_size	= 0;
 
 	IA64_MCA_DEBUG("ia64_mca_init : os init handler at %lx\n",ia64_mc_info.imi_monarch_init_handler);
 
diff -urN linux-davidm/arch/ia64/kernel/perfmon.c linux-2.4.0-test9-lia/arch/ia64/kernel/perfmon.c
--- linux-davidm/arch/ia64/kernel/perfmon.c	Thu Aug 24 08:17:30 2000
+++ linux-2.4.0-test9-lia/arch/ia64/kernel/perfmon.c	Wed Oct  4 21:36:39 2000
@@ -10,15 +10,19 @@
 
 #include <linux/config.h>
 #include <linux/kernel.h>
+#include <linux/init.h>
 #include <linux/sched.h>
 #include <linux/interrupt.h>
 #include <linux/smp_lock.h>
+#include <linux/proc_fs.h>
+#include <linux/ptrace.h>
 
 #include <asm/errno.h>
 #include <asm/hw_irq.h>
 #include <asm/processor.h>
 #include <asm/system.h>
 #include <asm/uaccess.h>
+#include <asm/pal.h>
 
 /* Long blurb on how this works: 
  * We set dcr.pp, psr.pp, and the appropriate pmc control values with
@@ -52,68 +56,107 @@
 #ifdef CONFIG_PERFMON
 
 #define MAX_PERF_COUNTER	4	/* true for Itanium, at least */
+#define PMU_FIRST_COUNTER	4	/* first generic counter */
+
 #define WRITE_PMCS_AND_START	0xa0
 #define WRITE_PMCS		0xa1
 #define READ_PMDS		0xa2
 #define STOP_PMCS		0xa3
-#define IA64_COUNTER_MASK	0xffffffffffffff6fL
-#define PERF_OVFL_VAL		0xffffffffL
 
-volatile int used_by_system;
 
-struct perfmon_counter {
-        unsigned long data;
-        unsigned long counter_num;
-};
+/*
+ * this structure needs to be enhanced
+ */
+typedef struct {
+	unsigned long pmu_reg_data;	/* generic PMD register */
+	unsigned long pmu_reg_num;	/* which register number */
+} perfmon_reg_t; 
+
+/*
+ * This structure is initialize at boot time and contains
+ * a description of the PMU main characteristic as indicated
+ * by PAL
+ */
+typedef struct {
+	unsigned long perf_ovfl_val;	/* overflow value for generic counters */
+	unsigned long max_pmc;		/* highest PMC */
+	unsigned long max_pmd;		/* highest PMD */
+	unsigned long max_counters;	/* number of generic counter pairs (PMC/PMD) */
+} pmu_config_t;
 
+/* XXX will go static when ptrace() is cleaned */
+unsigned long perf_ovfl_val;	/* overflow value for generic counters */
+
+static pmu_config_t pmu_conf;
+
+/*
+ * could optimize to avoid cache conflicts in SMP
+ */
 unsigned long pmds[NR_CPUS][MAX_PERF_COUNTER];
 
 asmlinkage unsigned long
-sys_perfmonctl (int cmd1, int cmd2, void *ptr)
+sys_perfmonctl (int cmd, int count, void *ptr, long arg4, long arg5, long arg6, long arg7, long arg8, long stack)
 {
-        struct perfmon_counter tmp, *cptr = ptr;
-        unsigned long cnum, dcr, flags;
-        struct perf_counter;
+	struct pt_regs *regs = (struct pt_regs *) &stack;
+        perfmon_reg_t tmp, *cptr = ptr;
+        unsigned long cnum;
         int i;
 
-        switch (cmd1) {
+        switch (cmd) {
 	      case WRITE_PMCS:           /* Writes to PMC's and clears PMDs */
 	      case WRITE_PMCS_AND_START: /* Also starts counting */
 
-		if (cmd2 <= 0 || cmd2 > MAX_PERF_COUNTER - used_by_system)
-			return -EINVAL;
-
-		if (!access_ok(VERIFY_READ, cptr, sizeof(struct perf_counter)*cmd2))
+		if (!access_ok(VERIFY_READ, cptr, sizeof(struct perfmon_reg_t)*count))
 			return -EFAULT;
 
-		current->thread.flags |= IA64_THREAD_PM_VALID;
+		for (i = 0; i < count; i++, cptr++) {
 
-		for (i = 0; i < cmd2; i++, cptr++) {
 			copy_from_user(&tmp, cptr, sizeof(tmp));
-			/* XXX need to check validity of counter_num and perhaps data!! */
-			if (tmp.counter_num < 4
-			    || tmp.counter_num >= 4 + MAX_PERF_COUNTER - used_by_system)
-				return -EFAULT;
-
-			ia64_set_pmc(tmp.counter_num, tmp.data);
-			ia64_set_pmd(tmp.counter_num, 0);
-			pmds[smp_processor_id()][tmp.counter_num - 4] = 0;
+
+			/* XXX need to check validity of pmu_reg_num and perhaps data!! */
+
+			if (tmp.pmu_reg_num > pmu_conf.max_pmc || tmp.pmu_reg_num = 0) return -EFAULT;
+
+			ia64_set_pmc(tmp.pmu_reg_num, tmp.pmu_reg_data);
+
+			/* to go away */
+			if (tmp.pmu_reg_num >= PMU_FIRST_COUNTER && tmp.pmu_reg_num < PMU_FIRST_COUNTER+pmu_conf.max_counters) {
+				ia64_set_pmd(tmp.pmu_reg_num, 0);
+				pmds[smp_processor_id()][tmp.pmu_reg_num - PMU_FIRST_COUNTER] = 0;
+
+				printk(__FUNCTION__" setting PMC/PMD[%ld] es=0x%lx pmd[%ld]=%lx\n", tmp.pmu_reg_num, (tmp.pmu_reg_data>>8) & 0x7f, tmp.pmu_reg_num, ia64_get_pmd(tmp.pmu_reg_num));
+			} else
+				printk(__FUNCTION__" setting PMC[%ld]=0x%lx\n", tmp.pmu_reg_num, tmp.pmu_reg_data);
 		}
 
-		if (cmd1 = WRITE_PMCS_AND_START) {
+		if (cmd = WRITE_PMCS_AND_START) {
+#if 0
+/* irrelevant with user monitors */
 			local_irq_save(flags);
+
 			dcr = ia64_get_dcr();
 			dcr |= IA64_DCR_PP;
 			ia64_set_dcr(dcr);
+
 			local_irq_restore(flags);
+#endif
+
 			ia64_set_pmc(0, 0);
+
+			/* will start monitoring right after rfi */
+			ia64_psr(regs)->up = 1;
 		}
+		/* 
+		 * mark the state as valid.
+		 * this will trigger save/restore at context switch
+		 */
+		current->thread.flags |= IA64_THREAD_PM_VALID;
                 break;
 
 	      case READ_PMDS:
-		if (cmd2 <= 0 || cmd2 > MAX_PERF_COUNTER - used_by_system)
+		if (count <= 0 || count > MAX_PERF_COUNTER)
 			return -EINVAL;
-		if (!access_ok(VERIFY_WRITE, cptr, sizeof(struct perf_counter)*cmd2))
+		if (!access_ok(VERIFY_WRITE, cptr, sizeof(struct perfmon_reg_t)*count))
 			return -EFAULT;
 
 		/* This looks shady, but IMHO this will work fine. This is  
@@ -121,14 +164,15 @@
 		 * with the interrupt handler. See explanation in the 
 		 * following comment.
 		 */
-
+#if 0
+/* irrelevant with user monitors */
 		local_irq_save(flags);
 		__asm__ __volatile__("rsm psr.pp\n");
 		dcr = ia64_get_dcr();
 		dcr &= ~IA64_DCR_PP;
 		ia64_set_dcr(dcr);
 		local_irq_restore(flags);
-
+#endif
 		/*
 		 * We cannot write to pmc[0] to stop counting here, as
 		 * that particular instruction might cause an overflow
@@ -142,36 +186,47 @@
 		 * when we re-enabled interrupts. When I muck with dcr, 
 		 * is the irq_save/restore needed?
 		 */
-		for (i = 0, cnum = 4;i < cmd2; i++, cnum++, cptr++) {
-			tmp.data = (pmds[smp_processor_id()][i]
-				    + (ia64_get_pmd(cnum) & PERF_OVFL_VAL));
-			tmp.counter_num = cnum;
-			if (copy_to_user(cptr, &tmp, sizeof(tmp)))
-				return -EFAULT;
-			//put_user(pmd, &cptr->data);
+
+
+		/* XXX: This needs to change to read more than just the counters */
+		for (i = 0, cnum = PMU_FIRST_COUNTER;i < count; i++, cnum++, cptr++) {
+
+			tmp.pmu_reg_data = (pmds[smp_processor_id()][i]
+				    + (ia64_get_pmd(cnum) & pmu_conf.perf_ovfl_val));
+
+			tmp.pmu_reg_num = cnum;
+
+			if (copy_to_user(cptr, &tmp, sizeof(tmp))) return -EFAULT;
 		}
+#if 0
+/* irrelevant with user monitors */
 		local_irq_save(flags);
 		__asm__ __volatile__("ssm psr.pp");
 		dcr = ia64_get_dcr();
 		dcr |= IA64_DCR_PP;
 		ia64_set_dcr(dcr);
 		local_irq_restore(flags);
+#endif
                 break;
 
 	      case STOP_PMCS:
 		ia64_set_pmc(0, 1);
 		ia64_srlz_d();
-		for (i = 0; i < MAX_PERF_COUNTER - used_by_system; ++i)
+		for (i = 0; i < MAX_PERF_COUNTER; ++i)
 			ia64_set_pmc(4+i, 0);
 
-		if (!used_by_system) {
-			local_irq_save(flags);
-			dcr = ia64_get_dcr();
-			dcr &= ~IA64_DCR_PP;
-			ia64_set_dcr(dcr);
-			local_irq_restore(flags);
-		}
+#if 0
+/* irrelevant with user monitors */
+		local_irq_save(flags);
+		dcr = ia64_get_dcr();
+		dcr &= ~IA64_DCR_PP;
+		ia64_set_dcr(dcr);
+		local_irq_restore(flags);
+		ia64_psr(regs)->up = 0;
+#endif
+
 		current->thread.flags &= ~(IA64_THREAD_PM_VALID);
+
 		break;
 
 	      default:
@@ -187,13 +242,21 @@
 	unsigned long mask, i, cnum, val;
 
 	mask = ia64_get_pmc(0) >> 4;
-	for (i = 0, cnum = 4; i < MAX_PERF_COUNTER - used_by_system; cnum++, i++, mask >>= 1) {
-		val = 0;
+	for (i = 0, cnum = PMU_FIRST_COUNTER ; i < pmu_conf.max_counters; cnum++, i++, mask >>= 1) {
+
+
+		val = mask & 0x1 ? pmu_conf.perf_ovfl_val + 1 : 0;
+
 		if (mask & 0x1) 
-			val += PERF_OVFL_VAL + 1;
+			printk(__FUNCTION__ " PMD%ld overflowed pmd=%lx pmod=%lx\n", cnum, ia64_get_pmd(cnum), pmds[smp_processor_id()][i]); 
+
 		/* since we got an interrupt, might as well clear every pmd. */
-		val += ia64_get_pmd(cnum) & PERF_OVFL_VAL;
+		val += ia64_get_pmd(cnum) & pmu_conf.perf_ovfl_val;
+
+		printk(__FUNCTION__ " adding val=%lx to pmod[%ld]=%lx \n", val, i, pmds[smp_processor_id()][i]); 
+
 		pmds[smp_processor_id()][i] += val;
+
 		ia64_set_pmd(cnum, 0);
 	}
 }
@@ -212,16 +275,69 @@
 	name:		"perfmon"
 };
 
-void
+static int
+perfmon_proc_info(char *page)
+{
+	char *p = page;
+	u64 pmc0 = ia64_get_pmc(0);
+
+	p += sprintf(p, "PMC[0]=%lx\n", pmc0);
+
+	return p - page;
+}
+
+static int
+perfmon_read_entry(char *page, char **start, off_t off, int count, int *eof, void *data)
+{
+	int len = perfmon_proc_info(page);
+
+        if (len <= off+count) *eof = 1;
+
+        *start = page + off;
+        len   -= off;
+
+        if (len>count) len = count;
+        if (len<0) len = 0;
+
+        return len;
+}
+
+static struct proc_dir_entry *perfmon_dir;
+
+void __init
 perfmon_init (void)
 {
+	pal_perf_mon_info_u_t pm_info;
+	u64 pm_buffer[16];
+	s64 status;
+	
 	irq_desc[PERFMON_IRQ].status |= IRQ_PER_CPU;
 	irq_desc[PERFMON_IRQ].handler = &irq_type_ia64_sapic;
 	setup_irq(PERFMON_IRQ, &perfmon_irqaction);
 
 	ia64_set_pmv(PERFMON_IRQ);
 	ia64_srlz_d();
-	printk("Initialized perfmon vector to %u\n",PERFMON_IRQ);
+
+	printk("perfmon: Initialized vector to %u\n",PERFMON_IRQ);
+
+	if ((status=ia64_pal_perf_mon_info(pm_buffer, &pm_info)) != 0) {
+		printk(__FUNCTION__ " pal call failed (%ld)\n", status);
+		return;
+	} 
+	pmu_conf.perf_ovfl_val = perf_ovfl_val = (1L << pm_info.pal_perf_mon_info_s.width) - 1; 
+
+	/* XXX need to use PAL instead */
+	pmu_conf.max_pmc       = 13;
+	pmu_conf.max_pmd       = 17;
+	pmu_conf.max_counters  = pm_info.pal_perf_mon_info_s.generic;
+
+	printk("perfmon: Counters are %d bits\n", pm_info.pal_perf_mon_info_s.width);
+	printk("perfmon: Maximum counter value 0x%lx\n", pmu_conf.perf_ovfl_val);
+
+	/*
+	 * for now here for debug purposes
+	 */
+	perfmon_dir = create_proc_read_entry ("perfmon", 0, 0, perfmon_read_entry, NULL);
 }
 
 void
@@ -238,10 +354,13 @@
 
 	ia64_set_pmc(0, 1);
 	ia64_srlz_d();
-	for (i=0; i< IA64_NUM_PM_REGS - used_by_system ; i++) {
-		t->pmd[i] = ia64_get_pmd(4+i);
+	/*
+	 * XXX: this will need to be extended beyong just counters
+	 */
+	for (i=0; i< IA64_NUM_PM_REGS; i++) {
+		t->pmd[i]  = ia64_get_pmd(4+i);
 		t->pmod[i] = pmds[smp_processor_id()][i];
-		t->pmc[i] = ia64_get_pmc(4+i);
+		t->pmc[i]  = ia64_get_pmc(4+i);
 	}
 }
 
@@ -250,7 +369,10 @@
 {
 	int i;
 
-	for (i=0; i< IA64_NUM_PM_REGS - used_by_system ; i++) {
+	/*
+	 * XXX: this will need to be extended beyong just counters 
+	 */
+	for (i=0; i< IA64_NUM_PM_REGS ; i++) {
 		ia64_set_pmd(4+i, t->pmd[i]);
 		pmds[smp_processor_id()][i] = t->pmod[i];
 		ia64_set_pmc(4+i, t->pmc[i]);
@@ -262,7 +384,7 @@
 #else /* !CONFIG_PERFMON */
 
 asmlinkage unsigned long
-sys_perfmonctl (int cmd1, int cmd2, void *ptr)
+sys_perfmonctl (int cmd, int count, void *ptr)
 {
 	return -ENOSYS;
 }
diff -urN linux-davidm/arch/ia64/kernel/process.c linux-2.4.0-test9-lia/arch/ia64/kernel/process.c
--- linux-davidm/arch/ia64/kernel/process.c	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/arch/ia64/kernel/process.c	Wed Oct  4 21:37:10 2000
@@ -294,7 +294,8 @@
 	 * call behavior where scratch registers are preserved across
 	 * system calls (unless used by the system call itself).
 	 */
-#	define THREAD_FLAGS_TO_CLEAR	(IA64_THREAD_FPH_VALID | IA64_THREAD_DBG_VALID)
+#	define THREAD_FLAGS_TO_CLEAR	(IA64_THREAD_FPH_VALID | IA64_THREAD_DBG_VALID \
+					 | IA64_THREAD_PM_VALID)
 #	define THREAD_FLAGS_TO_SET	0
 	p->thread.flags = ((current->thread.flags & ~THREAD_FLAGS_TO_CLEAR)
 			   | THREAD_FLAGS_TO_SET);
@@ -333,6 +334,17 @@
 		if (ia64_peek(pt, current, addr, &val) = 0)
 			access_process_vm(current, addr, &val, sizeof(val), 1);
 
+	/*
+	 * coredump format:
+	 *	r0-r31
+	 *	NaT bits (for r0-r31; bit N = 1 iff rN is a NaT)
+	 *	predicate registers (p0-p63)
+	 *	b0-b7
+	 *	ip cfm user-mask
+	 *	ar.rsc ar.bsp ar.bspstore ar.rnat
+	 *	ar.ccv ar.unat ar.fpsr ar.pfs ar.lc ar.ec
+	 */
+
 	/* r0 is zero */
 	for (i = 1, mask = (1UL << i); i < 32; ++i) {
 		unw_get_gr(info, i, &dst[i], &nat);
@@ -530,6 +542,24 @@
 #ifndef CONFIG_SMP
 	if (ia64_get_fpu_owner() = current)
 		ia64_set_fpu_owner(0);
+#endif
+#ifdef CONFIG_PERFMON
+       /* stop monitoring */
+	if ((current->thread.flags & IA64_THREAD_PM_VALID) != 0) {
+		/*
+		 * we cannot rely on switch_to() to save the PMU
+		 * context for the last time. There is a possible race
+		 * condition in SMP mode between the child and the
+		 * parent.  by explicitly saving the PMU context here
+		 * we garantee no race.  this call we also stop
+		 * monitoring
+		 */
+		ia64_save_pm_regs(&current->thread);
+		/*
+		 * make sure that switch_to() will not save context again
+		 */
+		current->thread.flags &= ~IA64_THREAD_PM_VALID;
+	}
 #endif
 }
 
diff -urN linux-davidm/arch/ia64/kernel/ptrace.c linux-2.4.0-test9-lia/arch/ia64/kernel/ptrace.c
--- linux-davidm/arch/ia64/kernel/ptrace.c	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/arch/ia64/kernel/ptrace.c	Wed Oct  4 21:37:31 2000
@@ -617,6 +617,7 @@
 	struct switch_stack *sw;
 	struct unw_frame_info info;
 	struct pt_regs *pt;
+	unsigned long pmd_tmp;
 
 	pt = ia64_task_regs(child);
 	sw = (struct switch_stack *) (child->thread.ksp + 16);
@@ -793,7 +794,11 @@
 				addr);
 			return -1;
 		}
-	} else {
+	} else 
+#ifdef CONFIG_PERFMON
+		if (addr < PT_PMD) 
+#endif
+		{
 		/* access debug registers */
 
 		if (!(child->thread.flags & IA64_THREAD_DBG_VALID)) {
@@ -816,6 +821,32 @@
 
 		ptr += regnum;
 	}
+#ifdef CONFIG_PERFMON
+	else {
+		/*
+		 * XXX: will eventually move back to perfmonctl()
+		 */
+		unsigned long pmd = (addr - PT_PMD) >> 3;
+		extern unsigned long perf_ovfl_val;
+
+		/* we just use ptrace to read */
+		if (write_access) return -1;
+
+		if (pmd > 3) {
+			printk("ptrace: rejecting access to PMD[%ld] address 0x%lx\n", pmd, addr);
+			return -1;
+		}
+
+		/* 
+		 * We always need to mask upper 32bits of pmd because value is random
+		 */
+		pmd_tmp = child->thread.pmod[pmd]+(child->thread.pmd[pmd]& perf_ovfl_val);
+
+		/*printk(__FUNCTION__" child=%d reading pmd[%ld]=%lx\n", child->pid, pmd, pmd_tmp);*/
+
+		ptr = &pmd_tmp;
+	}
+#endif
 	if (write_access)
 		*ptr = *data;
 	else
@@ -945,7 +976,12 @@
 			/* disallow accessing anything else... */
 			return -1;
 		}
-	} else {
+	} else 
+#ifdef CONFIG_PERFMON
+		if (addr < PT_PMD) 
+#endif
+		{
+
 		/* access debug registers */
 
 		if (!(child->thread.flags & IA64_THREAD_DBG_VALID)) {
@@ -966,6 +1002,33 @@
 
 		ptr += regnum;
 	}
+#ifdef CONFIG_PERFMON
+	else {
+		/*
+		 * XXX: will eventually move back to perfmonctl()
+		 */
+		unsigned long pmd = (addr - PT_PMD) >> 3;
+		extern unsigned long perf_ovfl_val;
+
+		/* we just use ptrace to read */
+		if (write_access) return -1;
+
+		if (pmd > 3) {
+			printk("ptrace: rejecting access to PMD[%ld] address 0x%lx\n", pmd, addr);
+			return -1;
+		}
+
+		/* 
+		 * We always need to mask upper 32bits of pmd because value is random
+		 */
+		pmd_tmp = child->thread.pmod[pmd]+(child->thread.pmd[pmd]& perf_ovfl_val);
+
+		/*printk(__FUNCTION__" child=%d reading pmd[%ld]=%lx\n", child->pid, pmd, pmd_tmp);*/
+
+		ptr = &pmd_tmp;
+	}
+#endif
+
 	if (write_access)
 		*ptr = *data;
 	else
@@ -1041,10 +1104,12 @@
 	ret = -ESRCH;
 	if (!(child->ptrace & PT_PTRACED))
 		goto out_tsk;
+
 	if (child->state != TASK_STOPPED) {
-		if (request != PTRACE_KILL)
+		if (request != PTRACE_KILL && request != PTRACE_PEEKUSR)
 			goto out_tsk;
 	}
+
 	if (child->p_pptr != current)
 		goto out_tsk;
 
diff -urN linux-davidm/arch/ia64/kernel/sal.c linux-2.4.0-test9-lia/arch/ia64/kernel/sal.c
--- linux-davidm/arch/ia64/kernel/sal.c	Thu Aug 24 08:17:30 2000
+++ linux-2.4.0-test9-lia/arch/ia64/kernel/sal.c	Wed Oct  4 21:37:41 2000
@@ -34,6 +34,7 @@
 }
 
 ia64_sal_handler ia64_sal = (ia64_sal_handler) default_handler;
+ia64_sal_desc_ptc_t *ia64_ptc_domain_info;
 
 const char *
 ia64_sal_strerror (long status)
@@ -125,6 +126,10 @@
 #endif
 			ia64_pal_handler_init(__va(ep->pal_proc));
 			ia64_sal_handler_init(__va(ep->sal_proc), __va(ep->gp));
+			break;
+
+		      case SAL_DESC_PTC:
+			ia64_ptc_domain_info = (ia64_sal_desc_ptc_t *)p;
 			break;
 
 		      case SAL_DESC_AP_WAKEUP:
diff -urN linux-davidm/arch/ia64/kernel/setup.c linux-2.4.0-test9-lia/arch/ia64/kernel/setup.c
--- linux-davidm/arch/ia64/kernel/setup.c	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/arch/ia64/kernel/setup.c	Wed Oct  4 21:37:50 2000
@@ -270,6 +270,11 @@
 int
 get_cpuinfo (char *buffer)
 {
+#ifdef CONFIG_SMP
+#	define lps	c->loops_per_sec
+#else
+#	define lps	loops_per_sec
+#endif
 	char family[32], model[32], features[128], *cp, *p = buffer;
 	struct cpuinfo_ia64 *c;
 	unsigned long mask;
@@ -320,7 +325,7 @@
 			     features,
 			     c->ppn, c->number, c->proc_freq / 1000000, c->proc_freq % 1000000,
 			     c->itc_freq / 1000000, c->itc_freq % 1000000,
-			     ia64_loops_per_sec() / 500000, (ia64_loops_per_sec() / 5000) % 100);
+			     lps / 500000, (lps / 5000) % 100);
         }
 	return p - buffer;
 }
@@ -416,8 +421,9 @@
 	 * do NOT defer TLB misses, page-not-present, access bit, or
 	 * debug faults but kernel code should not rely on any
 	 * particular setting of these bits.
-	 */
 	ia64_set_dcr(IA64_DCR_DR | IA64_DCR_DK | IA64_DCR_DX | IA64_DCR_PP);
+	 */
+	ia64_set_dcr(IA64_DCR_DR | IA64_DCR_DK | IA64_DCR_DX );
 #ifndef CONFIG_SMP
 	ia64_set_fpu_owner(0);		/* initialize ar.k5 */
 #endif
diff -urN linux-davidm/arch/ia64/kernel/smp.c linux-2.4.0-test9-lia/arch/ia64/kernel/smp.c
--- linux-davidm/arch/ia64/kernel/smp.c	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/arch/ia64/kernel/smp.c	Wed Oct  4 21:38:41 2000
@@ -44,8 +44,8 @@
 
 extern void __init calibrate_delay(void);
 extern int cpu_idle(void * unused);
-extern void _start(void);
 extern void machine_halt(void);
+extern void start_ap(void);
 
 extern int cpu_now_booting;			     /* Used by head.S to find idle task */
 extern volatile unsigned long cpu_online_map;	     /* Bitmap of available cpu's */
@@ -463,46 +463,6 @@
 	}
 }
 
-/* 
- * SAL shoves the AP's here when we start them.  Physical mode, no kernel TR, 
- * no RRs set, better than even chance that psr is bogus.  Fix all that and 
- * call _start.  In effect, pretend to be lilo.
- *
- * Stolen from lilo_start.c.  Thanks David! 
- */
-void
-start_ap(void)
-{
-	unsigned long flags;
-
-	/*
-	 * Install a translation register that identity maps the
-	 * kernel's 256MB page(s).
-	 */
-	ia64_clear_ic(flags);
-	ia64_set_rr(          0, (0x1000 << 8) | (_PAGE_SIZE_1M << 2));
-	ia64_set_rr(PAGE_OFFSET, (ia64_rid(0, PAGE_OFFSET) << 8) | (_PAGE_SIZE_256M << 2));
-	ia64_srlz_d();
-	ia64_itr(0x3, 1, PAGE_OFFSET,
-		 pte_val(mk_pte_phys(0, __pgprot(__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RWX))),
-		 _PAGE_SIZE_256M);
-	ia64_srlz_i();
-
-	flags = (IA64_PSR_IT | IA64_PSR_IC | IA64_PSR_DT | IA64_PSR_RT | IA64_PSR_DFH | 
-		 IA64_PSR_BN);
-	
-	asm volatile ("movl r8 = 1f\n"
-		      ";;\n"
-		      "mov cr.ipsr=%0\n"
-		      "mov cr.iip=r8\n" 
-		      "mov cr.ifs=r0\n"
-		      ";;\n"
-		      "rfi;;"
-		      "1:\n"
-		      "movl r1 = __gp" :: "r"(flags) : "r8");
-	_start();
-}
-
 
 /*
  * AP's start using C here.
@@ -642,7 +602,7 @@
 	/* Setup BP mappings */
 	__cpu_physical_id[0] = hard_smp_processor_id();
 
-	calibrate_delay();
+	/* on the BP, the kernel already called calibrate_delay_loop() in init/main.c */
 	my_cpu_data.loops_per_sec = loops_per_sec;
 #if 0
 	smp_tune_scheduling();
diff -urN linux-davidm/arch/ia64/kernel/smpboot.c linux-2.4.0-test9-lia/arch/ia64/kernel/smpboot.c
--- linux-davidm/arch/ia64/kernel/smpboot.c	Wed Dec 31 16:00:00 1969
+++ linux-2.4.0-test9-lia/arch/ia64/kernel/smpboot.c	Wed Oct  4 21:38:56 2000
@@ -0,0 +1,76 @@
+/*
+ * SMP Support
+ *
+ * Application processor startup code, moved from smp.c to better support kernel profile
+ */
+
+#include <linux/config.h>
+
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/smp.h>
+#include <linux/kernel_stat.h>
+#include <linux/mm.h>
+#include <linux/delay.h>
+
+#include <asm/atomic.h>
+#include <asm/bitops.h>
+#include <asm/current.h>
+#include <asm/delay.h>
+#include <asm/efi.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/page.h>
+#include <asm/pgtable.h>
+#include <asm/pgalloc.h>
+#include <asm/processor.h>
+#include <asm/ptrace.h>
+#include <asm/sal.h>
+#include <asm/system.h>
+#include <asm/unistd.h>
+
+/* 
+ * SAL shoves the AP's here when we start them.  Physical mode, no kernel TR, 
+ * no RRs set, better than even chance that psr is bogus.  Fix all that and 
+ * call _start.  In effect, pretend to be lilo.
+ *
+ * Stolen from lilo_start.c.  Thanks David! 
+ */
+void
+start_ap(void)
+{
+	extern void _start (void);
+	unsigned long flags;
+
+	/*
+	 * Install a translation register that identity maps the
+	 * kernel's 256MB page(s).
+	 */
+	ia64_clear_ic(flags);
+	ia64_set_rr(          0, (0x1000 << 8) | (_PAGE_SIZE_1M << 2));
+	ia64_set_rr(PAGE_OFFSET, (ia64_rid(0, PAGE_OFFSET) << 8) | (_PAGE_SIZE_256M << 2));
+	ia64_srlz_d();
+	ia64_itr(0x3, 1, PAGE_OFFSET,
+		 pte_val(mk_pte_phys(0, __pgprot(__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RWX))),
+		 _PAGE_SIZE_256M);
+	ia64_srlz_i();
+
+	flags = (IA64_PSR_IT | IA64_PSR_IC | IA64_PSR_DT | IA64_PSR_RT | IA64_PSR_DFH | 
+		 IA64_PSR_BN);
+	
+	asm volatile ("movl r8 = 1f\n"
+		      ";;\n"
+		      "mov cr.ipsr=%0\n"
+		      "mov cr.iip=r8\n" 
+		      "mov cr.ifs=r0\n"
+		      ";;\n"
+		      "rfi;;"
+		      "1:\n"
+		      "movl r1 = __gp" :: "r"(flags) : "r8");
+	_start();
+}
+
+
diff -urN linux-davidm/arch/ia64/kernel/traps.c linux-2.4.0-test9-lia/arch/ia64/kernel/traps.c
--- linux-davidm/arch/ia64/kernel/traps.c	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/arch/ia64/kernel/traps.c	Wed Oct  4 21:39:28 2000
@@ -254,10 +254,11 @@
 	 * kernel, so set those bits in the mask and set the low volatile
 	 * pointer to point to these registers.
 	 */
-	fp_state.bitmask_low64 = 0xffc0;  /* bit6..bit15 */
 #ifndef FPSWA_BUG
-	fp_state.fp_state_low_volatile = &regs->f6;
+	fp_state.bitmask_low64 = 0x3c0;  /* bit 6..9 */
+	fp_state.fp_state_low_volatile = (fp_state_low_volatile_t *) &regs->f6;
 #else
+	fp_state.bitmask_low64 = 0xffc0;  /* bit6..bit15 */
 	f6_15[0] = regs->f6;
 	f6_15[1] = regs->f7;
 	f6_15[2] = regs->f8;
diff -urN linux-davidm/arch/ia64/kernel/unwind.c linux-2.4.0-test9-lia/arch/ia64/kernel/unwind.c
--- linux-davidm/arch/ia64/kernel/unwind.c	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/arch/ia64/kernel/unwind.c	Wed Oct  4 21:39:58 2000
@@ -66,7 +66,7 @@
 #define UNW_STATS	0	/* WARNING: this disabled interrupts for long time-spans!! */
 
 #if UNW_DEBUG
-  static long unw_debug_level = 1;
+  static long unw_debug_level = 255;
 # define debug(level,format...)	if (unw_debug_level > level) printk(format)
 # define dprintk(format...)	printk(format)
 # define inline
@@ -111,7 +111,7 @@
 	struct unw_table kernel_table;
 
 	/* hash table that maps instruction pointer to script index: */
-	unw_hash_index_t hash[UNW_HASH_SIZE];
+	unsigned short hash[UNW_HASH_SIZE];
 
 	/* script cache: */
 	struct unw_script cache[UNW_CACHE_SIZE];
@@ -152,47 +152,47 @@
 		UNW_REG_UNAT, UNW_REG_LC, UNW_REG_FPSR, UNW_REG_PRI_UNAT_GR
 	},
 	preg_index: {
-		struct_offset(struct unw_frame_info, pri_unat)/8,	/* PRI_UNAT_GR */
-		struct_offset(struct unw_frame_info, pri_unat)/8,	/* PRI_UNAT_MEM */
-		struct_offset(struct unw_frame_info, pbsp)/8,
-		struct_offset(struct unw_frame_info, bspstore)/8,
-		struct_offset(struct unw_frame_info, pfs)/8,
-		struct_offset(struct unw_frame_info, rnat)/8,
+		struct_offset(struct unw_frame_info, pri_unat_loc)/8,	/* PRI_UNAT_GR */
+		struct_offset(struct unw_frame_info, pri_unat_loc)/8,	/* PRI_UNAT_MEM */
+		struct_offset(struct unw_frame_info, bsp_loc)/8,
+		struct_offset(struct unw_frame_info, bspstore_loc)/8,
+		struct_offset(struct unw_frame_info, pfs_loc)/8,
+		struct_offset(struct unw_frame_info, rnat_loc)/8,
 		struct_offset(struct unw_frame_info, psp)/8,
-		struct_offset(struct unw_frame_info, rp)/8,
+		struct_offset(struct unw_frame_info, rp_loc)/8,
 		struct_offset(struct unw_frame_info, r4)/8,
 		struct_offset(struct unw_frame_info, r5)/8,
 		struct_offset(struct unw_frame_info, r6)/8,
 		struct_offset(struct unw_frame_info, r7)/8,
-		struct_offset(struct unw_frame_info, unat)/8,
-		struct_offset(struct unw_frame_info, pr)/8,
-		struct_offset(struct unw_frame_info, lc)/8,
-		struct_offset(struct unw_frame_info, fpsr)/8,
-		struct_offset(struct unw_frame_info, b1)/8,
-		struct_offset(struct unw_frame_info, b2)/8,
-		struct_offset(struct unw_frame_info, b3)/8,
-		struct_offset(struct unw_frame_info, b4)/8,
-		struct_offset(struct unw_frame_info, b5)/8,
-		struct_offset(struct unw_frame_info, f2)/8,
-		struct_offset(struct unw_frame_info, f3)/8,
-		struct_offset(struct unw_frame_info, f4)/8,
-		struct_offset(struct unw_frame_info, f5)/8,
-		struct_offset(struct unw_frame_info, fr[16 - 16])/8,
-		struct_offset(struct unw_frame_info, fr[17 - 16])/8,
-		struct_offset(struct unw_frame_info, fr[18 - 16])/8,
-		struct_offset(struct unw_frame_info, fr[19 - 16])/8,
-		struct_offset(struct unw_frame_info, fr[20 - 16])/8,
-		struct_offset(struct unw_frame_info, fr[21 - 16])/8,
-		struct_offset(struct unw_frame_info, fr[22 - 16])/8,
-		struct_offset(struct unw_frame_info, fr[23 - 16])/8,
-		struct_offset(struct unw_frame_info, fr[24 - 16])/8,
-		struct_offset(struct unw_frame_info, fr[25 - 16])/8,
-		struct_offset(struct unw_frame_info, fr[26 - 16])/8,
-		struct_offset(struct unw_frame_info, fr[27 - 16])/8,
-		struct_offset(struct unw_frame_info, fr[28 - 16])/8,
-		struct_offset(struct unw_frame_info, fr[29 - 16])/8,
-		struct_offset(struct unw_frame_info, fr[30 - 16])/8,
-		struct_offset(struct unw_frame_info, fr[31 - 16])/8,
+		struct_offset(struct unw_frame_info, unat_loc)/8,
+		struct_offset(struct unw_frame_info, pr_loc)/8,
+		struct_offset(struct unw_frame_info, lc_loc)/8,
+		struct_offset(struct unw_frame_info, fpsr_loc)/8,
+		struct_offset(struct unw_frame_info, b1_loc)/8,
+		struct_offset(struct unw_frame_info, b2_loc)/8,
+		struct_offset(struct unw_frame_info, b3_loc)/8,
+		struct_offset(struct unw_frame_info, b4_loc)/8,
+		struct_offset(struct unw_frame_info, b5_loc)/8,
+		struct_offset(struct unw_frame_info, f2_loc)/8,
+		struct_offset(struct unw_frame_info, f3_loc)/8,
+		struct_offset(struct unw_frame_info, f4_loc)/8,
+		struct_offset(struct unw_frame_info, f5_loc)/8,
+		struct_offset(struct unw_frame_info, fr_loc[16 - 16])/8,
+		struct_offset(struct unw_frame_info, fr_loc[17 - 16])/8,
+		struct_offset(struct unw_frame_info, fr_loc[18 - 16])/8,
+		struct_offset(struct unw_frame_info, fr_loc[19 - 16])/8,
+		struct_offset(struct unw_frame_info, fr_loc[20 - 16])/8,
+		struct_offset(struct unw_frame_info, fr_loc[21 - 16])/8,
+		struct_offset(struct unw_frame_info, fr_loc[22 - 16])/8,
+		struct_offset(struct unw_frame_info, fr_loc[23 - 16])/8,
+		struct_offset(struct unw_frame_info, fr_loc[24 - 16])/8,
+		struct_offset(struct unw_frame_info, fr_loc[25 - 16])/8,
+		struct_offset(struct unw_frame_info, fr_loc[26 - 16])/8,
+		struct_offset(struct unw_frame_info, fr_loc[27 - 16])/8,
+		struct_offset(struct unw_frame_info, fr_loc[28 - 16])/8,
+		struct_offset(struct unw_frame_info, fr_loc[29 - 16])/8,
+		struct_offset(struct unw_frame_info, fr_loc[30 - 16])/8,
+		struct_offset(struct unw_frame_info, fr_loc[31 - 16])/8,
 	},
 	hash : { [0 ... UNW_HASH_SIZE - 1] = -1 },
 #if UNW_DEBUG
@@ -211,6 +211,27 @@
 
 /* Unwind accessors.  */
 
+/*
+ * Returns offset of rREG in struct pt_regs.
+ */
+static inline unsigned long
+pt_regs_off (unsigned long reg)
+{
+	unsigned long off =0;
+
+	if (reg >= 1 && reg <= 3)
+		off = struct_offset(struct pt_regs, r1) + 8*(reg - 1);
+	else if (reg <= 11)
+		off = struct_offset(struct pt_regs, r8) + 8*(reg - 8);
+	else if (reg <= 15)
+		off = struct_offset(struct pt_regs, r12) + 8*(reg - 12);
+	else if (reg <= 31)
+		off = struct_offset(struct pt_regs, r16) + 8*(reg - 16);
+	else
+		dprintk("unwind: bad scratch reg r%lu\n", reg);
+	return off;
+}
+
 int
 unw_access_gr (struct unw_frame_info *info, int regnum, unsigned long *val, char *nat, int write)
 {
@@ -251,26 +272,22 @@
 					}
 					/* fall through */
 				      case UNW_NAT_NONE:
+					dummy_nat = 0;
 					nat_addr = &dummy_nat;
 					break;
 
-				      case UNW_NAT_SCRATCH:
-					if (info->pri_unat)
-						nat_addr = info->pri_unat;
-					else
-						nat_addr = &info->sw->caller_unat;
-				      case UNW_NAT_PRI_UNAT:
+				      case UNW_NAT_MEMSTK:
 					nat_mask = (1UL << ((long) addr & 0x1f8)/8);
 					break;
 
-				      case UNW_NAT_STACKED:
+				      case UNW_NAT_REGSTK:
 					nat_addr = ia64_rse_rnat_addr(addr);
 					if ((unsigned long) addr < info->regstk.limit
 					    || (unsigned long) addr >= info->regstk.top)
 					{
 						dprintk("unwind: %p outside of regstk "
-							"[0x%lx-0x%lx)\n", addr,
-							(void *) info->regstk.limit,
+							"[0x%lx-0x%lx)\n", (void *) addr,
+							info->regstk.limit,
 							info->regstk.top);
 						return -1;
 					}
@@ -290,18 +307,11 @@
 				pt = (struct pt_regs *) info->psp - 1;
 			else
 				pt = (struct pt_regs *) info->sp - 1;
-			if (regnum <= 3)
-				addr = &pt->r1 + (regnum - 1);
-			else if (regnum <= 11)
-				addr = &pt->r8 + (regnum - 8);
-			else if (regnum <= 15)
-				addr = &pt->r12 + (regnum - 12);
-			else
-				addr = &pt->r16 + (regnum - 16);
-			if (info->pri_unat)
-				nat_addr = info->pri_unat;
+			addr = (unsigned long *) ((long) pt + pt_regs_off(regnum));
+			if (info->pri_unat_loc)
+				nat_addr = info->pri_unat_loc;
 			else
-				nat_addr = &info->sw->caller_unat;
+				nat_addr = &info->sw->ar_unat;
 			nat_mask = (1UL << ((long) addr & 0x1f8)/8);
 		}
 	} else {
@@ -321,7 +331,10 @@
 
 	if (write) {
 		*addr = *val;
-		*nat_addr = (*nat_addr & ~nat_mask) | nat_mask;
+		if (*nat)
+			*nat_addr |= nat_mask;
+		else
+			*nat_addr &= ~nat_mask;
 	} else {
 		*val = *addr;
 		*nat = (*nat_addr & nat_mask) != 0;
@@ -347,7 +360,7 @@
 
 		/* preserved: */
 	      case 1: case 2: case 3: case 4: case 5:
-		addr = *(&info->b1 + (regnum - 1));
+		addr = *(&info->b1_loc + (regnum - 1));
 		if (!addr)
 			addr = &info->sw->b1 + (regnum - 1);
 		break;
@@ -380,7 +393,7 @@
 		pt = (struct pt_regs *) info->sp - 1;
 
 	if (regnum <= 5) {
-		addr = *(&info->f2 + (regnum - 2));
+		addr = *(&info->f2_loc + (regnum - 2));
 		if (!addr)
 			addr = &info->sw->f2 + (regnum - 2);
 	} else if (regnum <= 15) {
@@ -389,7 +402,7 @@
 		else
 			addr = &info->sw->f10 + (regnum - 10);
 	} else if (regnum <= 31) {
-		addr = info->fr[regnum - 16];
+		addr = info->fr_loc[regnum - 16];
 		if (!addr)
 			addr = &info->sw->f16 + (regnum - 16);
 	} else {
@@ -422,52 +435,53 @@
 
 	switch (regnum) {
 	      case UNW_AR_BSP:
-		addr = info->pbsp;
+		addr = info->bsp_loc;
 		if (!addr)
 			addr = &info->sw->ar_bspstore;
 		break;
 
 	      case UNW_AR_BSPSTORE:
-		addr = info->bspstore;
+		addr = info->bspstore_loc;
 		if (!addr)
 			addr = &info->sw->ar_bspstore;
 		break;
 
 	      case UNW_AR_PFS:
-		addr = info->pfs;
+		addr = info->pfs_loc;
 		if (!addr)
 			addr = &info->sw->ar_pfs;
 		break;
 
 	      case UNW_AR_RNAT:
-		addr = info->rnat;
+		addr = info->rnat_loc;
 		if (!addr)
 			addr = &info->sw->ar_rnat;
 		break;
 
 	      case UNW_AR_UNAT:
-		addr = info->unat;
+		addr = info->unat_loc;
 		if (!addr)
 			addr = &info->sw->ar_unat;
 		break;
 
 	      case UNW_AR_LC:
-		addr = info->lc;
+		addr = info->lc_loc;
 		if (!addr)
 			addr = &info->sw->ar_lc;
 		break;
 
 	      case UNW_AR_EC:
-		if (!info->cfm)
+		if (!info->cfm_loc)
 			return -1;
 		if (write)
-			*info->cfm = (*info->cfm & ~(0x3fUL << 52)) | ((*val & 0x3f) << 52);
+			*info->cfm_loc +				(*info->cfm_loc & ~(0x3fUL << 52)) | ((*val & 0x3f) << 52);
 		else
-			*val = (*info->cfm >> 52) & 0x3f;
+			*val = (*info->cfm_loc >> 52) & 0x3f;
 		return 0;
 
 	      case UNW_AR_FPSR:
-		addr = info->fpsr;
+		addr = info->fpsr_loc;
 		if (!addr)
 			addr = &info->sw->ar_fpsr;
 		break;
@@ -497,7 +511,7 @@
 {
 	unsigned long *addr;
 
-	addr = info->pr;
+	addr = info->pr_loc;
 	if (!addr)
 		addr = &info->sw->pr;
 
@@ -609,9 +623,8 @@
 	int i;
 
 	/*
-	 * First, resolve implicit register save locations
-	 * (see Section "11.4.2.3 Rules for Using Unwind
-	 * Descriptors", rule 3):
+	 * First, resolve implicit register save locations (see Section "11.4.2.3 Rules
+	 * for Using Unwind Descriptors", rule 3):
 	 */
 	for (i = 0; i < (int) sizeof(unw.save_order)/sizeof(unw.save_order[0]); ++i) {
 		reg = sr->curr.reg + unw.save_order[i];
@@ -1049,16 +1062,16 @@
 static inline unw_hash_index_t
 hash (unsigned long ip)
 {
-#	define magic	0x9e3779b97f4a7c16	/* (sqrt(5)/2-1)*2^64 */
+#	define magic	0x9e3779b97f4a7c16	/* based on (sqrt(5)/2-1)*2^64 */
 
 	return (ip >> 4)*magic >> (64 - UNW_LOG_HASH_SIZE);
 }
 
 static inline long
-cache_match (struct unw_script *script, unsigned long ip, unsigned long pr_val)
+cache_match (struct unw_script *script, unsigned long ip, unsigned long pr)
 {
 	read_lock(&script->lock);
-	if ((ip) = (script)->ip && (((pr_val) ^ (script)->pr_val) & (script)->pr_mask) = 0)
+	if (ip = script->ip && ((pr ^ script->pr_val) & script->pr_mask) = 0)
 		/* keep the read lock... */
 		return 1;
 	read_unlock(&script->lock);
@@ -1069,21 +1082,26 @@
 script_lookup (struct unw_frame_info *info)
 {
 	struct unw_script *script = unw.cache + info->hint;
-	unsigned long ip, pr_val;
+	unsigned short index;
+	unsigned long ip, pr;
 
 	STAT(++unw.stat.cache.lookups);
 
 	ip = info->ip;
-	pr_val = info->pr_val;
+	pr = info->pr;
 
-	if (cache_match(script, ip, pr_val)) {
+	if (cache_match(script, ip, pr)) {
 		STAT(++unw.stat.cache.hinted_hits);
 		return script;
 	}
 
-	script = unw.cache + unw.hash[hash(ip)];
+	index = unw.hash[hash(ip)];
+	if (index >= UNW_CACHE_SIZE)
+		return 0;
+
+	script = unw.cache + index;
 	while (1) {
-		if (cache_match(script, ip, pr_val)) {
+		if (cache_match(script, ip, pr)) {
 			/* update hint; no locking required as single-word writes are atomic */
 			STAT(++unw.stat.cache.normal_hits);
 			unw.cache[info->prev_script].hint = script - unw.cache;
@@ -1103,8 +1121,8 @@
 script_new (unsigned long ip)
 {
 	struct unw_script *script, *prev, *tmp;
+	unw_hash_index_t index;
 	unsigned long flags;
-	unsigned char index;
 	unsigned short head;
 
 	STAT(++unw.stat.script.news);
@@ -1137,22 +1155,24 @@
 		unw.lru_tail = head;
 
 		/* remove the old script from the hash table (if it's there): */
-		index = hash(script->ip);
-		tmp = unw.cache + unw.hash[index];
-		prev = 0;
-		while (1) {
-			if (tmp = script) {
-				if (prev)
-					prev->coll_chain = tmp->coll_chain;
-				else
-					unw.hash[index] = tmp->coll_chain;
-				break;
-			} else
-				prev = tmp;
-			if (tmp->coll_chain >= UNW_CACHE_SIZE)
+		if (script->ip) {
+			index = hash(script->ip);
+			tmp = unw.cache + unw.hash[index];
+			prev = 0;
+			while (1) {
+				if (tmp = script) {
+					if (prev)
+						prev->coll_chain = tmp->coll_chain;
+					else
+						unw.hash[index] = tmp->coll_chain;
+					break;
+				} else
+					prev = tmp;
+				if (tmp->coll_chain >= UNW_CACHE_SIZE)
 				/* old script wasn't in the hash-table */
-				break;
-			tmp = unw.cache + tmp->coll_chain;
+					break;
+				tmp = unw.cache + tmp->coll_chain;
+			}
 		}
 
 		/* enter new script in the hash table */
@@ -1202,19 +1222,17 @@
 	struct unw_reg_info *r = sr->curr.reg + i;
 	enum unw_insn_opcode opc;
 	struct unw_insn insn;
-	unsigned long val;
+	unsigned long val = 0;
 
 	switch (r->where) {
 	      case UNW_WHERE_GR:
 		if (r->val >= 32) {
 			/* register got spilled to a stacked register */
 			opc = UNW_INSN_SETNAT_TYPE;
-			val = UNW_NAT_STACKED;
-		} else {
+			val = UNW_NAT_REGSTK;
+		} else
 			/* register got spilled to a scratch register */
-			opc = UNW_INSN_SETNAT_TYPE;
-			val = UNW_NAT_SCRATCH;
-		}
+			opc = UNW_INSN_SETNAT_MEMSTK;
 		break;
 
 	      case UNW_WHERE_FR:
@@ -1229,8 +1247,7 @@
 
 	      case UNW_WHERE_PSPREL:
 	      case UNW_WHERE_SPREL:
-		opc = UNW_INSN_SETNAT_PRI_UNAT;
-		val = 0;
+		opc = UNW_INSN_SETNAT_MEMSTK;
 		break;
 
 	      default:
@@ -1271,18 +1288,8 @@
 			}
 			val = unw.preg_index[UNW_REG_R4 + (rval - 4)];
 		} else {
-			opc = UNW_INSN_LOAD_SPREL;
-			val = -sizeof(struct pt_regs); 
-			if (rval >= 1 && rval <= 3)
-				val += struct_offset(struct pt_regs, r1) + 8*(rval - 1);
-			else if (rval <= 11)
-				val += struct_offset(struct pt_regs, r8) + 8*(rval - 8);
-			else if (rval <= 15)
-				val += struct_offset(struct pt_regs, r12) + 8*(rval - 12);
-			else if (rval <= 31)
-				val += struct_offset(struct pt_regs, r16) + 8*(rval - 16);
-			else
-				dprintk("unwind: bad scratch reg r%lu\n", rval);
+			opc = UNW_INSN_ADD_SP;
+			val = -sizeof(struct pt_regs) + pt_regs_off(rval);
 		}
 		break;
 
@@ -1292,7 +1299,7 @@
 		else if (rval >= 16 && rval <= 31)
 			val = unw.preg_index[UNW_REG_F16 + (rval - 16)];
 		else {
-			opc = UNW_INSN_LOAD_SPREL;
+			opc = UNW_INSN_ADD_SP;
 			val = -sizeof(struct pt_regs);
 			if (rval <= 9)
 				val += struct_offset(struct pt_regs, f6) + 16*(rval - 6);
@@ -1305,7 +1312,7 @@
 		if (rval >= 1 && rval <= 5)
 			val = unw.preg_index[UNW_REG_B1 + (rval - 1)];
 		else {
-			opc = UNW_INSN_LOAD_SPREL;
+			opc = UNW_INSN_ADD_SP;
 			val = -sizeof(struct pt_regs);
 			if (rval = 0)
 				val += struct_offset(struct pt_regs, b0);
@@ -1317,11 +1324,11 @@
 		break;
 
 	      case UNW_WHERE_SPREL:
-		opc = UNW_INSN_LOAD_SPREL;
+		opc = UNW_INSN_ADD_SP;
 		break;
 
 	      case UNW_WHERE_PSPREL:
-		opc = UNW_INSN_LOAD_PSPREL;
+		opc = UNW_INSN_ADD_PSP;
 		break;
 
 	      default:
@@ -1334,6 +1341,18 @@
 	script_emit(script, insn);
 	if (need_nat_info)
 		emit_nat_info(sr, i, script);
+
+	if (i = UNW_REG_PSP) {
+		/*
+		 * info->psp must contain the _value_ of the previous
+		 * sp, not it's save location.  We get this by
+		 * dereferencing the value we just stored in
+		 * info->psp:
+		 */
+		insn.opc = UNW_INSN_LOAD;
+		insn.dst = insn.val = unw.preg_index[UNW_REG_PSP];
+		script_emit(script, insn);
+	}
 }
 
 static inline struct unw_table_entry *
@@ -1382,7 +1401,7 @@
 	memset(&sr, 0, sizeof(sr));
 	for (r = sr.curr.reg; r < sr.curr.reg + UNW_NUM_REGS; ++r)
 		r->when = UNW_WHEN_NEVER;
-	sr.pr_val = info->pr_val;
+	sr.pr_val = info->pr;
 
 	script = script_new(ip);
 	if (!script) {
@@ -1451,8 +1470,8 @@
 	}
 
 #if UNW_DEBUG
-	printk ("unwind: state record for func 0x%lx, t=%u:\n",
-		table->segment_base + e->start_offset, sr.when_target);
+	printk("unwind: state record for func 0x%lx, t=%u:\n",
+	       table->segment_base + e->start_offset, sr.when_target);
 	for (r = sr.curr.reg; r < sr.curr.reg + UNW_NUM_REGS; ++r) {
 		if (r->where != UNW_WHERE_NONE || r->when != UNW_WHEN_NEVER) {
 			printk("  %s <- ", unw.preg_name[r - sr.curr.reg]);
@@ -1467,7 +1486,7 @@
 				break; 
 			      default:		     printk("BADWHERE(%d)", r->where); break;
 			}
-			printk ("\t\t%d\n", r->when);
+			printk("\t\t%d\n", r->when);
 		}
 	}
 #endif
@@ -1476,13 +1495,17 @@
 
 	/* translate state record into unwinder instructions: */
 
-	if (sr.curr.reg[UNW_REG_PSP].where = UNW_WHERE_NONE
-	    && sr.when_target > sr.curr.reg[UNW_REG_PSP].when && sr.curr.reg[UNW_REG_PSP].val != 0)
-	{
+	/*
+	 * First, set psp if we're dealing with a fixed-size frame;
+	 * subsequent instructions may depend on this value.
+	 */
+	if (sr.when_target > sr.curr.reg[UNW_REG_PSP].when
+	    && (sr.curr.reg[UNW_REG_PSP].where = UNW_WHERE_NONE)
+	    && sr.curr.reg[UNW_REG_PSP].val != 0) {
 		/* new psp is sp plus frame size */
 		insn.opc = UNW_INSN_ADD;
-		insn.dst = unw.preg_index[UNW_REG_PSP];
-		insn.val = sr.curr.reg[UNW_REG_PSP].val;
+		insn.dst = struct_offset(struct unw_frame_info, psp)/8;
+		insn.val = sr.curr.reg[UNW_REG_PSP].val;	/* frame size */
 		script_emit(script, insn);
 	}
 
@@ -1566,23 +1589,34 @@
 								    val);
 			break;
 
-		      case UNW_INSN_LOAD_PSPREL:
+		      case UNW_INSN_ADD_PSP:
 			s[dst] = state->psp + val;
 			break;
 
-		      case UNW_INSN_LOAD_SPREL:
+		      case UNW_INSN_ADD_SP:
 			s[dst] = state->sp + val;
 			break;
 
-		      case UNW_INSN_SETNAT_PRI_UNAT:
-			if (!state->pri_unat)
-				state->pri_unat = &state->sw->caller_unat;
-			s[dst+1] = ((*state->pri_unat - s[dst]) << 32) | UNW_NAT_PRI_UNAT;
+		      case UNW_INSN_SETNAT_MEMSTK:
+			if (!state->pri_unat_loc)
+				state->pri_unat_loc = &state->sw->ar_unat;
+			/* register off. is a multiple of 8, so the least 3 bits (type) are 0 */
+			s[dst+1] = (*state->pri_unat_loc - s[dst]) | UNW_NAT_MEMSTK;
 			break;
 
 		      case UNW_INSN_SETNAT_TYPE:
 			s[dst+1] = val;
 			break;
+
+		      case UNW_INSN_LOAD:
+#if UNW_DEBUG
+			if ((s[val] & (my_cpu_data.unimpl_va_mask | 0x7)) || s[val] < TASK_SIZE) {
+				debug(1, "unwind: rejecting bad psp=0x%lx\n", s[val]);
+				break;
+			}
+#endif
+			s[dst] = *(unsigned long *) s[val];
+			break;
 		}
 	}
 	STAT(unw.stat.script.run_time += ia64_get_itc() - start);
@@ -1591,13 +1625,14 @@
   lazy_init:
 	off = unw.sw_off[val];
 	s[val] = (unsigned long) state->sw + off;
-	if (off >= struct_offset (struct unw_frame_info, r4)
-	    && off <= struct_offset (struct unw_frame_info, r7))
+	if (off >= struct_offset(struct switch_stack, r4)
+	    && off <= struct_offset(struct switch_stack, r7))
 		/*
-		 * We're initializing a general register: init NaT info, too.  Note that we
-		 * rely on the fact that call_unat is the first field in struct switch_stack:
+		 * We're initializing a general register: init NaT info, too.  Note that
+		 * the offset is a multiple of 8 which gives us the 3 bits needed for
+		 * the type field.
 		 */
-		s[val+1] = (-off << 32) | UNW_NAT_PRI_UNAT;
+		s[val+1] = (struct_offset(struct switch_stack, ar_unat) - off) | UNW_NAT_MEMSTK;
 	goto redo;
 }
 
@@ -1610,7 +1645,7 @@
 	if ((info->ip & (my_cpu_data.unimpl_va_mask | 0xf)) || info->ip < TASK_SIZE) {
 		/* don't let obviously bad addresses pollute the cache */
 		debug(1, "unwind: rejecting bad ip=0x%lx\n", info->ip);
-		info->rp = 0;
+		info->rp_loc = 0;
 		return -1;
 	}
 
@@ -1651,12 +1686,12 @@
 	prev_bsp = info->bsp;
 
 	/* restore the ip */
-	if (!info->rp) {
+	if (!info->rp_loc) {
 		debug(1, "unwind: failed to locate return link (ip=0x%lx)!\n", info->ip);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
-	ip = info->ip = *info->rp;
+	ip = info->ip = *info->rp_loc;
 	if (ip < GATE_ADDR + PAGE_SIZE) {
 		/*
 		 * We don't have unwind info for the gate page, so we consider that part
@@ -1668,23 +1703,23 @@
 	}
 
 	/* restore the cfm: */
-	if (!info->pfs) {
+	if (!info->pfs_loc) {
 		dprintk("unwind: failed to locate ar.pfs!\n");
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
-	info->cfm = info->pfs;
+	info->cfm_loc = info->pfs_loc;
 
 	/* restore the bsp: */
-	pr = info->pr_val;
+	pr = info->pr;
 	num_regs = 0;
 	if ((info->flags & UNW_FLAG_INTERRUPT_FRAME)) {
 		if ((pr & (1UL << pNonSys)) != 0)
-			num_regs = *info->cfm & 0x7f;		/* size of frame */
-		info->pfs +			num_regs = *info->cfm_loc & 0x7f;		/* size of frame */
+		info->pfs_loc  			(unsigned long *) (info->sp + 16 + struct_offset(struct pt_regs, ar_pfs));
 	} else
-		num_regs = (*info->cfm >> 7) & 0x7f;	/* size of locals */
+		num_regs = (*info->cfm_loc >> 7) & 0x7f;	/* size of locals */
 	info->bsp = (unsigned long) ia64_rse_skip_regs((unsigned long *) info->bsp, -num_regs);
 	if (info->bsp < info->regstk.limit || info->bsp > info->regstk.top) {
 		dprintk("unwind: bsp (0x%lx) out of range [0x%lx-0x%lx]\n",
@@ -1697,7 +1732,7 @@
 	info->sp = info->psp;
 	if (info->sp < info->memstk.top || info->sp > info->memstk.limit) {
 		dprintk("unwind: sp (0x%lx) out of range [0x%lx-0x%lx]\n",
-			info->sp, info->regstk.top, info->regstk.limit);
+			info->sp, info->memstk.top, info->memstk.limit);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
@@ -1708,8 +1743,11 @@
 		return -1;
 	}
 
+	/* as we unwind, the saved ar.unat becomes the primary unat: */
+	info->pri_unat_loc = info->unat_loc;
+
 	/* finally, restore the predicates: */
-	unw_get_pr(info, &info->pr_val);
+	unw_get_pr(info, &info->pr);
 
 	retval = find_save_locs(info);
 	STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
@@ -1776,11 +1814,11 @@
 	info->task = t;
 	info->sw  = sw;
 	info->sp = info->psp = (unsigned long) (sw + 1) - 16;
-	info->cfm = &sw->ar_pfs;
-	sol = (*info->cfm >> 7) & 0x7f;
+	info->cfm_loc = &sw->ar_pfs;
+	sol = (*info->cfm_loc >> 7) & 0x7f;
 	info->bsp = (unsigned long) ia64_rse_skip_regs((unsigned long *) info->regstk.top, -sol);
 	info->ip = sw->b0;
-	info->pr_val = sw->pr;
+	info->pr = sw->pr;
 
 	find_save_locs(info);
 	STAT(unw.stat.api.init_time += ia64_get_itc() - start; local_irq_restore(flags));
@@ -1811,7 +1849,7 @@
 	info->regstk.top   = top;
 	info->sw  = sw;
 	info->bsp = (unsigned long) ia64_rse_skip_regs((unsigned long *) info->regstk.top, -sol);
-	info->cfm = &sw->ar_pfs;
+	info->cfm_loc = &sw->ar_pfs;
 	info->ip  = sw->b0;
 #endif
 }
@@ -1848,7 +1886,7 @@
 	info->regstk.top   = top;
 	info->sw = sw;
 	info->bsp = (unsigned long) ia64_rse_skip_regs(bsp, -sof);
-	info->cfm = &regs->cr_ifs;
+	info->cfm_loc = &regs->cr_ifs;
 	info->ip  = regs->cr_iip;
 #endif
 }
@@ -1884,7 +1922,7 @@
 int
 unw_unwind (struct unw_frame_info *info)
 {
-	unsigned long sol, cfm = *info->cfm;
+	unsigned long sol, cfm = *info->cfm_loc;
 	int is_nat;
 
 	sol = (cfm >> 7) & 0x7f;	/* size of locals */
@@ -1906,7 +1944,7 @@
 		/* reject let obviously bad addresses */
 		return -1;
 
-	info->cfm = ia64_rse_skip_regs((unsigned long *) info->bsp, sol - 1);
+	info->cfm_loc = ia64_rse_skip_regs((unsigned long *) info->bsp, sol - 1);
 	cfm = read_reg(info, sol - 1, &is_nat);
 	if (is_nat)
 		return -1;
@@ -2073,9 +2111,9 @@
 	for (i = UNW_REG_F16, off = SW(F16); i <= UNW_REG_F31; ++i, off += 16)
 		unw.sw_off[unw.preg_index[i]] = off;
 
-	unw.cache[0].coll_chain = -1;
-	for (i = 1; i < UNW_CACHE_SIZE; ++i) {
-		unw.cache[i].lru_chain = (i - 1);
+	for (i = 0; i < UNW_CACHE_SIZE; ++i) {
+		if (i > 0)
+			unw.cache[i].lru_chain = (i - 1);
 		unw.cache[i].coll_chain = -1;
 		unw.cache[i].lock = RW_LOCK_UNLOCKED;
 	}
diff -urN linux-davidm/arch/ia64/kernel/unwind_i.h linux-2.4.0-test9-lia/arch/ia64/kernel/unwind_i.h
--- linux-davidm/arch/ia64/kernel/unwind_i.h	Thu Jun 22 07:09:44 2000
+++ linux-2.4.0-test9-lia/arch/ia64/kernel/unwind_i.h	Wed Oct  4 21:40:28 2000
@@ -115,21 +115,21 @@
 enum unw_nat_type {
 	UNW_NAT_NONE,		/* NaT not represented */
 	UNW_NAT_VAL,		/* NaT represented by NaT value (fp reg) */
-	UNW_NAT_PRI_UNAT,	/* NaT value is in unat word at offset OFF  */
-	UNW_NAT_SCRATCH,	/* NaT value is in scratch.pri_unat */
-	UNW_NAT_STACKED		/* NaT is in rnat */
+	UNW_NAT_MEMSTK,		/* NaT value is in unat word at offset OFF  */
+	UNW_NAT_REGSTK		/* NaT is in rnat */
 };
 
 enum unw_insn_opcode {
 	UNW_INSN_ADD,			/* s[dst] += val */
+	UNW_INSN_ADD_PSP,		/* s[dst] = (s.psp + val) */
+	UNW_INSN_ADD_SP,		/* s[dst] = (s.sp + val) */
 	UNW_INSN_MOVE,			/* s[dst] = s[val] */
 	UNW_INSN_MOVE2,			/* s[dst] = s[val]; s[dst+1] = s[val+1] */
 	UNW_INSN_MOVE_STACKED,		/* s[dst] = ia64_rse_skip(*s.bsp, val) */
-	UNW_INSN_LOAD_PSPREL,		/* s[dst] = *(*s.psp + 8*val) */
-	UNW_INSN_LOAD_SPREL,		/* s[dst] = *(*s.sp + 8*val) */
-	UNW_INSN_SETNAT_PRI_UNAT,	/* s[dst+1].nat.type = PRI_UNAT;
+	UNW_INSN_SETNAT_MEMSTK,		/* s[dst+1].nat.type = MEMSTK;
 					   s[dst+1].nat.off = *s.pri_unat - s[dst] */
-	UNW_INSN_SETNAT_TYPE		/* s[dst+1].nat.type = val */
+	UNW_INSN_SETNAT_TYPE,		/* s[dst+1].nat.type = val */
+	UNW_INSN_LOAD			/* s[dst] = *s[val] */
 };
 
 struct unw_insn {
diff -urN linux-davidm/arch/ia64/lib/Makefile linux-2.4.0-test9-lia/arch/ia64/lib/Makefile
--- linux-davidm/arch/ia64/lib/Makefile	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/arch/ia64/lib/Makefile	Wed Oct  4 21:40:41 2000
@@ -7,7 +7,8 @@
 
 L_TARGET = lib.a
 
-L_OBJS  = __divdi3.o __udivdi3.o __moddi3.o __umoddi3.o					\
+L_OBJS  = __divsi3.o __udivsi3.o __modsi3.o __umodsi3.o					\
+	__divdi3.o __udivdi3.o __moddi3.o __umoddi3.o					\
 	checksum.o clear_page.o csum_partial_copy.o copy_page.o				\
 	copy_user.o clear_user.o strncpy_from_user.o strlen_user.o strnlen_user.o	\
 	flush.o do_csum.o
@@ -18,20 +19,33 @@
 
 LX_OBJS = io.o
 
-IGNORE_FLAGS_OBJS = __divdi3.o __udivdi3.o __moddi3.o __umoddi3.o
+IGNORE_FLAGS_OBJS =	__divsi3.o __udivsi3.o __modsi3.o __umodsi3.o \
+			__divdi3.o __udivdi3.o __moddi3.o __umoddi3.o
 
 $(L_TARGET):
 
-__divdi3.o: idiv.S
+__divdi3.o: idiv64.S
 	$(CC) $(AFLAGS) $(AFLAGS_KERNEL) -c -o $@ $<
 
-__udivdi3.o: idiv.S
+__udivdi3.o: idiv64.S
 	$(CC) $(AFLAGS) $(AFLAGS_KERNEL) -c -DUNSIGNED -c -o $@ $<
 
-__moddi3.o: idiv.S
+__moddi3.o: idiv64.S
 	$(CC) $(AFLAGS) $(AFLAGS_KERNEL) -c -DMODULO -c -o $@ $<
 
-__umoddi3.o: idiv.S
+__umoddi3.o: idiv64.S
+	$(CC) $(AFLAGS) $(AFLAGS_KERNEL) -c -DMODULO -DUNSIGNED -c -o $@ $<
+
+__divsi3.o: idiv32.S
+	$(CC) $(AFLAGS) $(AFLAGS_KERNEL) -c -o $@ $<
+
+__udivsi3.o: idiv32.S
+	$(CC) $(AFLAGS) $(AFLAGS_KERNEL) -c -DUNSIGNED -c -o $@ $<
+
+__modsi3.o: idiv32.S
+	$(CC) $(AFLAGS) $(AFLAGS_KERNEL) -c -DMODULO -c -o $@ $<
+
+__umodsi3.o: idiv32.S
 	$(CC) $(AFLAGS) $(AFLAGS_KERNEL) -c -DMODULO -DUNSIGNED -c -o $@ $<
 
 include $(TOPDIR)/Rules.make
diff -urN linux-davidm/arch/ia64/lib/idiv.S linux-2.4.0-test9-lia/arch/ia64/lib/idiv.S
--- linux-davidm/arch/ia64/lib/idiv.S	Wed Aug  2 18:54:02 2000
+++ linux-2.4.0-test9-lia/arch/ia64/lib/idiv.S	Wed Dec 31 16:00:00 1969
@@ -1,98 +0,0 @@
-/*
- * Integer division routine.
- *
- * Copyright (C) 1999-2000 Hewlett-Packard Co
- * Copyright (C) 1999-2000 David Mosberger-Tang <davidm@hpl.hp.com>
- */
-
-#include <asm/asmmacro.h>
-
-/*
- * Compute a 64-bit unsigned integer quotient.
- *
- * Use reciprocal approximation and Newton-Raphson iteration to compute the
- * quotient.  frcpa gives 8.6 significant bits, so we need 3 iterations
- * to get more than the 64 bits of precision that we need for DImode.
- *
- * Must use max precision for the reciprocal computations to get 64 bits of
- * precision.
- *
- * r32 holds the dividend.  r33 holds the divisor.
- */
-
-#ifdef MODULO
-# define OP	mod
-#else
-# define OP	div
-#endif
-
-#ifdef UNSIGNED
-# define SGN	u
-# define INT_TO_FP(a,b)	fcvt.xuf.s1 a=b
-# define FP_TO_INT(a,b)	fcvt.fxu.trunc.s1 a=b
-#else
-# define SGN
-# define INT_TO_FP(a,b)	fcvt.xf a=b
-# define FP_TO_INT(a,b)	fcvt.fx.trunc.s1 a=b
-#endif
-
-#define PASTE1(a,b)	a##b
-#define PASTE(a,b)	PASTE1(a,b)
-#define NAME		PASTE(PASTE(__,SGN),PASTE(OP,di3))
-
-GLOBAL_ENTRY(NAME)
-	UNW(.prologue)
-	.regstk 2,0,0,0
-	// Transfer inputs to FP registers.
-	setf.sig f8 = in0
-	setf.sig f9 = in1
-	UNW(.fframe 16)
-	UNW(.save.f 0x20)
-	stf.spill [sp] = f17,-16
-
-	// Convert the inputs to FP, to avoid FP software-assist faults.
-	INT_TO_FP(f8, f8)
-	;;
-
-	UNW(.save.f 0x10)
-	stf.spill [sp] = f16
-	UNW(.body)
-	INT_TO_FP(f9, f9)
-	;;
-	frcpa.s1 f17, p6 = f8, f9	// y = frcpa(b)
-	;;
-	/*
-	 * This is the magic algorithm described in Section 8.6.2 of "IA-64
-	 * and Elementary Functions" by Peter Markstein; HP Professional Books
-	 * (http://www.hp.com/go/retailbooks/)
-	 */
-(p6)	fmpy.s1 f7 = f8, f17		// q = a*y
-(p6)	fnma.s1 f6 = f9, f17, f1	// e = -b*y + 1 
-	;;
-(p6)	fma.s1 f16 = f7, f6, f7		// q1 = q*e + q
-(p6)	fmpy.s1 f7 = f6, f6		// e1 = e*e
-	;;
-(p6)	fma.s1 f16 = f16, f7, f16	// q2 = q1*e1 + q1
-(p6)	fma.s1 f6 = f17, f6, f17	// y1 = y*e + y 
-	;;
-(p6)	fma.s1 f6 = f6, f7, f6		// y2 = y1*e1 + y1
-(p6)	fnma.s1 f7 = f9, f16, f8	// r = -b*q2 + a 
-	;;
-(p6)	fma.s1 f17 = f7, f6, f16	// q3 = r*y2 + q2
-	;;
-#ifdef MODULO
-	FP_TO_INT(f17, f17)		// round quotient to an unsigned integer
-	;;
-	INT_TO_FP(f17, f17)		// renormalize
-	;;
-	fnma.s1 f17 = f17, f9, f8	// compute remainder
-	;;
-#endif
-	UNW(.restore sp)
-	ldf.fill f16 = [sp], 16
-	FP_TO_INT(f8, f17)		// round result to an (unsigned) integer
-	;;
-	ldf.fill f17 = [sp]
-	getf.sig r8 = f8		// transfer result to result register
-	br.ret.sptk rp
-END(NAME)
diff -urN linux-davidm/arch/ia64/lib/idiv32.S linux-2.4.0-test9-lia/arch/ia64/lib/idiv32.S
--- linux-davidm/arch/ia64/lib/idiv32.S	Wed Dec 31 16:00:00 1969
+++ linux-2.4.0-test9-lia/arch/ia64/lib/idiv32.S	Wed Oct  4 21:41:02 2000
@@ -0,0 +1,83 @@
+/*
+ * Copyright (C) 2000 Hewlett-Packard Co
+ * Copyright (C) 2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ *
+ * 32-bit integer division.
+ *
+ * This code is based on the application note entitled "Divide, Square Root
+ * and Remainder Algorithms for the IA-64 Architecture".  This document
+ * is available as Intel document number 248725-002 or via the web at
+ * http://developer.intel.com/software/opensource/numerics/
+ *
+ * For more details on the theory behind these algorithms, see "IA-64
+ * and Elementary Functions" by Peter Markstein; HP Professional Books
+ * (http://www.hp.com/go/retailbooks/)
+ */
+
+#include <asm/asmmacro.h>
+
+#ifdef MODULO
+# define OP	mod
+#else
+# define OP	div
+#endif
+
+#ifdef UNSIGNED
+# define SGN	u
+# define EXTEND	zxt4
+# define INT_TO_FP(a,b)	fcvt.xuf.s1 a=b
+# define FP_TO_INT(a,b)	fcvt.fxu.trunc.s1 a=b
+#else
+# define SGN
+# define EXTEND	sxt4
+# define INT_TO_FP(a,b)	fcvt.xf a=b
+# define FP_TO_INT(a,b)	fcvt.fx.trunc.s1 a=b
+#endif
+
+#define PASTE1(a,b)	a##b
+#define PASTE(a,b)	PASTE1(a,b)
+#define NAME		PASTE(PASTE(__,SGN),PASTE(OP,si3))
+
+GLOBAL_ENTRY(NAME)
+	.regstk 2,0,0,0
+	// Transfer inputs to FP registers.
+	mov r2 = 0xffdd			// r2 = -34 + 65535 (fp reg format bias)
+	EXTEND in0 = in0		// in0 = a
+	EXTEND in1 = in1		// in1 = b
+	;;
+	setf.sig f8 = in0
+	setf.sig f9 = in1
+#ifdef MODULO
+	sub in1 = r0, in1		// in1 = -b
+#endif
+	;;
+	// Convert the inputs to FP, to avoid FP software-assist faults.
+	INT_TO_FP(f8, f8)
+	INT_TO_FP(f9, f9)
+	;;
+	setf.exp f7 = r2		// f7 = 2^-34
+	frcpa.s1 f6, p6 = f8, f9	// y0 = frcpa(b)
+	;;
+(p6)	fmpy.s1 f8 = f8, f6		// q0 = a*y0
+(p6)	fnma.s1 f6 = f9, f6, f1		// e0 = -b*y0 + 1 
+	;;
+#ifdef MODULO
+	setf.sig f9 = in1		// f9 = -b
+#endif
+(p6)	fma.s1 f8 = f6, f8, f8		// q1 = e0*q0 + q0
+(p6)	fma.s1 f6 = f6, f6, f7		// e1 = e0*e0 + 2^-34
+	;;
+#ifdef MODULO
+	setf.sig f7 = in0
+#endif
+(p6)	fma.s1 f6 = f6, f8, f8		// q2 = e1*q1 + q1
+	;;
+	FP_TO_INT(f6, f6)		// q = trunc(q2)
+	;;
+#ifdef MODULO
+	xma.l f6 = f6, f9, f7		// r = q*(-b) + a
+	;;
+#endif
+	getf.sig r8 = f6		// transfer result to result register
+	br.ret.sptk rp
+END(NAME)
diff -urN linux-davidm/arch/ia64/lib/idiv64.S linux-2.4.0-test9-lia/arch/ia64/lib/idiv64.S
--- linux-davidm/arch/ia64/lib/idiv64.S	Wed Dec 31 16:00:00 1969
+++ linux-2.4.0-test9-lia/arch/ia64/lib/idiv64.S	Wed Oct  4 21:41:04 2000
@@ -0,0 +1,92 @@
+/*
+ * Copyright (C) 1999-2000 Hewlett-Packard Co
+ * Copyright (C) 1999-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ *
+ * 64-bit integer division.
+ *
+ * This code is based on the application note entitled "Divide, Square Root
+ * and Remainder Algorithms for the IA-64 Architecture".  This document
+ * is available as Intel document number 248725-002 or via the web at
+ * http://developer.intel.com/software/opensource/numerics/
+ *
+ * For more details on the theory behind these algorithms, see "IA-64
+ * and Elementary Functions" by Peter Markstein; HP Professional Books
+ * (http://www.hp.com/go/retailbooks/)
+ */
+
+#include <asm/asmmacro.h>
+
+#ifdef MODULO
+# define OP	mod
+#else
+# define OP	div
+#endif
+
+#ifdef UNSIGNED
+# define SGN	u
+# define INT_TO_FP(a,b)	fcvt.xuf.s1 a=b
+# define FP_TO_INT(a,b)	fcvt.fxu.trunc.s1 a=b
+#else
+# define SGN
+# define INT_TO_FP(a,b)	fcvt.xf a=b
+# define FP_TO_INT(a,b)	fcvt.fx.trunc.s1 a=b
+#endif
+
+#define PASTE1(a,b)	a##b
+#define PASTE(a,b)	PASTE1(a,b)
+#define NAME		PASTE(PASTE(__,SGN),PASTE(OP,di3))
+
+GLOBAL_ENTRY(NAME)
+	UNW(.prologue)
+	.regstk 2,0,0,0
+	// Transfer inputs to FP registers.
+	setf.sig f8 = in0
+	setf.sig f9 = in1
+	UNW(.fframe 16)
+	UNW(.save.f 0x20)
+	stf.spill [sp] = f17,-16
+
+	// Convert the inputs to FP, to avoid FP software-assist faults.
+	INT_TO_FP(f8, f8)
+	;;
+
+	UNW(.save.f 0x10)
+	stf.spill [sp] = f16
+	UNW(.body)
+	INT_TO_FP(f9, f9)
+	;;
+	frcpa.s1 f17, p6 = f8, f9	// y0 = frcpa(b)
+	;;
+(p6)	fmpy.s1 f7 = f8, f17		// q0 = a*y0
+(p6)	fnma.s1 f6 = f9, f17, f1	// e0 = -b*y0 + 1 
+	;;
+(p6)	fma.s1 f16 = f7, f6, f7		// q1 = q0*e0 + q0
+(p6)	fmpy.s1 f7 = f6, f6		// e1 = e0*e0
+	;;
+#ifdef MODULO
+	sub in1 = r0, in1		// in1 = -b
+#endif
+(p6)	fma.s1 f16 = f16, f7, f16	// q2 = q1*e1 + q1
+(p6)	fma.s1 f6 = f17, f6, f17	// y1 = y0*e0 + y0
+	;;
+(p6)	fma.s1 f6 = f6, f7, f6		// y2 = y1*e1 + y1
+(p6)	fnma.s1 f7 = f9, f16, f8	// r = -b*q2 + a 
+	;;
+#ifdef MODULO
+	setf.sig f8 = in0		// f8 = a
+	setf.sig f9 = in1		// f9 = -b
+#endif
+(p6)	fma.s1 f17 = f7, f6, f16	// q3 = r*y2 + q2
+	;;
+	UNW(.restore sp)
+	ldf.fill f16 = [sp], 16
+	FP_TO_INT(f17, f17)		// q = trunc(q3)
+	;;
+#ifdef MODULO
+	xma.l f17 = f17, f9, f8		// r = q*(-b) + a
+	;;
+#endif
+	getf.sig r8 = f17		// transfer result to result register
+	ldf.fill f17 = [sp]
+	br.ret.sptk rp
+END(NAME)
diff -urN linux-davidm/arch/ia64/mm/init.c linux-2.4.0-test9-lia/arch/ia64/mm/init.c
--- linux-davidm/arch/ia64/mm/init.c	Thu Aug 24 08:17:30 2000
+++ linux-2.4.0-test9-lia/arch/ia64/mm/init.c	Wed Oct  4 23:03:06 2000
@@ -357,6 +357,7 @@
 		panic("mm/init: overlap between virtually mapped linear page table and "
 		      "mapped kernel space!");
 	pta = POW2(61) - POW2(impl_va_msb);
+#ifndef CONFIG_DISABLE_VHPT
 	/*
 	 * Set the (virtually mapped linear) page table address.  Bit
 	 * 8 selects between the short and long format, bits 2-7 the
@@ -364,6 +365,9 @@
 	 * enabled.
 	 */
 	ia64_set_pta(pta | (0<<8) | ((3*(PAGE_SHIFT-3)+3)<<2) | 1);
+#else
+	ia64_set_pta(pta | (0<<8) | ((3*(PAGE_SHIFT-3)+3)<<2) | 0);
+#endif
 }
 
 /*
@@ -444,15 +448,6 @@
 
 	/* install the gate page in the global page table: */
 	put_gate_page(virt_to_page(__start_gate_section), GATE_ADDR);
-
-#ifndef CONFIG_IA64_SOFTSDV_HACKS
-	/*
-	 * (Some) SoftSDVs seem to have a problem with this call.
-	 * Since it's mostly a performance optimization, just don't do
-	 * it for now...  --davidm 99/12/6
-	 */
-	efi_enter_virtual_mode();
-#endif
 
 #ifdef CONFIG_IA32_SUPPORT
 	ia32_gdt_init();
diff -urN linux-davidm/drivers/char/vt.c linux-2.4.0-test9-lia/drivers/char/vt.c
--- linux-davidm/drivers/char/vt.c	Wed Aug  2 18:54:18 2000
+++ linux-2.4.0-test9-lia/drivers/char/vt.c	Wed Oct  4 21:43:13 2000
@@ -62,7 +62,7 @@
  */
 unsigned char keyboard_type = KB_101;
 
-#if !defined(__alpha__) && !defined(__mips__) && !defined(__arm__) && !defined(__sh__)
+#if !defined(__alpha__) && !defined(__ia64__) && !defined(__mips__) && !defined(__arm__) && !defined(__sh__)
 asmlinkage long sys_ioperm(unsigned long from, unsigned long num, int on);
 #endif
 
@@ -472,7 +472,7 @@
 		ucval = keyboard_type;
 		goto setchar;
 
-#if !defined(__alpha__) && !defined(__mips__) && !defined(__arm__) && !defined(__sh__)
+#if !defined(__alpha__) && !defined(__ia64__) && !defined(__mips__) && !defined(__arm__) && !defined(__sh__)
 		/*
 		 * These cannot be implemented on any machine that implements
 		 * ioperm() in user level (such as Alpha PCs).
diff -urN linux-davidm/drivers/scsi/Makefile linux-2.4.0-test9-lia/drivers/scsi/Makefile
--- linux-davidm/drivers/scsi/Makefile	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/drivers/scsi/Makefile	Wed Oct  4 21:30:21 2000
@@ -123,7 +123,7 @@
 			scsicam.o scsi_proc.o scsi_error.o \
 			scsi_obsolete.o scsi_queue.o scsi_lib.o \
 			scsi_merge.o scsi_dma.o scsi_scan.o \
-			
+
 sr_mod-objs	:= sr.o sr_ioctl.o sr_vendor.o
 initio-objs	:= ini9100u.o i91uscsi.o
 a100u2w-objs	:= inia100.o i60uscsi.o
diff -urN linux-davidm/drivers/scsi/qla1280.c linux-2.4.0-test9-lia/drivers/scsi/qla1280.c
--- linux-davidm/drivers/scsi/qla1280.c	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/drivers/scsi/qla1280.c	Wed Oct  4 21:43:30 2000
@@ -19,6 +19,10 @@
 
 /****************************************************************************
     Revision History:
+    Rev  3.17 Beta September 18, 2000 BN Qlogic
+        - Removed warnings for 32 bit 2.4.x compiles
+        - Corrected declared size for request and response
+          DMA addresses that are kept in each ha
     Rev. 3.16 Beta  August 25, 2000   BN  Qlogic
         - Corrected 64 bit addressing issue on IA-64
           where the upper 32 bits were not properly
@@ -98,7 +102,7 @@
 #include <linux/module.h>
 #endif
 
-#define QLA1280_VERSION      "3.16 Beta"
+#define QLA1280_VERSION      "3.17 Beta"
 
 #include <stdarg.h>
 #include <asm/io.h>
@@ -175,8 +179,13 @@
 #define QLA1280_DELAY(sec)  mdelay(sec * 1000)
 
 /* 3.16 */
+#if  BITS_PER_LONG > 32
 #define pci_dma_lo32(a) (a & 0xffffffff)
 #define pci_dma_hi32(a) ((a >> 32) & 0xffffffff)
+#else
+#define pci_dma_lo32(a) (a & 0xffffffff)
+#define pci_dma_hi32(a) 0
+#endif
 
 #define  VIRT_TO_BUS(a)  virt_to_bus(((void *)a))
 
@@ -2789,7 +2798,7 @@
     uint8_t *sp;
     uint8_t    *tbuf;
 #if BITS_PER_LONG > 32
-    u_long     p_tbuf;
+    dma_addr_t     p_tbuf;
 #else
     uint32_t   p_tbuf;
 #endif
@@ -4170,12 +4179,12 @@
 #endif
                 }
             }
-#ifdef QL_DEBUG_LEVEL_5
-            else                            /* No data transfer */
+            else         /* No data transfer */
             {
                 *dword_ptr++ = (uint32_t) 0;
                 *dword_ptr++ = (uint32_t) 0;
                 *dword_ptr = (uint32_t)  0;
+#ifdef QL_DEBUG_LEVEL_5
                 qla1280_print(
                         "qla1280_64bit_start_scsi: No data, command packet data - c");
                 qla1280_print(" b ");
@@ -4186,8 +4195,8 @@
                 qla1280_output_number((uint32_t)SCSI_LUN_32(cmd), 10);
                 qla1280_print("\n\r");
                 qla1280_dump_buffer((caddr_t)pkt, REQUEST_ENTRY_SIZE);
-            }
 #endif
+            }
             /* Adjust ring index. */
             ha->req_ring_index++;
             if (ha->req_ring_index = REQUEST_ENTRY_CNT)
diff -urN linux-davidm/drivers/scsi/qla1280.h linux-2.4.0-test9-lia/drivers/scsi/qla1280.h
--- linux-davidm/drivers/scsi/qla1280.h	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/drivers/scsi/qla1280.h	Wed Oct  4 21:43:38 2000
@@ -1439,22 +1439,35 @@
 
     request_t       req[REQUEST_ENTRY_CNT+1];
     response_t      res[RESPONSE_ENTRY_CNT+1];
+#if BITS_PER_LONG > 32
+    dma_addr_t      request_dma;        /* Physical Address */
+#else
     uint32_t        request_dma;        /* Physical address. */
+#endif
     request_t       *request_ring;      /* Base virtual address */
     request_t       *request_ring_ptr;  /* Current address. */
     uint16_t        req_ring_index;     /* Current index. */
     uint16_t        req_q_cnt;          /* Number of available entries. */
 
+#if BITS_PER_LONG > 32
+    dma_addr_t      response_dma;       /* Physical address. */
+#else
     uint32_t        response_dma;       /* Physical address. */
+#endif
     response_t      *response_ring;     /* Base virtual address */
     response_t      *response_ring_ptr; /* Current address. */
     uint16_t        rsp_ring_index;     /* Current index. */
 
 #if QL1280_TARGET_MODE_SUPPORT
     /* Target buffer and sense data. */
+#if BITS_PER_LONG > 32
+    dma_addr_t      tbuf_dma;           /* Physical address. */
+    dma_addr_t      tsense_dma;         /* Physical address. */
+#else
     uint32_t        tbuf_dma;           /* Physical address. */
-    tgt_t           *tbuf;
     uint32_t        tsense_dma;         /* Physical address. */
+#endif
+    tgt_t           *tbuf;
     uint8_t         *tsense;
 #endif
 
diff -urN linux-davidm/drivers/scsi/simscsi.c linux-2.4.0-test9-lia/drivers/scsi/simscsi.c
--- linux-davidm/drivers/scsi/simscsi.c	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/drivers/scsi/simscsi.c	Wed Oct  4 21:43:52 2000
@@ -357,3 +357,8 @@
 	}
 	return 0;
 }
+
+
+static Scsi_Host_Template driver_template = SIMSCSI;
+
+#include "scsi_module.c"
diff -urN linux-davidm/include/asm-ia64/acpikcfg.h linux-2.4.0-test9-lia/include/asm-ia64/acpikcfg.h
--- linux-davidm/include/asm-ia64/acpikcfg.h	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/acpikcfg.h	Wed Oct  4 21:46:27 2000
@@ -7,12 +7,10 @@
  */
 
 
-typedef	u32	ACPI_STATUS;    /* from actypes.h */
+u32	__init acpi_cf_init (void * rsdp);
+u32	__init acpi_cf_terminate (void );
 
-ACPI_STATUS	__init acpi_cf_init (void * rsdp);
-ACPI_STATUS	__init acpi_cf_terminate (void );
-
-ACPI_STATUS	__init
+u32	__init
 acpi_cf_get_pci_vectors (
 	struct pci_vector_struct	**vectors,
 	int				*num_pci_vectors
diff -urN linux-davidm/include/asm-ia64/atomic.h linux-2.4.0-test9-lia/include/asm-ia64/atomic.h
--- linux-davidm/include/asm-ia64/atomic.h	Fri Apr 21 15:21:24 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/atomic.h	Wed Oct  4 21:46:40 2000
@@ -17,13 +17,6 @@
 #include <asm/system.h>
 
 /*
- * Make sure gcc doesn't try to be clever and move things around
- * on us. We need to use _exactly_ the address the user gave us,
- * not some alias that contains the same information.
- */
-#define __atomic_fool_gcc(x) (*(volatile struct { int a[100]; } *)x)
-
-/*
  * On IA-64, counter must always be volatile to ensure that that the
  * memory accesses are ordered.
  */
diff -urN linux-davidm/include/asm-ia64/bitops.h linux-2.4.0-test9-lia/include/asm-ia64/bitops.h
--- linux-davidm/include/asm-ia64/bitops.h	Wed Jul  5 22:15:26 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/bitops.h	Wed Oct  4 21:46:53 2000
@@ -20,7 +20,7 @@
  * bit 0 is the LSB of addr; bit 32 is the LSB of (addr+1).
  */
 
-extern __inline__ void
+static __inline__ void
 set_bit (int nr, volatile void *addr)
 {
 	__u32 bit, old, new;
@@ -36,7 +36,12 @@
 	} while (cmpxchg_acq(m, old, new) != old);
 }
 
-extern __inline__ void
+/*
+ * clear_bit() doesn't provide any barrier for the compiler.
+ */
+#define smp_mb__before_clear_bit()	smp_mb()
+#define smp_mb__after_clear_bit()	smp_mb()
+static __inline__ void
 clear_bit (int nr, volatile void *addr)
 {
 	__u32 mask, old, new;
@@ -52,7 +57,7 @@
 	} while (cmpxchg_acq(m, old, new) != old);
 }
 
-extern __inline__ void
+static __inline__ void
 change_bit (int nr, volatile void *addr)
 {
 	__u32 bit, old, new;
@@ -68,7 +73,7 @@
 	} while (cmpxchg_acq(m, old, new) != old);
 }
 
-extern __inline__ int
+static __inline__ int
 test_and_set_bit (int nr, volatile void *addr)
 {
 	__u32 bit, old, new;
@@ -85,7 +90,7 @@
 	return (old & bit) != 0;
 }
 
-extern __inline__ int
+static __inline__ int
 test_and_clear_bit (int nr, volatile void *addr)
 {
 	__u32 mask, old, new;
@@ -102,7 +107,7 @@
 	return (old & ~mask) != 0;
 }
 
-extern __inline__ int
+static __inline__ int
 test_and_change_bit (int nr, volatile void *addr)
 {
 	__u32 bit, old, new;
@@ -119,7 +124,7 @@
 	return (old & bit) != 0;
 }
 
-extern __inline__ int
+static __inline__ int
 test_bit (int nr, volatile void *addr)
 {
 	return 1 & (((const volatile __u32 *) addr)[nr >> 5] >> (nr & 31));
@@ -129,7 +134,7 @@
  * ffz = Find First Zero in word. Undefined if no zero exists,
  * so code should check against ~0UL first..
  */
-extern inline unsigned long
+static inline unsigned long
 ffz (unsigned long x)
 {
 	unsigned long result;
@@ -164,7 +169,7 @@
  * hweightN: returns the hamming weight (i.e. the number
  * of bits set) of a N-bit word
  */
-extern __inline__ unsigned long
+static __inline__ unsigned long
 hweight64 (unsigned long x)
 {
 	unsigned long result;
@@ -181,7 +186,7 @@
 /*
  * Find next zero bit in a bitmap reasonably efficiently..
  */
-extern inline int
+static inline int
 find_next_zero_bit (void *addr, unsigned long size, unsigned long offset)
 {
 	unsigned long *p = ((unsigned long *) addr) + (offset >> 6);
diff -urN linux-davidm/include/asm-ia64/delay.h linux-2.4.0-test9-lia/include/asm-ia64/delay.h
--- linux-davidm/include/asm-ia64/delay.h	Sun Feb  6 18:42:40 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/delay.h	Wed Oct  4 21:46:59 2000
@@ -18,13 +18,13 @@
 
 #include <asm/processor.h>
 
-extern __inline__ void
+static __inline__ void
 ia64_set_itm (unsigned long val)
 {
 	__asm__ __volatile__("mov cr.itm=%0;; srlz.d;;" :: "r"(val) : "memory");
 }
 
-extern __inline__ unsigned long
+static __inline__ unsigned long
 ia64_get_itm (void)
 {
 	unsigned long result;
@@ -33,7 +33,7 @@
 	return result;
 }
 
-extern __inline__ void
+static __inline__ void
 ia64_set_itv (unsigned char vector, unsigned char masked)
 {
 	if (masked > 1)
@@ -43,13 +43,13 @@
 			     :: "r"((masked << 16) | vector) : "memory");
 }
 
-extern __inline__ void
+static __inline__ void
 ia64_set_itc (unsigned long val)
 {
 	__asm__ __volatile__("mov ar.itc=%0;; srlz.d;;" :: "r"(val) : "memory");
 }
 
-extern __inline__ unsigned long
+static __inline__ unsigned long
 ia64_get_itc (void)
 {
 	unsigned long result;
@@ -58,7 +58,7 @@
 	return result;
 }
 
-extern __inline__ void
+static __inline__ void
 __delay (unsigned long loops)
 {
         unsigned long saved_ar_lc;
@@ -72,7 +72,7 @@
 	__asm__ __volatile__("mov ar.lc=%0" :: "r"(saved_ar_lc));
 }
 
-extern __inline__ void
+static __inline__ void
 udelay (unsigned long usecs)
 {
 #ifdef CONFIG_IA64_SOFTSDV_HACKS
diff -urN linux-davidm/include/asm-ia64/efi.h linux-2.4.0-test9-lia/include/asm-ia64/efi.h
--- linux-davidm/include/asm-ia64/efi.h	Thu Aug 24 08:17:47 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/efi.h	Wed Oct  4 21:47:05 2000
@@ -219,7 +219,7 @@
 	efi_reset_system_t *reset_system;
 } efi;
 
-extern inline int
+static inline int
 efi_guidcmp (efi_guid_t left, efi_guid_t right)
 {
 	return memcmp(&left, &right, sizeof (efi_guid_t));
diff -urN linux-davidm/include/asm-ia64/io.h linux-2.4.0-test9-lia/include/asm-ia64/io.h
--- linux-davidm/include/asm-ia64/io.h	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/io.h	Wed Oct  4 21:47:47 2000
@@ -63,7 +63,7 @@
  */
 #define __ia64_mf_a()	__asm__ __volatile__ ("mf.a" ::: "memory")
 
-extern inline const unsigned long
+static inline const unsigned long
 __ia64_get_io_port_base (void)
 {
 	extern unsigned long ia64_iobase;
@@ -71,7 +71,7 @@
 	return ia64_iobase;
 }
 
-extern inline void*
+static inline void*
 __ia64_mk_io_addr (unsigned long port)
 {
 	const unsigned long io_base = __ia64_get_io_port_base();
@@ -99,7 +99,7 @@
  * order. --davidm 99/12/07 
  */
 
-extern inline unsigned int
+static inline unsigned int
 __inb (unsigned long port)
 {
 	volatile unsigned char *addr = __ia64_mk_io_addr(port);
@@ -110,7 +110,7 @@
 	return ret;
 }
 
-extern inline unsigned int
+static inline unsigned int
 __inw (unsigned long port)
 {
 	volatile unsigned short *addr = __ia64_mk_io_addr(port);
@@ -121,7 +121,7 @@
 	return ret;
 }
 
-extern inline unsigned int
+static inline unsigned int
 __inl (unsigned long port)
 {
 	volatile unsigned int *addr = __ia64_mk_io_addr(port);
@@ -132,7 +132,7 @@
 	return ret;
 }
 
-extern inline void
+static inline void
 __insb (unsigned long port, void *dst, unsigned long count)
 {
 	volatile unsigned char *addr = __ia64_mk_io_addr(port);
@@ -146,7 +146,7 @@
 	return;
 }
 
-extern inline void
+static inline void
 __insw (unsigned long port, void *dst, unsigned long count)
 {
 	volatile unsigned short *addr = __ia64_mk_io_addr(port);
@@ -160,7 +160,7 @@
 	return;
 }
 
-extern inline void
+static inline void
 __insl (unsigned long port, void *dst, unsigned long count)
 {
 	volatile unsigned int *addr = __ia64_mk_io_addr(port);
@@ -174,7 +174,7 @@
 	return;
 }
 
-extern inline void
+static inline void
 __outb (unsigned char val, unsigned long port)
 {
 	volatile unsigned char *addr = __ia64_mk_io_addr(port);
@@ -183,7 +183,7 @@
 	__ia64_mf_a();
 }
 
-extern inline void
+static inline void
 __outw (unsigned short val, unsigned long port)
 {
 	volatile unsigned short *addr = __ia64_mk_io_addr(port);
@@ -192,7 +192,7 @@
 	__ia64_mf_a();
 }
 
-extern inline void
+static inline void
 __outl (unsigned int val, unsigned long port)
 {
 	volatile unsigned int *addr = __ia64_mk_io_addr(port);
@@ -201,7 +201,7 @@
 	__ia64_mf_a();
 }
 
-extern inline void
+static inline void
 __outsb (unsigned long port, const void *src, unsigned long count)
 {
 	volatile unsigned char *addr = __ia64_mk_io_addr(port);
@@ -214,7 +214,7 @@
 	return;
 }
 
-extern inline void
+static inline void
 __outsw (unsigned long port, const void *src, unsigned long count)
 {
 	volatile unsigned short *addr = __ia64_mk_io_addr(port);
@@ -227,7 +227,7 @@
 	return;
 }
 
-extern inline void
+static inline void
 __outsl (unsigned long port, void *src, unsigned long count)
 {
 	volatile unsigned int *addr = __ia64_mk_io_addr(port);
@@ -256,49 +256,49 @@
 /*
  * The address passed to these functions are ioremap()ped already.
  */
-extern inline unsigned char
+static inline unsigned char
 __readb (void *addr)
 {
 	return *(volatile unsigned char *)addr;
 }
 
-extern inline unsigned short
+static inline unsigned short
 __readw (void *addr)
 {
 	return *(volatile unsigned short *)addr;
 }
 
-extern inline unsigned int
+static inline unsigned int
 __readl (void *addr)
 {
 	return *(volatile unsigned int *) addr;
 }
 
-extern inline unsigned long
+static inline unsigned long
 __readq (void *addr)
 {
 	return *(volatile unsigned long *) addr;
 }
 
-extern inline void
+static inline void
 __writeb (unsigned char val, void *addr)
 {
 	*(volatile unsigned char *) addr = val;
 }
 
-extern inline void
+static inline void
 __writew (unsigned short val, void *addr)
 {
 	*(volatile unsigned short *) addr = val;
 }
 
-extern inline void
+static inline void
 __writel (unsigned int val, void *addr)
 {
 	*(volatile unsigned int *) addr = val;
 }
 
-extern inline void
+static inline void
 __writeq (unsigned long val, void *addr)
 {
 	*(volatile unsigned long *) addr = val;
diff -urN linux-davidm/include/asm-ia64/mmu_context.h linux-2.4.0-test9-lia/include/asm-ia64/mmu_context.h
--- linux-davidm/include/asm-ia64/mmu_context.h	Thu Aug 24 08:17:47 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/mmu_context.h	Wed Oct  4 21:48:03 2000
@@ -57,7 +57,7 @@
 {
 }
 
-extern inline unsigned long
+static inline unsigned long
 ia64_rid (unsigned long context, unsigned long region_addr)
 {
 # ifdef CONFIG_IA64_TLB_CHECKS_REGION_NUMBER
@@ -67,7 +67,7 @@
 # endif
 }
 
-extern inline void
+static inline void
 get_new_mmu_context (struct mm_struct *mm)
 {
 	spin_lock(&ia64_ctx.lock);
@@ -80,7 +80,7 @@
 
 }
 
-extern inline void
+static inline void
 get_mmu_context (struct mm_struct *mm)
 {
 	/* check if our ASN is of an older generation and thus invalid: */
@@ -88,20 +88,20 @@
 		get_new_mmu_context(mm);
 }
 
-extern inline int
+static inline int
 init_new_context (struct task_struct *p, struct mm_struct *mm)
 {
 	mm->context = 0;
 	return 0;
 }
 
-extern inline void
+static inline void
 destroy_context (struct mm_struct *mm)
 {
 	/* Nothing to do.  */
 }
 
-extern inline void
+static inline void
 reload_context (struct mm_struct *mm)
 {
 	unsigned long rid;
diff -urN linux-davidm/include/asm-ia64/module.h linux-2.4.0-test9-lia/include/asm-ia64/module.h
--- linux-davidm/include/asm-ia64/module.h	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/module.h	Wed Oct  4 21:48:16 2000
@@ -76,7 +76,9 @@
 	 * Pointers are reasonable, add the module unwind table
 	 */
 	archdata->unw_table = unw_add_unwind_table(mod->name, archdata->segment_base,
-		archdata->gp, archdata->unw_start, archdata->unw_end);
+						   (unsigned long) archdata->gp,
+						   (unsigned long) archdata->unw_start,
+						   (unsigned long) archdata->unw_end);
 #endif /* CONFIG_IA64_NEW_UNWIND */
 	return 0;
 }
diff -urN linux-davidm/include/asm-ia64/offsets.h linux-2.4.0-test9-lia/include/asm-ia64/offsets.h
--- linux-davidm/include/asm-ia64/offsets.h	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/offsets.h	Wed Oct  4 21:48:29 2000
@@ -11,7 +11,7 @@
 #define PT_PTRACED_BIT			0
 #define PT_TRACESYS_BIT			1
 
-#define IA64_TASK_SIZE			2928	/* 0xb70 */
+#define IA64_TASK_SIZE			3328	/* 0xd00 */
 #define IA64_PT_REGS_SIZE		400	/* 0x190 */
 #define IA64_SWITCH_STACK_SIZE		560	/* 0x230 */
 #define IA64_SIGINFO_SIZE		128	/* 0x80 */
@@ -21,9 +21,9 @@
 #define IA64_TASK_SIGPENDING_OFFSET	16	/* 0x10 */
 #define IA64_TASK_NEED_RESCHED_OFFSET	40	/* 0x28 */
 #define IA64_TASK_PROCESSOR_OFFSET	100	/* 0x64 */
-#define IA64_TASK_THREAD_OFFSET		928	/* 0x3a0 */
-#define IA64_TASK_THREAD_KSP_OFFSET	928	/* 0x3a0 */
-#define IA64_TASK_THREAD_SIGMASK_OFFSET	2784	/* 0xae0 */
+#define IA64_TASK_THREAD_OFFSET		1424	/* 0x590 */
+#define IA64_TASK_THREAD_KSP_OFFSET	1424	/* 0x590 */
+#define IA64_TASK_THREAD_SIGMASK_OFFSET	3184	/* 0xc70 */
 #define IA64_TASK_PID_OFFSET		188	/* 0xbc */
 #define IA64_TASK_MM_OFFSET		88	/* 0x58 */
 #define IA64_PT_REGS_CR_IPSR_OFFSET	0	/* 0x0 */
diff -urN linux-davidm/include/asm-ia64/page.h linux-2.4.0-test9-lia/include/asm-ia64/page.h
--- linux-davidm/include/asm-ia64/page.h	Thu Aug 24 08:17:47 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/page.h	Wed Oct  4 21:48:41 2000
@@ -102,15 +102,13 @@
 #ifdef CONFIG_IA64_GENERIC
 # include <asm/machvec.h>
 # define virt_to_page(kaddr)   (mem_map + platform_map_nr(kaddr))
-#elif defined (CONFIG_IA64_SN_SN1_SIM)
+#elif defined (CONFIG_IA64_SN_SN1)
 # define virt_to_page(kaddr)   (mem_map + MAP_NR_SN1(kaddr))
 #else
 # define virt_to_page(kaddr)   (mem_map + MAP_NR_DENSE(kaddr))
 #endif
 #define VALID_PAGE(page)       ((page - mem_map) < max_mapnr)
 
-# endif /* __KERNEL__ */
-
 typedef union ia64_va {
 	struct {
 		unsigned long off : 61;		/* intra-region offset */
@@ -138,7 +136,7 @@
 #define BUG() do { printk("kernel BUG at %s:%d!\n", __FILE__, __LINE__); *(int *)0=0; } while (0)
 #define PAGE_BUG(page) do { BUG(); } while (0)
 
-extern __inline__ int
+static __inline__ int
 get_order (unsigned long size)
 {
 	double d = size - 1;
@@ -151,6 +149,7 @@
 	return order;
 }
 
+# endif /* __KERNEL__ */
 #endif /* !ASSEMBLY */
 
 #define PAGE_OFFSET		0xe000000000000000
diff -urN linux-davidm/include/asm-ia64/pal.h linux-2.4.0-test9-lia/include/asm-ia64/pal.h
--- linux-davidm/include/asm-ia64/pal.h	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/pal.h	Wed Oct  4 21:48:58 2000
@@ -708,7 +708,7 @@
 extern void pal_bus_features_print (u64);
 
 /* Provide information about configurable processor bus features */
-extern inline s64 
+static inline s64 
 ia64_pal_bus_get_features (pal_bus_features_u_t *features_avail,
 			   pal_bus_features_u_t *features_status,
 			   pal_bus_features_u_t *features_control)
@@ -725,7 +725,7 @@
 }
 
 /* Enables/disables specific processor bus features */
-extern inline s64 
+static inline s64 
 ia64_pal_bus_set_features (pal_bus_features_u_t feature_select) 
 {	
 	struct ia64_pal_retval iprv;
@@ -734,7 +734,7 @@
 }
 
 /* Get detailed cache information */
-extern inline s64
+static inline s64
 ia64_pal_cache_config_info (u64 cache_level, u64 cache_type, pal_cache_config_info_t *conf)
 {
 	struct ia64_pal_retval iprv;
@@ -752,7 +752,7 @@
 }
 
 /* Get detailed cche protection information */
-extern inline s64
+static inline s64
 ia64_pal_cache_prot_info (u64 cache_level, u64 cache_type, pal_cache_protection_info_t *prot)
 {
 	struct ia64_pal_retval iprv;
@@ -775,7 +775,7 @@
  * Flush the processor instruction or data caches.  *PROGRESS must be
  * initialized to zero before calling this for the first time..
  */
-extern inline s64 
+static inline s64 
 ia64_pal_cache_flush (u64 cache_type, u64 invalidate, u64 *progress) 
 {	
 	struct ia64_pal_retval iprv;
@@ -786,7 +786,7 @@
 
 
 /* Initialize the processor controlled caches */
-extern inline s64 
+static inline s64 
 ia64_pal_cache_init (u64 level, u64 cache_type, u64 restrict) 
 {	
 	struct ia64_pal_retval iprv;
@@ -798,7 +798,7 @@
  * processor controlled cache to known values without the availability 
  * of backing memory.
  */
-extern inline s64 
+static inline s64 
 ia64_pal_cache_line_init (u64 physical_addr, u64 data_value) 
 {	
 	struct ia64_pal_retval iprv;
@@ -808,7 +808,7 @@
 
 
 /* Read the data and tag of a processor controlled cache line for diags */
-extern inline s64 
+static inline s64 
 ia64_pal_cache_read (pal_cache_line_id_u_t line_id, u64 physical_addr) 
 {	
 	struct ia64_pal_retval iprv;
@@ -817,7 +817,7 @@
 }
 
 /* Return summary information about the heirarchy of caches controlled by the processor */
-extern inline s64 
+static inline s64 
 ia64_pal_cache_summary (u64 *cache_levels, u64 *unique_caches) 
 {	
 	struct ia64_pal_retval iprv;
@@ -830,7 +830,7 @@
 }
 
 /* Write the data and tag of a processor-controlled cache line for diags */
-extern inline s64 
+static inline s64 
 ia64_pal_cache_write (pal_cache_line_id_u_t line_id, u64 physical_addr, u64 data) 
 {	
 	struct ia64_pal_retval iprv;	
@@ -840,7 +840,7 @@
 
 
 /* Return the parameters needed to copy relocatable PAL procedures from ROM to memory */
-extern inline s64 
+static inline s64 
 ia64_pal_copy_info (u64 copy_type, u64 num_procs, u64 num_iopics,
 		    u64 *buffer_size, u64 *buffer_align) 
 {	
@@ -854,7 +854,7 @@
 }
 
 /* Copy relocatable PAL procedures from ROM to memory */
-extern inline s64 
+static inline s64 
 ia64_pal_copy_pal (u64 target_addr, u64 alloc_size, u64 processor, u64 *pal_proc_offset) 
 {	
 	struct ia64_pal_retval iprv;
@@ -865,7 +865,7 @@
 }
 
 /* Return the number of instruction and data debug register pairs */
-extern inline s64 
+static inline s64 
 ia64_pal_debug_info (u64 *inst_regs,  u64 *data_regs) 
 {	
 	struct ia64_pal_retval iprv;
@@ -880,7 +880,7 @@
 
 #ifdef TBD
 /* Switch from IA64-system environment to IA-32 system environment */
-extern inline s64 
+static inline s64 
 ia64_pal_enter_ia32_env (ia32_env1, ia32_env2, ia32_env3) 
 {	
 	struct ia64_pal_retval iprv;
@@ -890,7 +890,7 @@
 #endif
 
 /* Get unique geographical address of this processor on its bus */
-extern inline s64 
+static inline s64 
 ia64_pal_fixed_addr (u64 *global_unique_addr) 
 {	
 	struct ia64_pal_retval iprv;
@@ -901,7 +901,7 @@
 }
 
 /* Get base frequency of the platform if generated by the processor */
-extern inline s64 
+static inline s64 
 ia64_pal_freq_base (u64 *platform_base_freq) 
 {	
 	struct ia64_pal_retval iprv;
@@ -915,7 +915,7 @@
  * Get the ratios for processor frequency, bus frequency and interval timer to
  * to base frequency of the platform 
  */
-extern inline s64 
+static inline s64 
 ia64_pal_freq_ratios (struct pal_freq_ratio *proc_ratio, struct pal_freq_ratio *bus_ratio,
 		      struct pal_freq_ratio *itc_ratio) 
 {	
@@ -934,7 +934,7 @@
  * power states where prefetching and execution are suspended and cache and
  * TLB coherency is not maintained.
  */
-extern inline s64 
+static inline s64 
 ia64_pal_halt (u64 halt_state) 
 {	
 	struct ia64_pal_retval iprv;
@@ -954,7 +954,7 @@
 } pal_power_mgmt_info_u_t;
 
 /* Return information about processor's optional power management capabilities. */
-extern inline s64 
+static inline s64 
 ia64_pal_halt_info (pal_power_mgmt_info_u_t *power_buf) 
 {	
 	struct ia64_pal_retval iprv;
@@ -965,7 +965,7 @@
 /* Cause the processor to enter LIGHT HALT state, where prefetching and execution are
  * suspended, but cache and TLB coherency is maintained.
  */
-extern inline s64 
+static inline s64 
 ia64_pal_halt_light (void) 
 {	
 	struct ia64_pal_retval iprv;
@@ -977,7 +977,7 @@
  * the error logging registers to be written. This procedure also checks the pending
  * machine check bit and pending INIT bit and reports their states.
  */
-extern inline s64 
+static inline s64 
 ia64_pal_mc_clear_log (u64 *pending_vector) 
 {	
 	struct ia64_pal_retval iprv;
@@ -990,7 +990,7 @@
 /* Ensure that all outstanding transactions in a processor are completed or that any 
  * MCA due to thes outstanding transaction is taken.
  */
-extern inline s64 
+static inline s64 
 ia64_pal_mc_drain (void) 
 {	
 	struct ia64_pal_retval iprv;
@@ -999,7 +999,7 @@
 }
 
 /* Return the machine check dynamic processor state */
-extern inline s64 
+static inline s64 
 ia64_pal_mc_dynamic_state (u64 offset, u64 *size, u64 *pds) 
 {	
 	struct ia64_pal_retval iprv;
@@ -1012,7 +1012,7 @@
 }
 
 /* Return processor machine check information */
-extern inline s64 
+static inline s64 
 ia64_pal_mc_error_info (u64 info_index, u64 type_index, u64 *size, u64 *error_info) 
 {	
 	struct ia64_pal_retval iprv;
@@ -1027,7 +1027,7 @@
 /* Inform PALE_CHECK whether a machine check is expected so that PALE_CHECK willnot
  * attempt to correct any expected machine checks.
  */
-extern inline s64 
+static inline s64 
 ia64_pal_mc_expected (u64 expected, u64 *previous) 
 {	
 	struct ia64_pal_retval iprv;
@@ -1041,7 +1041,7 @@
  * minimal processor state in the event of a machine check or initialization
  * event.
  */
-extern inline s64
+static inline s64
 ia64_pal_mc_register_mem (u64 physical_addr) 
 {	
 	struct ia64_pal_retval iprv;
@@ -1052,7 +1052,7 @@
 /* Restore minimal architectural processor state, set CMC interrupt if necessary
  * and resume execution
  */
-extern inline s64 
+static inline s64 
 ia64_pal_mc_resume (u64 set_cmci, u64 save_ptr) 
 {	
 	struct ia64_pal_retval iprv;
@@ -1061,7 +1061,7 @@
 }
 
 /* Return the memory attributes implemented by the processor */
-extern inline s64 
+static inline s64 
 ia64_pal_mem_attrib (u64 *mem_attrib) 
 {	
 	struct ia64_pal_retval iprv;
@@ -1074,7 +1074,7 @@
 /* Return the amount of memory needed for second phase of processor
  * self-test and the required alignment of memory.
  */
-extern inline s64 
+static inline s64 
 ia64_pal_mem_for_test (u64 *bytes_needed, u64 *alignment)
 {
 	struct ia64_pal_retval iprv;
@@ -1100,7 +1100,7 @@
 /* Return the performance monitor information about what can be counted
  * and how to configure the monitors to count the desired events.
  */
-extern inline s64 
+static inline s64 
 ia64_pal_perf_mon_info (u64 *pm_buffer, pal_perf_mon_info_u_t *pm_info) 
 {	
 	struct ia64_pal_retval iprv;
@@ -1113,7 +1113,7 @@
 /* Specifies the physical address of the processor interrupt block
  * and I/O port space.
  */
-extern inline s64 
+static inline s64 
 ia64_pal_platform_addr (u64 type, u64 physical_addr) 
 {	
 	struct ia64_pal_retval iprv;
@@ -1122,7 +1122,7 @@
 }
 
 /* Set the SAL PMI entrypoint in memory */
-extern inline s64 
+static inline s64 
 ia64_pal_pmi_entrypoint (u64 sal_pmi_entry_addr) 
 {	
 	struct ia64_pal_retval iprv;
@@ -1132,7 +1132,7 @@
 
 struct pal_features_s;
 /* Provide information about configurable processor features */
-extern inline s64 
+static inline s64 
 ia64_pal_proc_get_features (u64 *features_avail, 
 			    u64 *features_status, 
 			    u64 *features_control)
@@ -1148,7 +1148,7 @@
 }
 
 /* Enable/disable processor dependent features */
-extern inline s64 
+static inline s64 
 ia64_pal_proc_set_features (u64 feature_select) 
 {	
 	struct ia64_pal_retval iprv;
@@ -1169,7 +1169,7 @@
 /* Return the information required for the architected loop used to purge
  * (initialize) the entire TC
  */
-extern inline s64
+static inline s64
 ia64_get_ptce (ia64_ptce_info_t *ptce)
 {
 	struct ia64_pal_retval iprv;
@@ -1189,7 +1189,7 @@
 }
 
 /* Return info about implemented application and control registers. */
-extern inline s64 
+static inline s64 
 ia64_pal_register_info (u64 info_request, u64 *reg_info_1, u64 *reg_info_2) 
 {	
 	struct ia64_pal_retval iprv;
@@ -1213,7 +1213,7 @@
 /* Return information about the register stack and RSE for this processor 
  * implementation.
  */
-extern inline s64 
+static inline s64 
 ia64_pal_rse_info (u64 *num_phys_stacked, pal_hints_u_t *hints)
 {	
 	struct ia64_pal_retval iprv;
@@ -1229,7 +1229,7 @@
  * suspended, but cause cache and TLB coherency to be maintained.
  * This is usually called in IA-32 mode.
  */
-extern inline s64 
+static inline s64 
 ia64_pal_shutdown (void) 
 {	
 	struct ia64_pal_retval iprv;
@@ -1238,7 +1238,7 @@
 }
 
 /* Perform the second phase of processor self-test. */
-extern inline s64 
+static inline s64 
 ia64_pal_test_proc (u64 test_addr, u64 test_size, u64 attributes, u64 *self_test_state)
 {
 	struct ia64_pal_retval iprv;
@@ -1263,7 +1263,7 @@
 
 
 /* Return PAL version information */
-extern inline s64 
+static inline s64 
 ia64_pal_version (pal_version_u_t *pal_min_version, pal_version_u_t *pal_cur_version) 
 {	
 	struct ia64_pal_retval iprv;
@@ -1301,7 +1301,7 @@
 /* Return information about the virtual memory characteristics of the processor 
  * implementation.
  */
-extern inline s64 
+static inline s64 
 ia64_pal_vm_info (u64 tc_level, u64 tc_type,  pal_tc_info_u_t *tc_info, u64 *tc_pages)
 {
 	struct ia64_pal_retval iprv;
@@ -1316,7 +1316,7 @@
 /* Get page size information about the virtual memory characteristics of the processor 
  * implementation.
  */
-extern inline s64 
+static inline s64 
 ia64_pal_vm_page_size (u64 *tr_pages, u64 *vw_pages)
 {
 	struct ia64_pal_retval iprv;
@@ -1355,7 +1355,7 @@
 /* Get summary information about the virtual memory characteristics of the processor 
  * implementation.
  */
-extern inline s64 
+static inline s64 
 ia64_pal_vm_summary (pal_vm_info_1_u_t *vm_info_1, pal_vm_info_2_u_t *vm_info_2) 
 {	
 	struct ia64_pal_retval iprv;
@@ -1379,7 +1379,7 @@
 } pal_tr_valid_u_t;
 
 /* Read a translation register */
-extern inline s64 
+static inline s64 
 ia64_pal_tr_read (u64 reg_num, u64 tr_type, u64 *tr_buffer, pal_tr_valid_u_t *tr_valid)
 {
 	struct ia64_pal_retval iprv;
@@ -1389,7 +1389,7 @@
 	return iprv.status; 
 }
 
-extern inline s64
+static inline s64
 ia64_pal_prefetch_visibility (void)
 {
 	struct ia64_pal_retval iprv;
diff -urN linux-davidm/include/asm-ia64/param.h linux-2.4.0-test9-lia/include/asm-ia64/param.h
--- linux-davidm/include/asm-ia64/param.h	Thu Aug 24 08:17:47 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/param.h	Wed Oct  4 21:49:06 2000
@@ -15,7 +15,7 @@
  * Yeah, simulating stuff is slow, so let us catch some breath between
  * timer interrupts...
  */
-# define HZ 20
+# define HZ	  32
 #else
 # define HZ	1024
 #endif
diff -urN linux-davidm/include/asm-ia64/parport.h linux-2.4.0-test9-lia/include/asm-ia64/parport.h
--- linux-davidm/include/asm-ia64/parport.h	Wed Dec 31 16:00:00 1969
+++ linux-2.4.0-test9-lia/include/asm-ia64/parport.h	Wed Oct  4 21:49:17 2000
@@ -0,0 +1,20 @@
+/*
+ * parport.h: platform-specific PC-style parport initialisation
+ *
+ * Copyright (C) 1999, 2000  Tim Waugh <tim@cyberelk.demon.co.uk>
+ *
+ * This file should only be included by drivers/parport/parport_pc.c.
+ */
+
+#ifndef _ASM_IA64_PARPORT_H
+#define _ASM_IA64_PARPORT_H 1
+
+static int __devinit parport_pc_find_isa_ports (int autoirq, int autodma);
+
+static int __devinit
+parport_pc_find_nonpci_ports (int autoirq, int autodma)
+{
+	return parport_pc_find_isa_ports(autoirq, autodma);
+}
+
+#endif /* _ASM_IA64_PARPORT_H */
diff -urN linux-davidm/include/asm-ia64/pci.h linux-2.4.0-test9-lia/include/asm-ia64/pci.h
--- linux-davidm/include/asm-ia64/pci.h	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/pci.h	Wed Oct  4 21:49:25 2000
@@ -22,12 +22,12 @@
 
 struct pci_dev;
 
-extern inline void pcibios_set_master(struct pci_dev *dev)
+static inline void pcibios_set_master(struct pci_dev *dev)
 {
 	/* No special bus mastering setup handling */
 }
 
-extern inline void pcibios_penalize_isa_irq(int irq)
+static inline void pcibios_penalize_isa_irq(int irq)
 {
 	/* We don't do dynamic PCI IRQ allocation */
 }
@@ -128,7 +128,7 @@
  * only drive the low 24-bits during PCI bus mastering, then
  * you would pass 0x00ffffff as the mask to this function.
  */
-extern inline int
+static inline int
 pci_dma_supported(struct pci_dev *hwdev, dma_addr_t mask)
 {
 	return 1;
diff -urN linux-davidm/include/asm-ia64/pgalloc.h linux-2.4.0-test9-lia/include/asm-ia64/pgalloc.h
--- linux-davidm/include/asm-ia64/pgalloc.h	Fri Apr 21 15:21:24 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/pgalloc.h	Wed Oct  4 21:49:31 2000
@@ -32,7 +32,7 @@
 #define pte_quicklist		(my_cpu_data.pte_quick)
 #define pgtable_cache_size	(my_cpu_data.pgtable_cache_sz)
 
-extern __inline__ pgd_t*
+static __inline__ pgd_t*
 get_pgd_slow (void)
 {
 	pgd_t *ret = (pgd_t *)__get_free_page(GFP_KERNEL);
@@ -41,7 +41,7 @@
 	return ret;
 }
 
-extern __inline__ pgd_t*
+static __inline__ pgd_t*
 get_pgd_fast (void)
 {
 	unsigned long *ret = pgd_quicklist;
@@ -54,7 +54,7 @@
 	return (pgd_t *)ret;
 }
 
-extern __inline__ pgd_t*
+static __inline__ pgd_t*
 pgd_alloc (void)
 {
 	pgd_t *pgd;
@@ -65,7 +65,7 @@
 	return pgd;
 }
 
-extern __inline__ void
+static __inline__ void
 free_pgd_fast (pgd_t *pgd)
 {
 	*(unsigned long *)pgd = (unsigned long) pgd_quicklist;
@@ -73,7 +73,7 @@
 	++pgtable_cache_size;
 }
 
-extern __inline__ pmd_t *
+static __inline__ pmd_t *
 get_pmd_slow (void)
 {
 	pmd_t *pmd = (pmd_t *) __get_free_page(GFP_KERNEL);
@@ -83,7 +83,7 @@
 	return pmd;
 }
 
-extern __inline__ pmd_t *
+static __inline__ pmd_t *
 get_pmd_fast (void)
 {
 	unsigned long *ret = (unsigned long *)pmd_quicklist;
@@ -96,7 +96,7 @@
 	return (pmd_t *)ret;
 }
 
-extern __inline__ void
+static __inline__ void
 free_pmd_fast (pmd_t *pmd)
 {
 	*(unsigned long *)pmd = (unsigned long) pmd_quicklist;
@@ -104,7 +104,7 @@
 	++pgtable_cache_size;
 }
 
-extern __inline__ void
+static __inline__ void
 free_pmd_slow (pmd_t *pmd)
 {
 	free_page((unsigned long)pmd);
@@ -112,7 +112,7 @@
 
 extern pte_t *get_pte_slow (pmd_t *pmd, unsigned long address_preadjusted);
 
-extern __inline__ pte_t *
+static __inline__ pte_t *
 get_pte_fast (void)
 {
 	unsigned long *ret = (unsigned long *)pte_quicklist;
@@ -125,7 +125,7 @@
 	return (pte_t *)ret;
 }
 
-extern __inline__ void
+static __inline__ void
 free_pte_fast (pte_t *pte)
 {
 	*(unsigned long *)pte = (unsigned long) pte_quicklist;
@@ -142,7 +142,7 @@
 extern void __handle_bad_pgd (pgd_t *pgd);
 extern void __handle_bad_pmd (pmd_t *pmd);
 
-extern __inline__ pte_t*
+static __inline__ pte_t*
 pte_alloc (pmd_t *pmd, unsigned long vmaddr)
 {
 	unsigned long offset;
@@ -163,7 +163,7 @@
 	return (pte_t *) pmd_page(*pmd) + offset;
 }
 
-extern __inline__ pmd_t*
+static __inline__ pmd_t*
 pmd_alloc (pgd_t *pgd, unsigned long vmaddr)
 {
 	unsigned long offset;
@@ -228,7 +228,7 @@
 /*
  * Flush a specified user mapping
  */
-extern __inline__ void
+static __inline__ void
 flush_tlb_mm (struct mm_struct *mm)
 {
 	if (mm) {
diff -urN linux-davidm/include/asm-ia64/pgtable.h linux-2.4.0-test9-lia/include/asm-ia64/pgtable.h
--- linux-davidm/include/asm-ia64/pgtable.h	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/pgtable.h	Wed Oct  4 21:49:41 2000
@@ -318,7 +318,7 @@
 /*
  * Return the region index for virtual address ADDRESS.
  */
-extern __inline__ unsigned long
+static __inline__ unsigned long
 rgn_index (unsigned long address)
 {
 	ia64_va a;
@@ -330,7 +330,7 @@
 /*
  * Return the region offset for virtual address ADDRESS.
  */
-extern __inline__ unsigned long
+static __inline__ unsigned long
 rgn_offset (unsigned long address)
 {
 	ia64_va a;
@@ -342,7 +342,7 @@
 #define RGN_SIZE	(1UL << 61)
 #define RGN_KERNEL	7
 
-extern __inline__ unsigned long
+static __inline__ unsigned long
 pgd_index (unsigned long address)
 {
 	unsigned long region = address >> 61;
@@ -353,7 +353,7 @@
 
 /* The offset in the 1-level directory is given by the 3 region bits
    (61..63) and the seven level-1 bits (33-39).  */
-extern __inline__ pgd_t*
+static __inline__ pgd_t*
 pgd_offset (struct mm_struct *mm, unsigned long address)
 {
 	return mm->pgd + pgd_index(address);
diff -urN linux-davidm/include/asm-ia64/processor.h linux-2.4.0-test9-lia/include/asm-ia64/processor.h
--- linux-davidm/include/asm-ia64/processor.h	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/processor.h	Wed Oct  4 21:49:46 2000
@@ -454,31 +454,31 @@
 	ia64_fph_disable();
 }
 
-extern inline void
+static inline void
 ia64_fc (void *addr)
 {
 	__asm__ __volatile__ ("fc %0" :: "r"(addr) : "memory");
 }
 
-extern inline void
+static inline void
 ia64_sync_i (void)
 {
 	__asm__ __volatile__ (";; sync.i" ::: "memory");
 }
 
-extern inline void
+static inline void
 ia64_srlz_i (void)
 {
 	__asm__ __volatile__ (";; srlz.i ;;" ::: "memory");
 }
 
-extern inline void
+static inline void
 ia64_srlz_d (void)
 {
 	__asm__ __volatile__ (";; srlz.d" ::: "memory");
 }
 
-extern inline __u64
+static inline __u64
 ia64_get_rr (__u64 reg_bits)
 {
 	__u64 r;
@@ -486,13 +486,13 @@
 	return r;
 }
 
-extern inline void
+static inline void
 ia64_set_rr (__u64 reg_bits, __u64 rr_val)
 {
 	__asm__ __volatile__ ("mov rr[%0]=%1" :: "r"(reg_bits), "r"(rr_val) : "memory");
 }
 
-extern inline __u64
+static inline __u64
 ia64_get_dcr (void)
 {
 	__u64 r;
@@ -500,14 +500,14 @@
 	return r;
 }
 
-extern inline void
+static inline void
 ia64_set_dcr (__u64 val)
 {
 	__asm__ __volatile__ ("mov cr.dcr=%0;;" :: "r"(val) : "memory");
 	ia64_srlz_d();
 }
 
-extern inline __u64
+static inline __u64
 ia64_get_lid (void)
 {
 	__u64 r;
@@ -515,7 +515,7 @@
 	return r;
 }
 
-extern inline void
+static inline void
 ia64_invala (void)
 {
 	__asm__ __volatile__ ("invala" ::: "memory");
@@ -533,7 +533,7 @@
  * Insert a translation into an instruction and/or data translation
  * register.
  */
-extern inline void
+static inline void
 ia64_itr (__u64 target_mask, __u64 tr_num,
 	  __u64 vmaddr, __u64 pte,
 	  __u64 log_page_size)
@@ -552,7 +552,7 @@
  * Insert a translation into the instruction and/or data translation
  * cache.
  */
-extern inline void
+static inline void
 ia64_itc (__u64 target_mask, __u64 vmaddr, __u64 pte,
 	  __u64 log_page_size)
 {
@@ -569,7 +569,7 @@
  * Purge a range of addresses from instruction and/or data translation
  * register(s).
  */
-extern inline void
+static inline void
 ia64_ptr (__u64 target_mask, __u64 vmaddr, __u64 log_size)
 {
 	if (target_mask & 0x1)
@@ -579,21 +579,21 @@
 }
 
 /* Set the interrupt vector address.  The address must be suitably aligned (32KB).  */
-extern inline void
+static inline void
 ia64_set_iva (void *ivt_addr)
 {
 	__asm__ __volatile__ ("mov cr.iva=%0;; srlz.i;;" :: "r"(ivt_addr) : "memory");
 }
 
 /* Set the page table address and control bits.  */
-extern inline void
+static inline void
 ia64_set_pta (__u64 pta)
 {
 	/* Note: srlz.i implies srlz.d */
 	__asm__ __volatile__ ("mov cr.pta=%0;; srlz.i;;" :: "r"(pta) : "memory");
 }
 
-extern inline __u64
+static inline __u64
 ia64_get_cpuid (__u64 regnum)
 {
 	__u64 r;
@@ -602,13 +602,13 @@
 	return r;
 }
 
-extern inline void
+static inline void
 ia64_eoi (void)
 {
 	__asm__ ("mov cr.eoi=r0;; srlz.d;;" ::: "memory");
 }
 
-extern __inline__ void
+static inline void
 ia64_set_lrr0 (__u8 vector, __u8 masked)
 {
 	if (masked > 1)
@@ -619,7 +619,7 @@
 }
 
 
-extern __inline__ void
+static inline void
 ia64_set_lrr1 (__u8 vector, __u8 masked)
 {
 	if (masked > 1)
@@ -629,13 +629,13 @@
 			      :: "r"((masked << 16) | vector) : "memory");
 }
 
-extern __inline__ void
+static inline void
 ia64_set_pmv (__u64 val)
 {
 	__asm__ __volatile__ ("mov cr.pmv=%0" :: "r"(val) : "memory");
 }
 
-extern __inline__ __u64
+static inline __u64
 ia64_get_pmc (__u64 regnum)
 {
 	__u64 retval;
@@ -644,13 +644,13 @@
 	return retval;
 }
 
-extern __inline__ void
+static inline void
 ia64_set_pmc (__u64 regnum, __u64 value)
 {
 	__asm__ __volatile__ ("mov pmc[%0]=%1" :: "r"(regnum), "r"(value));
 }
 
-extern __inline__ __u64
+static inline __u64
 ia64_get_pmd (__u64 regnum)
 {
 	__u64 retval;
@@ -659,7 +659,7 @@
 	return retval;
 }
 
-extern __inline__ void
+static inline void
 ia64_set_pmd (__u64 regnum, __u64 value)
 {
 	__asm__ __volatile__ ("mov pmd[%0]=%1" :: "r"(regnum), "r"(value));
@@ -669,7 +669,7 @@
  * Given the address to which a spill occurred, return the unat bit
  * number that corresponds to this address.
  */
-extern inline __u64
+static inline __u64
 ia64_unat_pos (void *spill_addr)
 {
 	return ((__u64) spill_addr >> 3) & 0x3f;
@@ -679,7 +679,7 @@
  * Set the NaT bit of an integer register which was spilled at address
  * SPILL_ADDR.  UNAT is the mask to be updated.
  */
-extern inline void
+static inline void
 ia64_set_unat (__u64 *unat, void *spill_addr, unsigned long nat)
 {
 	__u64 bit = ia64_unat_pos(spill_addr);
@@ -692,7 +692,7 @@
  * Return saved PC of a blocked thread.
  * Note that the only way T can block is through a call to schedule() -> switch_to().
  */
-extern inline unsigned long
+static inline unsigned long
 thread_saved_pc (struct thread_struct *t)
 {
 	struct unw_frame_info info;
@@ -727,7 +727,7 @@
 /*
  * Set the correctable machine check vector register
  */
-extern __inline__ void
+static inline void
 ia64_set_cmcv (__u64 val)
 {
 	__asm__ __volatile__ ("mov cr.cmcv=%0" :: "r"(val) : "memory");
@@ -736,7 +736,7 @@
 /*
  * Read the correctable machine check vector register
  */
-extern __inline__ __u64
+static inline __u64
 ia64_get_cmcv (void)
 {
 	__u64 val;
@@ -745,7 +745,7 @@
 	return val;
 }
 
-extern inline __u64
+static inline __u64
 ia64_get_ivr (void)
 {
 	__u64 r;
@@ -753,13 +753,13 @@
 	return r;
 }
 
-extern inline void
+static inline void
 ia64_set_tpr (__u64 val)
 {
 	__asm__ __volatile__ ("mov cr.tpr=%0" :: "r"(val));
 }
 
-extern inline __u64
+static inline __u64
 ia64_get_tpr (void)
 {
 	__u64 r;
@@ -767,71 +767,75 @@
 	return r;
 }
 
-extern __inline__ void
+static inline void
 ia64_set_irr0 (__u64 val)
 {
 	__asm__ __volatile__("mov cr.irr0=%0;;" :: "r"(val) : "memory");
 	ia64_srlz_d();
 }
 
-extern __inline__ __u64
+static inline __u64
 ia64_get_irr0 (void)
 {
 	__u64 val;
 
-	__asm__ ("mov %0=cr.irr0" : "=r"(val));
+	/* this is volatile because irr may change unbeknownst to gcc... */
+	__asm__ __volatile__("mov %0=cr.irr0" : "=r"(val));
 	return val;
 }
 
-extern __inline__ void
+static inline void
 ia64_set_irr1 (__u64 val)
 {
 	__asm__ __volatile__("mov cr.irr1=%0;;" :: "r"(val) : "memory");
 	ia64_srlz_d();
 }
 
-extern __inline__ __u64
+static inline __u64
 ia64_get_irr1 (void)
 {
 	__u64 val;
 
-	__asm__ ("mov %0=cr.irr1" : "=r"(val));
+	/* this is volatile because irr may change unbeknownst to gcc... */
+	__asm__ __volatile__("mov %0=cr.irr1" : "=r"(val));
 	return val;
 }
 
-extern __inline__ void
+static inline void
 ia64_set_irr2 (__u64 val)
 {
 	__asm__ __volatile__("mov cr.irr2=%0;;" :: "r"(val) : "memory");
 	ia64_srlz_d();
 }
 
-extern __inline__ __u64
+static inline __u64
 ia64_get_irr2 (void)
 {
 	__u64 val;
 
-	__asm__ ("mov %0=cr.irr2" : "=r"(val));
+	/* this is volatile because irr may change unbeknownst to gcc... */
+	__asm__ __volatile__("mov %0=cr.irr2" : "=r"(val));
 	return val;
 }
 
-extern __inline__ void
+static inline void
 ia64_set_irr3 (__u64 val)
 {
 	__asm__ __volatile__("mov cr.irr3=%0;;" :: "r"(val) : "memory");
 	ia64_srlz_d();
 }
 
-extern __inline__ __u64
+static inline __u64
 ia64_get_irr3 (void)
 {
 	__u64 val;
 
-	__asm__ ("mov %0=cr.irr3" : "=r"(val));
+	/* this is volatile because irr may change unbeknownst to gcc... */
+	__asm__ __volatile__("mov %0=cr.irr3" : "=r"(val));
 	return val;
 }
 
-extern __inline__ __u64
+static inline __u64
 ia64_get_gp(void)
 {
 	__u64 val;
@@ -859,7 +863,7 @@
 
 #define ia64_rotl(w,n)	ia64_rotr((w),(64)-(n))
 
-extern __inline__ __u64
+static inline __u64
 ia64_thash (__u64 addr)
 {
 	__u64 result;
diff -urN linux-davidm/include/asm-ia64/ptrace_offsets.h linux-2.4.0-test9-lia/include/asm-ia64/ptrace_offsets.h
--- linux-davidm/include/asm-ia64/ptrace_offsets.h	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/ptrace_offsets.h	Wed Oct  4 23:05:46 2000
@@ -17,6 +17,8 @@
  *		unsigned long dbr[8];
  *		unsigned long rsvd2[504];
  *		unsigned long ibr[8];
+ *		unsigned long rsvd3[504];
+ *		unsigned long pmd[4];
  *	}
  */
 
@@ -210,5 +212,6 @@
 
 #define PT_DBR			0x2000	/* data breakpoint registers */
 #define PT_IBR			0x3000	/* instruction breakpoint registers */
+#define PT_PMD			0x4000	/* performance monitoring counters */
 
 #endif /* _ASM_IA64_PTRACE_OFFSETS_H */
diff -urN linux-davidm/include/asm-ia64/sal.h linux-2.4.0-test9-lia/include/asm-ia64/sal.h
--- linux-davidm/include/asm-ia64/sal.h	Thu Jun 22 07:09:45 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/sal.h	Wed Oct  4 21:50:21 2000
@@ -17,6 +17,7 @@
  */
 
 #include <linux/config.h>
+#include <linux/spinlock.h>
 
 #include <asm/pal.h>
 #include <asm/system.h>
@@ -158,12 +159,22 @@
 	char reserved2[8];
 };
 
-struct ia64_sal_desc_ptc {
+typedef struct ia64_sal_desc_ptc {
 	char type;
 	char reserved1[3];
 	unsigned int num_domains;	/* # of coherence domains */
-	long domain_info;	/* physical address of domain info table */
-};
+	s64  domain_info;		/* physical address of domain info table */
+} ia64_sal_desc_ptc_t;
+
+typedef struct ia64_sal_ptc_domain_info {
+	unsigned long proc_count;	/* number of processors in domain */
+	long proc_list;			/* physical address of LID array */
+} ia64_sal_ptc_domain_info_t;
+
+typedef struct ia64_sal_ptc_domain_proc_entry {
+	unsigned char id;		/* id of processor */
+	unsigned char eid;		/* eid of processor */
+} ia64_sal_ptc_domain_proc_entry_t;
 
 #define IA64_SAL_AP_EXTERNAL_INT 0
 
@@ -175,6 +186,7 @@
 };
 
 extern ia64_sal_handler ia64_sal;
+extern struct ia64_sal_desc_ptc *ia64_ptc_domain_info;
 
 extern const char *ia64_sal_strerror (long status);
 extern void ia64_sal_init (struct ia64_sal_systab *sal_systab);
@@ -387,7 +399,7 @@
  * Now define a couple of inline functions for improved type checking
  * and convenience.
  */
-extern inline long
+static inline long
 ia64_sal_freq_base (unsigned long which, unsigned long *ticks_per_second,
 		    unsigned long *drift_info)
 {
@@ -400,7 +412,7 @@
 }
 
 /* Flush all the processor and platform level instruction and/or data caches */
-extern inline s64
+static inline s64
 ia64_sal_cache_flush (u64 cache_type)
 {
 	struct ia64_sal_retval isrv;
@@ -411,7 +423,7 @@
 
 	
 /* Initialize all the processor and platform level instruction and data caches */
-extern inline s64
+static inline s64
 ia64_sal_cache_init (void)
 {
 	struct ia64_sal_retval isrv;
@@ -422,7 +434,7 @@
 /* Clear the processor and platform information logged by SAL with respect to the 
  * machine state at the time of MCA's, INITs or CMCs 
  */
-extern inline s64
+static inline s64
 ia64_sal_clear_state_info (u64 sal_info_type, u64 sal_info_sub_type)
 {
 	struct ia64_sal_retval isrv;
@@ -434,7 +446,7 @@
 /* Get the processor and platform information logged by SAL with respect to the machine
  * state at the time of the MCAs, INITs or CMCs.
  */
-extern inline u64
+static inline u64
 ia64_sal_get_state_info (u64 sal_info_type, u64 sal_info_sub_type, u64 *sal_info)
 {
 	struct ia64_sal_retval isrv;
@@ -446,7 +458,7 @@
 /* Get the maximum size of the information logged by SAL with respect to the machine 
  * state at the time of MCAs, INITs or CMCs
  */
-extern inline u64
+static inline u64
 ia64_sal_get_state_info_size (u64 sal_info_type, u64 sal_info_sub_type)
 {
 	struct ia64_sal_retval isrv;
@@ -459,7 +471,7 @@
 /* Causes the processor to go into a spin loop within SAL where SAL awaits a wakeup
  * from the monarch processor.
  */
-extern inline s64
+static inline s64
 ia64_sal_mc_rendez (void)
 {
 	struct ia64_sal_retval isrv;
@@ -471,7 +483,7 @@
  * the machine check rendezvous sequence as well as the mechanism to wake up the 
  * non-monarch processor at the end of machine check processing.
  */
-extern inline s64
+static inline s64
 ia64_sal_mc_set_params (u64 param_type, u64 i_or_m, u64 i_or_m_val, u64 timeout)
 {
 	struct ia64_sal_retval isrv;
@@ -480,7 +492,7 @@
 }
 
 /* Read from PCI configuration space */
-extern inline s64
+static inline s64
 ia64_sal_pci_config_read (u64 pci_config_addr, u64 size, u64 *value)
 {
 	struct ia64_sal_retval isrv;
@@ -503,7 +515,7 @@
 }
 
 /* Write to PCI configuration space */
-extern inline s64
+static inline s64
 ia64_sal_pci_config_write (u64 pci_config_addr, u64 size, u64 value)
 {
 	struct ia64_sal_retval isrv;
@@ -527,7 +539,7 @@
  * Register physical addresses of locations needed by SAL when SAL
  * procedures are invoked in virtual mode.
  */
-extern inline s64
+static inline s64
 ia64_sal_register_physical_addr (u64 phys_entry, u64 phys_addr)
 {
 	struct ia64_sal_retval isrv;
@@ -539,7 +551,7 @@
  * or entry points where SAL will pass control for the specified event. These event
  * handlers are for the bott rendezvous, MCAs and INIT scenarios.
  */
-extern inline s64
+static inline s64
 ia64_sal_set_vectors (u64 vector_type,
 		      u64 handler_addr1, u64 gp1, u64 handler_len1,
 		      u64 handler_addr2, u64 gp2, u64 handler_len2)
@@ -552,7 +564,7 @@
 	return isrv.status;
 }		
 /* Update the contents of PAL block in the non-volatile storage device */
-extern inline s64
+static inline s64
 ia64_sal_update_pal (u64 param_buf, u64 scratch_buf, u64 scratch_buf_size,
 		     u64 *error_code, u64 *scratch_buf_size_needed)
 {
diff -urN linux-davidm/include/asm-ia64/semaphore.h linux-2.4.0-test9-lia/include/asm-ia64/semaphore.h
--- linux-davidm/include/asm-ia64/semaphore.h	Fri Apr 21 15:21:24 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/semaphore.h	Wed Oct  4 21:50:28 2000
@@ -39,7 +39,7 @@
 #define DECLARE_MUTEX(name)		__DECLARE_SEMAPHORE_GENERIC(name, 1)
 #define DECLARE_MUTEX_LOCKED(name)	__DECLARE_SEMAPHORE_GENERIC(name, 0)
 
-extern inline void
+static inline void
 sema_init (struct semaphore *sem, int val)
 {
 	*sem = (struct semaphore) __SEMAPHORE_INITIALIZER(*sem, val);
@@ -68,7 +68,7 @@
  * Atomically decrement the semaphore's count.  If it goes negative,
  * block the calling thread in the TASK_UNINTERRUPTIBLE state.
  */
-extern inline void
+static inline void
 down (struct semaphore *sem)
 {
 #if WAITQUEUE_DEBUG
@@ -82,7 +82,7 @@
  * Atomically decrement the semaphore's count.  If it goes negative,
  * block the calling thread in the TASK_INTERRUPTIBLE state.
  */
-extern inline int
+static inline int
 down_interruptible (struct semaphore * sem)
 {
 	int ret = 0;
@@ -95,7 +95,7 @@
 	return ret;
 }
 
-extern inline int
+static inline int
 down_trylock (struct semaphore *sem)
 {
 	int ret = 0;
@@ -108,7 +108,7 @@
 	return ret;
 }
 
-extern inline void
+static inline void
 up (struct semaphore * sem)
 {
 #if WAITQUEUE_DEBUG
@@ -181,7 +181,7 @@
 extern void __down_write_failed (struct rw_semaphore *sem, long count);
 extern void __rwsem_wake (struct rw_semaphore *sem, long count);
 
-extern inline void
+static inline void
 init_rwsem (struct rw_semaphore *sem)
 {
 	sem->count = RW_LOCK_BIAS;
@@ -196,7 +196,7 @@
 #endif
 }
 
-extern inline void
+static inline void
 down_read (struct rw_semaphore *sem)
 {
 	long count;
@@ -218,7 +218,7 @@
 #endif
 }
 
-extern inline void
+static inline void
 down_write (struct rw_semaphore *sem)
 {
 	long old_count, new_count;
@@ -252,7 +252,7 @@
  * case is when there was a writer waiting, and we've
  * bumped the count to 0: we must wake the writer up.
  */
-extern inline void
+static inline void
 __up_read (struct rw_semaphore *sem)
 {
 	long count;
@@ -271,7 +271,7 @@
  * Releasing the writer is easy -- just release it and
  * wake up any sleepers.
  */
-extern inline void
+static inline void
 __up_write (struct rw_semaphore *sem)
 {
 	long old_count, new_count;
@@ -290,7 +290,7 @@
 		__rwsem_wake(sem, new_count);
 }
 
-extern inline void
+static inline void
 up_read (struct rw_semaphore *sem)
 {
 #if WAITQUEUE_DEBUG
@@ -303,7 +303,7 @@
 	__up_read(sem);
 }
 
-extern inline void
+static inline void
 up_write (struct rw_semaphore *sem)
 {
 #if WAITQUEUE_DEBUG
diff -urN linux-davidm/include/asm-ia64/siginfo.h linux-2.4.0-test9-lia/include/asm-ia64/siginfo.h
--- linux-davidm/include/asm-ia64/siginfo.h	Thu Aug 24 08:17:47 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/siginfo.h	Wed Oct  4 21:50:51 2000
@@ -235,7 +235,8 @@
 #ifdef __KERNEL__
 #include <linux/string.h>
 
-extern inline void copy_siginfo(siginfo_t *to, siginfo_t *from)
+static inline void
+copy_siginfo (siginfo_t *to, siginfo_t *from)
 {
 	if (from->si_code < 0)
 		memcpy(to, from, sizeof(siginfo_t));
diff -urN linux-davidm/include/asm-ia64/smp.h linux-2.4.0-test9-lia/include/asm-ia64/smp.h
--- linux-davidm/include/asm-ia64/smp.h	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/smp.h	Wed Oct  4 21:51:16 2000
@@ -49,7 +49,7 @@
  * Function to map hard smp processor id to logical id.  Slow, so
  * don't use this in performance-critical code.
  */
-extern __inline__ int
+static inline int
 cpu_logical_id (int cpuid)
 {
 	int i;
@@ -68,28 +68,28 @@
  *    max_xtp   :  never deliver interrupts to this CPU.
  */
 
-extern __inline__ void 
+static inline void 
 min_xtp(void)
 {
 	if (smp_int_redirect & SMP_IRQ_REDIRECTION)
 		writeb(0x00, ipi_base_addr | XTP_OFFSET); /* XTP to min */
 }
 
-extern __inline__ void
+static inline void
 normal_xtp(void)
 {
 	if (smp_int_redirect & SMP_IRQ_REDIRECTION)
 		writeb(0x08, ipi_base_addr | XTP_OFFSET); /* XTP normal */
 }
 
-extern __inline__ void
+static inline void
 max_xtp(void) 
 {
 	if (smp_int_redirect & SMP_IRQ_REDIRECTION)
 		writeb(0x0f, ipi_base_addr | XTP_OFFSET); /* Set XTP to max */
 }
 
-extern __inline__ unsigned int 
+static inline unsigned int 
 hard_smp_processor_id(void)
 {
 	struct {
diff -urN linux-davidm/include/asm-ia64/spinlock.h linux-2.4.0-test9-lia/include/asm-ia64/spinlock.h
--- linux-davidm/include/asm-ia64/spinlock.h	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/spinlock.h	Wed Oct  4 21:51:32 2000
@@ -63,8 +63,8 @@
 })
 
 #define spin_is_locked(x)	((x)->lock != 0)
-#define spin_unlock(x)		({((spinlock_t *) x)->lock = 0;})
-#define spin_unlock_wait(x)	({ while ((x)->lock); })
+#define spin_unlock(x)		do {((spinlock_t *) x)->lock = 0;} while (0)
+#define spin_unlock_wait(x)	do {} while ((x)->lock)
 
 #else /* !NEW_LOCK */
 
@@ -97,9 +97,9 @@
 	:: "r"(&(x)->lock) : "r2", "r29", "memory")
 
 #define spin_is_locked(x)	((x)->lock != 0)
-#define spin_unlock(x)		({((spinlock_t *) x)->lock = 0; barrier();})
+#define spin_unlock(x)		do {((spinlock_t *) x)->lock = 0; barrier(); } while (0)
 #define spin_trylock(x)		(cmpxchg_acq(&(x)->lock, 0, 1) = 0)
-#define spin_unlock_wait(x)	({ do { barrier(); } while ((x)->lock); })
+#define spin_unlock_wait(x)	do { barrier(); } while ((x)->lock)
 
 #endif /* !NEW_LOCK */
 
@@ -146,16 +146,16 @@
 		"movl r29 = 0x80000000\n"					\
 		";;\n"								\
 		"1:\n"								\
-		"ld4 r2 = %0\n"							\
+		"ld4 r2 = [%0]\n"						\
 		";;\n"								\
 		"cmp4.eq p0,p7 = r0,r2\n"					\
 		"(p7) br.cond.spnt.few 1b \n"					\
-		IA64_SEMFIX"cmpxchg4.acq r2 = %0, r29, ar.ccv\n"		\
+		IA64_SEMFIX"cmpxchg4.acq r2 = [%0], r29, ar.ccv\n"		\
 		";;\n"								\
 		"cmp4.eq p0,p7 = r0, r2\n"					\
 		"(p7) br.cond.spnt.few 1b\n"					\
 		";;\n"								\
-		:: "m" __atomic_fool_gcc((rw)) : "r2", "r29", "memory");	\
+		:: "r"(rw) : "r2", "r29", "memory");				\
 } while(0)
 
 /*
diff -urN linux-davidm/include/asm-ia64/system.h linux-2.4.0-test9-lia/include/asm-ia64/system.h
--- linux-davidm/include/asm-ia64/system.h	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/system.h	Thu Oct  5 00:20:25 2000
@@ -38,6 +38,7 @@
 
 #ifndef __ASSEMBLY__
 
+#include <linux/kernel.h>
 #include <linux/types.h>
 
 struct pci_vector_struct {
@@ -67,7 +68,7 @@
 	__u64 initrd_size;
 } ia64_boot_param;
 
-extern inline void
+static inline void
 ia64_insn_group_barrier (void)
 {
 	__asm__ __volatile__ (";;" ::: "memory");
@@ -98,6 +99,16 @@
 #define mb()	__asm__ __volatile__ ("mf" ::: "memory")
 #define rmb()	mb()
 #define wmb()	mb()
+
+#ifdef CONFIG_SMP
+# define smp_mb()	mb()
+# define smp_rmb()	rmb()
+# define smp_wmb()	wmb()
+#else
+# define smp_mb()	barrier()
+# define smp_rmb()	barrier()
+# define smp_wmb()	barrier()
+#endif
 
 /*
  * XXX check on these---I suspect what Linus really wants here is
diff -urN linux-davidm/include/asm-ia64/uaccess.h linux-2.4.0-test9-lia/include/asm-ia64/uaccess.h
--- linux-davidm/include/asm-ia64/uaccess.h	Wed Oct  4 23:20:21 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/uaccess.h	Wed Oct  4 21:51:49 2000
@@ -61,7 +61,7 @@
 #define __access_ok(addr,size,segment)	(((unsigned long) (addr)) <= (segment).seg)
 #define access_ok(type,addr,size)	__access_ok((addr),(size),get_fs())
 
-extern inline int
+static inline int
 verify_area (int type, const void *addr, unsigned long size)
 {
 	return access_ok(type,addr,size) ? 0 : -EFAULT;
diff -urN linux-davidm/include/asm-ia64/unaligned.h linux-2.4.0-test9-lia/include/asm-ia64/unaligned.h
--- linux-davidm/include/asm-ia64/unaligned.h	Sun Feb  6 18:42:40 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/unaligned.h	Wed Oct  4 21:52:08 2000
@@ -22,42 +22,42 @@
 struct __una_u32 { __u32 x __attribute__((packed)); };
 struct __una_u16 { __u16 x __attribute__((packed)); };
 
-extern inline unsigned long
+static inline unsigned long
 __uldq (const unsigned long * r11)
 {
 	const struct __una_u64 *ptr = (const struct __una_u64 *) r11;
 	return ptr->x;
 }
 
-extern inline unsigned long
+static inline unsigned long
 __uldl (const unsigned int * r11)
 {
 	const struct __una_u32 *ptr = (const struct __una_u32 *) r11;
 	return ptr->x;
 }
 
-extern inline unsigned long
+static inline unsigned long
 __uldw (const unsigned short * r11)
 {
 	const struct __una_u16 *ptr = (const struct __una_u16 *) r11;
 	return ptr->x;
 }
 
-extern inline void
+static inline void
 __ustq (unsigned long r5, unsigned long * r11)
 {
 	struct __una_u64 *ptr = (struct __una_u64 *) r11;
 	ptr->x = r5;
 }
 
-extern inline void
+static inline void
 __ustl (unsigned long r5, unsigned int * r11)
 {
 	struct __una_u32 *ptr = (struct __una_u32 *) r11;
 	ptr->x = r5;
 }
 
-extern inline void
+static inline void
 __ustw (unsigned long r5, unsigned short * r11)
 {
 	struct __una_u16 *ptr = (struct __una_u16 *) r11;
diff -urN linux-davidm/include/asm-ia64/unistd.h linux-2.4.0-test9-lia/include/asm-ia64/unistd.h
--- linux-davidm/include/asm-ia64/unistd.h	Wed Sep 13 18:25:40 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/unistd.h	Wed Oct  4 21:52:16 2000
@@ -93,7 +93,7 @@
 #define __NR_setpriority		1102
 #define __NR_statfs			1103
 #define __NR_fstatfs			1104
-#define __NR_ioperm			1105
+/* unused; used to be __NR_ioperm */
 #define __NR_semget			1106
 #define __NR_semop			1107
 #define __NR_semctl			1108
diff -urN linux-davidm/include/asm-ia64/unwind.h linux-2.4.0-test9-lia/include/asm-ia64/unwind.h
--- linux-davidm/include/asm-ia64/unwind.h	Thu Jun 22 07:09:45 2000
+++ linux-2.4.0-test9-lia/include/asm-ia64/unwind.h	Wed Oct  4 21:52:27 2000
@@ -52,36 +52,38 @@
 	unsigned int flags;
 	short hint;
 	short prev_script;
-	unsigned long bsp;
-	unsigned long sp;		/* stack pointer */
-	unsigned long psp;		/* previous sp */
-	unsigned long ip;		/* instruction pointer */
-	unsigned long pr_val;		/* current predicates */
-	unsigned long *cfm;
+
+	/* current frame info: */
+	unsigned long bsp;		/* backing store pointer value */
+	unsigned long sp;		/* stack pointer value */
+	unsigned long psp;		/* previous sp value */
+	unsigned long ip;		/* instruction pointer value */
+	unsigned long pr;		/* current predicate values */
+	unsigned long *cfm_loc;		/* cfm save location (or NULL) */
 
 	struct task_struct *task;
 	struct switch_stack *sw;
 
 	/* preserved state: */
-	unsigned long *pbsp;		/* previous bsp */
-	unsigned long *bspstore;
-	unsigned long *pfs;
-	unsigned long *rnat;
-	unsigned long *rp;
-	unsigned long *pri_unat;
-	unsigned long *unat;
-	unsigned long *pr;
-	unsigned long *lc;
-	unsigned long *fpsr;
+	unsigned long *bsp_loc;		/* previous bsp save location */
+	unsigned long *bspstore_loc;
+	unsigned long *pfs_loc;
+	unsigned long *rnat_loc;
+	unsigned long *rp_loc;
+	unsigned long *pri_unat_loc;
+	unsigned long *unat_loc;
+	unsigned long *pr_loc;
+	unsigned long *lc_loc;
+	unsigned long *fpsr_loc;
 	struct unw_ireg {
 		unsigned long *loc;
 		struct unw_ireg_nat {
-			int type : 3;		/* enum unw_nat_type */
-			signed int off;		/* NaT word is at loc+nat.off */
+			long type : 3;			/* enum unw_nat_type */
+			signed long off : 61;		/* NaT word is at loc+nat.off */
 		} nat;
 	} r4, r5, r6, r7;
-	unsigned long *b1, *b2, *b3, *b4, *b5;
-	struct ia64_fpreg *f2, *f3, *f4, *f5, *fr[16];
+	unsigned long *b1_loc, *b2_loc, *b3_loc, *b4_loc, *b5_loc;
+	struct ia64_fpreg *f2_loc, *f3_loc, *f4_loc, *f5_loc, *fr_loc[16];
 };
 
 /*
@@ -140,19 +142,56 @@
  */
 extern int unw_unwind_to_user (struct unw_frame_info *info);
 
-#define unw_get_ip(info,vp)	({*(vp) = (info)->ip; 0;})
-#define unw_get_sp(info,vp)	({*(vp) = (unsigned long) (info)->sp; 0;})
-#define unw_get_psp(info,vp)	({*(vp) = (unsigned long) (info)->psp; 0;})
-#define unw_get_bsp(info,vp)	({*(vp) = (unsigned long) (info)->bsp; 0;})
-#define unw_get_cfm(info,vp)	({*(vp) = *(info)->cfm; 0;})
-#define unw_set_cfm(info,val)	({*(info)->cfm = (val); 0;})
+#define unw_is_intr_frame(info)	(((info)->flags & UNW_FLAG_INTERRUPT_FRAME) != 0)
+
+static inline unsigned long
+unw_get_ip (struct unw_frame_info *info, unsigned long *valp)
+{
+	*valp = (info)->ip;
+	return 0;
+}
+
+static inline unsigned long
+unw_get_sp (struct unw_frame_info *info, unsigned long *valp)
+{
+	*valp = (info)->sp;
+	return 0;
+}
+
+static inline unsigned long
+unw_get_psp (struct unw_frame_info *info, unsigned long *valp)
+{
+	*valp = (info)->psp;
+	return 0;
+}
+
+static inline unsigned long
+unw_get_bsp (struct unw_frame_info *info, unsigned long *valp)
+{
+	*valp = (info)->bsp;
+	return 0;
+}
+
+static inline unsigned long
+unw_get_cfm (struct unw_frame_info *info, unsigned long *valp)
+{
+	*valp = *(info)->cfm_loc;
+	return 0;
+}
+
+static inline unsigned long
+unw_set_cfm (struct unw_frame_info *info, unsigned long val)
+{
+	*(info)->cfm_loc = val;
+	return 0;
+}
 
 static inline int
 unw_get_rp (struct unw_frame_info *info, unsigned long *val)
 {
-	if (!info->rp)
+	if (!info->rp_loc)
 		return -1;
-	*val = *info->rp;
+	*val = *info->rp_loc;
 	return 0;
 }
 
diff -urN linux-davidm/kernel/Makefile linux-2.4.0-test9-lia/kernel/Makefile
--- linux-davidm/kernel/Makefile	Thu Aug 10 19:56:32 2000
+++ linux-2.4.0-test9-lia/kernel/Makefile	Wed Oct  4 21:53:44 2000
@@ -30,6 +30,13 @@
 OX_OBJS += pm.o
 endif
 
+ifneq ($(CONFIG_IA64),y)
+# According to Alan Modra <alan@linuxcare.com.au>, the -fno-omit-frame-pointer is
+# needed for x86 only.  Why this used to be enabled for all architectures is beyond
+# me.  I suspect most platforms don't need this, but until we know that for sure
+# I turn this off for IA-64 only.  Andreas Schwab says it's also needed on m68k
+# to get a correct value for the wait-channel (WCHAN in ps). --davidm
 CFLAGS_sched.o := $(PROFILING) -fno-omit-frame-pointer
+endif
 
 include $(TOPDIR)/Rules.make

