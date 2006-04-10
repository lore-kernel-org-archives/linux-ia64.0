From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 10 Apr 2006 18:58:31 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200604101858.k3AIwV02007557@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Bugfixes, cleanups, new syscalls, oh my!

Thanks!

-Tony

 arch/ia64/kernel/acpi-ext.c       |  143 ++++++++++++++++++--------------------
 arch/ia64/kernel/entry.S          |    7 +
 arch/ia64/kernel/mca.c            |   33 +++++---
 arch/ia64/kernel/mca_asm.S        |   10 +-
 arch/ia64/kernel/module.c         |    2 
 arch/ia64/mm/fault.c              |    3 
 arch/ia64/sn/kernel/xpc_channel.c |    2 
 include/asm-ia64/acpi-ext.h       |   11 +-
 include/asm-ia64/kdebug.h         |    2 
 include/asm-ia64/mca.h            |    5 +
 include/asm-ia64/mutex.h          |    2 
 include/asm-ia64/unistd.h         |    7 +
 include/asm-ia64/vga.h            |    2 
 13 files changed, 128 insertions(+), 101 deletions(-)

Bjorn Helgaas:
      [IA64] update HP CSR space discovery via ACPI
      [IA64] always map VGA framebuffer UC, even if it supports WB

Chen, Kenneth W:
      [IA64] fix bug in ia64 __mutex_fastpath_trylock

Christoph Lameter:
      [IA64] Prefetch mmap_sem in ia64_do_page_fault()

KAMEZAWA Hiroyuki:
      [IA64] for_each_possible_cpu: ia64

Keith Owens:
      [IA64] Pass more data to the MCA/INIT notify_die hooks
      [IA64] Failure to resume after INIT in user space

Tony Luck:
      [IA64] Wire up new syscall sync_file_range()
      [IA64] 'msg' may be used uninitialized in xpc_initiate_allocate()
      [IA64] Wire up new syscalls {set,get}_robust_list


Full "git whatchanged -" output:

