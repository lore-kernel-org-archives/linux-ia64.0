From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 15 Dec 2000 05:00:58 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.0-test12)
Message-Id: <marc-linux-ia64-105590678205848@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The latest IA-64 patch is now available at:

 ftp://ftp.kernel.org/pub/linux/kernel/port/pub/linux/kernel/ports/ia64/

in files linux-2.4.0-test12-ia64-001214.diff*

Summary of changes:

 - Jonathan Nicklin: per-CPU interrupts now have their own IRQ handler
   to avoid unnecesary serialization due to irq descriptor locking
 - Kanoj et al: various SGI SN1 updates
 - Support for A1 step CPUs is gone
 - The software I/O TLB implementation has moved from kernel/pci-dma.c
   to lib/swiotlb.c and the function names got renamed accordingly.
   This makes room for other (platform-dependent) implementations of
   the PCI DMA interface.
 - Fix alternate TLB handlers to always set access rights to to RWX
 - Fix Dirty bit handler to also set the Access bit (this is just
   a performance optimization)
 - NaT demining: avoid crashing the kernel when the user passes NaT
   values to a system call
 - re-structure the way i-cache flushing is done
 - fix GENERIC build

Caveat: I consider this patch somewhat experimental because the
i-cache flush restructuring changed the approach to cache flushing
quite fundamentally.  The new approach is all-improved and gives a
nice performance boost when execve()ing binaries repeatedly.  However,
there is a small risk that something doesn't quite work the way it's
supposed to.  Thus, I'd like to see everyone giving this kernel a good
workout and to report any new problems.

Enjoy,

	--david

diff -urN linux-davidm/Documentation/Configure.help linux-2.4.0-test12-lia/=
Documentation/Configure.help
--- linux-davidm/Documentation/Configure.help	Thu Dec 14 19:58:05 2000
+++ linux-2.4.0-test12-lia/Documentation/Configure.help	Thu Dec 14 15:08:15=
 2000
@@ -16931,12 +16931,6 @@
   with an A-step CPU.  You have an A-step CPU if the "revision" field in
   /proc/cpuinfo is 0.
=20
-Enable Itanium A1-step specific code
-CONFIG_ITANIUM_A1_SPECIFIC
-  Select this option to build a kernel for an Itanium prototype system
-  with an A1-step CPU.  If you don't know whether you have an A1-step CPU,
-  you probably don't and you can answer "no" here.
-
 Enable Itanium B-step specific code
 CONFIG_ITANIUM_BSTEP_SPECIFIC
   Select this option to build a kernel for an Itanium prototype system
diff -urN linux-davidm/Documentation/IO-mapping.txt linux-2.4.0-test12-lia/=
Documentation/IO-mapping.txt
--- linux-davidm/Documentation/IO-mapping.txt	Fri Oct 27 10:58:02 2000
+++ linux-2.4.0-test12-lia/Documentation/IO-mapping.txt	Thu Dec 14 14:06:14=
 2000
@@ -1,3 +1,9 @@
+[ NOTE: The virt_to_bus() and bus_to_virt() functions have been
+	superseded by the functionality provided by the PCI DMA
+	interface (see Documentation/DMA-mapping.txt).  They continue
+	to be documented below for historical purposes, but new code
+	must not use them. --davidm 00/12/12 ]
+
 [ This is a mail message in response to a query on IO mapping, thus the
   strange format for a "document" ]
=20
diff -urN linux-davidm/arch/ia64/boot/Makefile linux-2.4.0-test12-lia/arch/=
ia64/boot/Makefile
--- linux-davidm/arch/ia64/boot/Makefile	Thu Jun 22 07:09:44 2000
+++ linux-2.4.0-test12-lia/arch/ia64/boot/Makefile	Thu Dec 14 14:07:03 2000
@@ -16,13 +16,12 @@
 	$(CC) $(AFLAGS) -traditional -c -o $*.o $<
=20
 OBJECTS	=3D bootloader.o
-TARGETS +targets-y =20
-ifdef CONFIG_IA64_HP_SIM
- TARGETS +=3D bootloader
-endif
+targets-$(CONFIG_IA64_HP_SIM) +=3D bootloader
+targets-$(CONFIG_IA64_GENERIC) +=3D bootloader
=20
-all:	$(TARGETS)
+all:	$(targets-y)
=20
 bootloader: $(OBJECTS)
 	$(LD) $(LINKFLAGS) $(OBJECTS) $(TOPDIR)/lib/lib.a $(TOPDIR)/arch/$(ARCH)/=
lib/lib.a \
diff -urN linux-davidm/arch/ia64/config.in linux-2.4.0-test12-lia/arch/ia64=
/config.in
--- linux-davidm/arch/ia64/config.in	Thu Dec 14 19:58:05 2000
+++ linux-2.4.0-test12-lia/arch/ia64/config.in	Thu Dec 14 19:51:13 2000
@@ -18,7 +18,6 @@
 comment 'General setup'
=20
 define_bool CONFIG_IA64 y
-define_bool CONFIG_SWIOTLB y	# for now...
=20
 define_bool CONFIG_ISA n
 define_bool CONFIG_EISA n
@@ -41,9 +40,6 @@
 	define_bool CONFIG_ITANIUM y
 	define_bool CONFIG_IA64_BRL_EMU y
 	bool '  Enable Itanium A-step specific code' CONFIG_ITANIUM_ASTEP_SPECIFIC
-	if [ "$CONFIG_ITANIUM_ASTEP_SPECIFIC" =3D "y" ]; then
-	  bool '   Enable Itanium A1-step specific code' CONFIG_ITANIUM_A1_SPECIF=
IC
-	fi
 	bool '  Enable Itanium B-step specific code' CONFIG_ITANIUM_BSTEP_SPECIFIC
 	if [ "$CONFIG_ITANIUM_BSTEP_SPECIFIC" =3D "y" ]; then
 	  bool '   Enable Itanium B0-step specific code' CONFIG_ITANIUM_B0_SPECIF=
IC
@@ -75,7 +71,6 @@
 	  bool '    Enable Itanium B0-step specific code' CONFIG_ITANIUM_B0_SPECI=
FIC
 	fi
 	bool '  Enable SGI Medusa Simulator Support' CONFIG_IA64_SGI_SN1_SIM n
-        bool '  Enable SGI hack for version 1.0 syngery bugs' CONFIG_IA64_=
SGI_SYNERGY_1_0_HACKS n
 	define_bool CONFIG_DEVFS_DEBUG y
 	define_bool CONFIG_DEVFS_FS y
 	define_bool CONFIG_IA64_BRL_EMU y
@@ -83,6 +78,7 @@
 	define_bool CONFIG_ITANIUM y
 	define_bool CONFIG_SGI_IOC3_ETH y
 	bool '  Enable DISCONTIGMEM support' CONFIG_DISCONTIGMEM y
+	bool '	Enable NUMA support' CONFIG_NUMA y
 fi
=20
 define_bool CONFIG_KCORE_ELF y	# On IA-64, we always want an ELF /proc/kco=
re.
diff -urN linux-davidm/arch/ia64/kernel/Makefile linux-2.4.0-test12-lia/arc=
h/ia64/kernel/Makefile
--- linux-davidm/arch/ia64/kernel/Makefile	Thu Dec 14 19:58:05 2000
+++ linux-2.4.0-test12-lia/arch/ia64/kernel/Makefile	Thu Dec 14 14:08:10 20=
00
@@ -10,7 +10,7 @@
 all: kernel.o head.o init_task.o
=20
 obj-y :=3D acpi.o entry.o gate.o efi.o efi_stub.o irq.o irq_ia64.o irq_sap=
ic.o ivt.o		\
-	 machvec.o pal.o pci-dma.o process.o perfmon.o ptrace.o sal.o semaphore.o=
 setup.o	\
+	 machvec.o pal.o process.o perfmon.o ptrace.o sal.o semaphore.o setup.o	\
 	 signal.o sys_ia64.o traps.o time.o unaligned.o unwind.o
=20
 obj-$(CONFIG_IA64_GENERIC) +=3D machvec.o iosapic.o
diff -urN linux-davidm/arch/ia64/kernel/ia64_ksyms.c linux-2.4.0-test12-lia=
/arch/ia64/kernel/ia64_ksyms.c
--- linux-davidm/arch/ia64/kernel/ia64_ksyms.c	Thu Dec 14 19:58:05 2000
+++ linux-2.4.0-test12-lia/arch/ia64/kernel/ia64_ksyms.c	Thu Dec 14 14:08:4=
7 2000
@@ -24,10 +24,6 @@
 EXPORT_SYMBOL(strstr);
 EXPORT_SYMBOL(strtok);
=20
-#include <linux/pci.h>
-EXPORT_SYMBOL(pci_alloc_consistent);
-EXPORT_SYMBOL(pci_free_consistent);
-
 #include <linux/in6.h>
 #include <asm/checksum.h>
 /* not coded yet?? EXPORT_SYMBOL(csum_ipv6_magic); */
@@ -48,14 +44,6 @@
=20
 #include <asm/page.h>
 EXPORT_SYMBOL(clear_page);
-
-#include <asm/pci.h>
-EXPORT_SYMBOL(pci_dma_sync_sg);
-EXPORT_SYMBOL(pci_dma_sync_single);
-EXPORT_SYMBOL(pci_map_sg);
-EXPORT_SYMBOL(pci_map_single);
-EXPORT_SYMBOL(pci_unmap_sg);
-EXPORT_SYMBOL(pci_unmap_single);
=20
 #include <asm/processor.h>
 EXPORT_SYMBOL(cpu_data);
diff -urN linux-davidm/arch/ia64/kernel/irq.c linux-2.4.0-test12-lia/arch/i=
a64/kernel/irq.c
--- linux-davidm/arch/ia64/kernel/irq.c	Wed Dec 13 17:29:20 2000
+++ linux-2.4.0-test12-lia/arch/ia64/kernel/irq.c	Thu Dec 14 14:09:00 2000
@@ -541,6 +541,18 @@
 	spin_unlock_irqrestore(&desc->lock, flags);
 }
=20
+void do_IRQ_per_cpu(unsigned long irq, struct pt_regs *regs)
+{
+	irq_desc_t *desc =3D irq_desc + irq;
+	int cpu =3D smp_processor_id();
+
+	kstat.irqs[cpu][irq]++;
+
+	desc->handler->ack(irq);
+	handle_IRQ_event(irq, regs, desc->action);
+	desc->handler->end(irq);
+}
+
 /*
  * do_IRQ handles all normal device IRQ's (the special
  * SMP cross-CPU interrupts have their own specific
@@ -581,8 +593,7 @@
 	if (!(status & (IRQ_DISABLED | IRQ_INPROGRESS))) {
 		action =3D desc->action;
 		status &=3D ~IRQ_PENDING; /* we commit to handling */
-		if (!(status & IRQ_PER_CPU))
-			status |=3D IRQ_INPROGRESS; /* we are handling it */
+		status |=3D IRQ_INPROGRESS; /* we are handling it */
 	}
 	desc->status =3D status;
=20
diff -urN linux-davidm/arch/ia64/kernel/irq_ia64.c linux-2.4.0-test12-lia/a=
rch/ia64/kernel/irq_ia64.c
--- linux-davidm/arch/ia64/kernel/irq_ia64.c	Thu Dec 14 19:58:05 2000
+++ linux-2.4.0-test12-lia/arch/ia64/kernel/irq_ia64.c	Thu Dec 14 14:09:33 =
2000
@@ -38,10 +38,6 @@
=20
 #define IRQ_DEBUG	0
=20
-#ifdef CONFIG_ITANIUM_A1_SPECIFIC
-spinlock_t ivr_read_lock;
-#endif
-
 /* default base addr of IPI table */
 unsigned long ipi_base_addr =3D (__IA64_UNCACHED_OFFSET | IPI_DEFAULT_BASE=
_ADDR);=09
=20
@@ -65,22 +61,6 @@
 	return next_irq++;
 }
=20
-#ifdef CONFIG_ITANIUM_A1_SPECIFIC
-
-int usbfix;
-
-static int __init
-usbfix_option (char *str)
-{
-	printk("irq: enabling USB workaround\n");
-	usbfix =3D 1;
-	return 1;
-}
-
-__setup("usbfix", usbfix_option);
-
-#endif /* CONFIG_ITANIUM_A1_SPECIFIC */
-
 /*
  * That's where the IVT branches when we get an external
  * interrupt. This branches to the correct hardware IRQ handler via
@@ -90,42 +70,6 @@
 ia64_handle_irq (unsigned long vector, struct pt_regs *regs)
 {
 	unsigned long saved_tpr;
-#ifdef CONFIG_ITANIUM_A1_SPECIFIC
-	unsigned long eoi_ptr;
-=20
-# ifdef CONFIG_USB
-	extern void reenable_usb (void);
-	extern void disable_usb (void);
-
-	if (usbfix)
-		disable_usb();
-# endif
-	/*
-	 * Stop IPIs by getting the ivr_read_lock
-	 */
-	spin_lock(&ivr_read_lock);
-	{
-		unsigned int tmp;
-		/*
-		 * Disable PCI writes
-		 */
-		outl(0x80ff81c0, 0xcf8);
-		tmp =3D inl(0xcfc);
-		outl(tmp | 0x400, 0xcfc);
-		eoi_ptr =3D inl(0xcfc);
-		vector =3D ia64_get_ivr();
-		/*
-		 * Enable PCI writes
-		 */
-		outl(tmp, 0xcfc);
-	}
-	spin_unlock(&ivr_read_lock);
-
-# ifdef CONFIG_USB
-	if (usbfix)
-		reenable_usb();
-# endif
-#endif /* CONFIG_ITANIUM_A1_SPECIFIC */
=20
 #if IRQ_DEBUG
 	{
@@ -174,7 +118,10 @@
 		ia64_set_tpr(vector);
 		ia64_srlz_d();
=20
-		do_IRQ(vector, regs);
+		if ((irq_desc[vector].status & IRQ_PER_CPU) !=3D 0)
+			do_IRQ_per_cpu(vector, regs);
+		else
+			do_IRQ(vector, regs);
=20
 		/*
 		 * Disable interrupts and send EOI:
@@ -182,9 +129,6 @@
 		local_irq_disable();
 		ia64_set_tpr(saved_tpr);
 		ia64_eoi();
-#ifdef CONFIG_ITANIUM_A1_SPECIFIC
-		break;
-#endif
 		vector =3D ia64_get_ivr();
 	} while (vector !=3D IA64_SPURIOUS_INT);
 }
@@ -207,8 +151,8 @@
 	 * Disable all local interrupts
 	 */
 	ia64_set_itv(0, 1);
-	ia64_set_lrr0(0, 1);=09
-	ia64_set_lrr1(0, 1);=09
+	ia64_set_lrr0(0, 1);
+	ia64_set_lrr1(0, 1);
=20
 	irq_desc[IA64_SPURIOUS_INT].handler =3D &irq_type_ia64_sapic;
 #ifdef CONFIG_SMP
@@ -235,9 +179,6 @@
 	unsigned long ipi_addr;
 	unsigned long ipi_data;
 	unsigned long phys_cpu_id;
-#ifdef CONFIG_ITANIUM_A1_SPECIFIC
-	unsigned long flags;
-#endif
=20
 #ifdef CONFIG_SMP
 	phys_cpu_id =3D cpu_physical_id(cpu);
@@ -252,13 +193,5 @@
 	ipi_data =3D (delivery_mode << 8) | (vector & 0xff);
 	ipi_addr =3D ipi_base_addr | (phys_cpu_id << 4) | ((redirect & 1)  << 3);
=20
-#ifdef CONFIG_ITANIUM_A1_SPECIFIC
-	spin_lock_irqsave(&ivr_read_lock, flags);
-#endif
-
 	writeq(ipi_data, ipi_addr);
-
-#ifdef CONFIG_ITANIUM_A1_SPECIFIC
-	spin_unlock_irqrestore(&ivr_read_lock, flags);
-#endif
 }
