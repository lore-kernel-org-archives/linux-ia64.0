From: Khalid Aziz <khalid_aziz@hp.com>
Date: Tue, 16 Nov 2004 19:37:58 +0000
Subject: [PATCH] Fix for kexec reboot failing after multiple continued
Message-Id: <1100633878.21234.15.camel@lyra.fc.hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-4yeb+qv4BJGszX3jwecb"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--=-4yeb+qv4BJGszX3jwecb
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

kexec patch I had sent out earlier has bug where it appends
"kexec_reboot" to kernel parameters blindly. After several kexec reboots
from kexec'd kernel, kernel parameters line becomes too long and kernel
fails to boot. Attached patch  will cure this. Patch
kexec-ia64-reboot.diff can be applied on top of the previous patch I had
sent. Patch 2.6.8.1-kexec3-ia64-2.diff includes this fix and is
repalcement for my previous patch. 

My current kexec patches for ia64 can also be found at
<http://free.linux.hp.com/~khalid/kexec-ia64/>.

-- 
Khalid

====================================================================
Khalid Aziz                                Linux and Open Source Lab
(970)898-9214                                        Hewlett-Packard
khalid_aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
				- Alessandro Rubini


--=-4yeb+qv4BJGszX3jwecb
Content-Disposition: attachment; filename=kexec-ia64-reboot.diff
Content-Type: text/x-patch; name=kexec-ia64-reboot.diff; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit

diff -urN linux-2.6.8-kexec/arch/ia64/kernel/machine_kexec.c linux-2.6.8-ia64/arch/ia64/kernel/machine_kexec.c
--- linux-2.6.8-kexec/arch/ia64/kernel/machine_kexec.c	2004-11-16 11:09:19.000000000 -0700
+++ linux-2.6.8-ia64/arch/ia64/kernel/machine_kexec.c	2004-11-16 11:10:59.000000000 -0700
@@ -22,6 +22,7 @@
 static struct ia64_boot_param boot_param;
 extern unsigned long saved_efi_memmap_size;
 extern void *saved_efi_memmap;
