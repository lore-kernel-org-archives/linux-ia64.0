From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 26 Jul 2004 22:24:40 +0000
Subject: [BROKEN PATCH] kexec for ia64
Message-Id: <200407261524.40804.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_oSYBBKNk8UrDrVd"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_oSYBBKNk8UrDrVd
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I yanked Eric's original patch out of a webpage and bashed it into a recent BK 
tree.  You'll need Randy's full kexec patch 
(http://developer.osdl.org/rddunlap/kexec/) in addition to this one to have 
something remotely useful.  It still needs a lot of work:

  o userspace tools need ia64 support
  o need to deal with in-flight DMA (see FIXME in machine_kexec)

I'm also worried about a few things in this patch.  Is relocate_kernel.S 
really necessary in 2.6?  Can we copy the kernel to a contiguous 64MB aligned 
area, drop into phys mode and just jump to it?  Also, what about EFI boot 
services and PROM tables that the kernel frees part way through boot?  Should 
we copy those into a safe place for the new image at boot time?  Or just 
leave them there if CONFIG_KEXEC is enabled?

Comments and suggestions welcome.  It would be really nice to have this stuff 
working since it appears that crash dumps will be collected with a 
panic->kexec'd kernel rather than polling mode network/disk writing.  (Well, 
that and reboots would be *much* faster :)

Thanks,
Jesse

--Boundary-00=_oSYBBKNk8UrDrVd
Content-Type: text/plain;
  charset="us-ascii";
  name="kexec-ia64.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="kexec-ia64.patch"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/07/26 15:16:34-07:00 jbarnes@tomahawk.engr.sgi.com 
#   kexec
# 
# include/asm-ia64/kexec.h
#   2004/07/26 15:16:25-07:00 jbarnes@tomahawk.engr.sgi.com +15 -0
# 
# include/asm-ia64/kexec.h
#   2004/07/26 15:16:25-07:00 jbarnes@tomahawk.engr.sgi.com +0 -0
#   BitKeeper file /home/jbarnes/working/linux-2.5-kexec/include/asm-ia64/kexec.h
# 
# arch/ia64/kernel/relocate_kernel.S
#   2004/07/26 15:16:24-07:00 jbarnes@tomahawk.engr.sgi.com +97 -0
# 
# arch/ia64/kernel/relocate_kernel.S
#   2004/07/26 15:16:24-07:00 jbarnes@tomahawk.engr.sgi.com +0 -0
#   BitKeeper file /home/jbarnes/working/linux-2.5-kexec/arch/ia64/kernel/relocate_kernel.S
# 
# arch/ia64/kernel/machine_kexec.c
#   2004/07/26 15:16:23-07:00 jbarnes@tomahawk.engr.sgi.com +52 -0
# 
# include/asm-ia64/mmu_context.h
#   2004/07/26 15:16:23-07:00 jbarnes@tomahawk.engr.sgi.com +2 -0
#   kexec
# 
# arch/ia64/kernel/machine_kexec.c
#   2004/07/26 15:16:23-07:00 jbarnes@tomahawk.engr.sgi.com +0 -0
#   BitKeeper file /home/jbarnes/working/linux-2.5-kexec/arch/ia64/kernel/machine_kexec.c
# 
# arch/ia64/kernel/entry.S
#   2004/07/26 15:16:23-07:00 jbarnes@tomahawk.engr.sgi.com +1 -1
#   kexec
# 
# arch/ia64/kernel/efi.c
#   2004/07/26 15:16:23-07:00 jbarnes@tomahawk.engr.sgi.com +6 -0
#   kexec
# 
# arch/ia64/kernel/Makefile
#   2004/07/26 15:16:23-07:00 jbarnes@tomahawk.engr.sgi.com +1 -0
#   kexec
# 
# arch/ia64/Kconfig
#   2004/07/26 15:16:23-07:00 jbarnes@tomahawk.engr.sgi.com +17 -0
#   kexec
# 
diff -Nru a/arch/ia64/Kconfig b/arch/ia64/Kconfig
--- a/arch/ia64/Kconfig	2004-07-26 15:21:02 -07:00
+++ b/arch/ia64/Kconfig	2004-07-26 15:21:02 -07:00
@@ -251,6 +251,23 @@
           Say Y here if you are building a kernel for a desktop, embedded
           or real-time system.  Say N if you are unsure.
 
+config KEXEC
+	bool "kexec system call (EXPERIMENTAL)"
+	depends on EXPERIMENTAL
+	help
+	  kexec is a system call that implements the ability to  shutdown your
+	  current kernel, and to start another kernel.  It is like a reboot
+	  but it is indepedent of the system firmware.   And like a reboot
+	  you can start any kernel with it not just Linux.
+
+	  The name comes from the similiarity to the exec system call.
+
+	  It is on an going process to be certain the hardware in a machine
+	  is properly shutdown, so do not be surprised if this code does not
+	  initially work for you.  It may help to enable device hotplugging
+	  support.  As of this writing the exact hardware interface is
+	  strongly in flux, so no good recommendation can be made.
+
 config HAVE_DEC_LOCK
 	bool
 	depends on (SMP || PREEMPT)