diff -urN linux-davidm/arch/ia64/kernel/ivt.S linux-2.4.0-test12-lia/arch/i=
a64/kernel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Thu Dec 14 19:58:05 2000
+++ linux-2.4.0-test12-lia/arch/ia64/kernel/ivt.S	Thu Dec 14 20:11:48 2000
@@ -348,7 +348,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x0c00 Entry 3 (size 64 bundles) Alt ITLB (19)
 	mov r16=3Dcr.ifa		// get address that caused the TLB miss
-	movl r17=3D__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RX
+	movl r17=3D__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RWX
 	mov r21=3Dcr.ipsr
 	mov r31=3Dpr
 	;;
@@ -378,7 +378,7 @@
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x1000 Entry 4 (size 64 bundles) Alt DTLB (7,46)
 	mov r16=3Dcr.ifa		// get address that caused the TLB miss
-	movl r17=3D__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RW
+	movl r17=3D__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RWX
 	mov r20=3Dcr.isr
 	mov r21=3Dcr.ipsr
 	mov r31=3Dpr
@@ -532,7 +532,7 @@
 	;;
 1:	ld8 r18=3D[r17]
 	;;					// avoid RAW on r18
-	or r18=3D_PAGE_D,r18			// set the dirty bit
+	or r18=3D_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
 	mov b0=3Dr29				// restore b0
 	;;
 	st8 [r17]=3Dr18				// store back updated PTE
@@ -549,7 +549,7 @@
 1:	ld8 r18=3D[r17]
 	;;					// avoid RAW on r18
 	mov ar.ccv=3Dr18				// set compare value for cmpxchg
-	or r25=3D_PAGE_D,r18			// set the dirty bit
+	or r25=3D_PAGE_D|_PAGE_A,r18		// set the dirty and accessed bits
 	;;
 	cmpxchg8.acq r26=3D[r17],r25,ar.ccv
 	mov r24=3DPAGE_SHIFT<<2
@@ -741,14 +741,13 @@
 	adds r3=3D8,r2		// set up second base pointer for SAVE_REST
 	;;
 	SAVE_REST
-	;;			// avoid WAW on r2 & r3
+	br.call.sptk rp=DEmine_args		// clear NaT bits in (potential) syscall args
=20
 	mov r3%5
 	adds r15=3D-1024,r15			// r15 contains the syscall number---subtract 1024
 	adds r2=3DIA64_TASK_PTRACE_OFFSET,r13	// r2 =3D &current->ptrace
-
 	;;
-	cmp.geu.unc p6,p7=3Dr3,r15		// (syscall > 0 && syscall <=3D 1024+255) ?
+	cmp.geu p6,p7=3Dr3,r15		// (syscall > 0 && syscall <=3D 1024+255) ?
 	movl r16=3Dsys_call_table
 	;;
 (p6)	shladd r16=3Dr15,3,r16
@@ -787,6 +786,33 @@
 	br.call.sptk.few rp=3Dia64_trace_syscall	// rp will be overwritten (ignor=
ed)
 	// NOT REACHED
=20
+	.proc demine_args
+demine_args:
+	alloc r2=3Dar.pfs,8,0,0,0
+	tnat.nz p8,p0=3Din0
+	tnat.nz p9,p0=3Din1
+	;;
+(p8)	mov in0=3D-1
+	tnat.nz p10,p0=3Din2
+	tnat.nz p11,p0=3Din3
+
+(p9)	mov in1=3D-1
+	tnat.nz p12,p0=3Din4
+	tnat.nz p13,p0=3Din5
+	;;
+(p10)	mov in2=3D-1
+	tnat.nz p14,p0=3Din6
+	tnat.nz p15,p0=3Din7
+
+(p11)	mov in3=3D-1
+(p12)	mov in4=3D-1
+(p13)	mov in5=3D-1
+	;;
+(p14)	mov in6=3D-1
+(p15)	mov in7=3D-1
+	br.ret.sptk.few rp
+	.endp demine_args
+
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x3000 Entry 12 (size 64 bundles) External Interrupt (4)
@@ -802,11 +828,7 @@
 	SAVE_REST
 	;;
 	alloc r14=3Dar.pfs,0,0,2,0 // must be first in an insn group
-#ifdef CONFIG_ITANIUM_A1_SPECIFIC
-	mov out0=3Dr0		// defer reading of cr.ivr to handle_irq...
-#else
 	mov out0=3Dcr.ivr		// pass cr.ivr as first arg
-#endif
 	add out1=16,sp		// pass pointer to pt_regs as second arg
 	;;
 	srlz.d			// make  sure we see the effect of cr.ivr
@@ -1091,12 +1113,11 @@
 // 0x5000 Entry 20 (size 16 bundles) Page Not Present (10,22,49)
 	mov r16=3Dcr.ifa
 	rsm psr.dt
-#if 1
-	// If you disable this, you MUST re-enable to update_mmu_cache() code in =
pgtable.h
+	// The Linux page fault handler doesn't expect non-present pages to be in
+	// the TLB.  Flush the existing entry now, so we meet that expectation.
 	mov r17=3D_PAGE_SIZE_4K<<2
 	;;
 	ptc.l r16,r17
-#endif
 	;;
 	mov r31=3Dpr
 	srlz.d
diff -urN linux-davidm/arch/ia64/kernel/pci-dma.c linux-2.4.0-test12-lia/ar=
ch/ia64/kernel/pci-dma.c
--- linux-davidm/arch/ia64/kernel/pci-dma.c	Thu Dec 14 19:58:05 2000
+++ linux-2.4.0-test12-lia/arch/ia64/kernel/pci-dma.c	Wed Dec 31 16:00:00 1=
969
@@ -1,530 +0,0 @@
-/*
- * Dynamic DMA mapping support.
- *
- * This implementation is for IA-64 platforms that do not support
- * I/O TLBs (aka DMA address translation hardware).
- * Copyright (C) 2000 Asit Mallick <Asit.K.Mallick@intel.com>
- * Copyright (C) 2000 Goutham Rao <goutham.rao@intel.com>
- */
-
-#include <linux/config.h>
-
-#include <linux/mm.h>
-#include <linux/pci.h>
-#include <linux/spinlock.h>
-#include <linux/string.h>
-#include <linux/types.h>
-
-#include <asm/io.h>
-#include <asm/pci.h>
-#include <asm/dma.h>
-
-#ifdef CONFIG_SWIOTLB
-
-#include <linux/init.h>
-#include <linux/bootmem.h>
-
-#define ALIGN(val, align) ((unsigned long)	\
-	(((unsigned long) (val) + ((align) - 1)) & ~((align) - 1)))
-
-/*
- * log of the size of each IO TLB slab.  The number of slabs is command li=
ne
- * controllable.
- */
-#define IO_TLB_SHIFT 11
-
-/*
- * Used to do a quick range check in pci_unmap_single and pci_sync_single,=
 to see if the=20
- * memory was in fact allocated by this API.
- */
-static char *io_tlb_start, *io_tlb_end;
-
-/*
- * The number of IO TLB blocks (in groups of 64) betweeen io_tlb_start and=
 io_tlb_end.
- * This is command line adjustable via setup_io_tlb_npages.
- */
-unsigned long io_tlb_nslabs =3D 1024;
-
-/*
- * This is a free list describing the number of free entries available fro=
m each index
- */
-static unsigned int *io_tlb_list;
-static unsigned int io_tlb_index;
-
-/*
- * We need to save away the original address corresponding to a mapped ent=
ry for the sync=20
- * operations.
- */
-static unsigned char **io_tlb_orig_addr;
-
-/*
- * Protect the above data structures in the map and unmap calls
- */=20
-spinlock_t io_tlb_lock =3D SPIN_LOCK_UNLOCKED;
-
-static int __init
-setup_io_tlb_npages (char *str)
-{
-	io_tlb_nslabs =3D simple_strtoul(str, NULL, 0) << (PAGE_SHIFT - IO_TLB_SH=
IFT);
-	return 1;
-}
-__setup("swiotlb=3D", setup_io_tlb_npages);
-
-/*
- * Statically reserve bounce buffer space and initialize bounce buffer
- * data structures for the software IO TLB used to implement the PCI DMA A=
PI
- */
-void
-setup_swiotlb (void)
-{
-	int i;
-
-	/*
-	 * Get IO TLB memory from the low pages
-	 */
-	io_tlb_start =3D alloc_bootmem_low_pages(io_tlb_nslabs * (1 << IO_TLB_SHI=
FT));
-	if (!io_tlb_start)
-		BUG();
-	io_tlb_end =3D io_tlb_start + io_tlb_nslabs * (1 << IO_TLB_SHIFT);
-
-	/*
-	 * Allocate and initialize the free list array.  This array is used
-	 * to find contiguous free memory regions of size 2^IO_TLB_SHIFT between
-	 * io_tlb_start and io_tlb_end.
-	 */
-	io_tlb_list =3D alloc_bootmem(io_tlb_nslabs * sizeof(int));
-	for (i =3D 0; i < io_tlb_nslabs; i++)
-		io_tlb_list[i] =3D io_tlb_nslabs - i;
-	io_tlb_index =3D 0;
-	io_tlb_orig_addr =3D alloc_bootmem(io_tlb_nslabs * sizeof(char *));
-
-	printk("Placing software IO TLB between 0x%p - 0x%p\n",
-	       (void *) io_tlb_start, (void *) io_tlb_end);
-}
-
-/*
- * Allocates bounce buffer and returns its kernel virtual address.
- */
-static void *
-__pci_map_single (struct pci_dev *hwdev, char *buffer, size_t size, int di=
rection)
-{
-	unsigned long flags;
-	char *dma_addr;
-	unsigned int nslots, stride, index, wrap;
-	int i;
-
-	/*
-	 * For mappings greater than a page size, we limit the stride (and hence =
alignment)
-	 * to a page size.
-	 */
-	nslots =3D ALIGN(size, 1 << IO_TLB_SHIFT) >> IO_TLB_SHIFT;
-	if (size > (1 << PAGE_SHIFT))
-		stride =3D (1 << (PAGE_SHIFT - IO_TLB_SHIFT));
-	else
-		stride =3D nslots;
-
-	if (!nslots)
-		BUG();
-
-	/*
-	 * Find suitable number of IO TLB entries size that will fit this request=
 and
-	 * allocate a buffer from that IO TLB pool.
-	 */
-	spin_lock_irqsave(&io_tlb_lock, flags);
-	{
-		wrap =3D index =3D ALIGN(io_tlb_index, stride);
-
-		if (index >=3D io_tlb_nslabs)=20
-			wrap =3D index =3D 0;
-
-		do {
-			/*
-			 * If we find a slot that indicates we have 'nslots' number of=20
-			 * contiguous buffers, we allocate the buffers from that slot and mark =
the
-			 * entries as '0' indicating unavailable.
-			 */
-			if (io_tlb_list[index] >=3D nslots) {
-				int count =3D 0;
-
-				for (i =3D index; i < index + nslots; i++)
-					io_tlb_list[i] =3D 0;
-				for (i =3D index - 1; (i >=3D 0) && io_tlb_list[i]; i--)
-					io_tlb_list[i] =3D ++count;
-				dma_addr =3D io_tlb_start + (index << IO_TLB_SHIFT);
-
-				/*
-				 * Update the indices to avoid searching in the next round.
-				 */
-				io_tlb_index =3D ((index + nslots) < io_tlb_nslabs
-						? (index + nslots) : 0);
-
-				goto found;
-			}
-			index +=3D stride;
-			if (index >=3D io_tlb_nslabs)
-				index =3D 0;
-		} while (index !=3D wrap);
-
-		/*
-		 * XXX What is a suitable recovery mechanism here?  We cannot=20
-		 * sleep because we are called from with in interrupts!
-		 */
-		panic("__pci_map_single: could not allocate software IO TLB (%ld bytes)"=
, size);
-found:
-	}
-	spin_unlock_irqrestore(&io_tlb_lock, flags);
-
-	/*
-	 * Save away the mapping from the original address to the DMA address.  T=
his is needed
-	 * when we sync the memory.  Then we sync the buffer if needed.
-	 */
-	io_tlb_orig_addr[index] =3D buffer;
-	if (direction =3D PCI_DMA_TODEVICE || direction =3D PCI_DMA_BIDIRECTIONAL)
-		memcpy(dma_addr, buffer, size);
-
-	return dma_addr;
-}
-
-/*
- * dma_addr is the kernel virtual address of the bounce buffer to unmap.
- */
-static void
-__pci_unmap_single (struct pci_dev *hwdev, char *dma_addr, size_t size, in=
t direction)
-{
-	unsigned long flags;
-	int i, nslots =3D ALIGN(size, 1 << IO_TLB_SHIFT) >> IO_TLB_SHIFT;
-	int index =3D (dma_addr - io_tlb_start) >> IO_TLB_SHIFT;
-	char *buffer =3D io_tlb_orig_addr[index];
-
-	/*
-	 * First, sync the memory before unmapping the entry
-	 */
-	if ((direction =3D PCI_DMA_FROMDEVICE) || (direction =3D PCI_DMA_BIDIRECT=
IONAL))
-		/*
- 	 	 * bounce... copy the data back into the original buffer
-	  	 * and delete the bounce buffer.
- 	 	 */
-		memcpy(buffer, dma_addr, size);
-
-	/*
-	 * Return the buffer to the free list by setting the corresponding entrie=
s to indicate
-	 * the number of contigous entries available. =20
-	 * While returning the entries to the free list, we merge the entries wit=
h slots below
-	 * and above the pool being returned.
-	 */
-	spin_lock_irqsave(&io_tlb_lock, flags);
-	{
-		int count =3D ((index + nslots) < io_tlb_nslabs ? io_tlb_list[index + ns=
lots] : 0);
-		/*
-		 * Step 1: return the slots to the free list, merging the slots with
-		 * superceeding slots
-		 */
-		for (i =3D index + nslots - 1; i >=3D index; i--)
-			io_tlb_list[i] =3D ++count;
-		/*
-		 * Step 2: merge the returned slots with the preceeding slots, if
-		 * available (non zero)
-		 */
-		for (i =3D index - 1; (i >=3D 0) && io_tlb_list[i]; i--)
-			io_tlb_list[i] =3D ++count;
-	}
-	spin_unlock_irqrestore(&io_tlb_lock, flags);
-}
-
-static void
-__pci_sync_single (struct pci_dev *hwdev, char *dma_addr, size_t size, int=
 direction)
-{
-	int index =3D (dma_addr - io_tlb_start) >> IO_TLB_SHIFT;
-	char *buffer =3D io_tlb_orig_addr[index];
-
-	/*
-  	 * bounce... copy the data back into/from the original buffer
-	 * XXX How do you handle PCI_DMA_BIDIRECTIONAL here ?
- 	 */
-	if (direction =3D PCI_DMA_FROMDEVICE)
-		memcpy(buffer, dma_addr, size);
-	else if (direction =3D PCI_DMA_TODEVICE)
-		memcpy(dma_addr, buffer, size);
-	else
-		BUG();
-}
-
-/*
- * Map a single buffer of the indicated size for DMA in streaming mode.
- * The PCI address to use is returned.
- *
- * Once the device is given the dma address, the device owns this memory
- * until either pci_unmap_single or pci_dma_sync_single is performed.
- */
-dma_addr_t
-pci_map_single (struct pci_dev *hwdev, void *ptr, size_t size, int directi=
on)
-{
-	unsigned long pci_addr =3D virt_to_phys(ptr);
-
-	if (direction =3D PCI_DMA_NONE)
-		BUG();
-	/*
-	 * Check if the PCI device can DMA to ptr... if so, just return ptr
-	 */
-	if ((pci_addr & ~hwdev->dma_mask) =3D 0)
-		/*
-		 * Device is bit capable of DMA'ing to the
-		 * buffer... just return the PCI address of ptr
-		 */
-		return pci_addr;
-
-	/*=20
-	 * get a bounce buffer:=20
-	 */
-	pci_addr =3D virt_to_phys(__pci_map_single(hwdev, ptr, size, direction));
-
-	/*
-	 * Ensure that the address returned is DMA'ble:
-	 */
-	if ((pci_addr & ~hwdev->dma_mask) !=3D 0)
-		panic("__pci_map_single: bounce buffer is not DMA'ble");
-
-	return pci_addr;
-}
-
-/*
- * Unmap a single streaming mode DMA translation.  The dma_addr and size
- * must match what was provided for in a previous pci_map_single call.  All
- * other usages are undefined.
- *
- * After this call, reads by the cpu to the buffer are guarenteed to see
- * whatever the device wrote there.
- */
-void
-pci_unmap_single (struct pci_dev *hwdev, dma_addr_t pci_addr, size_t size,=
 int direction)