+extern unsigned long kexec_reboot;
 
 static void set_io_base(void)
 {
@@ -155,7 +156,8 @@
 	 */
 	control_code_buffer = relocate_new_kernel;
 	rnk = &control_code_buffer;
-	strcat(saved_command_line, " kexec_reboot");
+	if (!kexec_reboot)
+		strcat(saved_command_line, " kexec_reboot");
 	cmdline = __va(ia64_boot_param->command_line);
 	strlcpy(cmdline, saved_command_line, COMMAND_LINE_SIZE);
 	/* Restore original EFI memory map */

--=-4yeb+qv4BJGszX3jwecb
Content-Disposition: attachment; filename=2.6.8.1-kexec3-ia64-2.diff
Content-Type: text/x-patch; name=2.6.8.1-kexec3-ia64-2.diff; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit

diff -urN linux-2.6.8/arch/ia64/Kconfig linux-2.6.8-ia64/arch/ia64/Kconfig
--- linux-2.6.8/arch/ia64/Kconfig	2004-08-13 23:38:04.000000000 -0600
+++ linux-2.6.8-ia64/arch/ia64/Kconfig	2004-11-12 09:32:23.000000000 -0700
@@ -278,6 +278,23 @@
 	  little bigger and slows down execution a bit, but it is generally
 	  a good idea to turn this on.  If you're unsure, say Y.
 
+config KEXEC
+	bool "kexec system call (EXPERIMENTAL)"
+	depends on EXPERIMENTAL
+	help
+         kexec is a system call that implements the ability to shutdown your
+         current kernel, and to start another kernel.  It is like a reboot
+         but it is indepedent of the system firmware.   And like a reboot
+         you can start any kernel with it, not just Linux.  
+       
+         The name comes from the similiarity to the exec system call. 
+       
+         It is an ongoing process to be certain the hardware in a machine
+         is properly shutdown, so do not be surprised if this code does not
+         initially work for you.  It may help to enable device hotplugging
+         support.  As of this writing the exact hardware interface is
+         strongly in flux, so no good recommendation can be made.
+
 config IA64_PALINFO
 	tristate "/proc/pal support"
 	help
diff -urN linux-2.6.8/arch/ia64/kernel/Makefile linux-2.6.8-ia64/arch/ia64/kernel/Makefile
--- linux-2.6.8/arch/ia64/kernel/Makefile	2004-08-13 23:38:09.000000000 -0600
+++ linux-2.6.8-ia64/arch/ia64/kernel/Makefile	2004-11-12 09:32:23.000000000 -0700
@@ -17,6 +17,7 @@
 obj-$(CONFIG_SMP)		+= smp.o smpboot.o
 obj-$(CONFIG_PERFMON)		+= perfmon_default_smpl.o
 obj-$(CONFIG_IA64_CYCLONE)	+= cyclone.o
+obj-$(CONFIG_KEXEC)		+= machine_kexec.o relocate_kernel.o
 
 # The gate DSO image is built using a special linker script.
 targets += gate.so gate-syms.o
diff -urN linux-2.6.8/arch/ia64/kernel/efi.c linux-2.6.8-ia64/arch/ia64/kernel/efi.c
--- linux-2.6.8/arch/ia64/kernel/efi.c	2004-08-13 23:36:13.000000000 -0600
+++ linux-2.6.8-ia64/arch/ia64/kernel/efi.c	2004-11-15 11:05:39.000000000 -0700
@@ -17,6 +17,9 @@
  *
  * Goutham Rao: <goutham.rao@intel.com>
  *	Skip non-WB memory and ignore empty memory ranges.
+ *
+ * Nov 12, 2004: Added initial support for kexec 
+ * 				- Khalid Aziz <khalid.aziz@hp.com>
  */
 #include <linux/config.h>
 #include <linux/module.h>
@@ -37,6 +40,10 @@
 extern efi_status_t efi_call_phys (void *, ...);
 
 struct efi efi;
+#ifdef CONFIG_KEXEC
+unsigned long kexec_reboot = 0;
+unsigned long saved_efi_memmap_size;
+#endif
 EXPORT_SYMBOL(efi);
 static efi_runtime_services_t *runtime;
 static unsigned long mem_limit = ~0UL, max_addr = ~0UL;
@@ -464,6 +471,9 @@
 		 * Cannot write to CRx with PSR.ic=1
 		 */
 		psr = ia64_clear_ic();
+#if CONFIG_KEXEC
+		ia64_ptr(0x01, vaddr & mask, IA64_GRANULE_SHIFT);
+#endif
 		ia64_itr(0x1, IA64_TR_PALCODE, vaddr & mask,
 			 pte_val(pfn_pte(md->phys_addr >> PAGE_SHIFT, PAGE_KERNEL)),
 			 IA64_GRANULE_SHIFT);
@@ -503,6 +513,14 @@
 			if (end != cp)
 				break;
 			cp = end;
+#ifdef CONFIG_KEXEC
+		} else if (memcmp(cp, "kexec_reboot", 12) == 0) {
+			cp += 12;
+			kexec_reboot = 1;
+			if (end != cp)
+				break;
+			cp = end;
+#endif
 		} else {
 			while (*cp != ' ' && *cp)
 				++cp;
@@ -595,6 +613,9 @@
 	}
 #endif
 
+#ifdef CONFIG_KEXEC
+	saved_efi_memmap_size = ia64_boot_param->efi_memmap_size;
+#endif
 	efi_map_pal_code();
 	efi_enter_virtual_mode();
 }
@@ -647,10 +668,17 @@
 		}
 	}
 