diff -Nru a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
--- a/arch/ia64/kernel/Makefile	2004-07-26 15:21:02 -07:00
+++ b/arch/ia64/kernel/Makefile	2004-07-26 15:21:02 -07:00
@@ -17,6 +17,7 @@
 obj-$(CONFIG_SMP)		+= smp.o smpboot.o
 obj-$(CONFIG_PERFMON)		+= perfmon_default_smpl.o
 obj-$(CONFIG_IA64_CYCLONE)	+= cyclone.o
+obj-$(CONFIG_KEXEC)		+= machine_kexec.o relocate_kernel.o
 
 # The gate DSO image is built using a special linker script.
 targets += gate.so gate-syms.o
diff -Nru a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c	2004-07-26 15:21:02 -07:00
+++ b/arch/ia64/kernel/efi.c	2004-07-26 15:21:02 -07:00
@@ -198,6 +198,7 @@
 
 #define id(arg)	arg
 
+#if 0
 STUB_GET_TIME(virt, id)
 STUB_SET_TIME(virt, id)
 STUB_GET_WAKEUP_TIME(virt, id)
@@ -207,6 +208,7 @@
 STUB_SET_VARIABLE(virt, id)
 STUB_GET_NEXT_HIGH_MONO_COUNT(virt, id)
 STUB_RESET_SYSTEM(virt, id)
+#endif
 
 void
 efi_gettimeofday (struct timespec *ts)
@@ -596,9 +598,12 @@
 #endif
 
 	efi_map_pal_code();
+#if 0
 	efi_enter_virtual_mode();
+#endif
 }
 
+#if 0
 void
 efi_enter_virtual_mode (void)
 {
@@ -670,6 +675,7 @@
 	efi.get_next_high_mono_count = virt_get_next_high_mono_count;
 	efi.reset_system = virt_reset_system;
 }