-{
-	char *dma_addr =3D phys_to_virt(pci_addr);
-
-	if (direction =3D PCI_DMA_NONE)
-		BUG();
-	if (dma_addr >=3D io_tlb_start && dma_addr < io_tlb_end)
-		__pci_unmap_single(hwdev, dma_addr, size, direction);
-}
-
-/*
- * Make physical memory consistent for a single
- * streaming mode DMA translation after a transfer.
- *
- * If you perform a pci_map_single() but wish to interrogate the
- * buffer using the cpu, yet do not wish to teardown the PCI dma
- * mapping, you must call this function before doing so.  At the
- * next point you give the PCI dma address back to the card, the
- * device again owns the buffer.
- */
-void
-pci_dma_sync_single (struct pci_dev *hwdev, dma_addr_t pci_addr, size_t si=
ze, int direction)
-{
-	char *dma_addr =3D phys_to_virt(pci_addr);
-
-	if (direction =3D PCI_DMA_NONE)
-		BUG();
-	if (dma_addr >=3D io_tlb_start && dma_addr < io_tlb_end)
-		__pci_sync_single(hwdev, dma_addr, size, direction);
-}
-
-/*
- * Map a set of buffers described by scatterlist in streaming
- * mode for DMA.  This is the scather-gather version of the
- * above pci_map_single interface.  Here the scatter gather list
- * elements are each tagged with the appropriate dma address
- * and length.  They are obtained via sg_dma_{address,length}(SG).
- *
- * NOTE: An implementation may be able to use a smaller number of
- *       DMA address/length pairs than there are SG table elements.
- *       (for example via virtual mapping capabilities)
- *       The routine returns the number of addr/length pairs actually
- *       used, at most nents.
- *
- * Device ownership issues as mentioned above for pci_map_single are
- * the same here.
- */
-int
-pci_map_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nelems, int=
 direction)
-{
-	int i;
-
-	if (direction =3D PCI_DMA_NONE)
-		BUG();
-
-	for (i =3D 0; i < nelems; i++, sg++) {
-		sg->orig_address =3D sg->address;
-		if ((virt_to_phys(sg->address) & ~hwdev->dma_mask) !=3D 0) {
-			sg->address =3D __pci_map_single(hwdev, sg->address, sg->length, direct=
ion);
-		}
-	}
-	return nelems;
-}
-
-/*
- * Unmap a set of streaming mode DMA translations.
- * Again, cpu read rules concerning calls here are the same as for
- * pci_unmap_single() above.
- */
-void
-pci_unmap_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nelems, i=
nt direction)
-{
-	int i;
-
-	if (direction =3D PCI_DMA_NONE)
-		BUG();
-
-	for (i =3D 0; i < nelems; i++, sg++)
-		if (sg->orig_address !=3D sg->address) {
-			__pci_unmap_single(hwdev, sg->address, sg->length, direction);
-			sg->address =3D sg->orig_address;
-		}
-}
-
-/*
- * Make physical memory consistent for a set of streaming mode DMA
- * translations after a transfer.
- *
- * The same as pci_dma_sync_single but for a scatter-gather list,
- * same rules and usage.
- */
-void
-pci_dma_sync_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nelems=
, int direction)
-{
-	int i;
-
-	if (direction =3D PCI_DMA_NONE)
-		BUG();
-
-	for (i =3D 0; i < nelems; i++, sg++)
-		if (sg->orig_address !=3D sg->address)
-			__pci_sync_single(hwdev, sg->address, sg->length, direction);
-}
-
-#else
-/*
- * Map a single buffer of the indicated size for DMA in streaming mode.
- * The 32-bit bus address to use is returned.
- *
- * Once the device is given the dma address, the device owns this memory
- * until either pci_unmap_single or pci_dma_sync_single is performed.
- */
-dma_addr_t
-pci_map_single (struct pci_dev *hwdev, void *ptr, size_t size, int directi=
on)
-{
-        if (direction =3D PCI_DMA_NONE)
-                BUG();
-        return virt_to_bus(ptr);
-}
-
-/*
- * Unmap a single streaming mode DMA translation.  The dma_addr and size
- * must match what was provided for in a previous pci_map_single call.  All
- * other usages are undefined.
- *
- * After this call, reads by the cpu to the buffer are guarenteed to see
- * whatever the device wrote there.
- */
-void
-pci_unmap_single (struct pci_dev *hwdev, dma_addr_t dma_addr, size_t size,=
 int direction)
-{
-        if (direction =3D PCI_DMA_NONE)
-                BUG();
-        /* Nothing to do */
-}
-/*
- * Map a set of buffers described by scatterlist in streaming
- * mode for DMA.  This is the scather-gather version of the
- * above pci_map_single interface.  Here the scatter gather list
- * elements are each tagged with the appropriate dma address
- * and length.  They are obtained via sg_dma_{address,length}(SG).
- *
- * NOTE: An implementation may be able to use a smaller number of
- *       DMA address/length pairs than there are SG table elements.
- *       (for example via virtual mapping capabilities)
- *       The routine returns the number of addr/length pairs actually
- *       used, at most nents.
- *
- * Device ownership issues as mentioned above for pci_map_single are
- * the same here.
- */
-int
-pci_map_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nents, int =
direction)
-{
-        if (direction =3D PCI_DMA_NONE)
-                BUG();
-        return nents;
-}
-
-/*
- * Unmap a set of streaming mode DMA translations.
- * Again, cpu read rules concerning calls here are the same as for
- * pci_unmap_single() above.
- */
-void
-pci_unmap_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nents, in=
t direction)
-{
-        if (direction =3D PCI_DMA_NONE)
-                BUG();
-        /* Nothing to do */
-}
-/*
- * Make physical memory consistent for a single
- * streaming mode DMA translation after a transfer.
- *
- * If you perform a pci_map_single() but wish to interrogate the
- * buffer using the cpu, yet do not wish to teardown the PCI dma
- * mapping, you must call this function before doing so.  At the
- * next point you give the PCI dma address back to the card, the
- * device again owns the buffer.
- */
-void
-pci_dma_sync_single (struct pci_dev *hwdev, dma_addr_t dma_handle, size_t =
size, int direction)
-{
-        if (direction =3D PCI_DMA_NONE)
-                BUG();
-        /* Nothing to do */
-}
-
-/*
- * Make physical memory consistent for a set of streaming mode DMA
- * translations after a transfer.
- *
- * The same as pci_dma_sync_single but for a scatter-gather list,
- * same rules and usage.
- */
-void
-pci_dma_sync_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nelems=
, int direction)
-{
-        if (direction =3D PCI_DMA_NONE)
-                BUG();
-        /* Nothing to do */
-}
-
-#endif /* CONFIG_SWIOTLB */
-
-void *
-pci_alloc_consistent (struct pci_dev *hwdev, size_t size, dma_addr_t *dma_=
handle)
-{
-	unsigned long pci_addr;
-	int gfp =3D GFP_ATOMIC;
-	void *ret;
-
-	if (!hwdev || hwdev->dma_mask <=3D 0xffffffff)
-		gfp |=3D GFP_DMA; /* XXX fix me: should change this to GFP_32BIT or ZONE=
_32BIT */
-	ret =3D (void *)__get_free_pages(gfp, get_order(size));
-	if (!ret)
-		return NULL;
-
-	memset(ret, 0, size);
-	pci_addr =3D virt_to_phys(ret);
-	if ((pci_addr & ~hwdev->dma_mask) !=3D 0)
-		panic("pci_alloc_consistent: allocated memory is out of range for PCI de=
vice");
-	*dma_handle =3D pci_addr;
-	return ret;
-}
-
-void
-pci_free_consistent (struct pci_dev *hwdev, size_t size, void *vaddr, dma_=
addr_t dma_handle)
-{
-	free_pages((unsigned long) vaddr, get_order(size));
-}
diff -urN linux-davidm/arch/ia64/kernel/setup.c linux-2.4.0-test12-lia/arch=
/ia64/kernel/setup.c
--- linux-davidm/arch/ia64/kernel/setup.c	Thu Dec 14 19:58:05 2000
+++ linux-2.4.0-test12-lia/arch/ia64/kernel/setup.c	Thu Dec 14 14:12:41 2000
@@ -261,13 +261,6 @@
=20
 	paging_init();
 	platform_setup(cmdline_p);
-
-#ifdef CONFIG_SWIOTLB
-	{
-		extern void setup_swiotlb (void);
-		setup_swiotlb();
-	}
-#endif
 }
=20
 /*
diff -urN linux-davidm/arch/ia64/kernel/smp.c linux-2.4.0-test12-lia/arch/i=
a64/kernel/smp.c
--- linux-davidm/arch/ia64/kernel/smp.c	Thu Dec 14 19:58:05 2000
+++ linux-2.4.0-test12-lia/arch/ia64/kernel/smp.c	Thu Dec 14 20:11:27 2000
@@ -81,10 +81,6 @@
 };
 static volatile struct smp_call_struct *smp_call_function_data;
=20
-#ifdef	CONFIG_ITANIUM_A1_SPECIFIC
-extern spinlock_t ivr_read_lock;
-#endif
-
 #define IPI_RESCHEDULE	        0
 #define IPI_CALL_FUNC	        1
 #define IPI_CPU_STOP	        2
diff -urN linux-davidm/arch/ia64/kernel/unwind.c linux-2.4.0-test12-lia/arc=
h/ia64/kernel/unwind.c
--- linux-davidm/arch/ia64/kernel/unwind.c	Thu Dec 14 19:58:05 2000
+++ linux-2.4.0-test12-lia/arch/ia64/kernel/unwind.c	Thu Dec 14 14:14:49 20=
00
@@ -521,6 +521,10 @@
 	struct unw_reg_state *rs;
=20
 	rs =3D alloc_reg_state();
+	if (!rs) {
+		printk("unwind: cannot stack reg state!\n");
+		return;
+	}
 	memcpy(rs, &sr->curr, sizeof(*rs));
 	rs->next =3D sr->stack;
 	sr->stack =3D rs;
diff -urN linux-davidm/arch/ia64/lib/Makefile linux-2.4.0-test12-lia/arch/i=
a64/lib/Makefile
--- linux-davidm/arch/ia64/lib/Makefile	Mon Oct  9 17:54:56 2000
+++ linux-2.4.0-test12-lia/arch/ia64/lib/Makefile	Thu Dec 14 14:15:00 2000
@@ -11,7 +11,8 @@
 	__divdi3.o __udivdi3.o __moddi3.o __umoddi3.o					\
 	checksum.o clear_page.o csum_partial_copy.o copy_page.o				\
 	copy_user.o clear_user.o strncpy_from_user.o strlen_user.o strnlen_user.o=
	\
-	flush.o do_csum.o
+	flush.o do_csum.o \
+	swiotlb.o
=20
 ifneq ($(CONFIG_ITANIUM_ASTEP_SPECIFIC),y)
   L_OBJS +=3D memcpy.o memset.o strlen.o
diff -urN linux-davidm/arch/ia64/lib/flush.S linux-2.4.0-test12-lia/arch/ia=
64/lib/flush.S
--- linux-davidm/arch/ia64/lib/flush.S	Thu Jun 22 07:09:44 2000
+++ linux-2.4.0-test12-lia/arch/ia64/lib/flush.S	Thu Dec 14 14:15:15 2000
@@ -12,29 +12,33 @@
 	.psr lsb
 	.lsb
=20
-GLOBAL_ENTRY(ia64_flush_icache_page)
+	/*
+	 * flush_icache_range(start,end)
+	 *	Must flush range from start to end-1 but nothing else (need to
+	 *	be careful not to touch addresses that may be unmapped).
+	 */
+GLOBAL_ENTRY(flush_icache_range)
 	UNW(.prologue)
-	alloc r2=3Dar.pfs,1,0,0,0
+	alloc r2=3Dar.pfs,2,0,0,0
+	sub r8=3Din1,in0,1
+	;;
+	shr.u r8=3Dr8,5			// we flush 32 bytes per iteration
 	UNW(.save ar.lc, r3)
 	mov r3=3Dar.lc			// save ar.lc=09
+	;;
=20
 	.body
=20
-	mov r8=3DPAGE_SIZE/64-1		// repeat/until loop
-	;;
 	mov ar.lc=3Dr8
-	add r82,in0
 	;;
-.Loop1:	fc in0				// issuable on M0 only
-	add in0d,in0
-	fc r8
-	add r8d,r8
-	br.cloop.sptk.few .Loop1
+.Loop:	fc in0				// issuable on M0 only
+	add in02,in0
+	br.cloop.sptk.few .Loop
 	;;
 	sync.i
 	;;
 	srlz.i
 	;;=09
 	mov ar.lc=3Dr3			// restore ar.lc
-	br.ret.sptk.few rp
-END(ia64_flush_icache_page)
+	br.ret.sptk.many rp
+END(flush_icache_range)
diff -urN linux-davidm/arch/ia64/lib/io.c linux-2.4.0-test12-lia/arch/ia64/=
lib/io.c
--- linux-davidm/arch/ia64/lib/io.c	Mon Oct  9 17:54:56 2000
+++ linux-2.4.0-test12-lia/arch/ia64/lib/io.c	Thu Dec 14 14:15:32 2000
@@ -1,3 +1,4 @@
+#include <linux/config.h>
 #include <linux/types.h>
=20
 #include <asm/io.h>
@@ -48,3 +49,54 @@
 	}
 }