-	status = efi_call_phys(__va(runtime->set_virtual_address_map),
+#ifdef CONFIG_KEXEC
+	if (kexec_reboot == 0)
+		status = efi_call_phys(__va(runtime->set_virtual_address_map),
 			       ia64_boot_param->efi_memmap_size,
 			       efi_desc_size, ia64_boot_param->efi_memdesc_version,
 			       ia64_boot_param->efi_memmap);
+	else {
+		printk(KERN_INFO "kexec'd kernel: Not virtualizing EFI\n");
+		status = EFI_SUCCESS;
+	}
+#endif
 	if (status != EFI_SUCCESS) {
 		printk(KERN_WARNING "warning: unable to switch EFI into virtual mode "
 		       "(status=%lu)\n", status);
diff -urN linux-2.6.8/arch/ia64/kernel/entry.S linux-2.6.8-ia64/arch/ia64/kernel/entry.S
--- linux-2.6.8/arch/ia64/kernel/entry.S	2004-08-13 23:36:32.000000000 -0600
+++ linux-2.6.8-ia64/arch/ia64/kernel/entry.S	2004-11-12 09:32:23.000000000 -0700
@@ -1525,7 +1525,7 @@
 	data8 sys_mq_timedreceive		// 1265
 	data8 sys_mq_notify
 	data8 sys_mq_getsetattr
-	data8 sys_ni_syscall			// reserved for kexec_load
+	data8 sys_kexec_load
 	data8 sys_ni_syscall
 	data8 sys_ni_syscall			// 1270
 	data8 sys_ni_syscall
diff -urN linux-2.6.8/arch/ia64/kernel/machine_kexec.c linux-2.6.8-ia64/arch/ia64/kernel/machine_kexec.c
--- linux-2.6.8/arch/ia64/kernel/machine_kexec.c	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.8-ia64/arch/ia64/kernel/machine_kexec.c	2004-11-16 11:10:59.000000000 -0700
@@ -0,0 +1,181 @@
+/*
+ * machine_kexec.c - handle transition of Linux booting another kernel
+ * Copyright (C) 2004 Khalid Aziz <khalid.aziz@hp.com>
+ * Copyright (C) 2004 Hewlett Packard Development Co
+ *
+ * This source code is licensed under the GNU General Public License,
+ * Version 2.  See the file COPYING for more details.
+ */
+
+#include <linux/kernel.h>
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/kexec.h>
+#include <asm/mmu_context.h>
+#include <asm/setup.h>
+#include <asm/mca.h>
+#include <asm/page.h>
+#include <asm/bitops.h>
+
+#define PHYS_UNCACHED_OFFSET	0x8000000000000000
+extern unsigned long ia64_iobase;
+static struct ia64_boot_param boot_param;
+extern unsigned long saved_efi_memmap_size;
+extern void *saved_efi_memmap;
+extern unsigned long kexec_reboot;
+
+static void set_io_base(void)
+{
+	unsigned long phys_iobase;
+
+	/* set kr0 to iobase */
+	phys_iobase = __pa(ia64_iobase);
+	ia64_set_kr(IA64_KR_IO_BASE, PHYS_UNCACHED_OFFSET | phys_iobase);
+};
+
+typedef void (*relocate_new_kernel_t)(
+	unsigned long indirection_page, unsigned long start_address, 
+	unsigned long boot_param_address);
+
+//extern void relocate_new_kernel(unsigned long indirection_page, 
+//				unsigned long start_address,
+//				unsigned long boot_param_address);
+const extern unsigned long relocate_new_kernel[];
+const extern unsigned int relocate_new_kernel_size;
+extern void use_mm(struct mm_struct *mm);
+
+const extern unsigned char test_loader[];
+extern void test_loader_end(void);
+const extern unsigned int test_loader_size;
+
+volatile extern long kexec_cont;
+const extern unsigned char kexec_reloc[];
+extern long kexec_ptcebase, kexec_count0, kexec_count1;
+extern long kexec_stride0, kexec_stride1;
+extern long kexec_tlblist;
+
+
+/*
+ * Do what every setup is needed on image and the
+ * reboot code buffer to allow us to avoid allocations
+ * later.  Currently nothing.
+ */
+int machine_kexec_prepare(struct kimage *image)
+{
+	return 0;
+}
+
+void machine_kexec_cleanup(struct kimage *image)
+{
+}
+
+void machine_shutdown(void)
+{
+#ifdef CONFIG_SMP
+	int reboot_cpu_id;
+
+	/* The boot cpu is always logical cpu 0 */
+	reboot_cpu_id = 0;
+
+	/* Make certain the cpu I'm rebooting on is online */
+	if (!cpu_isset(reboot_cpu_id, cpu_online_map)) {
+		reboot_cpu_id = smp_processor_id();
+	}
+
+	/* Make certain I only run on the appropriate processor */
+	set_cpus_allowed(current, cpumask_of_cpu(reboot_cpu_id));
+	
+	/* O.K. Now that I'm on the appropriate processor, flush
+	 * TLB on all other CPUs and stop all of the others.
+	 */
+
+	/*smp_flush_tlb_all();*/
+	smp_send_stop();
+#endif
+}
+
+/*
+ * Do not allocate memory (or fail in any way) in machine_kexec().
+ * We are past the point of no return, committed to rebooting now. 
+ */
+void machine_kexec(struct kimage *image)
+{
+	unsigned long indirection_page;
+	void *control_code_buffer;
+	relocate_new_kernel_t rnk;
+	unsigned char *cmdline;
+	int cpu;
+	void *efi_map_start;
+
+	/* Interrupts aren't acceptable while we reboot */
+	local_irq_disable();
+
+
+	control_code_buffer = ((unsigned long)phys_to_virt(page_to_pfn(image->control_code_page) << PAGE_SHIFT) & (unsigned long)0x1fffffffffffffffL) | __IA64_UNCACHED_OFFSET;
+	indirection_page = image->head & PAGE_MASK;
+
+	/* copy it out */
+	memcpy((void *)control_code_buffer, relocate_new_kernel, relocate_new_kernel_size);
+
+#if 0
+	/* Build boot parameter list */
+	boot_param.efi_systab = ia64_tpa(efi.systab);
+	boot_param.efi_memmap = ia64_boot_param->efi_memmap;
+	boot_param.efi_memmap_size = ia64_boot_param->efi_memmap_size;
+	boot_param.efi_memdesc_size = ia64_boot_param->efi_memdesc_size;
+	boot_param.efi_memdesc_version = ia64_boot_param->efi_memdesc_version;
+	boot_param.fpswa = ia64_boot_param->fpswa;
+#endif
+
+	kexec_cont = (long)(page_to_pfn(image->control_code_page) << PAGE_SHIFT) + (long)kexec_reloc -  (long) relocate_new_kernel;
+
+	/* Save PTCE data for cache flush later */
+        kexec_ptcebase    = local_cpu_data->ptce_base; 
+	kexec_count0  = local_cpu_data->ptce_count[0]; 
+	kexec_count1  = local_cpu_data->ptce_count[1];
+	kexec_stride0 = local_cpu_data->ptce_stride[0];
+        kexec_stride1 = local_cpu_data->ptce_stride[1];
+
+	/* Save PAL mapping for TR flush later */
+	cpu = smp_processor_id();
+	kexec_tlblist = &ia64_mca_tlb_list;
+
+	/* set kr0 to the appropriate address */
+	set_io_base();
+
+	/* now execute the control code 
+	 * We will start by executing the control code linked into the 
+	 * kernel as opposed to the code we copied in control code buffer		 * page. When this code switches to physical mode, we will start
+	 * executing the code in control code buffer page. Reason for
+	 * doing this is we start code execution in virtual address space.
+	 * If we were to try to execute the newly copied code in virtual
+	 * address space, we will need to make an ITLB entry to avoid ITLB 
+	 * miss. By executing the code linked into kernel, we take advantage
+	 * of the ITLB entry already in place of kernel and avoid making
+	 * a new entry.
+	 */
+	control_code_buffer = relocate_new_kernel;
+	rnk = &control_code_buffer;
+	if (!kexec_reboot)
+		strcat(saved_command_line, " kexec_reboot");
+	cmdline = __va(ia64_boot_param->command_line);
+	strlcpy(cmdline, saved_command_line, COMMAND_LINE_SIZE);
+	/* Restore original EFI memory map */
+	memcpy(__va(ia64_boot_param->efi_memmap), saved_efi_memmap, saved_efi_memmap_size);
+	ia64_boot_param->efi_memmap_size = saved_efi_memmap_size;
+
+	{
+		unsigned long pta, impl_va_bits;
+
+#       define pte_bits                 3
+#       define vmlpt_bits               (impl_va_bits - PAGE_SHIFT + pte_bits)
+#       define POW2(n)                  (1ULL << (n))
+
+		/* Disable VHPT */
+		impl_va_bits = ffz(~(local_cpu_data->unimpl_va_mask | (7UL << 61)));
+		pta = POW2(61) - POW2(vmlpt_bits);
+		ia64_set_pta(pta | (0 << 8) | (vmlpt_bits << 2) | 0);
+	}
+
+	rnk(indirection_page, image->start, ia64_boot_param);
+}
diff -urN linux-2.6.8/arch/ia64/kernel/relocate_kernel.S linux-2.6.8-ia64/arch/ia64/kernel/relocate_kernel.S
--- linux-2.6.8/arch/ia64/kernel/relocate_kernel.S	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.8-ia64/arch/ia64/kernel/relocate_kernel.S	2004-11-12 09:47:14.000000000 -0700
@@ -0,0 +1,228 @@
+/*
+ * relocate_kernel.S - put the kernel image in place to boot
+ * Copyright (C) 2002-2004 Eric Biederman  <ebiederm@xmission.com>
+ * Copyright (C) 2004 Khalid Aziz <khalid.aziz@hp.com>
+ * Copyright (C) 2004 Hewlett Packard Development Co
+ *
+ * This source code is licensed under the GNU General Public License,
+ * Version 2.  See the file COPYING for more details.
+ */
+#include <linux/config.h>
+#include <asm/asmmacro.h>
+#include <asm/kregs.h>
+#include <asm/page.h>
+#include <asm/pgtable.h>
+
+       /* Must be relocatable PIC code callable as a C function, that once
+        * it starts can not use the previous processes stack.
+        *
+        */
+       /* Q: Do I want to setup an interrupt vector, so what happens
+        * when exceptions occur is well defined?
+        */
+	.text
+	.align 32
+	.global relocate_new_kernel#
+	.proc relocate_new_kernel#
+relocate_new_kernel:
+	mf
+	;;
+	/* Save the ptce information for translation cache purge later */
+	movl	r25=kexec_cont
+	movl	r27=kexec_ptcebase
+	movl	r28=kexec_count0
+	;;
+	ld8	r17=[r25]
+	ld8	r22=[r27]
+	ld8	r20=[r28]
+	;;
+	movl	r25=kexec_count1
+	movl	r27=kexec_stride0
+	movl	r28=kexec_stride1
+	;;
+	ld8	r21=[r25]
+	ld8	r23=[r27]
+	ld8	r24=[r28]
+	;;
+	movl	r27=kexec_tlblist
+	adds 	r25=48,r27
+	;;
+	ld8	r26=[r25]
+
+	{
+		flushrs
+		srlz.i
+	}
+	;;
+       /* See where I am running, and compute gp */
+	{
+		mov     ar.rsc = 0      /* Put RSE in enforce lacy, LE mode */
+		mov     gp = ip         /* gp == relocate_new_kernel */
+	}
+
+	movl r8=0x00000100000000
+	;;
+	mov cr.iva=r8
+
+	/* Transition from virtual to physical mode */
+	rsm	psr.i | psr.ic
+	srlz.i
+	movl	r16=(IA64_PSR_AC | IA64_PSR_BN | IA64_PSR_IC | IA64_PSR_MFL)
+	;;
+	mov	cr.ipsr=r16
+	;;
+	mov	cr.iip=r17
+	mov	cr.ifs=r0
+	;;
+	rfi
+	;;
+	.global kexec_reloc
+kexec_reloc:     /* Now we are in physical mode */
+	/* Setup the memory stack */
+	add     r12=(memory_stack_end - relocate_new_kernel),gp
+	/* Setup the register stack */
+	add     r8=(register_stack - relocate_new_kernel),gp
+	;;
+	loadrs
+	;;
+	mov     ar.bspstore=r8
+	;;
+
+	/* Do the copies */
+	mov     r8=r32
+	mov     b6=r33
+	tpa     r28=r34
+	mov     r9=0
+	mov     r11=PAGE_SIZE
+	;;
+	/* top, read another word for the indirection page */
+top:   ld8     r10=[r8], 8
+	;;
+	tbit.nz p6,p0 = r10, 0  /* Is it a destination page? */
+	tbit.nz p7,p0 = r10, 1  /* Is it an indirection page? */
+	tbit.nz p8,p0 = r10, 3  /* Is it the source indicator? */
+	tbit.nz p9,p0 = r10, 2  /* Is it the done indicator? */
+	addl	r19 = -4096, r0
+	;;
+	and	r10 = r10, r19	/* Clear the low 12 bits of r10 */
+	;;
+(p6)   mov     r9 = r10        /* destination addr */
+(p7)   mov     r8 = r10        /* indirection addr */
+(p8)   br.cond.sptk.few        source
+(p9)   br.cond.sptk.few        done
+	br.cond.sptk.few        top
+source:
+	add     r16 = r11, r10
+	add     r14 = 8, r10
+	add     r15 = 8, r9
+	;;
+0:
+	ld8     r17 = [r10],16
+	ld8     r18 = [r14],16
+	;;
+	st8     [r9]  = r17, 16
+	st8     [r15] = r18, 16
+	cmp.ne  p6,p0 = r16, r10
+	;;
+(p6)   br.cond.sptk.few        0b
+	br.cond.sptk.few        top
+done:
+	srlz.i
+	srlz.d
+	;;
+
+	/* Now purge local tlb */
+	mov r19 = r0
+	adds	r21=-1,r20
+	;;
+2:
+	cmp.ltu	p6,p7=r19,r20
+(p7)	br.cond.dpnt.few	4f
+	mov	ar.lc=r21
+3:
+	ptc.e	r22
+	;;
+	add	r22=r24,r22
+	br.cloop.sptk.few	3b
+	;;
+	add	r22=r23,r22
+	add	r19=1,r19
+	;;
+	br.sptk.few	2b
+4:
+	srlz.i ;;
+	
+       // Now purge addresses formerly mapped by TR registers
+	// Purge ITR&DTR for kernel.
+	movl r16=KERNEL_START
+	mov r18=KERNEL_TR_PAGE_SHIFT<<2
+	;;
+	ptr.i r16, r18
+	ptr.d r16, r18
+	;;
+	srlz.i
+	;;
+	srlz.d
+	;;
+	// Purge DTR for PERCPU data.
+	movl r16=PERCPU_ADDR
+	mov r18=PERCPU_PAGE_SHIFT<<2
+	;;
+	ptr.d r16,r18
+	;;
+	srlz.d
+	;;
+	// Purge ITR for PAL code
+	mov r18=IA64_GRANULE_SHIFT<<2
+	;;
+	ptr.i r26,r18
+	;;
+	srlz.i
+	;;
+	// Purge DTR for stack.
+	mov r16=IA64_KR(CURRENT_STACK)
+	;;
+	shl r16=r16,IA64_GRANULE_SHIFT
+	movl r19=PAGE_OFFSET
+	;;
+	add r16=r19,r16
+	mov r18=IA64_GRANULE_SHIFT<<2
+	;;
+	ptr.d r16,r18
+	;;
+	srlz.i
+	;;
+
+	br.sptk.few		b6
+	br.cond.sptk.few        0b
+	.endp relocate_new_kernel#
+
+	.balign 8192
+relocate_new_kernel_end:
+	.global relocate_new_kernel_size
+relocate_new_kernel_size:
+	.long relocate_new_kernel_end - relocate_new_kernel
+
+	.global kexec_cont
+	.align 8
+kexec_cont:	data8 0xdeadbeefdeadbeef
+	.global kexec_ptcebase
+kexec_ptcebase:	data8 0xdeadbeefdeadbeef
+	.global kexec_count0
+kexec_count0:	data8 0xdeadbeefdeadbeef
+	.global kexec_count1
+kexec_count1:	data8 0xdeadbeefdeadbeef
+	.global kexec_stride0
+kexec_stride0:	data8 0xdeadbeefdeadbeef
+	.global kexec_stride1
+kexec_stride1:	data8 0xdeadbeefdeadbeef
+	.global kexec_tlblist
+kexec_tlblist:	data8 0xdeadbeefdeadbeef
+
+
+register_stack:
+	.fill           8192, 1, 0
+register_stack_end:
+memory_stack:
+	.fill           8192, 1, 0
+memory_stack_end:
diff -urN linux-2.6.8/arch/ia64/mm/contig.c linux-2.6.8-ia64/arch/ia64/mm/contig.c
--- linux-2.6.8/arch/ia64/mm/contig.c	2004-08-13 23:36:45.000000000 -0600
+++ linux-2.6.8-ia64/arch/ia64/mm/contig.c	2004-11-15 12:22:15.000000000 -0700
@@ -29,6 +29,11 @@
 static unsigned long num_dma_physpages;
 #endif
 
+#ifdef CONFIG_KEXEC
+void *saved_efi_memmap;
+extern unsigned long saved_efi_memmap_size;
+#endif
+
 /**
  * show_mem - display a memory statistics summary
  *
@@ -164,6 +169,11 @@
 	/* Free all available memory, then mark bootmem-map as being in use. */
 	efi_memmap_walk(filter_rsvd_memory, free_bootmem);
 	reserve_bootmem(bootmap_start, bootmap_size);
+#ifdef CONFIG_KEXEC
+	/* Save EFI memory map for use later when kexec'ing a kernel */
+	saved_efi_memmap = alloc_bootmem(saved_efi_memmap_size);
+	memcpy(saved_efi_memmap, __va(ia64_boot_param->efi_memmap), saved_efi_memmap_size);
+#endif
 
 	find_initrd();
 }
diff -urN linux-2.6.8/arch/ia64/mm/discontig.c linux-2.6.8-ia64/arch/ia64/mm/discontig.c
--- linux-2.6.8/arch/ia64/mm/discontig.c	2004-11-12 09:48:47.000000000 -0700
+++ linux-2.6.8-ia64/arch/ia64/mm/discontig.c	2004-11-15 12:29:40.000000000 -0700
@@ -40,6 +40,11 @@
 
 static struct early_node_data mem_data[NR_NODES] __initdata;
 
+#ifdef CONFIG_KEXEC
+void *saved_efi_memmap;
+extern unsigned long saved_efi_memmap_size;
+#endif
+
 /**
  * reassign_cpu_only_nodes - called from find_memory to move CPU-only nodes to a memory node
  *
@@ -459,6 +464,12 @@
 	reserve_pernode_space();
 	initialize_pernode_data();
 
+#ifdef CONFIG_KEXEC
+	/* Save EFI memory map for use later when kexec'ing a kernel */
+	saved_efi_memmap = alloc_bootmem(saved_efi_memmap_size);
+	memcpy(saved_efi_memmap, __va(ia64_boot_param->efi_memmap), saved_efi_memmap_size);
+#endif
+
 	max_pfn = max_low_pfn;
 
 	find_initrd();
diff -urN linux-2.6.8/include/asm-ia64/kexec.h linux-2.6.8-ia64/include/asm-ia64/kexec.h
--- linux-2.6.8/include/asm-ia64/kexec.h	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.8-ia64/include/asm-ia64/kexec.h	2004-11-12 09:32:23.000000000 -0700
@@ -0,0 +1,14 @@
+#ifndef _ASM_IA64_KEXEC_H
+#define _ASM_IA64_KEXEC_H
+
+
+/* Maximum physical address we can use pages from */
+#define KEXEC_SOURCE_MEMORY_LIMIT (-1UL)
+/* Maximum address we can reach in physical address mode */
+#define KEXEC_DESTINATION_MEMORY_LIMIT (-1UL)
+/* Maximum address we can use for the control code buffer */
+#define KEXEC_CONTROL_MEMORY_LIMIT TASK_SIZE
+
+#define KEXEC_CONTROL_CODE_SIZE (8192 + 8192 + 4096)
+
+#endif /* _ASM_IA64_KEXEC_H */
diff -urN linux-2.6.8/include/asm-ia64/mmu_context.h linux-2.6.8-ia64/include/asm-ia64/mmu_context.h
--- linux-2.6.8/include/asm-ia64/mmu_context.h	2004-08-13 23:36:16.000000000 -0600
+++ linux-2.6.8-ia64/include/asm-ia64/mmu_context.h	2004-11-12 09:32:23.000000000 -0700
@@ -203,5 +203,7 @@
 
 #define switch_mm(prev_mm,next_mm,next_task)	activate_mm(prev_mm, next_mm)
 
+extern void use_mm(struct mm_struct *mm);
+
 # endif /* ! __ASSEMBLY__ */
 #endif /* _ASM_IA64_MMU_CONTEXT_H */
diff -urN linux-2.6.8/kernel/sys.c linux-2.6.8-ia64/kernel/sys.c
--- linux-2.6.8/kernel/sys.c	2004-11-12 09:28:23.000000000 -0700
+++ linux-2.6.8-ia64/kernel/sys.c	2004-11-12 09:32:23.000000000 -0700
@@ -516,7 +516,7 @@
 			return -EINVAL;
 		}
 		notifier_call_chain(&reboot_notifier_list, SYS_RESTART, NULL);
-		system_state = SYSTEM_BOOTING;
+		system_state = SYSTEM_RESTART;
 		device_shutdown();
 		printk(KERN_EMERG "Starting new kernel\n");
 		machine_shutdown();

--=-4yeb+qv4BJGszX3jwecb--