diff-tree 0ffe984917b9cd6ecc19ffbc06f35869d8c18df8 (from 8cab7ccccbdd9fe3cf6b3400d5a88ecb683a5b1b)
Author: Christoph Lameter <clameter@sgi.com>
Date:   Tue Mar 28 22:54:38 2006 -0800

    [IA64] Prefetch mmap_sem in ia64_do_page_fault()
    
    Take a hint from an x86_64 optimization by Arjan van de Ven and use it
    for ia64.  See a9ba9a3b3897561d01e04cd21433746df46548c0
    
    Prefetch the mmap_sem, which is critical for the performance of the page fault
    handler.
    
    Note: mm may be NULL but I guess that is safe.
    See 458f935527372499b714bf4f8e646a68bb0f52e3
    
    Signed-off-by: Christoph Lameter <clameter@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index af7eb08..d98ec49 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -60,6 +60,9 @@ ia64_do_page_fault (unsigned long addres
 	struct siginfo si;
 	unsigned long mask;
 
+	/* mmap_sem is performance critical.... */
+	prefetchw(&mm->mmap_sem);
+
 	/*
 	 * If we're in an interrupt or have no user context, we must not take the fault..
 	 */

diff-tree 8cab7ccccbdd9fe3cf6b3400d5a88ecb683a5b1b (from 958b166c00b39ff0b28ad2bbb32624b9f305a4e1)
Author: Keith Owens <kaos@sgi.com>
Date:   Fri Apr 7 16:34:34 2006 +1000

    [IA64] Failure to resume after INIT in user space
    
    The OS INIT handler is loading incorrect values into cr.ifa on exit.
    This shows up as a hang when resuming after an INIT that is delivered
    while a cpu is in user space.  Correct the value loaded into cr.ifa.
    
    Signed-off-by: Keith Owens <kaos@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/mca_asm.S b/arch/ia64/kernel/mca_asm.S
index 60a464b..6dff024 100644
--- a/arch/ia64/kernel/mca_asm.S
+++ b/arch/ia64/kernel/mca_asm.S
@@ -827,7 +827,7 @@ ia64_state_restore:
 	ld8 r9=[temp2],16	// sal_gp
 	;;
 	ld8 r22=[temp1],16	// pal_min_state, virtual
-	ld8 r21=[temp2],16	// prev_IA64_KR_CURRENT
+	ld8 r13=[temp2],16	// prev_IA64_KR_CURRENT
 	;;
 	ld8 r16=[temp1],16	// prev_IA64_KR_CURRENT_STACK
 	ld8 r20=[temp2],16	// prev_task
@@ -848,7 +848,7 @@ ia64_state_restore:
 	mov cr.iim=temp3
 	mov cr.iha=temp4
 	dep r22=0,r22,62,1	// pal_min_state, physical, uncached
-	mov IA64_KR(CURRENT)=r21
+	mov IA64_KR(CURRENT)=r13
 	ld8 r8=[temp1]		// os_status
 	ld8 r10=[temp2]		// context
 
@@ -856,7 +856,7 @@ ia64_state_restore:
 	 * avoid any dependencies on the algorithm in ia64_switch_to(), just
 	 * purge any existing CURRENT_STACK mapping and insert the new one.
 	 *
-	 * r16 contains prev_IA64_KR_CURRENT_STACK, r21 contains
+	 * r16 contains prev_IA64_KR_CURRENT_STACK, r13 contains
 	 * prev_IA64_KR_CURRENT, these values may have been changed by the C
 	 * code.  Do not use r8, r9, r10, r22, they contain values ready for
 	 * the return to SAL.
@@ -873,7 +873,7 @@ ia64_state_restore:
 	;;
 	srlz.d
 
-	extr.u r19=r21,61,3			// r21 = prev_IA64_KR_CURRENT
+	extr.u r19=r13,61,3			// r13 = prev_IA64_KR_CURRENT
 	shl r20=r16,IA64_GRANULE_SHIFT		// r16 = prev_IA64_KR_CURRENT_STACK
 	movl r21=PAGE_KERNEL			// page properties
 	;;
@@ -883,7 +883,7 @@ ia64_state_restore:
 (p6)	br.spnt 1f				// the dreaded cpu 0 idle task in region 5:(
 	;;
 	mov cr.itir=r18
-	mov cr.ifa=r21
+	mov cr.ifa=r13
 	mov r20=IA64_TR_CURRENT_STACK
 	;;
 	itr.d dtr[r20]=r21

diff-tree 958b166c00b39ff0b28ad2bbb32624b9f305a4e1 (from 2db8d99ffdbed7d2beb1bbdefdcd086dda9dee98)
Author: Keith Owens <kaos@sgi.com>
Date:   Mon Apr 3 15:26:12 2006 +1000

    [IA64] Pass more data to the MCA/INIT notify_die hooks
    
    The MCA/INIT handlers maintain important state in the SAL to OS (sos)
    area and in the monarch_cpu flag.  Kernel debuggers (such as KDB) need
    this data, and may need to adjust the monarch_cpu field so make the
    data available to the notify_die hooks.  Define two more events for
    calling the functions on the notify_die chain.
    
    Signed-off-by: Keith Owens <kaos@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 8963171..5e6fdbe 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -581,10 +581,12 @@ ia64_mca_rendez_int_handler(int rendez_i
 {
 	unsigned long flags;
 	int cpu = smp_processor_id();
+	struct ia64_mca_notify_die nd +		{ .sos = NULL, .monarch_cpu = &monarch_cpu };
 
 	/* Mask all interrupts */
 	local_irq_save(flags);
-	if (notify_die(DIE_MCA_RENDZVOUS_ENTER, "MCA", regs, 0, 0, 0)
+	if (notify_die(DIE_MCA_RENDZVOUS_ENTER, "MCA", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
 
@@ -594,7 +596,7 @@ ia64_mca_rendez_int_handler(int rendez_i
 	 */
 	ia64_sal_mc_rendez();
 
-	if (notify_die(DIE_MCA_RENDZVOUS_PROCESS, "MCA", regs, 0, 0, 0)
+	if (notify_die(DIE_MCA_RENDZVOUS_PROCESS, "MCA", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
 
@@ -602,7 +604,7 @@ ia64_mca_rendez_int_handler(int rendez_i
 	while (monarch_cpu != -1)
 	       cpu_relax();	/* spin until monarch leaves */
 
-	if (notify_die(DIE_MCA_RENDZVOUS_LEAVE, "MCA", regs, 0, 0, 0)
+	if (notify_die(DIE_MCA_RENDZVOUS_LEAVE, "MCA", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
 
@@ -1023,6 +1025,8 @@ ia64_mca_handler(struct pt_regs *regs, s
 		&sos->proc_state_param;
 	int recover, cpu = smp_processor_id();
 	task_t *previous_current;
+	struct ia64_mca_notify_die nd +		{ .sos = sos, .monarch_cpu = &monarch_cpu };
 
 	oops_in_progress = 1;	/* FIXME: make printk NMI/MCA/INIT safe */
 	console_loglevel = 15;	/* make sure printks make it to console */
@@ -1031,7 +1035,7 @@ ia64_mca_handler(struct pt_regs *regs, s
 
 	previous_current = ia64_mca_modify_original_stack(regs, sw, sos, "MCA");
 	monarch_cpu = cpu;
-	if (notify_die(DIE_MCA_MONARCH_ENTER, "MCA", regs, 0, 0, 0)
+	if (notify_die(DIE_MCA_MONARCH_ENTER, "MCA", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
 	ia64_wait_for_slaves(cpu);
@@ -1043,7 +1047,7 @@ ia64_mca_handler(struct pt_regs *regs, s
 	 * spinning in SAL does not work.
 	 */
 	ia64_mca_wakeup_all();
-	if (notify_die(DIE_MCA_MONARCH_PROCESS, "MCA", regs, 0, 0, 0)
+	if (notify_die(DIE_MCA_MONARCH_PROCESS, "MCA", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
 
@@ -1064,7 +1068,7 @@ ia64_mca_handler(struct pt_regs *regs, s
 		ia64_sal_clear_state_info(SAL_INFO_TYPE_MCA);
 		sos->os_status = IA64_MCA_CORRECTED;
 	}
-	if (notify_die(DIE_MCA_MONARCH_LEAVE, "MCA", regs, 0, 0, recover)
+	if (notify_die(DIE_MCA_MONARCH_LEAVE, "MCA", regs, (long)&nd, 0, recover)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
 
@@ -1351,10 +1355,14 @@ ia64_init_handler(struct pt_regs *regs, 
 	static atomic_t monarchs;
 	task_t *previous_current;
 	int cpu = smp_processor_id();
+	struct ia64_mca_notify_die nd +		{ .sos = sos, .monarch_cpu = &monarch_cpu };
 
 	oops_in_progress = 1;	/* FIXME: make printk NMI/MCA/INIT safe */
 	console_loglevel = 15;	/* make sure printks make it to console */
 
+	(void) notify_die(DIE_INIT_ENTER, "INIT", regs, (long)&nd, 0, 0);
+
 	printk(KERN_INFO "Entered OS INIT handler. PSP=%lx cpu=%d monarch=%ld\n",
 		sos->proc_state_param, cpu, sos->monarch);
 	salinfo_log_wakeup(SAL_INFO_TYPE_INIT, NULL, 0, 0);
@@ -1390,15 +1398,15 @@ ia64_init_handler(struct pt_regs *regs, 
 		ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_INIT;
 		while (monarch_cpu = -1)
 		       cpu_relax();	/* spin until monarch enters */
-		if (notify_die(DIE_INIT_SLAVE_ENTER, "INIT", regs, 0, 0, 0)
+		if (notify_die(DIE_INIT_SLAVE_ENTER, "INIT", regs, (long)&nd, 0, 0)
 				= NOTIFY_STOP)
 			ia64_mca_spin(__FUNCTION__);
-		if (notify_die(DIE_INIT_SLAVE_PROCESS, "INIT", regs, 0, 0, 0)
+		if (notify_die(DIE_INIT_SLAVE_PROCESS, "INIT", regs, (long)&nd, 0, 0)
 				= NOTIFY_STOP)
 			ia64_mca_spin(__FUNCTION__);
 		while (monarch_cpu != -1)
 		       cpu_relax();	/* spin until monarch leaves */
-		if (notify_die(DIE_INIT_SLAVE_LEAVE, "INIT", regs, 0, 0, 0)
+		if (notify_die(DIE_INIT_SLAVE_LEAVE, "INIT", regs, (long)&nd, 0, 0)
 				= NOTIFY_STOP)
 			ia64_mca_spin(__FUNCTION__);
 		printk("Slave on cpu %d returning to normal service.\n", cpu);
@@ -1409,7 +1417,7 @@ ia64_init_handler(struct pt_regs *regs, 
 	}
 
 	monarch_cpu = cpu;
-	if (notify_die(DIE_INIT_MONARCH_ENTER, "INIT", regs, 0, 0, 0)
+	if (notify_die(DIE_INIT_MONARCH_ENTER, "INIT", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
 
@@ -1426,10 +1434,10 @@ ia64_init_handler(struct pt_regs *regs, 
 	 * to default_monarch_init_process() above and just print all the
 	 * tasks.
 	 */
-	if (notify_die(DIE_INIT_MONARCH_PROCESS, "INIT", regs, 0, 0, 0)
+	if (notify_die(DIE_INIT_MONARCH_PROCESS, "INIT", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
-	if (notify_die(DIE_INIT_MONARCH_LEAVE, "INIT", regs, 0, 0, 0)
+	if (notify_die(DIE_INIT_MONARCH_LEAVE, "INIT", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
 	printk("\nINIT dump complete.  Monarch on cpu %d returning to normal service.\n", cpu);
@@ -1631,6 +1639,7 @@ ia64_mca_init(void)
 			printk(KERN_INFO "Increasing MCA rendezvous timeout from "
 				"%ld to %ld milliseconds\n", timeout, isrv.v0);
 			timeout = isrv.v0;
+			(void) notify_die(DIE_MCA_NEW_TIMEOUT, "MCA", NULL, timeout, 0, 0);
 			continue;
 		}
 		printk(KERN_ERR "Failed to register rendezvous interrupt "
diff --git a/include/asm-ia64/kdebug.h b/include/asm-ia64/kdebug.h
index 218c458..c195a9a 100644
--- a/include/asm-ia64/kdebug.h
+++ b/include/asm-ia64/kdebug.h
@@ -58,6 +58,8 @@ enum die_val {
 	DIE_MCA_RENDZVOUS_ENTER,
 	DIE_MCA_RENDZVOUS_PROCESS,
 	DIE_MCA_RENDZVOUS_LEAVE,
+	DIE_MCA_NEW_TIMEOUT,
+	DIE_INIT_ENTER,
 	DIE_INIT_MONARCH_ENTER,
 	DIE_INIT_MONARCH_PROCESS,
 	DIE_INIT_MONARCH_LEAVE,
diff --git a/include/asm-ia64/mca.h b/include/asm-ia64/mca.h
index bfbbb8d..9c5389b 100644
--- a/include/asm-ia64/mca.h
+++ b/include/asm-ia64/mca.h
@@ -148,6 +148,11 @@ extern int  ia64_reg_MCA_extension(int (
 extern void ia64_unreg_MCA_extension(void);
 extern u64 ia64_get_rnat(u64 *);
 
+struct ia64_mca_notify_die {
+	struct ia64_sal_os_state *sos;
+	int *monarch_cpu;
+};
+
 #else	/* __ASSEMBLY__ */
 
 #define IA64_MCA_CORRECTED	0x0	/* Error has been corrected by OS_MCA */

diff-tree 2db8d99ffdbed7d2beb1bbdefdcd086dda9dee98 (from cfab9d0e1da8e08a39759d0fc3bf5e40f0ac2d55)
Author: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date:   Fri Apr 7 22:47:12 2006 -0700

    [IA64] always map VGA framebuffer UC, even if it supports WB
    
    EFI on some machines, e.g., Intel Tiger, reports that the VGA framebuffer
    supports WB access.  ioremap() prefers WB when possible, so it can work
    when mapping main memory.
    
    But it doesn't make sense to map a framebuffer WB, because the driver
    doesn't flush explicitly, so updates won't make it to the device
    immediately.
    
    This is due to Zou Nan hai <nanhai.zou@intel.com>.
    
    More extensive fix that adds a "size" argument coming soon.
    
    Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
    Cc: "Antonino A. Daplas" <adaplas@pol.net>
    Cc: "Luck, Tony" <tony.luck@intel.com>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/asm-ia64/vga.h b/include/asm-ia64/vga.h
index bc3349f..091177c 100644
--- a/include/asm-ia64/vga.h
+++ b/include/asm-ia64/vga.h
@@ -17,7 +17,7 @@ #define __ASM_IA64_VGA_H_
 extern unsigned long vga_console_iobase;
 extern unsigned long vga_console_membase;
 
-#define VGA_MAP_MEM(x)	((unsigned long) ioremap(vga_console_membase + (x), 0))
+#define VGA_MAP_MEM(x)	((unsigned long) ioremap_nocache(vga_console_membase + (x), 0))
 
 #define vga_readb(x)	(*(x))
 #define vga_writeb(x,y)	(*(y) = (x))

diff-tree cfab9d0e1da8e08a39759d0fc3bf5e40f0ac2d55 (from 0681226661754a99de711cda2c2bd12ff9cd2c3b)
Author: Chen, Kenneth W <kenneth.w.chen@intel.com>
Date:   Fri Apr 7 17:12:54 2006 -0700

    [IA64] fix bug in ia64 __mutex_fastpath_trylock
    
    The parenthesis around "likely" used in ia64 __mutex_fastpath_trylock
    is incorrect, and it leads to broken mutex_trylock.  Here is the
    patch that fixed the bug.  I removed the likely altogether because
    there is no branch and gcc does a reasonable job at predicating the
    return value.
    
    Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/asm-ia64/mutex.h b/include/asm-ia64/mutex.h
index 5a3224f..bed73a6 100644
--- a/include/asm-ia64/mutex.h
+++ b/include/asm-ia64/mutex.h
@@ -84,7 +84,7 @@ #define __mutex_slowpath_needs_to_unlock
 static inline int
 __mutex_fastpath_trylock(atomic_t *count, int (*fail_fn)(atomic_t *))
 {
-	if (likely(cmpxchg_acq(count, 1, 0)) = 1)
+	if (cmpxchg_acq(count, 1, 0) = 1)
 		return 1;
 	return 0;
 }

diff-tree 0681226661754a99de711cda2c2bd12ff9cd2c3b (from 03fbaca36a85a8c923e30abfb1a9a630bf1c5a1d)
Author: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date:   Tue Mar 28 14:50:09 2006 -0800

    [IA64] for_each_possible_cpu: ia64
    
    for_each_cpu() actually iterates across all possible CPUs.  We've had mistakes
    in the past where people were using for_each_cpu() where they should have been
    iterating across only online or present CPUs.  This is inefficient and
    possibly buggy.
    
    We're renaming for_each_cpu() to for_each_possible_cpu() to avoid this in the
    future.
    
    This patch replaces for_each_cpu with for_each_possible_cpu under
    arch/ia64/kernel/.
    
    Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fjitsu.com>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/module.c b/arch/ia64/kernel/module.c
index 7a2f0a7..3a30cfc 100644
--- a/arch/ia64/kernel/module.c
+++ b/arch/ia64/kernel/module.c
@@ -947,7 +947,7 @@ void
 percpu_modcopy (void *pcpudst, const void *src, unsigned long size)
 {
 	unsigned int i;
-	for_each_cpu(i) {
+	for_each_possible_cpu(i) {
 		memcpy(pcpudst + __per_cpu_offset[i], src, size);
 	}
 }

diff-tree 03fbaca36a85a8c923e30abfb1a9a630bf1c5a1d (from b8cd2af862c3cbd428600e1c4f0d3f97c0da54cc)
Author: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date:   Tue Mar 28 14:06:20 2006 -0800

    [IA64] update HP CSR space discovery via ACPI
    
    Get rid of the manual search of _CRS, in favor of
    acpi_get_vendor_resource() which is now provided by the ACPI CA.  And fall
    back to searching for a consumer-only address space descriptor if no
    vendor-defined resource is found.
    
    Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/acpi-ext.c b/arch/ia64/kernel/acpi-ext.c
index 4a5574f..fff8292 100644
--- a/arch/ia64/kernel/acpi-ext.c
+++ b/arch/ia64/kernel/acpi-ext.c
@@ -1,105 +1,104 @@
 /*
- * arch/ia64/kernel/acpi-ext.c
+ * (c) Copyright 2003, 2006 Hewlett-Packard Development Company, L.P.
+ *	Alex Williamson <alex.williamson@hp.com>
+ *	Bjorn Helgaas <bjorn.helgaas@hp.com>
  *
- * Copyright (C) 2003 Hewlett-Packard
- * Copyright (C) Alex Williamson
- * Copyright (C) Bjorn Helgaas
- *
- * Vendor specific extensions to ACPI.
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
  */
 
 #include <linux/config.h>
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/acpi.h>
-#include <linux/efi.h>
 
 #include <asm/acpi-ext.h>
 
-struct acpi_vendor_descriptor {
-	u8 guid_id;
-	efi_guid_t guid;
-};
+/*
+ * Device CSRs that do not appear in PCI config space should be described
+ * via ACPI.  This would normally be done with Address Space Descriptors
+ * marked as "consumer-only," but old versions of Windows and Linux ignore
+ * the producer/consumer flag, so HP invented a vendor-defined resource to
+ * describe the location and size of CSR space.
+ */
 
-struct acpi_vendor_info {
-	struct acpi_vendor_descriptor *descriptor;
-	u8 *data;
-	u32 length;
+struct acpi_vendor_uuid hp_ccsr_uuid = {
+	.subtype = 2,
+	.data = { 0xf9, 0xad, 0xe9, 0x69, 0x4f, 0x92, 0x5f, 0xab, 0xf6, 0x4a,
+	    0x24, 0xd2, 0x01, 0x37, 0x0e, 0xad },
 };
 
-acpi_status
-acpi_vendor_resource_match(struct acpi_resource *resource, void *context)
+static acpi_status hp_ccsr_locate(acpi_handle obj, u64 *base, u64 *length)
 {
-	struct acpi_vendor_info *info = (struct acpi_vendor_info *)context;
-	struct acpi_resource_vendor *vendor;
-	struct acpi_vendor_descriptor *descriptor;
-	u32 byte_length;
-
-	if (resource->type != ACPI_RESOURCE_TYPE_VENDOR)
-		return AE_OK;
-
-	vendor = (struct acpi_resource_vendor *)&resource->data;
-	descriptor = (struct acpi_vendor_descriptor *)vendor->byte_data;
-	if (vendor->byte_length <= sizeof(*info->descriptor) ||
-	    descriptor->guid_id != info->descriptor->guid_id ||
-	    efi_guidcmp(descriptor->guid, info->descriptor->guid))
-		return AE_OK;
-
-	byte_length = vendor->byte_length - sizeof(struct acpi_vendor_descriptor);
-	info->data = acpi_os_allocate(byte_length);
-	if (!info->data)
-		return AE_NO_MEMORY;
-
-	memcpy(info->data,
-	       vendor->byte_data + sizeof(struct acpi_vendor_descriptor),
-	       byte_length);
-	info->length = byte_length;
-	return AE_CTRL_TERMINATE;
-}
+	acpi_status status;
+	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
+	struct acpi_resource *resource;
+	struct acpi_resource_vendor_typed *vendor;
 
-acpi_status
-acpi_find_vendor_resource(acpi_handle obj, struct acpi_vendor_descriptor * id,
-			  u8 ** data, u32 * byte_length)
-{
-	struct acpi_vendor_info info;
+	status = acpi_get_vendor_resource(obj, METHOD_NAME__CRS, &hp_ccsr_uuid,
+		&buffer);
 
-	info.descriptor = id;
-	info.data = NULL;
+	resource = buffer.pointer;
+	vendor = &resource->data.vendor_typed;
 
-	acpi_walk_resources(obj, METHOD_NAME__CRS, acpi_vendor_resource_match,
-			    &info);
-	if (!info.data)
-		return AE_NOT_FOUND;
+	if (ACPI_FAILURE(status) || vendor->byte_length < 16) {
+		status = AE_NOT_FOUND;
+		goto exit;
+	}
 
-	*data = info.data;
-	*byte_length = info.length;
-	return AE_OK;
+	memcpy(base, vendor->byte_data, sizeof(*base));
+	memcpy(length, vendor->byte_data + 8, sizeof(*length));
+
+  exit:
+	acpi_os_free(buffer.pointer);
+	return status;
 }
 
-struct acpi_vendor_descriptor hp_ccsr_descriptor = {
-	.guid_id = 2,
-	.guid -	    EFI_GUID(0x69e9adf9, 0x924f, 0xab5f, 0xf6, 0x4a, 0x24, 0xd2, 0x01,
-		     0x37, 0x0e, 0xad)
+struct csr_space {
+	u64	base;
+	u64	length;
 };
 
-acpi_status hp_acpi_csr_space(acpi_handle obj, u64 * csr_base, u64 * csr_length)
+static acpi_status find_csr_space(struct acpi_resource *resource, void *data)
 {
+	struct csr_space *space = data;
+	struct acpi_resource_address64 addr;
 	acpi_status status;
-	u8 *data;
-	u32 length;
 
-	status -	    acpi_find_vendor_resource(obj, &hp_ccsr_descriptor, &data, &length);
+	status = acpi_resource_to_address64(resource, &addr);
+	if (ACPI_SUCCESS(status) &&
+	    addr.resource_type = ACPI_MEMORY_RANGE &&
+	    addr.address_length &&
+	    addr.producer_consumer = ACPI_CONSUMER) {
+		space->base = addr.minimum;
+		space->length = addr.address_length;
+		return AE_CTRL_TERMINATE;
+	}
+	return AE_OK;		/* keep looking */
+}
 
-	if (ACPI_FAILURE(status) || length != 16)
-		return AE_NOT_FOUND;
+static acpi_status hp_crs_locate(acpi_handle obj, u64 *base, u64 *length)
+{
+	struct csr_space space = { 0, 0 };
 
-	memcpy(csr_base, data, sizeof(*csr_base));
-	memcpy(csr_length, data + 8, sizeof(*csr_length));
-	acpi_os_free(data);
+	acpi_walk_resources(obj, METHOD_NAME__CRS, find_csr_space, &space);
+	if (!space.length)
+		return AE_NOT_FOUND;
 
+	*base = space.base;
+	*length = space.length;
 	return AE_OK;
 }
 
+acpi_status hp_acpi_csr_space(acpi_handle obj, u64 *csr_base, u64 *csr_length)
+{
+	acpi_status status;
+
+	status = hp_ccsr_locate(obj, csr_base, csr_length);
+	if (ACPI_SUCCESS(status))
+		return status;
+
+	return hp_crs_locate(obj, csr_base, csr_length);
+}
 EXPORT_SYMBOL(hp_acpi_csr_space);
diff --git a/include/asm-ia64/acpi-ext.h b/include/asm-ia64/acpi-ext.h
index 56d2ddc..734d137 100644
--- a/include/asm-ia64/acpi-ext.h
+++ b/include/asm-ia64/acpi-ext.h
@@ -1,12 +1,15 @@
 /*
- * ia64/platform/hp/common/hp_acpi.h
+ * (c) Copyright 2003, 2006 Hewlett-Packard Development Company, L.P.
+ *	Alex Williamson <alex.williamson@hp.com>
+ *	Bjorn Helgaas <bjorn.helgaas@hp.com>
  *
- * Copyright (C) 2003 Hewlett-Packard
- * Copyright (C) Alex Williamson
- * Copyright (C) Bjorn Helgaas
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
  *
  * Vendor specific extensions to ACPI.
  */
+
 #ifndef _ASM_IA64_ACPI_EXT_H
 #define _ASM_IA64_ACPI_EXT_H
 

diff-tree b8cd2af862c3cbd428600e1c4f0d3f97c0da54cc (from 27f4aa3db090ff5bc0e6c192aae6d99b21563b21)
Author: Tony Luck <tony.luck@intel.com>
Date:   Thu Apr 6 14:20:16 2006 -0700

    [IA64] Wire up new syscalls {set,get}_robust_list
    
    Join the dots to enable Ingo's robut futex syscalls.
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 26ac96a..6e16f6b 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -1606,8 +1606,8 @@ sys_call_table:
 	data8 sys_ni_syscall			// 1295 reserved for ppoll
 	data8 sys_unshare
 	data8 sys_splice
-	data8 sys_ni_syscall			// reserved for set_robust_futex
-	data8 sys_ni_syscall			// reserved for get_robust_futex
+	data8 sys_set_robust_list
+	data8 sys_get_robust_list
 	data8 sys_sync_file_range		// 1300
 
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
diff --git a/include/asm-ia64/unistd.h b/include/asm-ia64/unistd.h
index c15fc92..1c749ac 100644
--- a/include/asm-ia64/unistd.h
+++ b/include/asm-ia64/unistd.h
@@ -286,7 +286,8 @@ #define __NR_faccessat			1293
 /* 1294, 1295 reserved for pselect/ppoll */
 #define __NR_unshare			1296
 #define __NR_splice			1297
-/* 1298, 1299 reserved for {set,get}_robust_list */
+#define __NR_set_robust_list		1298
+#define __NR_get_robust_list		1299
 #define __NR_sync_file_range		1300
 
 #ifdef __KERNEL__

diff-tree 27f4aa3db090ff5bc0e6c192aae6d99b21563b21 (from d905b00b3bc9484d92dd6e9bd9fd8cf66580dc8a)
Author: Tony Luck <tony.luck@intel.com>
Date:   Tue Apr 4 14:11:49 2006 -0700

    [IA64] 'msg' may be used uninitialized in xpc_initiate_allocate()
    
    Found by gcc4.1 and reported by Dean Nelson.
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/xpc_channel.c b/arch/ia64/sn/kernel/xpc_channel.c
index d0abddd..8255a9b 100644
--- a/arch/ia64/sn/kernel/xpc_channel.c
+++ b/arch/ia64/sn/kernel/xpc_channel.c
@@ -1831,7 +1831,7 @@ xpc_initiate_allocate(partid_t partid, i
 {
 	struct xpc_partition *part = &xpc_partitions[partid];
 	enum xpc_retval ret = xpcUnknownReason;
-	struct xpc_msg *msg;
+	struct xpc_msg *msg = NULL;
 
 
 	DBUG_ON(partid <= 0 || partid >= XP_MAX_PARTITIONS);

diff-tree d905b00b3bc9484d92dd6e9bd9fd8cf66580dc8a (from 6246b6128bbe34d0752f119cf7c5111c85fe481d)
Author: Tony Luck <tony.luck@intel.com>
Date:   Tue Apr 4 14:08:11 2006 -0700

    [IA64] Wire up new syscall sync_file_range()
    
    Also reserve syscall numbers for {set,get}_robust_list
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 750e8e7..26ac96a 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -1606,5 +1606,8 @@ sys_call_table:
 	data8 sys_ni_syscall			// 1295 reserved for ppoll
 	data8 sys_unshare
 	data8 sys_splice
+	data8 sys_ni_syscall			// reserved for set_robust_futex
+	data8 sys_ni_syscall			// reserved for get_robust_futex
+	data8 sys_sync_file_range		// 1300
 
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
diff --git a/include/asm-ia64/unistd.h b/include/asm-ia64/unistd.h
index 36070c1..c15fc92 100644
--- a/include/asm-ia64/unistd.h
+++ b/include/asm-ia64/unistd.h
@@ -286,12 +286,14 @@ #define __NR_faccessat			1293
 /* 1294, 1295 reserved for pselect/ppoll */
 #define __NR_unshare			1296
 #define __NR_splice			1297
+/* 1298, 1299 reserved for {set,get}_robust_list */
+#define __NR_sync_file_range		1300
 
 #ifdef __KERNEL__
 
 #include <linux/config.h>
 
-#define NR_syscalls			274 /* length of syscall table */
+#define NR_syscalls			277 /* length of syscall table */
 
 #define __ARCH_WANT_SYS_RT_SIGACTION
 