=20
+#ifdef CONFIG_IA64_GENERIC
+
+unsigned int
+ia64_inb (unsigned long port)
+{
+	return __ia64_inb(port);
+}
+
+unsigned int
+ia64_inw (unsigned long port)
+{
+	return __ia64_inw(port);
+}
+
+unsigned int
+ia64_inl (unsigned long port)
+{
+	return __ia64_inl(port);
+}
+
+void
+ia64_outb (unsigned char val, unsigned long port)
+{
+	__ia64_outb(val, port);
+}
+
+void
+ia64_outw (unsigned short val, unsigned long port)
+{
+	__ia64_outw(val, port);
+}
+
+void
+ia64_outl (unsigned int val, unsigned long port)
+{
+	__ia64_outl(val, port);
+}
+
+/* define aliases: */
+
+asm (".global __ia64_inb, __ia64_inw, __ia64_inl");
+asm ("__ia64_inb =3D ia64_inb");
+asm ("__ia64_inw =3D ia64_inw");
+asm ("__ia64_inl =3D ia64_inl");
+
+asm (".global __ia64_outb, __ia64_outw, __ia64_outl");
+asm ("__ia64_outb =3D ia64_outb");
+asm ("__ia64_outw =3D ia64_outw");
+asm ("__ia64_outl =3D ia64_outl");
+
+#endif /* CONFIG_IA64_GENERIC */
diff -urN linux-davidm/arch/ia64/lib/swiotlb.c linux-2.4.0-test12-lia/arch/=
ia64/lib/swiotlb.c
--- linux-davidm/arch/ia64/lib/swiotlb.c	Wed Dec 31 16:00:00 1969
+++ linux-2.4.0-test12-lia/arch/ia64/lib/swiotlb.c	Thu Dec 14 14:19:36 2000
@@ -0,0 +1,454 @@
+/*
+ * Dynamic DMA mapping support.
+ *
+ * This implementation is for IA-64 platforms that do not support
+ * I/O TLBs (aka DMA address translation hardware).
+ * Copyright (C) 2000 Asit Mallick <Asit.K.Mallick@intel.com>
+ * Copyright (C) 2000 Goutham Rao <goutham.rao@intel.com>
+ *
+ * 00/12/13 davidm	Rename to swiotlb.c and add mark_clean() to avoid
+ *			unnecessary i-cache flushing.
+ */
+
+#include <linux/config.h>
+
+#include <linux/mm.h>
+#include <linux/pci.h>
+#include <linux/spinlock.h>
+#include <linux/string.h>
+#include <linux/types.h>
+
+#include <asm/io.h>
+#include <asm/pci.h>
+#include <asm/dma.h>
+
+#include <linux/init.h>
+#include <linux/bootmem.h>
+
+#define ALIGN(val, align) ((unsigned long)	\
+	(((unsigned long) (val) + ((align) - 1)) & ~((align) - 1)))
+
+/*
+ * log of the size of each IO TLB slab.  The number of slabs is command li=
ne controllable.
+ */
+#define IO_TLB_SHIFT 11
+
+/*
+ * Used to do a quick range check in swiotlb_unmap_single and swiotlb_sync=
_single, to see
+ * if the memory was in fact allocated by this API.
+ */
+static char *io_tlb_start, *io_tlb_end;
+
+/*
+ * The number of IO TLB blocks (in groups of 64) betweeen io_tlb_start and=
 io_tlb_end.
+ * This is command line adjustable via setup_io_tlb_npages.
+ */
+static unsigned long io_tlb_nslabs =3D 1024;
+
+/*
+ * This is a free list describing the number of free entries available fro=
m each index
+ */
+static unsigned int *io_tlb_list;
+static unsigned int io_tlb_index;
+
+/*
+ * We need to save away the original address corresponding to a mapped ent=
ry for the sync=20
+ * operations.
+ */
+static unsigned char **io_tlb_orig_addr;
+
+/*
+ * Protect the above data structures in the map and unmap calls
+ */=20
+static spinlock_t io_tlb_lock =3D SPIN_LOCK_UNLOCKED;
+
+static int __init
+setup_io_tlb_npages (char *str)
+{
+	io_tlb_nslabs =3D simple_strtoul(str, NULL, 0) << (PAGE_SHIFT - IO_TLB_SH=
IFT);
+	return 1;
+}
+__setup("swiotlb=3D", setup_io_tlb_npages);
+
+/*
+ * Statically reserve bounce buffer space and initialize bounce buffer dat=
a structures for
+ * the software IO TLB used to implement the PCI DMA API.
+ */
+void
+swiotlb_init (void)
+{
+	int i;
+
+	/*
+	 * Get IO TLB memory from the low pages
+	 */
+	io_tlb_start =3D alloc_bootmem_low_pages(io_tlb_nslabs * (1 << IO_TLB_SHI=
FT));
+	if (!io_tlb_start)
+		BUG();
+	io_tlb_end =3D io_tlb_start + io_tlb_nslabs * (1 << IO_TLB_SHIFT);
+
+	/*
+	 * Allocate and initialize the free list array.  This array is used
+	 * to find contiguous free memory regions of size 2^IO_TLB_SHIFT between
+	 * io_tlb_start and io_tlb_end.
+	 */
+	io_tlb_list =3D alloc_bootmem(io_tlb_nslabs * sizeof(int));
+	for (i =3D 0; i < io_tlb_nslabs; i++)
+		io_tlb_list[i] =3D io_tlb_nslabs - i;
+	io_tlb_index =3D 0;
+	io_tlb_orig_addr =3D alloc_bootmem(io_tlb_nslabs * sizeof(char *));
+
+	printk("Placing software IO TLB between 0x%p - 0x%p\n",
+	       (void *) io_tlb_start, (void *) io_tlb_end);
+}
+
+/*
+ * Allocates bounce buffer and returns its kernel virtual address.
+ */
+static void *
+map_single (struct pci_dev *hwdev, char *buffer, size_t size, int directio=
n)
+{
+	unsigned long flags;
+	char *dma_addr;
+	unsigned int nslots, stride, index, wrap;
+	int i;
+
+	/*
+	 * For mappings greater than a page size, we limit the stride (and hence =
alignment)
+	 * to a page size.
+	 */
+	nslots =3D ALIGN(size, 1 << IO_TLB_SHIFT) >> IO_TLB_SHIFT;
+	if (size > (1 << PAGE_SHIFT))
+		stride =3D (1 << (PAGE_SHIFT - IO_TLB_SHIFT));
+	else
+		stride =3D nslots;
+
+	if (!nslots)
+		BUG();
+
+	/*
+	 * Find suitable number of IO TLB entries size that will fit this request=
 and
+	 * allocate a buffer from that IO TLB pool.
+	 */
+	spin_lock_irqsave(&io_tlb_lock, flags);
+	{
+		wrap =3D index =3D ALIGN(io_tlb_index, stride);
+
+		if (index >=3D io_tlb_nslabs)=20
+			wrap =3D index =3D 0;
+
+		do {
+			/*
+			 * If we find a slot that indicates we have 'nslots' number of
+			 * contiguous buffers, we allocate the buffers from that slot and
+			 * mark the entries as '0' indicating unavailable.
+			 */
+			if (io_tlb_list[index] >=3D nslots) {
+				int count =3D 0;
+
+				for (i =3D index; i < index + nslots; i++)
+					io_tlb_list[i] =3D 0;
+				for (i =3D index - 1; (i >=3D 0) && io_tlb_list[i]; i--)
+					io_tlb_list[i] =3D ++count;
+				dma_addr =3D io_tlb_start + (index << IO_TLB_SHIFT);
+
+				/*
+				 * Update the indices to avoid searching in the next round.
+				 */
+				io_tlb_index =3D ((index + nslots) < io_tlb_nslabs
+						? (index + nslots) : 0);
+
+				goto found;
+			}
+			index +=3D stride;
+			if (index >=3D io_tlb_nslabs)
+				index =3D 0;
+		} while (index !=3D wrap);
+
+		/*
+		 * XXX What is a suitable recovery mechanism here?  We cannot=20
+		 * sleep because we are called from with in interrupts!
+		 */
+		panic("map_single: could not allocate software IO TLB (%ld bytes)", size=
);
+found:
+	}
+	spin_unlock_irqrestore(&io_tlb_lock, flags);
+
+	/*
+	 * Save away the mapping from the original address to the DMA address.  T=
his is
+	 * needed when we sync the memory.  Then we sync the buffer if needed.
+	 */
+	io_tlb_orig_addr[index] =3D buffer;
+	if (direction =3D PCI_DMA_TODEVICE || direction =3D PCI_DMA_BIDIRECTIONAL)
+		memcpy(dma_addr, buffer, size);
+
+	return dma_addr;
+}
+
+/*
+ * dma_addr is the kernel virtual address of the bounce buffer to unmap.
+ */
+static void
+unmap_single (struct pci_dev *hwdev, char *dma_addr, size_t size, int dire=
ction)
+{
+	unsigned long flags;
+	int i, nslots =3D ALIGN(size, 1 << IO_TLB_SHIFT) >> IO_TLB_SHIFT;
+	int index =3D (dma_addr - io_tlb_start) >> IO_TLB_SHIFT;
+	char *buffer =3D io_tlb_orig_addr[index];
+
+	/*
+	 * First, sync the memory before unmapping the entry
+	 */
+	if ((direction =3D PCI_DMA_FROMDEVICE) || (direction =3D PCI_DMA_BIDIRECT=
IONAL))
+		/*
+ 	 	 * bounce... copy the data back into the original buffer * and delete =
the
+ 	 	 * bounce buffer.
+ 	 	 */
+		memcpy(buffer, dma_addr, size);
+
+	/*
+	 * Return the buffer to the free list by setting the corresponding entrie=
s to
+	 * indicate the number of contigous entries available.  While returning t=
he
+	 * entries to the free list, we merge the entries with slots below and ab=
ove the
+	 * pool being returned.
+	 */
+	spin_lock_irqsave(&io_tlb_lock, flags);
+	{
+		int count =3D ((index + nslots) < io_tlb_nslabs ? io_tlb_list[index + ns=
lots] : 0);
+		/*
+		 * Step 1: return the slots to the free list, merging the slots with
+		 * superceeding slots
+		 */
+		for (i =3D index + nslots - 1; i >=3D index; i--)
+			io_tlb_list[i] =3D ++count;
+		/*
+		 * Step 2: merge the returned slots with the preceeding slots, if
+		 * available (non zero)
+		 */
+		for (i =3D index - 1; (i >=3D 0) && io_tlb_list[i]; i--)
+			io_tlb_list[i] =3D ++count;
+	}
+	spin_unlock_irqrestore(&io_tlb_lock, flags);
+}
+
+static void
+sync_single (struct pci_dev *hwdev, char *dma_addr, size_t size, int direc=
tion)
+{
+	int index =3D (dma_addr - io_tlb_start) >> IO_TLB_SHIFT;
+	char *buffer =3D io_tlb_orig_addr[index];
+
+	/*
+  	 * bounce... copy the data back into/from the original buffer
+	 * XXX How do you handle PCI_DMA_BIDIRECTIONAL here ?
+ 	 */
+	if (direction =3D PCI_DMA_FROMDEVICE)
+		memcpy(buffer, dma_addr, size);
+	else if (direction =3D PCI_DMA_TODEVICE)
+		memcpy(dma_addr, buffer, size);
+	else
+		BUG();
+}
+
+void *
+swiotlb_alloc_consistent (struct pci_dev *hwdev, size_t size, dma_addr_t *=
dma_handle)
+{
+	unsigned long pci_addr;
+	int gfp =3D GFP_ATOMIC;
+	void *ret;
+
+	if (!hwdev || hwdev->dma_mask <=3D 0xffffffff)
+		gfp |=3D GFP_DMA; /* XXX fix me: should change this to GFP_32BIT or ZONE=
_32BIT */
+	ret =3D (void *)__get_free_pages(gfp, get_order(size));
+	if (!ret)
+		return NULL;
+
+	memset(ret, 0, size);
+	pci_addr =3D virt_to_phys(ret);
+	if ((pci_addr & ~hwdev->dma_mask) !=3D 0)
+		panic("swiotlb_alloc_consistent: allocated memory is out of range for PC=
I device");
+	*dma_handle =3D pci_addr;
+	return ret;
+}
+
+void
+swiotlb_free_consistent (struct pci_dev *hwdev, size_t size, void *vaddr, =
dma_addr_t dma_handle)
+{
+	free_pages((unsigned long) vaddr, get_order(size));
+}
+
+/*
+ * Map a single buffer of the indicated size for DMA in streaming mode.  T=
he PCI address
+ * to use is returned.
+ *
+ * Once the device is given the dma address, the device owns this memory u=
ntil either
+ * swiotlb_unmap_single or swiotlb_dma_sync_single is performed.
+ */
+dma_addr_t
+swiotlb_map_single (struct pci_dev *hwdev, void *ptr, size_t size, int dir=
ection)
+{
+	unsigned long pci_addr =3D virt_to_phys(ptr);
+
+	if (direction =3D PCI_DMA_NONE)
+		BUG();
+	/*
+	 * Check if the PCI device can DMA to ptr... if so, just return ptr
+	 */
+	if ((pci_addr & ~hwdev->dma_mask) =3D 0)
+		/*
+		 * Device is bit capable of DMA'ing to the buffer... just return the PCI
+		 * address of ptr
+		 */
+		return pci_addr;
+
+	/*=20
+	 * get a bounce buffer:=20
+	 */
+	pci_addr =3D virt_to_phys(map_single(hwdev, ptr, size, direction));
+
+	/*
+	 * Ensure that the address returned is DMA'ble:
+	 */
+	if ((pci_addr & ~hwdev->dma_mask) !=3D 0)
+		panic("map_single: bounce buffer is not DMA'ble");
+
+	return pci_addr;
+}
+
+/*
+ * Since DMA is i-cache coherent, any (complete) pages that were written v=
ia
+ * DMA can be marked as "clean" so that update_mmu_cache() doesn't have to
+ * flush them when they get mapped into an executable vm-area.
+ */
+static void
+mark_clean (void *addr, size_t size)
+{
+	unsigned long pg_addr, end;
+
+	pg_addr =3D PAGE_ALIGN((unsigned long) addr);
+	end =3D (unsigned long) addr + size;
+	while (pg_addr + PAGE_SIZE <=3D end) {
+		set_bit(PG_arch_1, virt_to_page(pg_addr));
+		pg_addr +=3D PAGE_SIZE;
+	}
+}
+
+/*
+ * Unmap a single streaming mode DMA translation.  The dma_addr and size m=
ust match what
+ * was provided for in a previous swiotlb_map_single call.  All other usag=
es are
+ * undefined.
+ *
+ * After this call, reads by the cpu to the buffer are guarenteed to see w=
hatever the
+ * device wrote there.
+ */
+void
+swiotlb_unmap_single (struct pci_dev *hwdev, dma_addr_t pci_addr, size_t s=
ize, int direction)
+{
+	char *dma_addr =3D phys_to_virt(pci_addr);
+
+	if (direction =3D PCI_DMA_NONE)
+		BUG();
+	if (dma_addr >=3D io_tlb_start && dma_addr < io_tlb_end)
+		unmap_single(hwdev, dma_addr, size, direction);
+	else if (direction =3D PCI_DMA_FROMDEVICE)
+		mark_clean(dma_addr, size);
+}
+
+/*
+ * Make physical memory consistent for a single streaming mode DMA transla=
tion after a
+ * transfer.
+ *
+ * If you perform a swiotlb_map_single() but wish to interrogate the buffe=
r using the cpu,
+ * yet do not wish to teardown the PCI dma mapping, you must call this fun=
ction before
+ * doing so.  At the next point you give the PCI dma address back to the c=
ard, the device
+ * again owns the buffer.
+ */
+void
+swiotlb_sync_single (struct pci_dev *hwdev, dma_addr_t pci_addr, size_t si=
ze, int direction)
+{
+	char *dma_addr =3D phys_to_virt(pci_addr);
+
+	if (direction =3D PCI_DMA_NONE)
+		BUG();
+	if (dma_addr >=3D io_tlb_start && dma_addr < io_tlb_end)
+		sync_single(hwdev, dma_addr, size, direction);
+	else if (direction =3D PCI_DMA_FROMDEVICE)
+		mark_clean(dma_addr, size);
+}
+
+/*
+ * Map a set of buffers described by scatterlist in streaming mode for DMA=
.  This is the
+ * scather-gather version of the above swiotlb_map_single interface.  Here=
 the scatter
+ * gather list elements are each tagged with the appropriate dma address a=
nd length.  They
+ * are obtained via sg_dma_{address,length}(SG).
+ *
+ * NOTE: An implementation may be able to use a smaller number of
+ *       DMA address/length pairs than there are SG table elements.
+ *       (for example via virtual mapping capabilities)
+ *       The routine returns the number of addr/length pairs actually
+ *       used, at most nents.
+ *
+ * Device ownership issues as mentioned above for swiotlb_map_single are t=
he same here.
+ */
+int
+swiotlb_map_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nelems,=
 int direction)