+#endif
 
 /*
  * Walk the EFI memory map looking for the I/O port range.  There can only be one entry of
diff -Nru a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	2004-07-26 15:21:02 -07:00
+++ b/arch/ia64/kernel/entry.S	2004-07-26 15:21:02 -07:00
@@ -1525,7 +1525,7 @@
 	data8 sys_mq_timedreceive		// 1265
 	data8 sys_mq_notify
 	data8 sys_mq_getsetattr
-	data8 sys_ni_syscall			// reserved for kexec_load
+	data8 sys_kexec_load
 	data8 sys_ni_syscall
 	data8 sys_ni_syscall			// 1270
 	data8 sys_ni_syscall
diff -Nru a/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_kexec.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/arch/ia64/kernel/machine_kexec.c	2004-07-26 15:21:02 -07:00
@@ -0,0 +1,52 @@
+#include <linux/kernel.h>
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/kexec.h>
+#include <asm/mmu_context.h>
+
+#define PHYS_UNCACHED_OFFSET 0x8000000000000000UL
+extern unsigned long ia64_iobase;
+
+static void set_io_base(void)
+{
+	/* Set kr0 to iobase... */
+	unsigned long phys_iobase;
+	phys_iobase = __pa(ia64_iobase);
+	ia64_set_kr(IA64_KR_IO_BASE, PHYS_UNCACHED_OFFSET | phys_iobase);
+}
+
+typedef void (*relocate_new_kernel_t)(unsigned long indirection_page,
+				      unsigned long start_address);
+
+const extern unsigned char relocate_new_kernel[];
+const extern unsigned int relocate_new_kernel_size;
+
+void machine_kexec(struct kimage *image)
+{
+	unsigned long indirection_page;
+	unsigned long reboot_code_buffer;
+	relocate_new_kernel_t rnk;
+
+	/* switch to an mm where the reboot_code_buffer is identity mapped */
+	use_mm(&init_mm);
+
+	/* Interrupts aren't acceptable while we reboot */
+	local_irq_disable();
+
+	/* Find the physical addresses */
+	reboot_code_buffer = page_to_pfn(image->reboot_code_pages) << PAGE_SHIFT;
+	indirection_page = image->head & PAGE_MASK;
+
+	/* copy it out */
+	memcpy((void *)reboot_code_buffer, relocate_new_kernel,
+	       relocate_new_kernel_size);
+
+	/* set kr0 to the appropriate address */
+	set_io_base();
+
+	/* now call it */
+	rnk = (relocate_new_kernel_t)reboot_code_buffer;
+	(*rnk)(indirection_page, image->start);
+
+	/* FIXME: deal with in-flight DMA!! */
+}
diff -Nru a/arch/ia64/kernel/relocate_kernel.S b/arch/ia64/kernel/relocate_kernel.S
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/arch/ia64/kernel/relocate_kernel.S	2004-07-26 15:21:02 -07:00
@@ -0,0 +1,97 @@
+#include <linux/config.h>
+#include <asm/asmmacro.h>
+#include <asm/kregs.h>
+#include <asm/page.h>
+
+       /* Must be relocatable PIC code callable as a C function, that once
+        * it starts can not use the previous processes stack.
+        *
+        */
+       /* Q: Do I want to setup an interrupt vector, so what happens
+        * when exceptions occur is well defined?
+        */
+       .globl relocate_new_kernel
+relocate_new_kernel:
+       /* See where I am running, and compute gp */
+       {
+               mov     ar.rsc = 0      /* Put RSE in enforce lacy, LE mode */
+               mov     gp = ip         /* gp == relocate_new_kernel */
+       }
+       /* Transition from virtual to physical mode */
+       movl    r8=(IA64_PSR_AC | IA64_PSR_IC | IA64_PSR_BN)
+       movl    r9=1f
+       ;;
+       mov     cr.ipsr=r8
+       mov     cr.iip=r9
+       mov     cr.ifs=r0
+       ;;
+       rfi
+       ;;
+1:     /* Now we are in physical mode */
+       {
+               srlz.i
+               /* Setup the memory stack */
+               add     r12=(memory_stack_end - relocate_new_kernel),gp
+               /* Setup the register stack */
+               add     r8=(register_stack - relocate_new_kernel),gp
+       }
+       ;;
+       mov     ar.bspstore=r8
+       ;;
+       loadrs
+       ;;
+       /* FIXME switch from virtual to physical mode */
+
+       /* Do the copies */
+       mov     r8=r32
+       mov     b6=r33
+       mov     r9=0
+       mov     r11=PAGE_SIZE
+       ;;
+       /* top, read another word for the indirection page */
+top:   ld8     r10=[r8], 8
+       ;;
+       tbit.nz p6,p0 = r10, 0  /* Is it a destination page? */
+       tbit.nz p7,p0 = r10, 1  /* Is it an indirection page? */
+       tbit.nz p8,p0 = r10, 3  /* Is it the source indicator? */
+       tbit.nz p9,p0 = r10, 2  /* Is it the done indicator? */
+       dep.z   r10 = r10, 0, 12 /* Clear the low bits of r10 */
+       ;;
+(p6)   mov     r9 = r10        /* destination addr */
+(p7)   mov     r8 = r10        /* indirection addr */
+(p8)   br.cond.sptk.few        source
+(p9)   br.cond.sptk.few        done
+       br.cond.sptk.few        top
+source:
+       add     r16 = r11, r10
+       add     r14 = 8, r10
+       add     r15 = 8, r9
+       ;;
+0:
+       ld8     r17 = [r10],16
+       ld8     r18 = [r14],16
+       ;;
+       st8     [r9]  = r17, 16
+       st8     [r15] = r18, 16
+       cmp.ne  p6,p0 = r16, r10
+       ;;
+(p6)   br.cond.sptk.few        0b
+       br.cond.sptk.few        top
+done:
+       srlz.i
+       srlz.d
+       ;;
+       br.call.sptk.few        b0=b6
+0:     br.cond.sptk.few        0b
+
+       .balign 8192
+register_stack:
+       .fill           8192, 1, 0
+register_stack_end:
+memory_stack:
+       .fill           8192, 1, 0
+memory_stack_end:
+relocate_new_kernel_end:
+       .globl relocate_new_kernel_size
+relocate_new_kernel_size:
+       .long relocate_new_kernel_end - relocate_new_kernel
diff -Nru a/include/asm-ia64/kexec.h b/include/asm-ia64/kexec.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/include/asm-ia64/kexec.h	2004-07-26 15:21:02 -07:00
@@ -0,0 +1,15 @@
+#ifndef _ASM_IA64_KEXEC_H
+#define _ASM_IA64_KEXEC_H
+
+
+/* Maximum physical address we can use pages from */
+#define KEXEC_SOURCE_MEMORY_LIMIT (-1UL)
+/* Maximum address we can reach in physical address mode */
+#define KEXEC_DESTINATION_MEMORY_LIMIT (-1UL)
+
+/* Zone to allocate memory from */
+#define GFP_KEXEC GFP_KERNEL
+
+#define KEXEC_REBOOT_CODE_SIZE (8192 + 8192 + 4096)
+
+#endif /* _ASM_IA64_KEXEC_H */
diff -Nru a/include/asm-ia64/mmu_context.h b/include/asm-ia64/mmu_context.h
--- a/include/asm-ia64/mmu_context.h	2004-07-26 15:21:02 -07:00
+++ b/include/asm-ia64/mmu_context.h	2004-07-26 15:21:02 -07:00
@@ -203,5 +203,7 @@
 
 #define switch_mm(prev_mm,next_mm,next_task)	activate_mm(prev_mm, next_mm)
 
+extern void use_mm(struct mm_struct *mm);
+
 # endif /* ! __ASSEMBLY__ */
 #endif /* _ASM_IA64_MMU_CONTEXT_H */

--Boundary-00=_oSYBBKNk8UrDrVd--