+{
+	int i;
+
+	if (direction =3D PCI_DMA_NONE)
+		BUG();
+
+	for (i =3D 0; i < nelems; i++, sg++) {
+		sg->orig_address =3D sg->address;
+		if ((virt_to_phys(sg->address) & ~hwdev->dma_mask) !=3D 0) {
+			sg->address =3D map_single(hwdev, sg->address, sg->length,
+							 direction);
+		}
+	}
+	return nelems;
+}
+
+/*
+ * Unmap a set of streaming mode DMA translations.  Again, cpu read rules =
concerning calls
+ * here are the same as for swiotlb_unmap_single() above.
+ */
+void
+swiotlb_unmap_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nelem=
s, int direction)
+{
+	int i;
+
+	if (direction =3D PCI_DMA_NONE)
+		BUG();
+
+	for (i =3D 0; i < nelems; i++, sg++)
+		if (sg->orig_address !=3D sg->address) {
+			unmap_single(hwdev, sg->address, sg->length, direction);
+			sg->address =3D sg->orig_address;
+		} else if (direction =3D PCI_DMA_FROMDEVICE)
+			mark_clean(sg->address, sg->length);
+}
+
+/*
+ * Make physical memory consistent for a set of streaming mode DMA transla=
tions after a
+ * transfer.
+ *
+ * The same as swiotlb_dma_sync_single but for a scatter-gather list, same=
 rules and
+ * usage.
+ */
+void
+swiotlb_sync_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nelems=
, int direction)
+{
+	int i;
+
+	if (direction =3D PCI_DMA_NONE)
+		BUG();
+
+	for (i =3D 0; i < nelems; i++, sg++)
+		if (sg->orig_address !=3D sg->address)
+			sync_single(hwdev, sg->address, sg->length, direction);
+}
+
+unsigned long
+swiotlb_dma_address (struct scatterlist *sg)
+{
+	return virt_to_phys(sg->address);
+}
diff -urN linux-davidm/arch/ia64/mm/init.c linux-2.4.0-test12-lia/arch/ia64=
/mm/init.c
--- linux-davidm/arch/ia64/mm/init.c	Thu Dec 14 19:58:05 2000
+++ linux-2.4.0-test12-lia/arch/ia64/mm/init.c	Thu Dec 14 14:36:33 2000
@@ -1,8 +1,8 @@
 /*
  * Initialize MMU support.
  *
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2000 Hewlett-Packard Co
+ * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #include <linux/config.h>
 #include <linux/kernel.h>
@@ -19,6 +19,7 @@
 #include <asm/efi.h>
 #include <asm/ia32.h>
 #include <asm/io.h>
+#include <asm/machvec.h>
 #include <asm/pgalloc.h>
 #include <asm/sal.h>
 #include <asm/system.h>
@@ -428,17 +429,15 @@
 	extern char __start_gate_section[];
 	long reserved_pages, codesize, datasize, initsize;
=20
-#ifdef CONFIG_SWIOTLB
-	{
-		/*
-		 * This needs to be called _after_ the command line has been parsed but
-		 * _before_ any drivers that may need the sw I/O TLB are initialized or
-		 * bootmem has been freed.
-		 */
-		extern void setup_swiotlb (void);
-		setup_swiotlb();
-	}
+#ifdef CONFIG_PCI
+	/*
+	 * This needs to be called _after_ the command line has been parsed but _=
before_
+	 * any drivers that may need the PCI DMA interface are initialized or boo=
tmem has
+	 * been freed.
+	 */
+	platform_pci_dma_init();
 #endif
+
 	if (!mem_map)
 		BUG();
=20
diff -urN linux-davidm/arch/ia64/sn/fprom/fpmem.c linux-2.4.0-test12-lia/ar=
ch/ia64/sn/fprom/fpmem.c
--- linux-davidm/arch/ia64/sn/fprom/fpmem.c	Thu Dec 14 19:58:05 2000
+++ linux-2.4.0-test12-lia/arch/ia64/sn/fprom/fpmem.c	Wed Dec 13 18:59:33 2=
000
@@ -176,7 +176,7 @@
                                 if (bank =3D 0) {
 					hole =3D (cnode =3D 0) ? KERNEL_SIZE : PROMRESERVED_SIZE;
 					numbytes -=3D hole;
-                                        build_mem_desc(md, EFI_RUNTIME_SER=
VICES_CODE, paddr, hole);
+                                        build_mem_desc(md, EFI_RUNTIME_SER=
VICES_DATA, paddr, hole);
                                         paddr +=3D hole;
 			        	count++ ;
                                         md +=3D mdsize;
diff -urN linux-davidm/arch/ia64/sn/fprom/fw-emu.c linux-2.4.0-test12-lia/a=
rch/ia64/sn/fprom/fw-emu.c
--- linux-davidm/arch/ia64/sn/fprom/fw-emu.c	Thu Dec 14 19:58:05 2000
+++ linux-2.4.0-test12-lia/arch/ia64/sn/fprom/fw-emu.c	Wed Dec 13 18:59:33 =
2000
@@ -379,6 +379,9 @@
=20
 	memcpy(acpi_rsdt->header.signature, "RSDT",4);
 	acpi_rsdt->header.length =3D sizeof(acpi_rsdt_t);
+	memcpy(acpi_rsdt->header.oem_id, "SGI", 3);
+	memcpy(acpi_rsdt->header.oem_table_id, "SN1", 3);
+	acpi_rsdt->header.oem_revision =3D 0x00010001;
 	acpi_rsdt->entry_ptrs[0] =3D __fwtab_pa(base_nasid, acpi_sapic);
=20
 	memcpy(acpi_sapic->header.signature, "SPIC ", 4);
@@ -407,7 +410,7 @@
 	sal_systab->entry_count =3D 3;
=20
 	strcpy(sal_systab->oem_id, "SGI");
-	strcpy(sal_systab->product_id, "sn1");
+	strcpy(sal_systab->product_id, "SN1");
=20
 	/* fill in an entry point: */=09
 	sal_ed->type =3D SAL_DESC_ENTRY_POINT;
@@ -464,7 +467,7 @@
 	bp->efi_memmap =3D __fwtab_pa(base_nasid, efi_memmap);
 	bp->efi_memmap_size =3D num_memmd*mdsize;
 	bp->efi_memdesc_size =3D mdsize;
-	bp->efi_memdesc_version =3D 1;
+	bp->efi_memdesc_version =3D 0x101;
 	bp->command_line =3D __fwtab_pa(base_nasid, cmd_line);
 	bp->console_info.num_cols =3D 80;
 	bp->console_info.num_rows =3D 25;
diff -urN linux-davidm/arch/ia64/sn/io/klgraph_hack.c linux-2.4.0-test12-li=
a/arch/ia64/sn/io/klgraph_hack.c
--- linux-davidm/arch/ia64/sn/io/klgraph_hack.c	Thu Dec 14 19:58:05 2000
+++ linux-2.4.0-test12-lia/arch/ia64/sn/io/klgraph_hack.c	Wed Dec 13 18:59:=
33 2000
@@ -139,11 +139,12 @@
 	uint64_t	*tmp;
 	volatile u32	*tmp32;
=20
+#ifdef 0
 	/* Preset some values */
 	/* Write IOERR clear to clear the CRAZY bit in the status */
 	tmp =3D (uint64_t *)0xc0000a0001c001f8; *tmp =3D (uint64_t)0xffffffff;
 	/* set widget control register...setting bedrock widget id to b */
-	tmp =3D (uint64_t *)0xc0000a0001c00020; *tmp =3D (uint64_t)0x801b;
+	/* tmp =3D (uint64_t *)0xc0000a0001c00020; *tmp =3D (uint64_t)0x801b; */
 	/* set io outbound widget access...allow all */
 	tmp =3D (uint64_t *)0xc0000a0001c00110; *tmp =3D (uint64_t)0xff01;
 	/* set io inbound widget access...allow all */
@@ -163,6 +164,7 @@
 	*tmp32 =3D 0xba98;
 	tmp32 =3D (volatile u32 *)0xc0000a000f000288L;
 	*tmp32 =3D 0xba98;
+#endif
=20
 printk("Widget ID Address 0x%p Value 0x%lx\n", (uint64_t *)0xc0000a0001e00=
000, *( (volatile uint64_t *)0xc0000a0001e00000) );
=20
diff -urN linux-davidm/arch/ia64/sn/io/ml_SN_intr.c linux-2.4.0-test12-lia/=
arch/ia64/sn/io/ml_SN_intr.c
--- linux-davidm/arch/ia64/sn/io/ml_SN_intr.c	Thu Dec 14 19:58:06 2000
+++ linux-2.4.0-test12-lia/arch/ia64/sn/io/ml_SN_intr.c	Wed Dec 13 18:59:33=
 2000
@@ -19,6 +19,7 @@
 #include <linux/types.h>
 #include <linux/config.h>
 #include <linux/slab.h>
+#include <asm/smp.h>
 #include <asm/sn/sgi.h>
 #include <asm/sn/iograph.h>
 #include <asm/sn/invent.h>
@@ -678,6 +679,7 @@
 		int local_cpu_num;
=20
 		cpu =3D cnode_slice_to_cpuid(cnode, slice);
+		cpu =3D cpu_logical_id(cpu);
 		if (cpu =3D CPU_NONE)
 			continue;
=20
diff -urN linux-davidm/arch/ia64/sn/io/pci_bus_cvlink.c linux-2.4.0-test12-=
lia/arch/ia64/sn/io/pci_bus_cvlink.c
--- linux-davidm/arch/ia64/sn/io/pci_bus_cvlink.c	Thu Dec 14 19:58:06 2000
+++ linux-2.4.0-test12-lia/arch/ia64/sn/io/pci_bus_cvlink.c	Wed Dec 13 18:5=
9:33 2000
@@ -8,9 +8,11 @@
  * Copyright (C) 2000 by Colin Ngam
  */
=20
+#include <linux/init.h>
 #include <linux/types.h>
 #include <linux/config.h>
 #include <linux/pci.h>
+#include <linux/pci_ids.h>
 #include <linux/sched.h>
 #include <linux/ioport.h>
 #include <asm/sn/types.h>
@@ -149,6 +151,34 @@
 }
=20
 /*
+ * Most drivers currently do not properly tell the arch specific pci dma
+ * interfaces whether they can handle A64. Here is where we privately
+ * keep track of this.
+ */
+static void __init
+set_sn1_pci64(struct pci_dev *dev)
+{
+	unsigned short vendor =3D dev->vendor;
+	unsigned short device =3D dev->device;
+
+	if (vendor =3D PCI_VENDOR_ID_QLOGIC) {
+		if ((device =3D PCI_DEVICE_ID_QLOGIC_ISP2100) ||
+				(device =3D PCI_DEVICE_ID_QLOGIC_ISP2200)) {
+			SET_PCIA64(dev);
+			return;
+		}
+	}
+
+	if (vendor =3D PCI_VENDOR_ID_SGI) {
+		if (device =3D PCI_DEVICE_ID_SGI_IOC3) {
+			SET_PCIA64(dev);
+			return;
+		}
+	}
+
+}
+
+/*
  * sn1_pci_fixup() - This routine is called when platform_pci_fixup() is=20
  *	invoked at the end of pcibios_init() to link the Linux pci=20
  *	infrastructure to SGI IO Infrasturcture - ia64/kernel/pci.c
@@ -172,6 +202,7 @@
 		sn1_pci_find_bios();
 		return;
 	}
+
 #if 0
 {
         devfs_handle_t  bridge_vhdl =3D pci_bus_to_vertex(0);
@@ -236,7 +267,9 @@
 		device_sysdata =3D kmalloc(sizeof(struct sn1_device_sysdata),
 					GFP_KERNEL);
 		device_sysdata->vhdl =3D devfn_to_vertex(device_dev->bus->number, device=
_dev->devfn);
+		device_sysdata->isa64 =3D 0;
 		device_dev->sysdata =3D (void *) device_sysdata;
+		set_sn1_pci64(device_dev);
 		pci_read_config_word(device_dev, PCI_COMMAND, &cmd);
=20
 		/*
diff -urN linux-davidm/arch/ia64/sn/io/pci_dma.c linux-2.4.0-test12-lia/arc=
h/ia64/sn/io/pci_dma.c
--- linux-davidm/arch/ia64/sn/io/pci_dma.c	Thu Dec 14 19:58:06 2000
+++ linux-2.4.0-test12-lia/arch/ia64/sn/io/pci_dma.c	Wed Dec 13 18:59:33 20=
00
@@ -1,5 +1,4 @@
-/* $Id$
- *
+/*
  * This file is subject to the terms and conditions of the GNU General Pub=
lic
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
@@ -12,6 +11,18 @@
 #include <linux/mm.h>
 #include <linux/string.h>
 #include <linux/pci.h>
+#include <linux/slab.h>
+#include <linux/devfs_fs_kernel.h>
+
+#ifndef LANGUAGE_C=20
+#define LANGUAGE_C 99
+#endif
+#ifndef _LANGUAGE_C
+#define _LANGUAGE_C 99
+#endif
+#ifndef CONFIG_IA64_SGI_IO
+#define CONFIG_IA64_SGI_IO 99
+#endif
=20
 #include <asm/io.h>
 #include <asm/sn/sgi.h>
@@ -20,11 +31,27 @@
 #include <asm/sn/pci/pcibr.h>
 #include <asm/sn/pci/pcibr_private.h>
 #include <asm/sn/iobus.h>
+#include <asm/sn/pci/pci_bus_cvlink.h>
+#include <asm/sn/types.h>
+#include <asm/sn/sgi.h>
+#include <asm/sn/invent.h>
+#include <asm/sn/hcl.h>
+#include <asm/sn/pci/pcibr.h>
+#include <asm/sn/pci/pcibr_private.h>
+#include <asm/sn/alenlist.h>
=20
-#ifdef BRINGUP
-#ifndef BRIDGE_DIRECT_MAP_DMA
-#define BRIDGE_DIRECT_MAP_DMA 0xb180000000000000ull
+/*
+ * this is REALLY ugly, blame it on gcc's lame inlining that we
+ * have to put procedures in header files
+ */
+#if LANGUAGE_C =3D 99
+#undef LANGUAGE_C
 #endif
+#if _LANGUAGE_C =3D 99
+#undef _LANGUAGE_C
+#endif
+#if CONFIG_IA64_SGI_IO =3D 99
+#undef CONFIG_IA64_SGI_IO
 #endif
=20
 /*
@@ -40,37 +67,267 @@
         void *ret;
         int gfp =3D GFP_ATOMIC;
 	devfs_handle_t    vhdl;
-        unsigned char   slot;
+	struct sn1_device_sysdata *device_sysdata;
+	paddr_t temp_ptr;
+
+	*dma_handle =3D (dma_addr_t) NULL;
=20
 	/*
 	 * get vertex for the device
 	 */
-	vhdl =3D (devfs_handle_t) hwdev->sysdata;
-	slot =3D PCI_SLOT(hwdev->devfn);
+	device_sysdata =3D (struct sn1_device_sysdata *) hwdev->sysdata;
+	vhdl =3D device_sysdata->vhdl;
+
+        if ( ret =3D (void *)__get_free_pages(gfp, get_order(size)) ) {
+		memset(ret, 0, size);
+	} else {
+		return(NULL);
+	}
+
+	temp_ptr =3D (paddr_t) __pa(ret);
+	if (IS_PCIA64(hwdev)) {
+
+		/*
+		 * This device supports 64bits DMA addresses.
+		 */
+		*dma_handle =3D pciio_dmatrans_addr(vhdl, NULL, temp_ptr, size,
+			PCIBR_BARRIER | PCIIO_BYTE_STREAM | PCIIO_DMA_CMD
+			| PCIIO_DMA_A64 );
+		return (ret);
+	}
=20
 	/*
-	 * any device that can't dma into a 32 bit address space
-	 * really has no business in this system, but we'll do
- 	 * what we can..
-	 */
-        if (!hwdev || hwdev->dma_mask !=3D 0xffffffff)
-                gfp |=3D GFP_DMA;
-        ret =3D (void *)__get_free_pages(gfp, get_order(size));
-
-#ifdef BRINGUP
-	printk("%s : FIXME: not doing busaddr\n", __FUNCTION__);
-	if (ret) {
-                memset(ret, 0, size);
-		*dma_handle =3D __pa(ret) | BRIDGE_DIRECT_MAP_DMA;
-	}
-#else
-        if (ret) {
-                memset(ret, 0, size);
-	=09
-                *dma_handle =3D pciio_dmatrans_addr(vhdl, NULL, (paddr_t)r=
et, size,=20
+	 * Devices that supports 32 Bits upto 63 Bits DMA Address gets
+	 * 32 Bits DMA addresses.
+	 *
+	 * First try to get 32 Bit Direct Map Support.
+	 */
+	if (IS_PCI32G(hwdev)) {
+		*dma_handle =3D pciio_dmatrans_addr(vhdl, NULL, temp_ptr, size,
+			PCIBR_BARRIER | PCIIO_BYTE_STREAM | PCIIO_DMA_CMD);
+		if (dma_handle) {
+			return (ret);
+		} else {
+			/*
+			 * We need to map this request by using ATEs.
+			 */
+			printk("sn1_pci_alloc_consistent: 32Bits DMA Page Map support not avail=
able yet!");
+			BUG();
+		}
+	}
+
+	if (IS_PCI32L(hwdev)) {
+		/*
+		 * SNIA64 cannot support DMA Addresses smaller than 32 bits.
+		 */
+		return (NULL);
+	}
+
+        return NULL;
+}
+
+void
+sn1_pci_free_consistent(struct pci_dev *hwdev, size_t size, void *vaddr, d=
ma_addr_t dma_handle)
+{
+	free_pages((unsigned long) vaddr, get_order(size));
+}
+
+/*
+ * On sn1 we use the alt_address entry of the scatterlist to store
+ * the physical address corresponding to the given virtual address
+ */
+int
+sn1_pci_map_sg (struct pci_dev *hwdev,
+                        struct scatterlist *sg, int nents, int direction)
+{
+
+	int i;
+	devfs_handle_t	vhdl;
+	dma_addr_t dma_addr;
+	paddr_t temp_ptr;
+	struct sn1_device_sysdata *device_sysdata;
+
+
+	if (direction =3D PCI_DMA_NONE)
+		BUG();
+
+	/*
+	 * Handle 64 bit cards.
+	 */
+	device_sysdata =3D (struct sn1_device_sysdata *) hwdev->sysdata;
+	vhdl =3D device_sysdata->vhdl;
+	for (i =3D 0; i < nents; i++, sg++) {
+		sg->orig_address =3D sg->address;
+		dma_addr =3D 0;
+		temp_ptr =3D (paddr_t) __pa(sg->address);
+
+		/*
+		 * Handle the most common case 64Bit cards.
+		 */
+		if (IS_PCIA64(hwdev)) {
+			dma_addr =3D (dma_addr_t) pciio_dmatrans_addr(vhdl, NULL,
+				temp_ptr, sg->length,
+				PCIBR_BARRIER | PCIIO_BYTE_STREAM |
+				PCIIO_DMA_CMD | PCIIO_DMA_A64 );
+			sg->address =3D (char *)dma_addr;
+/* printk("pci_map_sg: 64Bits hwdev %p DMA Address 0x%p alt_address 0x%p o=
rig_address 0x%p length 0x%x\n", hwdev, sg->address, sg->alt_address, sg->o=
rig_address, sg->length); */
+			continue;
+		}
+
+		/*
+		 * Handle 32Bits and greater cards.
+		 */
+		if (IS_PCI32G(hwdev)) {
+			dma_addr =3D (dma_addr_t) pciio_dmatrans_addr(vhdl, NULL,
+				temp_ptr, sg->length,
+				PCIBR_BARRIER | PCIIO_BYTE_STREAM |
 				PCIIO_DMA_CMD);
-        }
-#endif /* BRINGUP */
-        return ret;
+			if (dma_addr) {
+				sg->address =3D (char *)dma_addr;
+/* printk("pci_map_single: 32Bit direct pciio_dmatrans_addr pcidev %p retu=
rns dma_addr 0x%lx\n", hwdev, dma_addr); */
+				continue;
+			} else {
+				/*
+				 * We need to map this request by using ATEs.
+				 */
+				printk("pci_map_single: 32Bits DMA Page Map support not available yet!=
");
+				BUG();
+
+			}
+		}
+	}
+
+	return nents;
+
+}
+
+/*
+ * Unmap a set of streaming mode DMA translations.
+ * Again, cpu read rules concerning calls here are the same as for
+ * pci_unmap_single() above.
+ */
+void
+sn1_pci_unmap_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nelem=
s, int direction)
+{
+	int i;
+
+	if (direction =3D PCI_DMA_NONE)
+		BUG();
+	for (i =3D 0; i < nelems; i++, sg++)
+		if (sg->orig_address !=3D sg->address) {
+			/* phys_to_virt((dma_addr_t)sg->address | ~0x80000000); */
+			sg->address =3D sg->orig_address;
+			sg->orig_address =3D 0;
+		}
+}
+
+/*
+ * We map this to the one step pciio_dmamap_trans interface rather than
+ * the two step pciio_dmamap_alloc/pciio_dmamap_addr because we have
+ * no way of saving the dmamap handle from the alloc to later free
+ * (which is pretty much unacceptable).
+ *
+ * TODO: simplify our interface;
+ *       get rid of dev_desc and vhdl (seems redundant given a pci_dev);
+ *       figure out how to save dmamap handle so can use two step.
+ */
+dma_addr_t sn1_pci_map_single (struct pci_dev *hwdev,
+				void *ptr, size_t size, int direction)
+{
+	devfs_handle_t	vhdl;
+	dma_addr_t dma_addr;
+	paddr_t temp_ptr;
+	struct sn1_device_sysdata *device_sysdata;
+
+
+	if (direction =3D PCI_DMA_NONE)
+		BUG();
+
+	if (IS_PCI32L(hwdev)) {
+		/*
+		 * SNIA64 cannot support DMA Addresses smaller than 32 bits.
+		 */
+		return ((dma_addr_t) NULL);
+	}
+
+	/*
+	 * find vertex for the device
+	 */
+	device_sysdata =3D (struct sn1_device_sysdata *)hwdev->sysdata;
+	vhdl =3D device_sysdata->vhdl;
+/* printk("pci_map_single: Called vhdl =3D 0x%p ptr =3D 0x%p size =3D %d\n=
", vhdl, ptr, size); */
+	/*
+	 * Call our dmamap interface
+	 */
+	dma_addr =3D 0;
+	temp_ptr =3D (paddr_t) __pa(ptr);
+
+	if (IS_PCIA64(hwdev)) {
+		/*
+		 * This device supports 64bits DMA addresses.
+		 */
+		dma_addr =3D (dma_addr_t) pciio_dmatrans_addr(vhdl, NULL,
+			temp_ptr, size,
+			PCIBR_BARRIER | PCIIO_BYTE_STREAM | PCIIO_DMA_CMD
+			| PCIIO_DMA_A64 );
+/* printk("pci_map_single: 64Bit pciio_dmatrans_addr pcidev %p returns dma=
_addr 0x%lx\n", hwdev, dma_addr); */
+		return (dma_addr);
+	}
+
+	/*
+	 * Devices that supports 32 Bits upto 63 Bits DMA Address gets
+	 * 32 Bits DMA addresses.
+	 *
+	 * First try to get 32 Bit Direct Map Support.
+	 */
+	if (IS_PCI32G(hwdev)) {
+		dma_addr =3D (dma_addr_t) pciio_dmatrans_addr(vhdl, NULL,
+			temp_ptr, size,
+			PCIBR_BARRIER | PCIIO_BYTE_STREAM | PCIIO_DMA_CMD);
+		if (dma_addr) {
+/* printk("pci_map_single: 32Bit direct pciio_dmatrans_addr pcidev %p retu=
rns dma_addr 0x%lx\n", hwdev, dma_addr); */
+			return (dma_addr);
+		} else {
+			/*
+			 * We need to map this request by using ATEs.
+			 */
+			printk("pci_map_single: 32Bits DMA Page Map support not available yet!"=
);
+			BUG();
+		}
+	}
+
+	if (IS_PCI32L(hwdev)) {
+		/*
+		 * SNIA64 cannot support DMA Addresses smaller than 32 bits.
+		 */
+		return ((dma_addr_t) NULL);
+	}
+
+	return ((dma_addr_t) NULL);
+
+}
+
+void
+sn1_pci_unmap_single (struct pci_dev *hwdev, dma_addr_t dma_addr, size_t s=
ize, int direction)
+{
+        if (direction =3D PCI_DMA_NONE)
+                BUG();
+        /* Nothing to do */
+}
+
+void
+sn1_pci_dma_sync_single (struct pci_dev *hwdev, dma_addr_t dma_handle, siz=
e_t size, int direction)
+{
+        if (direction =3D PCI_DMA_NONE)
+                BUG();
+        /* Nothing to do */
+}
+
+void
+sn1_pci_dma_sync_sg (struct pci_dev *hwdev, struct scatterlist *sg, int ne=
lems, int direction)
+{
+        if (direction =3D PCI_DMA_NONE)
+                BUG();
+        /* Nothing to do */
 }
=20
diff -urN linux-davidm/arch/ia64/sn/sn1/sn1_asm.S linux-2.4.0-test12-lia/ar=
ch/ia64/sn/sn1/sn1_asm.S
--- linux-davidm/arch/ia64/sn/sn1/sn1_asm.S	Thu Dec 14 19:58:06 2000
+++ linux-2.4.0-test12-lia/arch/ia64/sn/sn1/sn1_asm.S	Wed Dec 13 18:59:33 2=
000
@@ -6,22 +6,3 @@
=20
 #include <linux/config.h>
=20
-#ifdef CONFIG_IA64_SGI_SYNERGY_1_0_HACKS
-// Code to work around a SYNERGY 1.0 bug.
-
-	.align 16
-	.global enable_fsb_hack
-	.proc enable_fsb_hack
-enable_fsb_hack:
-	movl	r16=3D0xe000000000000000
-	movl	r17=3D0x4ffffffff0000000		/* only trap 0-256MB: covered by DTR0 */
-	mov	r20=3D0
-	mov	r21=3D1
-	;;
-	mov	dbr[r20]=3Dr16
-	mov	dbr[r21]=3Dr17
-	;;
-	srlz.d
-	br.ret.sptk.few rp
-	.endp enable_fsb_hack
-#endif /* CONFIG_IA64_SGI_SYNERGY_1_0_HACKS */
diff -urN linux-davidm/drivers/net/eepro100.c linux-2.4.0-test12-lia/driver=
s/net/eepro100.c
--- linux-davidm/drivers/net/eepro100.c	Thu Dec 14 19:58:06 2000
+++ linux-2.4.0-test12-lia/drivers/net/eepro100.c	Thu Dec 14 14:42:16 2000
@@ -43,7 +43,7 @@
 static int txdmacount =3D 128;
 static int rxdmacount /* =3D 0 */;
=20
-#ifdef __ia64__
+#if defined(__ia64__) || defined(__alpha__) || defined(__sparc__)
   /* align rx buffers to 2 bytes so that IP header is aligned */
 # define RX_ALIGN
 # define RxFD_ALIGNMENT		__attribute__ ((aligned (2), packed))
@@ -53,11 +53,7 @@
=20
 /* Set the copy breakpoint for the copy-only-tiny-buffer Rx method.
    Lower values use more memory, but are faster. */
-#if defined(__alpha__) || defined(__sparc__)
-static int rx_copybreak =3D 1518;
-#else
 static int rx_copybreak =3D 200;
-#endif
=20
 /* Maximum events (Rx packets, etc.) to handle at each interrupt. */
 static int max_interrupt_work =3D 20;
diff -urN linux-davidm/drivers/scsi/qla1280.c linux-2.4.0-test12-lia/driver=
s/scsi/qla1280.c
--- linux-davidm/drivers/scsi/qla1280.c	Thu Dec 14 19:58:06 2000
+++ linux-2.4.0-test12-lia/drivers/scsi/qla1280.c	Thu Dec 14 14:42:57 2000
@@ -242,9 +242,6 @@
 STATIC void qla1280_removeq(scsi_lu_t *q, srb_t *sp);
 STATIC void qla1280_mem_free(scsi_qla_host_t *ha);
 static void qla1280_do_dpc(void *p);
-#ifdef  QLA1280_UNUSED=20
-static void qla1280_set_flags(char * s);
-#endif
 static char	*qla1280_get_token(char *, char *);
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,1,0)
 STATIC inline void mdelay(int);
diff -urN linux-davidm/drivers/usb/uhci.c linux-2.4.0-test12-lia/drivers/us=
b/uhci.c
--- linux-davidm/drivers/usb/uhci.c	Thu Dec 14 19:58:06 2000
+++ linux-2.4.0-test12-lia/drivers/usb/uhci.c	Thu Dec 14 14:43:23 2000
@@ -71,46 +71,6 @@
 /* If a transfer is still active after this much time, turn off FSBR */
 #define IDLE_TIMEOUT	(HZ / 20)	/* 50 ms */
=20
-#ifdef CONFIG_ITANIUM_A1_SPECIFIC
-
-static struct uhci *guhci;
-
-void
-disable_usb (void)
-{
-	unsigned short cmd;
-	unsigned int io_addr;
-
-	if (guhci =3D NULL)
-		return;
-
-	io_addr =3D guhci->io_addr;
-
-	cmd =3D inw (io_addr + USBCMD);=20
-
-	outw(cmd & ~ USBCMD_RS, io_addr+USBCMD);
-
-	while ((inw (io_addr + USBSTS) & USBSTS_HCH) =3D 0);
-}
-
-void
-reenable_usb (void)
-{
-	unsigned int io_addr;
-	unsigned short cmd;
-
-	if (guhci =3D NULL)
-		return;
-
-	io_addr =3D guhci->io_addr;
-
-	cmd =3D inw (io_addr + USBCMD);=20
-
-	outw(cmd | USBCMD_RS, io_addr+USBCMD);
-}
-
-#endif /* CONFIG_ITANIUM_A1_SPECIFIC */
-
 /*
  * Only the USB core should call uhci_alloc_dev and uhci_free_dev
  */
diff -urN linux-davidm/fs/partitions/check.c linux-2.4.0-test12-lia/fs/part=
itions/check.c
--- linux-davidm/fs/partitions/check.c	Thu Dec 14 19:58:06 2000
+++ linux-2.4.0-test12-lia/fs/partitions/check.c	Thu Dec 14 14:43:39 2000
@@ -32,7 +32,10 @@
 #include "sun.h"
 #include "ibm.h"
 #include "ultrix.h"
-#include "efi.h"
+
+#ifdef CONFIG_EFI_PARTITION
+# include "efi.h"
+#endif
=20
 extern void device_init(void);
 extern int *blk_size[];
diff -urN linux-davidm/include/asm-ia64/hw_irq.h linux-2.4.0-test12-lia/inc=
lude/asm-ia64/hw_irq.h
--- linux-davidm/include/asm-ia64/hw_irq.h	Thu Dec 14 19:58:06 2000
+++ linux-2.4.0-test12-lia/include/asm-ia64/hw_irq.h	Thu Dec 14 14:43:48 20=
00
@@ -8,6 +8,7 @@
=20
 #include <linux/config.h>
=20
+#include <linux/sched.h>
 #include <linux/types.h>
=20
 #include <asm/machvec.h>
diff -urN linux-davidm/include/asm-ia64/machvec.h linux-2.4.0-test12-lia/in=
clude/asm-ia64/machvec.h
--- linux-davidm/include/asm-ia64/machvec.h	Thu Dec 14 19:58:06 2000
+++ linux-2.4.0-test12-lia/include/asm-ia64/machvec.h	Thu Dec 14 14:44:03 2=
000
@@ -14,14 +14,9 @@
 #include <linux/types.h>
=20
 /* forward declarations: */
-struct hw_interrupt_type;
-struct irq_desc;
-struct mm_struct;
+struct pci_dev;
 struct pt_regs;
-struct task_struct;
-struct timeval;
-struct vm_area_struct;
-struct acpi_entry_iosapic;
+struct scatterlist;
=20
 typedef void ia64_mv_setup_t (char **);
 typedef void ia64_mv_irq_init_t (void);
@@ -32,6 +27,18 @@
 typedef void ia64_mv_cmci_handler_t (int, void *, struct pt_regs *);
 typedef void ia64_mv_log_print_t (void);
 typedef void ia64_mv_send_ipi_t (int, int, int, int);
+
+/* PCI-DMA interface: */
+typedef void ia64_mv_pci_dma_init (void);
+typedef void *ia64_mv_pci_alloc_consistent (struct pci_dev *, size_t, dma_=
addr_t *);
+typedef void ia64_mv_pci_free_consistent (struct pci_dev *, size_t, void *=
, dma_addr_t);
+typedef dma_addr_t ia64_mv_pci_map_single (struct pci_dev *, void *, size_=
t, int);
+typedef void ia64_mv_pci_unmap_single (struct pci_dev *, dma_addr_t, size_=
t, int);
+typedef int ia64_mv_pci_map_sg (struct pci_dev *, struct scatterlist *, in=
t, int);
+typedef void ia64_mv_pci_unmap_sg (struct pci_dev *, struct scatterlist *,=
 int, int);
+typedef void ia64_mv_pci_dma_sync_single (struct pci_dev *, dma_addr_t, si=
ze_t, int);
+typedef void ia64_mv_pci_dma_sync_sg (struct pci_dev *, struct scatterlist=
 *, int, int);
+typedef unsigned long ia64_mv_pci_dma_address (struct scatterlist *);
 /*
  * WARNING: The legacy I/O space is _architected_.  Platforms are
  * expected to follow this architected model (see Section 10.7 in the
@@ -71,6 +78,16 @@
 #  define platform_log_print	ia64_mv.log_print
 #  define platform_pci_fixup	ia64_mv.pci_fixup
 #  define platform_send_ipi	ia64_mv.send_ipi
+#  define platform_pci_dma_init		ia64_mv.dma_init
+#  define platform_pci_alloc_consistent	ia64_mv.alloc_consistent
+#  define platform_pci_free_consistent	ia64_mv.free_consistent
+#  define platform_pci_map_single	ia64_mv.map_single
+#  define platform_pci_unmap_single	ia64_mv.unmap_single
+#  define platform_pci_map_sg		ia64_mv.map_sg
+#  define platform_pci_unmap_sg		ia64_mv.unmap_sg
+#  define platform_pci_dma_sync_single	ia64_mv.sync_single
+#  define platform_pci_dma_sync_sg	ia64_mv.sync_sg
+#  define platform_pci_dma_address	ia64_mv.dma_address
 #  define platform_inb		ia64_mv.inb
 #  define platform_inw		ia64_mv.inw
 #  define platform_inl		ia64_mv.inl
@@ -90,6 +107,16 @@
 	ia64_mv_cmci_handler_t *cmci_handler;
 	ia64_mv_log_print_t *log_print;
 	ia64_mv_send_ipi_t *send_ipi;
+	ia64_mv_pci_dma_init *dma_init;
+	ia64_mv_pci_alloc_consistent *alloc_consistent;
+	ia64_mv_pci_free_consistent *free_consistent;
+	ia64_mv_pci_map_single *map_single;
+	ia64_mv_pci_unmap_single *unmap_single;
+	ia64_mv_pci_map_sg *map_sg;
+	ia64_mv_pci_unmap_sg *unmap_sg;
+	ia64_mv_pci_dma_sync_single *sync_single;
+	ia64_mv_pci_dma_sync_sg *sync_sg;
+	ia64_mv_pci_dma_address *dma_address;
 	ia64_mv_inb_t *inb;
 	ia64_mv_inw_t *inw;
 	ia64_mv_inl_t *inl;
@@ -110,6 +137,16 @@
 	platform_cmci_handler,			\
 	platform_log_print,			\
 	platform_send_ipi,			\
+	platform_pci_dma_init,			\
+	platform_pci_alloc_consistent,		\
+	platform_pci_free_consistent,		\
+	platform_pci_map_single,		\
+	platform_pci_unmap_single,		\
+	platform_pci_map_sg,			\
+	platform_pci_unmap_sg,			\
+	platform_pci_dma_sync_single,		\
+	platform_pci_dma_sync_sg,		\
+	platform_pci_dma_address,		\
 	platform_inb,				\
 	platform_inw,				\
 	platform_inl,				\
@@ -126,6 +163,20 @@
 # endif /* CONFIG_IA64_GENERIC */
=20
 /*
+ * Declare default routines which aren't declared anywhere else:
+ */
+extern ia64_mv_pci_dma_init swiotlb_init;
+extern ia64_mv_pci_alloc_consistent swiotlb_alloc_consistent;
+extern ia64_mv_pci_free_consistent swiotlb_free_consistent;
+extern ia64_mv_pci_map_single swiotlb_map_single;
+extern ia64_mv_pci_unmap_single swiotlb_unmap_single;
+extern ia64_mv_pci_map_sg swiotlb_map_sg;
+extern ia64_mv_pci_unmap_sg swiotlb_unmap_sg;
+extern ia64_mv_pci_dma_sync_single swiotlb_sync_single;
+extern ia64_mv_pci_dma_sync_sg swiotlb_sync_sg;
+extern ia64_mv_pci_dma_address swiotlb_dma_address;
+
+/*
  * Define default versions so we can extend machvec for new platforms with=
out having
  * to update the machvec files for all existing platforms.
  */
@@ -152,6 +203,36 @@
 #endif
 #ifndef platform_send_ipi
 # define platform_send_ipi	ia64_send_ipi	/* default to architected version=
 */
+#endif
+#ifndef platform_pci_dma_init
+# define platform_pci_dma_init		swiotlb_init
+#endif
+#ifndef platform_pci_alloc_consistent
+# define platform_pci_alloc_consistent	swiotlb_alloc_consistent
+#endif
+#ifndef platform_pci_free_consistent
+# define platform_pci_free_consistent	swiotlb_free_consistent
+#endif
+#ifndef platform_pci_map_single
+# define platform_pci_map_single	swiotlb_map_single
+#endif
+#ifndef platform_pci_unmap_single
+# define platform_pci_unmap_single	swiotlb_unmap_single
+#endif
+#ifndef platform_pci_map_sg
+# define platform_pci_map_sg		swiotlb_map_sg
+#endif
+#ifndef platform_pci_unmap_sg
+# define platform_pci_unmap_sg		swiotlb_unmap_sg
+#endif
+#ifndef platform_pci_dma_sync_single
+# define platform_pci_dma_sync_single	swiotlb_sync_single
+#endif
+#ifndef platform_pci_dma_sync_sg
+# define platform_pci_dma_sync_sg	swiotlb_sync_sg
+#endif
+#ifndef platform_pci_dma_address
+# define  platform_pci_dma_address	swiotlb_dma_address
 #endif
 #ifndef platform_inb
 # define platform_inb		__ia64_inb
diff -urN linux-davidm/include/asm-ia64/offsets.h linux-2.4.0-test12-lia/in=
clude/asm-ia64/offsets.h
--- linux-davidm/include/asm-ia64/offsets.h	Thu Dec 14 19:58:06 2000
+++ linux-2.4.0-test12-lia/include/asm-ia64/offsets.h	Thu Dec 14 14:44:18 2=
000
@@ -8,7 +8,7 @@
  */
 #define PT_PTRACED_BIT		0
 #define PT_TRACESYS_BIT		1
-#define IA64_TASK_SIZE			3968	/* 0xf80 */
+#define IA64_TASK_SIZE			3360	/* 0xd20 */
 #define IA64_PT_REGS_SIZE		400	/* 0x190 */
 #define IA64_SWITCH_STACK_SIZE		560	/* 0x230 */
 #define IA64_SIGINFO_SIZE		128	/* 0x80 */
@@ -20,7 +20,7 @@
 #define IA64_TASK_PROCESSOR_OFFSET	100	/* 0x64 */
 #define IA64_TASK_THREAD_OFFSET		1456	/* 0x5b0 */
 #define IA64_TASK_THREAD_KSP_OFFSET	1456	/* 0x5b0 */
-#define IA64_TASK_THREAD_SIGMASK_OFFSET	3824	/* 0xef0 */
+#define IA64_TASK_THREAD_SIGMASK_OFFSET	3216	/* 0xc90 */
 #define IA64_TASK_PID_OFFSET		196	/* 0xc4 */
 #define IA64_TASK_MM_OFFSET		88	/* 0x58 */
 #define IA64_PT_REGS_CR_IPSR_OFFSET	0	/* 0x0 */
diff -urN linux-davidm/include/asm-ia64/page.h linux-2.4.0-test12-lia/inclu=
de/asm-ia64/page.h
--- linux-davidm/include/asm-ia64/page.h	Thu Dec 14 19:58:06 2000
+++ linux-2.4.0-test12-lia/include/asm-ia64/page.h	Thu Dec 14 14:44:29 2000
@@ -40,9 +40,6 @@
 extern void clear_page (void *page);
 extern void copy_page (void *to, void *from);
=20
-#define clear_user_page(page, vaddr)	clear_page(page)
-#define copy_user_page(to, from, vaddr)	copy_page(to, from)
-
 #  ifdef STRICT_MM_TYPECHECKS
 /*
  * These are used to make use of C type-checking..
diff -urN linux-davidm/include/asm-ia64/pci.h linux-2.4.0-test12-lia/includ=
e/asm-ia64/pci.h
--- linux-davidm/include/asm-ia64/pci.h	Thu Dec 14 19:58:06 2000
+++ linux-2.4.0-test12-lia/include/asm-ia64/pci.h	Thu Dec 14 14:44:39 2000
@@ -22,125 +22,42 @@
=20
 struct pci_dev;
=20
-static inline void pcibios_set_master(struct pci_dev *dev)
+static inline void
+pcibios_set_master (struct pci_dev *dev)
 {
 	/* No special bus mastering setup handling */
 }
=20
-static inline void pcibios_penalize_isa_irq(int irq)
+static inline void
+pcibios_penalize_isa_irq (int irq)
 {
 	/* We don't do dynamic PCI IRQ allocation */
 }
=20
 /*
- * Dynamic DMA mapping API.
+ * Dynamic DMA mapping API.  See Documentation/DMA-mapping.txt for details.
  */
+#define pci_alloc_consistent		platform_pci_alloc_consistent
+#define pci_free_consistent		platform_pci_free_consistent
+#define pci_map_single			platform_pci_map_single
+#define pci_unmap_single		platform_pci_unmap_single
+#define pci_map_sg			platform_pci_map_sg
+#define pci_unmap_sg			platform_pci_unmap_sg
+#define pci_dma_sync_single		platform_pci_dma_sync_single
+#define pci_dma_sync_sg			platform_pci_dma_sync_sg
+#define sg_dma_address			platform_pci_dma_address
=20
 /*
- * Allocate and map kernel buffer using consistent mode DMA for a device.
- * hwdev should be valid struct pci_dev pointer for PCI devices,
- * NULL for PCI-like buses (ISA, EISA).
- * Returns non-NULL cpu-view pointer to the buffer if successful and
- * sets *dma_addrp to the pci side dma address as well, else *dma_addrp
- * is undefined.
- */
-extern void *pci_alloc_consistent (struct pci_dev *hwdev, size_t size, dma=
_addr_t *dma_handle);
-
-/*
- * Free and unmap a consistent DMA buffer.
- * cpu_addr is what was returned from pci_alloc_consistent,
- * size must be the same as what as passed into pci_alloc_consistent,
- * and likewise dma_addr must be the same as what *dma_addrp was set to.
- *
- * References to the memory and mappings associated with cpu_addr/dma_addr
- * past this call are illegal.
- */
-extern void pci_free_consistent (struct pci_dev *hwdev, size_t size,
-				 void *vaddr, dma_addr_t dma_handle);
-
-/*
- * Map a single buffer of the indicated size for DMA in streaming mode.
- * The 32-bit bus address to use is returned.
- *
- * Once the device is given the dma address, the device owns this memory
- * until either pci_unmap_single or pci_dma_sync_single is performed.
- */
-extern dma_addr_t pci_map_single(struct pci_dev *hwdev, void *ptr, size_t =
size, int direction);
-
-/*
- * Unmap a single streaming mode DMA translation.  The dma_addr and size
- * must match what was provided for in a previous pci_map_single call.  All
- * other usages are undefined.
- *
- * After this call, reads by the cpu to the buffer are guarenteed to see
- * whatever the device wrote there.
- */
-extern void pci_unmap_single (struct pci_dev *hwdev, dma_addr_t dma_addr, =
size_t size, int direction);
-
-/*
- * Map a set of buffers described by scatterlist in streaming
- * mode for DMA.  This is the scather-gather version of the
- * above pci_map_single interface.  Here the scatter gather list
- * elements are each tagged with the appropriate dma address
- * and length.  They are obtained via sg_dma_{address,length}(SG).
- *
- * NOTE: An implementation may be able to use a smaller number of
- *       DMA address/length pairs than there are SG table elements.
- *       (for example via virtual mapping capabilities)
- *       The routine returns the number of addr/length pairs actually
- *       used, at most nents.
- *
- * Device ownership issues as mentioned above for pci_map_single are
- * the same here.
- */
-extern int pci_map_sg(struct pci_dev *hwdev, struct scatterlist *sg, int n=
ents, int direction);
-
-/*
- * Unmap a set of streaming mode DMA translations.
- * Again, cpu read rules concerning calls here are the same as for
- * pci_unmap_single() above.
- */
-extern void pci_unmap_sg(struct pci_dev *hwdev, struct scatterlist *sg, in=
t nents, int direction);
-
-/*
- * Make physical memory consistent for a single
- * streaming mode DMA translation after a transfer.
- *
- * If you perform a pci_map_single() but wish to interrogate the
- * buffer using the cpu, yet do not wish to teardown the PCI dma
- * mapping, you must call this function before doing so.  At the
- * next point you give the PCI dma address back to the card, the
- * device again owns the buffer.
- */
-extern void pci_dma_sync_single (struct pci_dev *hwdev, dma_addr_t dma_han=
dle, size_t size, int direction);
-
-/*
- * Make physical memory consistent for a set of streaming mode DMA
- * translations after a transfer.
- *
- * The same as pci_dma_sync_single but for a scatter-gather list,
- * same rules and usage.
- */
-extern void pci_dma_sync_sg(struct pci_dev *hwdev, struct scatterlist *sg,=
 int nelems, int direction);
-
-/* Return whether the given PCI device DMA address mask can
- * be supported properly.  For example, if your device can
- * only drive the low 24-bits during PCI bus mastering, then
+ * Return whether the given PCI device DMA address mask can be supported p=
roperly.  For
+ * example, if your device can only drive the low 24-bits during PCI bus m=
astering, then
  * you would pass 0x00ffffff as the mask to this function.
  */
 static inline int
-pci_dma_supported(struct pci_dev *hwdev, dma_addr_t mask)
+pci_dma_supported (struct pci_dev *hwdev, dma_addr_t mask)
 {
 	return 1;
 }
=20
-/* These macros should be used after a pci_map_sg call has been done
- * to get bus addresses of each of the SG entries and their lengths.
- * You should only work with the number of sg entries pci_map_sg
- * returns, or alternatively stop on the first sg_dma_len(sg) which
- * is 0.
- */
-#define sg_dma_address(sg)	(virt_to_bus((sg)->address))
 #define sg_dma_len(sg)		((sg)->length)
=20
 #endif /* _ASM_IA64_PCI_H */
diff -urN linux-davidm/include/asm-ia64/pgalloc.h linux-2.4.0-test12-lia/in=
clude/asm-ia64/pgalloc.h
--- linux-davidm/include/asm-ia64/pgalloc.h	Thu Dec 14 19:58:06 2000
+++ linux-2.4.0-test12-lia/include/asm-ia64/pgalloc.h	Thu Dec 14 14:44:49 2=
000
@@ -15,6 +15,7 @@
=20
 #include <linux/config.h>
=20
+#include <linux/mm.h>
 #include <linux/threads.h>
=20
 #include <asm/mmu_context.h>
@@ -260,6 +261,73 @@
 		printk("flush_tlb_pgtables: can't flush across regions!!\n");
 	}
 	flush_tlb_range(mm, ia64_thash(start), ia64_thash(end));
+}
+
+/*
+ * Now for some cache flushing routines.  This is the kind of stuff
+ * that can be very expensive, so try to avoid them whenever possible.
+ */
+
+/* Caches aren't brain-dead on the IA-64. */
+#define flush_cache_all()			do { } while (0)
+#define flush_cache_mm(mm)			do { } while (0)
+#define flush_cache_range(mm, start, end)	do { } while (0)
+#define flush_cache_page(vma, vmaddr)		do { } while (0)
+#define flush_page_to_ram(page)			do { } while (0)
+
+extern void flush_icache_range (unsigned long start, unsigned long end);
+
+static inline void
+flush_dcache_page (struct page *page)
+{
+	clear_bit(PG_arch_1, &page->flags);
+}
+
+static inline void
+clear_user_page (void *addr, unsigned long vaddr, struct page *page)
+{
+	clear_page(addr);
+	flush_dcache_page(page);
+}
+
+static inline void
+copy_user_page (void *to, void *from, unsigned long vaddr, struct page *pa=
ge)
+{
+	copy_page(to, from);
+	flush_dcache_page(page);
+}
+
+/*
+ * IA-64 doesn't have any external MMU info: the page tables contain
+ * all the necessary information.  However, we can use this macro
+ * to pre-install (override) a PTE that we know is needed anyhow.
+ */
+static inline void
+update_mmu_cache (struct vm_area_struct *vma, unsigned long address, pte_t=
 pte)
+{
+	struct page *page;
+
+	if ((vma->vm_flags & PROT_EXEC) =3D 0)
+		return;				/* not an executable page... */
+
+	page =3D pte_page(pte);
+	address &=3D PAGE_MASK;
+
+	/*
+	 * Avoid flushing pages that can't possibly contain code.  All newly crea=
ted
+	 * anonymous pages are such pages.  However, once the page gets swapped o=
ut and
+	 * then read back in, the page may contain code (since the user may have =
written
+	 * code into that page).  Fortunately, page->mapping tells us which case =
applies:
+	 * it's non-NULL if and only if the page is in the page cache (whether du=
e to
+	 * regular mappings or due to swap-cache pages).
+	 */
+	if (!page->mapping)
+		return;
+
+	if (test_and_set_bit(PG_arch_1, &page->flags))
+		return;
+
+	flush_icache_range(address, address + PAGE_SIZE);
 }
=20
 #endif /* _ASM_IA64_PGALLOC_H */
diff -urN linux-davidm/include/asm-ia64/pgtable.h linux-2.4.0-test12-lia/in=
clude/asm-ia64/pgtable.h
--- linux-davidm/include/asm-ia64/pgtable.h	Thu Dec 14 19:58:06 2000
+++ linux-2.4.0-test12-lia/include/asm-ia64/pgtable.h	Thu Dec 14 14:50:34 2=
000
@@ -163,28 +163,6 @@
  */
 #define page_address(page)	((page)->virtual)
=20
-/*
- * Now for some cache flushing routines.  This is the kind of stuff
- * that can be very expensive, so try to avoid them whenever possible.
- */
-
-/* Caches aren't brain-dead on the ia-64. */
-#define flush_cache_all()			do { } while (0)
-#define flush_cache_mm(mm)			do { } while (0)
-#define flush_cache_range(mm, start, end)	do { } while (0)
-#define flush_cache_page(vma, vmaddr)		do { } while (0)
-#define flush_page_to_ram(page)			do { } while (0)
-#define flush_dcache_page(page)			do { } while (0)
-#define flush_icache_range(start, end)		do { } while (0)
-
-extern void ia64_flush_icache_page (unsigned long addr);
-
-#define flush_icache_page(vma,pg)				\
-do {								\
-	if ((vma)->vm_flags & PROT_EXEC)			\
-		ia64_flush_icache_page((unsigned long) page_address(pg));	\
-} while (0)
-
 /* Quick test to see if ADDR is a (potentially) valid physical address. */
 static inline long
 ia64_phys_addr_valid (unsigned long addr)
@@ -449,47 +427,6 @@
=20
 extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
 extern void paging_init (void);
-
-/*
- * IA-64 doesn't have any external MMU info: the page tables contain
- * all the necessary information.  However, we can use this macro
- * to pre-install (override) a PTE that we know is needed anyhow.
- *
- * Asit says that on Itanium, it is generally faster to let the VHPT
- * walker pick up a newly installed PTE (and VHPT misses should be
- * extremely rare compared to normal misses).  Also, since
- * pre-installing the PTE has the problem that we may evict another
- * TLB entry needlessly because we don't know for sure whether we need
- * to update the iTLB or dTLB, I tend to prefer this solution, too.
- * Also, this avoids nasty issues with forward progress (what if the
- * newly installed PTE gets replaced before we return to the previous
- * execution context?).
- *
- */
-#if 1
-# define update_mmu_cache(vma,address,pte)
-#else
-# define update_mmu_cache(vma,address,pte)							\
-do {												\
-	/*											\
-	 * This is usually not a win.  We may end up polluting the				\
-	 * dtlb with itlb entries and vice versa (e.g., consider stack				\
-	 * pages that are normally marked executable).  It would be				\
-	 * better to insert the TLB entry for the TLB cache that we				\
-	 * know needs the new entry.  However, the update_mmu_cache()				\
-	 * arguments don't tell us whether we got here through a data				\
-	 * access or through an instruction fetch.						\
-	 *											\
-	 * If you re-enable this code, you must disable the ptc code in				\
-	 * Entry 20 of the ivt.									\
-	 */											\
-	unsigned long flags;									\
-												\
-	ia64_clear_ic(flags);									\
-	ia64_itc((vma->vm_flags & PROT_EXEC) ? 0x3 : 0x2, address, pte_val(pte), =
PAGE_SHIFT);	\
-	__restore_flags(flags);									\
-} while (0)
-#endif
=20
 #define SWP_TYPE(entry)			(((entry).val >> 1) & 0xff)
 #define SWP_OFFSET(entry)		(((entry).val << 1) >> 10)
diff -urN linux-davidm/include/asm-ia64/sal.h linux-2.4.0-test12-lia/includ=
e/asm-ia64/sal.h
--- linux-davidm/include/asm-ia64/sal.h	Thu Dec 14 19:58:06 2000
+++ linux-2.4.0-test12-lia/include/asm-ia64/sal.h	Thu Dec 14 14:50:49 2000
@@ -505,19 +505,7 @@
 ia64_sal_pci_config_read (u64 pci_config_addr, u64 size, u64 *value)
 {
 	struct ia64_sal_retval isrv;
-#ifdef CONFIG_ITANIUM_A1_SPECIFIC
-	extern spinlock_t ivr_read_lock;
-	unsigned long flags;
-
-	/*
-	 * Avoid PCI configuration read/write overwrite -- A0 Interrupt loss work=
around
-	 */
-	spin_lock_irqsave(&ivr_read_lock, flags);
-#endif
 	SAL_CALL(isrv, SAL_PCI_CONFIG_READ, pci_config_addr, size, 0, 0, 0, 0, 0);
-#ifdef CONFIG_ITANIUM_A1_SPECIFIC
-	spin_unlock_irqrestore(&ivr_read_lock, flags);
-#endif
 	if (value)
 		*value =3D isrv.v0;
 	return isrv.status;
@@ -528,20 +516,8 @@
 ia64_sal_pci_config_write (u64 pci_config_addr, u64 size, u64 value)
 {
 	struct ia64_sal_retval isrv;
-#ifdef CONFIG_ITANIUM_A1_SPECIFIC
-	extern spinlock_t ivr_read_lock;
-	unsigned long flags;
-
-	/*
-	 * Avoid PCI configuration read/write overwrite -- A0 Interrupt loss work=
around
-	 */
-	spin_lock_irqsave(&ivr_read_lock, flags);
-#endif
 	SAL_CALL(isrv, SAL_PCI_CONFIG_WRITE, pci_config_addr, size, value,
 	         0, 0, 0, 0);
-#ifdef CONFIG_ITANIUM_A1_SPECIFIC
-	spin_unlock_irqrestore(&ivr_read_lock, flags);
-#endif
 	return isrv.status;
 }
=20
diff -urN linux-davidm/include/asm-ia64/sn/mmzone.h linux-2.4.0-test12-lia/=
include/asm-ia64/sn/mmzone.h
--- linux-davidm/include/asm-ia64/sn/mmzone.h	Thu Dec 14 19:58:06 2000
+++ linux-2.4.0-test12-lia/include/asm-ia64/sn/mmzone.h	Wed Dec 13 19:35:14=
 2000
@@ -6,6 +6,7 @@
 #define _LINUX_ASM_SN_MMZONE_H
=20
 #include <asm/sn/mmzone_sn1.h>
+#include <asm/sn/sn_cpuid.h>
=20
 /*
  * Memory is conceptually divided into chunks. A chunk is either
@@ -104,5 +105,7 @@
 #define MAP_NR_SN1(addr)	(((unsigned long) (addr) - PAGE_OFFSET) >> PAGE_S=
HIFT)
=20
 #endif /* CONFIG_DISCONTIGMEM */
+
+#define numa_node_id()		cpuid_to_cnodeid(smp_processor_id())
=20
 #endif /* !_LINUX_ASM_SN_MMZONE_H */
diff -urN linux-davidm/include/asm-ia64/sn/mmzone_sn1.h linux-2.4.0-test12-=
lia/include/asm-ia64/sn/mmzone_sn1.h
--- linux-davidm/include/asm-ia64/sn/mmzone_sn1.h	Thu Dec 14 19:58:06 2000
+++ linux-2.4.0-test12-lia/include/asm-ia64/sn/mmzone_sn1.h	Wed Dec 13 18:5=
9:33 2000
@@ -5,8 +5,10 @@
  * Copyright, 2000, Silicon Graphics, sprasad@engr.sgi.com
  */
=20
-/* SN1 will first attempt a 64 cpu config =3D 16 nodes X 4 cpus */
-#define MAXNODES                16
+/* Maximum configuration supported by SNIA hardware. There are other
+ * restrictions that may limit us to a smaller max configuration.
+ */
+#define MAXNODES                128
 #define MAXNASIDS		128
=20
 #define CHUNKSZ                (64*1024*1024)
diff -urN linux-davidm/include/asm-ia64/sn/pci/pci_bus_cvlink.h linux-2.4.0=
-test12-lia/include/asm-ia64/sn/pci/pci_bus_cvlink.h
--- linux-davidm/include/asm-ia64/sn/pci/pci_bus_cvlink.h	Thu Dec 14 19:58:=
07 2000
+++ linux-2.4.0-test12-lia/include/asm-ia64/sn/pci/pci_bus_cvlink.h	Wed Dec=
 13 18:59:33 2000
@@ -10,12 +10,20 @@
 #ifndef _ASM_SN_PCI_CVLINK_H
 #define _ASM_SN_PCI_CVLINK_H
=20
+#define SET_PCIA64(dev) \
+	(((struct sn1_device_sysdata *)((dev)->sysdata))->isa64) =3D 1
+#define IS_PCIA64(dev)	(((dev)->dma_mask =3D 0xffffffffffffffffUL) || \
+		(((struct sn1_device_sysdata *)((dev)->sysdata))->isa64))
+#define IS_PCI32G(dev)	((dev)->dma_mask >=3D 0xffffffff)
+#define IS_PCI32L(dev)	((dev)->dma_mask < 0xffffffff)
+
 struct sn1_widget_sysdata {
         devfs_handle_t  vhdl;
 };
=20
 struct sn1_device_sysdata {
         devfs_handle_t  vhdl;
+	int		isa64;
 };
=20
 #endif				/* _ASM_SN_PCI_CVLINK_H */
diff -urN linux-davidm/include/linux/highmem.h linux-2.4.0-test12-lia/inclu=
de/linux/highmem.h
--- linux-davidm/include/linux/highmem.h	Wed Dec 13 17:30:34 2000
+++ linux-2.4.0-test12-lia/include/linux/highmem.h	Thu Dec 14 14:51:06 2000
@@ -45,7 +45,7 @@
 /* when CONFIG_HIGHMEM is not set these will be plain clear/copy_page */
 static inline void clear_user_highpage(struct page *page, unsigned long va=
ddr)
 {
-	clear_user_page(kmap(page), vaddr);
+	clear_user_page(kmap(page), vaddr, page);
 	kunmap(page);
 }
=20
@@ -87,7 +87,7 @@
=20
 	vfrom =3D kmap(from);
 	vto =3D kmap(to);
-	copy_user_page(vto, vfrom, vaddr);
+	copy_user_page(vto, vfrom, vaddr, to);
 	kunmap(from);
 	kunmap(to);
 }
diff -urN linux-davidm/include/linux/irq.h linux-2.4.0-test12-lia/include/l=
inux/irq.h
--- linux-davidm/include/linux/irq.h	Thu Dec 14 19:58:07 2000
+++ linux-2.4.0-test12-lia/include/linux/irq.h	Thu Dec 14 14:51:17 2000
@@ -57,6 +57,7 @@
 #include <asm/hw_irq.h> /* the arch dependent stuff */
=20
 extern unsigned int do_IRQ (unsigned long irq, struct pt_regs *regs);
+extern void do_IRQ_per_cpu (unsigned long irq, struct pt_regs *regs);
 extern int handle_IRQ_event(unsigned int, struct pt_regs *, struct irqacti=
on *);
 extern int setup_irq(unsigned int , struct irqaction * );
=20
diff -urN linux-davidm/kernel/ptrace.c linux-2.4.0-test12-lia/kernel/ptrace=
.c
--- linux-davidm/kernel/ptrace.c	Wed Dec  6 18:33:42 2000
+++ linux-2.4.0-test12-lia/kernel/ptrace.c	Thu Dec 14 14:52:18 2000
@@ -53,14 +53,14 @@
 	flush_cache_page(vma, addr);
=20
 	if (write) {
-		maddr =3D kmap(page);
-		memcpy(maddr + (addr & ~PAGE_MASK), buf, len);
+		maddr =3D kmap(page) + (addr & ~PAGE_MASK);
+		memcpy(maddr, buf, len);
 		flush_page_to_ram(page);
-		flush_icache_page(vma, page);
+		flush_icache_range((unsigned long) maddr, (unsigned long)maddr + len);
 		kunmap(page);
 	} else {
-		maddr =3D kmap(page);
-		memcpy(buf, maddr + (addr & ~PAGE_MASK), len);
+		maddr =3D kmap(page) + (addr & ~PAGE_MASK);
+		memcpy(buf, maddr, len);
 		flush_page_to_ram(page);
 		kunmap(page);
 	}
diff -urN linux-davidm/mm/memory.c linux-2.4.0-test12-lia/mm/memory.c
--- linux-davidm/mm/memory.c	Thu Dec 14 19:58:07 2000
+++ linux-2.4.0-test12-lia/mm/memory.c	Thu Dec 14 14:52:29 2000
@@ -1030,7 +1030,6 @@
 			return -1;
=20
 		flush_page_to_ram(page);
-		flush_icache_page(vma, page);
 	}
=20
 	mm->rss++;
@@ -1118,7 +1117,6 @@
 	 * handle that later.
 	 */
 	flush_page_to_ram(new_page);
-	flush_icache_page(vma, new_page);
 	entry =3D mk_pte(new_page, vma->vm_page_prot);
 	if (write_access) {
 		entry =3D pte_mkwrite(pte_mkdirty(entry));

