From: Zou Nan hai <nanhai.zou@intel.com>
Date: Wed, 07 Jun 2006 22:48:23 +0000
Subject: Ia64 kdump patch
Message-Id: <1149720503.2591.152.camel@linux-znh>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-OAwZ112ebexHlrRcE/CD"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--=-OAwZ112ebexHlrRcE/CD
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

The ia64 kdump patch is in 2 parts.

the kexec-kdump-ia64-2.6.16.patch should apply on top of the previous 
kexec patch by Khalid in Tony's test tree.

the kexec-tools-kdump-ia64.patch should apply to kexec-tools-1.101
with kexec-tools-1.101-kdump.patch


To test it.
Build first SMP kernel with KEXEC and KDUMP enabled.

Boot it with kernel parameter "crashkernel=XXX@YYY"
means reserver XXX from YYY for crashdumping.
Build an UP kernel with KEXEC KDUMP VMCORE enabled.
load this kernel as a crashdumping kernel
kexec -p vmlinux.gz --initrd=initrd --append="...."

trigger a crash,
maybe "echo c > /proc/sysrq-trigger"
after the crash kernel boots,
cp /proc/vmcore core

gdb first_kernel_vmlinux core

please test and review.

Signed-off-by: Khalid Aziz <khalid_aziz@hp.com>
Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>




--=-OAwZ112ebexHlrRcE/CD
Content-Disposition: attachment; filename=kexec-kdump-ia64-2.6.16.patch
Content-Type: text/x-patch; name=kexec-kdump-ia64-2.6.16.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -Nraup linux-2.6.16/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
--- linux-2.6.16/arch/ia64/hp/common/sba_iommu.c	2006-03-20 13:53:29.000000000 +0800
+++ b/arch/ia64/hp/common/sba_iommu.c	2006-06-08 12:23:31.000000000 +0800
@@ -1624,6 +1624,28 @@ ioc_iova_init(struct ioc *ioc)
 	READ_REG(ioc->ioc_hpa + IOC_IBASE);
 }
 
+#ifdef CONFIG_KEXEC
+void
+ioc_iova_disable(void)
+{
+	struct ioc *ioc;
+
+	ioc = ioc_list;
+
+	while (ioc != NULL) {
+		/* Disable IOVA translation */
+		WRITE_REG(ioc->ibase & 0xfffffffffffffffe, ioc->ioc_hpa + IOC_IBASE);
+		READ_REG(ioc->ioc_hpa + IOC_IBASE);
+
+		/* Clear I/O TLB of any possible entries */
+		WRITE_REG(ioc->ibase | (get_iovp_order(ioc->iov_size) + iovp_shift), ioc->ioc_hpa + IOC_PCOM);
+		READ_REG(ioc->ioc_hpa + IOC_PCOM);
+
+		ioc = ioc->next;
+	}
+}
+#endif
+
 static void __init
 ioc_resource_init(struct ioc *ioc)
 {
diff -Nraup linux-2.6.16/arch/ia64/Kconfig b/arch/ia64/Kconfig
--- linux-2.6.16/arch/ia64/Kconfig	2006-03-20 13:53:29.000000000 +0800
+++ b/arch/ia64/Kconfig	2006-06-08 12:23:39.000000000 +0800
@@ -376,6 +376,29 @@ config IA64_PALINFO
 config SGI_SN
 	def_bool y if (IA64_SGI_SN2 || IA64_GENERIC)
 
+config KEXEC
+	bool "kexec system call (EXPERIMENTAL)"
+	depends on EXPERIMENTAL
+	help
+	  kexec is a system call that implements the ability to shutdown your
+	  current kernel, and to start another kernel.  It is like a reboot
+	  but it is indepedent of the system firmware.   And like a reboot
+	  you can start any kernel with it, not just Linux.
+
+	  The name comes from the similiarity to the exec system call.
+
+	  It is an ongoing process to be certain the hardware in a machine
+	  is properly shutdown, so do not be surprised if this code does not
+	  initially work for you.  It may help to enable device hotplugging
+	  support.  As of this writing the exact hardware interface is
+	  strongly in flux, so no good recommendation can be made.
+
+config CRASH_DUMP
+	  bool "kernel crash dumps (EXPERIMENTAL)"
+	  depends on EXPERIMENTAL
+	  help
+	    Generate crash dump after being started by kexec.
+
 source "drivers/firmware/Kconfig"
 
 source "fs/Kconfig.binfmt"
diff -Nraup linux-2.6.16/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
--- linux-2.6.16/arch/ia64/kernel/crash.c	1970-01-01 08:00:00.000000000 +0800
+++ b/arch/ia64/kernel/crash.c	2006-06-08 12:23:39.000000000 +0800
@@ -0,0 +1,152 @@
+/*
+ * arch/ia64/kernel/crash.c
+ *
+ * Architecture specific (ia64) functions for kexec based crash dumps.
+ *
+ * Created by: Khalid Aziz <khalid.aziz@hp.com>
+ * Copyright (C) 2005 Hewlett-Packard Development Company, L.P.
+ * Copyright (C) 2005 Intel Corp	Zou Nan hai <nanhai.zou@intel.com>
+ *
+ */
+#include <linux/init.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/smp.h>
+#include <linux/irq.h>
+#include <linux/pci.h>
+#include <linux/reboot.h>
+#include <linux/kexec.h>
+#include <linux/irq.h>
+#include <linux/delay.h>
+#include <linux/elf.h>
+#include <linux/elfcore.h>
+#include <linux/device.h>
+#include <asm/uaccess.h>
+
+size_t copy_oldmem_page(unsigned long pfn, char *buf,
+                               size_t csize, unsigned long offset, int userbuf)
+{
+        void  *vaddr;
+
+        if (!csize)
+                return 0;
+        vaddr = page_address(pfn_to_page(pfn));
+
+        if (userbuf) {
+                if (copy_to_user(buf, (vaddr + offset), csize)) {
+                        return -EFAULT;
+                }
+        } else
+                memcpy(buf, (vaddr + offset), csize);
+        return csize;
+}
+
+static void device_shootdown(void)
+{
+       struct pci_dev *dev;
+       irq_desc_t *desc;
+       u16 pci_command;
+
+       list_for_each_entry(dev, &pci_devices, global_list) {
+               desc = irq_descp(dev->irq);
+               if (!desc->action)
+                       continue;
+               pci_read_config_word(dev, PCI_COMMAND, &pci_command);
+               if (pci_command & PCI_COMMAND_MASTER) {
+                       pci_command &= ~PCI_COMMAND_MASTER;
+                       pci_write_config_word(dev, PCI_COMMAND, pci_command);
+               }
+               disable_irq_nosync(dev->irq);
+               desc->handler->end(dev->irq);
+       }
+}
+
+static Elf64_Word
+*append_elf_note(Elf64_Word *buf, char *name, unsigned type, void *data,
+		size_t data_len)
+{
+	struct elf_note *note = (struct elf_note *)buf;
+	note->n_namesz = strlen(name) + 1;
+	note->n_descsz = data_len;
+	note->n_type   = type;
+	buf += (sizeof(*note) + 3)/4;
+	memcpy(buf, name, note->n_namesz);
+	buf += (note->n_namesz + 3)/4;
+	memcpy(buf, data, data_len);
+	buf += (data_len + 3)/4;
+	return buf;
+}
+
+static void
+final_note(void *buf)
+{
+	memset(buf, 0, sizeof(struct elf_note));
+}
+
+static void
+crash_save_this_cpu(void)
+{
+	void *buf;
+	struct elf_prstatus prstatus;
+	int cpu = smp_processor_id();
+	elf_greg_t *dst = (elf_greg_t *)&prstatus.pr_reg;
+
+	memset(&prstatus, 0, sizeof(prstatus));
+	prstatus.pr_pid = current->pid;
+
+    	dst[1] = ia64_getreg(_IA64_REG_GP);
+    	dst[12] = ia64_getreg(_IA64_REG_SP);
+    	dst[13] = ia64_getreg(_IA64_REG_TP);
+
+    	dst[42] = ia64_getreg(_IA64_REG_IP);
+    	dst[45] = ia64_getreg(_IA64_REG_AR_RSC);
+
+	ia64_setreg(_IA64_REG_AR_RSC, 0);
+	ia64_srlz_i();
+
+    	dst[46] = ia64_getreg(_IA64_REG_AR_BSP);
+    	dst[47] = ia64_getreg(_IA64_REG_AR_BSPSTORE);
+
+    	dst[48] = ia64_getreg(_IA64_REG_AR_RNAT);
+    	dst[49] = ia64_getreg(_IA64_REG_AR_CCV);
+    	dst[50] = ia64_getreg(_IA64_REG_AR_UNAT);
+
+    	dst[51] = ia64_getreg(_IA64_REG_AR_FPSR);
+    	dst[52] = ia64_getreg(_IA64_REG_AR_PFS);
+    	dst[53] = ia64_getreg(_IA64_REG_AR_LC);
+
+    	dst[54] = ia64_getreg(_IA64_REG_AR_LC);
+    	dst[55] = ia64_getreg(_IA64_REG_AR_CSD);
+    	dst[56] = ia64_getreg(_IA64_REG_AR_SSD);
+
+        buf = (u64 *) per_cpu_ptr(crash_notes, cpu);
+	if (!buf)
+		return;
+	buf = append_elf_note(buf, "CORE", NT_PRSTATUS, &prstatus,
+		sizeof(prstatus));
+	final_note(buf);
+}
+
+void
+machine_crash_shutdown(struct pt_regs *pt)
+{
+	/* This function is only called after the system
+	 * has paniced or is otherwise in a critical state.
+	 * The minimum amount of code to allow a kexec'd kernel
+	 * to run successfully needs to happen here.
+	 *
+	 * In practice this means shooting down the other cpus in
+	 * an SMP system.
+	 */
+	if (in_interrupt()) {
+		ia64_eoi();
+	}
+	crash_save_this_cpu();
+	device_shootdown();
+#ifdef CONFIG_SMP
+	smp_send_stop();
+#endif
+#ifdef CONFIG_IA64_HP_ZX1
+	ioc_iova_disable();
+#endif
+}
diff -Nraup linux-2.6.16/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
--- linux-2.6.16/arch/ia64/kernel/efi.c	2006-03-20 13:53:29.000000000 +0800
+++ b/arch/ia64/kernel/efi.c	2006-06-08 12:26:11.000000000 +0800
@@ -25,6 +25,7 @@
 #include <linux/types.h>
 #include <linux/time.h>
 #include <linux/efi.h>
+#include <linux/kexec.h>
 
 #include <asm/io.h>
 #include <asm/kregs.h>
@@ -40,7 +41,7 @@ extern efi_status_t efi_call_phys (void 
 struct efi efi;
 EXPORT_SYMBOL(efi);
 static efi_runtime_services_t *runtime;
-static unsigned long mem_limit = ~0UL, max_addr = ~0UL;
+static unsigned long mem_limit = ~0UL, max_addr = ~0UL, min_addr = 0UL;
 
 #define efi_call_virt(f, args...)	(*(f))(args)
 
@@ -420,6 +421,8 @@ efi_init (void)
 			mem_limit = memparse(cp + 4, &cp);
 		} else if (memcmp(cp, "max_addr=", 9) == 0) {
 			max_addr = GRANULEROUNDDOWN(memparse(cp + 9, &cp));
+		} else if (memcmp(cp, "min_addr=", 9) == 0) {
+			min_addr = GRANULEROUNDDOWN(memparse(cp + 9, &cp));
 		} else {
 			while (*cp != ' ' && *cp)
 				++cp;
@@ -427,6 +430,8 @@ efi_init (void)
 				++cp;
 		}
 	}
+	if (min_addr != 0UL)
+		printk(KERN_INFO "Ignoring memory below %luMB\n", min_addr >> 20);
 	if (max_addr != ~0UL)
 		printk(KERN_INFO "Ignoring memory above %luMB\n", max_addr >> 20);
 
@@ -839,7 +844,8 @@ find_memmap_space (void)
 		as = max(contig_low, md->phys_addr);
 		ae = min(contig_high, efi_md_end(md));
 
-		/* keep within max_addr= command line arg */
+		/* keep within max_addr= and min_addr= command line arg */
+		as = max(as, min_addr);
 		ae = min(ae, max_addr);
 		if (ae <= as)
 			continue;
@@ -949,7 +955,8 @@ efi_memmap_init(unsigned long *s, unsign
 		} else
 			ae = efi_md_end(md);
 
-		/* keep within max_addr= command line arg */
+		/* keep within max_addr= and min_addr= command line arg */
+		as = max(as, min_addr);
 		ae = min(ae, max_addr);
 		if (ae <= as)
 			continue;
@@ -1061,6 +1068,10 @@ efi_initialize_iomem_resources(struct re
 			 */
 			insert_resource(res, code_resource);
 			insert_resource(res, data_resource);
+#ifdef CONFIG_KEXEC
+			if (crashk_res.end > crashk_res.start)
+				insert_resource(res, &crashk_res);
+#endif
 		}
 	}
 }
diff -Nraup linux-2.6.16/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- linux-2.6.16/arch/ia64/kernel/entry.S	2006-03-20 13:53:29.000000000 +0800
+++ b/arch/ia64/kernel/entry.S	2006-06-08 12:23:31.000000000 +0800
@@ -1590,7 +1590,7 @@ sys_call_table:
 	data8 sys_mq_timedreceive		// 1265
 	data8 sys_mq_notify
 	data8 sys_mq_getsetattr
-	data8 sys_ni_syscall			// reserved for kexec_load
+	data8 sys_kexec_load
 	data8 sys_ni_syscall			// reserved for vserver
 	data8 sys_waitid			// 1270
 	data8 sys_add_key
diff -Nraup linux-2.6.16/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_kexec.c
--- linux-2.6.16/arch/ia64/kernel/machine_kexec.c	1970-01-01 08:00:00.000000000 +0800
+++ b/arch/ia64/kernel/machine_kexec.c	2006-06-08 12:55:57.000000000 +0800
@@ -0,0 +1,115 @@
+/*
+ * arch/ia64/kernel/machine_kexec.c 
+ *
+ * Handle transition of Linux booting another kernel
+ * Copyright (C) 2005 Hewlett-Packard Development Comapny, L.P.
+ * Copyright (C) 2005 Khalid Aziz <khalid.aziz@hp.com>
+ * Copyright (C) 2006 Intel Corp, Zou Nan hai <nanhai.zou@intel.com>
+ *
+ * This source code is licensed under the GNU General Public License,
+ * Version 2.  See the file COPYING for more details.
+ */
+
+#include <linux/kernel.h>
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/kexec.h>
+#include <linux/pci.h>
+#include <linux/cpu.h>
+#include <asm/mmu_context.h>
+#include <asm/setup.h>
+#include <asm/mca.h>
+#include <asm/page.h>
+#include <asm/bitops.h>
+#include <asm/tlbflush.h>
+#include <asm/delay.h>
+#include <asm/meminit.h>
+
+typedef void (*relocate_new_kernel_t)(unsigned long, unsigned long,
+		struct ia64_boot_param *, unsigned long);
+
+/*
+ * Do what every setup is needed on image and the
+ * reboot code buffer to allow us to avoid allocations
+ * later.
+ */
+int machine_kexec_prepare(struct kimage *image)
+{
+	void *control_code_buffer;
+	const unsigned long *func;
+
+	func = (unsigned long *)&relocate_new_kernel;
+	/* Pre-load control code buffer to minimize work in kexec path */
+	control_code_buffer = page_address(image->control_code_page);
+	memcpy((void *)control_code_buffer, (const void *)func[0], 
+			relocate_new_kernel_size);
+	flush_icache_range((unsigned long)control_code_buffer, 
+			(unsigned long)control_code_buffer + relocate_new_kernel_size);
+
+	return 0;
+}
+
+void machine_kexec_cleanup(struct kimage *image)
+{
+}
+
+void machine_shutdown(void)
+{
+#ifdef CONFIG_PCI
+	struct pci_dev *dev = NULL;
+	irq_desc_t *idesc;
+	cpumask_t mask = CPU_MASK_NONE;
+	/* Disable all PCI devices */
+	while ((dev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL) {
+		if (!(dev->is_enabled))
+			continue;
+		idesc = irq_descp(dev->irq);
+		if (!idesc)
+			continue;
+		cpu_set(0, mask);
+		disable_irq_nosync(dev->irq);
+		idesc->handler->end(dev->irq);
+		idesc->handler->set_affinity(dev->irq, mask);
+		idesc->action = NULL;
+		pci_disable_device(dev);
+	}
+#endif
+
+#ifdef CONFIG_HOTPLUG_CPU
+	{
+		int cpu;
+
+		for_each_online_cpu(cpu) {
+			if (cpu != smp_processor_id())
+				cpu_down(cpu);
+		}
+	}
+#elif defined(CONFIG_SMP)
+	smp_call_function(kexec_stop_this_cpu, (void *)image->start, 0, 0);
+#endif
+
+
+#ifdef CONFIG_IA64_HP_ZX1
+	ioc_iova_disable();
+#endif
+}
+
+/*
+ * Do not allocate memory (or fail in any way) in machine_kexec().
+ * We are past the point of no return, committed to rebooting now. 
+ */
+extern void *efi_get_pal_addr(void);
+void machine_kexec(struct kimage *image)
+{
+	relocate_new_kernel_t rnk;
+	void *pal_addr = efi_get_pal_addr();
+	unsigned long code_addr = (unsigned long)page_address(image->control_code_page);
+	/* Interrupts aren't acceptable while we reboot */
+	ia64_set_itv(1<<16);
+	local_irq_disable();
+	rnk = (relocate_new_kernel_t)&code_addr;
+	(*rnk)(image->head, image->start, ia64_boot_param,
+		     GRANULEROUNDDOWN((unsigned long) pal_addr));
+	BUG();
+	for (;;);
+}
diff -Nraup linux-2.6.16/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
--- linux-2.6.16/arch/ia64/kernel/Makefile	2006-03-20 13:53:29.000000000 +0800
+++ b/arch/ia64/kernel/Makefile	2006-06-08 12:23:31.000000000 +0800
@@ -28,6 +28,7 @@ obj-$(CONFIG_IA64_CYCLONE)	+= cyclone.o
 obj-$(CONFIG_CPU_FREQ)		+= cpufreq/
 obj-$(CONFIG_IA64_MCA_RECOVERY)	+= mca_recovery.o
 obj-$(CONFIG_KPROBES)		+= kprobes.o jprobes.o
+obj-$(CONFIG_KEXEC)		+= machine_kexec.o relocate_kernel.o crash.o
 obj-$(CONFIG_IA64_UNCACHED_ALLOCATOR)	+= uncached.o
 mca_recovery-y			+= mca_drv.o mca_drv_asm.o
 
diff -Nraup linux-2.6.16/arch/ia64/kernel/relocate_kernel.S b/arch/ia64/kernel/relocate_kernel.S
--- linux-2.6.16/arch/ia64/kernel/relocate_kernel.S	1970-01-01 08:00:00.000000000 +0800
+++ b/arch/ia64/kernel/relocate_kernel.S	2006-06-08 12:23:39.000000000 +0800
@@ -0,0 +1,353 @@
+/*
+ * arch/ia64/kernel/relocate_kernel.S 
+ *
+ * Relocate kexec'able kernel and start it
+ *
+ * Copyright (C) 2005 Hewlett-Packard Development Company, L.P.
+ * Copyright (C) 2005 Khalid Aziz  <khalid.aziz@hp.com>
+ * Copyright (C) 2005 Intel Corp,  Zou Nan hai <nanhai.zou@intel.com>
+ *
+ * This source code is licensed under the GNU General Public License,
+ * Version 2.  See the file COPYING for more details.
+ */
+#include <linux/config.h>
+#include <asm/asmmacro.h>
+#include <asm/kregs.h>
+#include <asm/page.h>
+#include <asm/pgtable.h>
+#include <asm/mca_asm.h>
+
+       /* Must be relocatable PIC code callable as a C function
+        */
+GLOBAL_ENTRY(relocate_new_kernel)
+	.prologue
+	alloc r31=ar.pfs,4,0,0,0
+        .body
+.reloc_entry:
+{
+	rsm psr.i| psr.ic
+	mov r2=ip
+}
+	;;
+{
+        flushrs                         // must be first insn in group
+        srlz.i
+}
+	;;
+	dep r2=0,r2,61,3		//to physical address
+	;;
+	//first switch to physical mode
+	add r3=1f-.reloc_entry, r2
+	movl r16 = IA64_PSR_AC|IA64_PSR_BN|IA64_PSR_IC
+	mov ar.rsc=0	          	// put RSE in enforced lazy mode
+	;;
+	add sp=(memory_stack_end - 16 - .reloc_entry),r2
+	add r8=(register_stack - .reloc_entry),r2
+	;;
+	mov r18=ar.rnat
+	mov ar.bspstore=r8
+	;;
+        mov cr.ipsr=r16
+        mov cr.iip=r3
+        mov cr.ifs=r0
+	srlz.i
+	;;
+	mov ar.rnat=r18
+	rfi
+	;;
+1:
+	//physical mode code begin
+	mov b6=in1
+	dep r28=0,in2,61,3	//to physical address
+
+	// purge all TC entries
+#define O(member)       IA64_CPUINFO_##member##_OFFSET
+        GET_THIS_PADDR(r2, cpu_info)    // load phys addr of cpu_info into r2
+        ;;
+        addl r17=O(PTCE_STRIDE),r2
+        addl r2=O(PTCE_BASE),r2
+        ;;
+        ld8 r18=[r2],(O(PTCE_COUNT)-O(PTCE_BASE));;    	// r18=ptce_base
+        ld4 r19=[r2],4                                  // r19=ptce_count[0]
+        ld4 r21=[r17],4                                 // r21=ptce_stride[0]
+        ;;
+        ld4 r20=[r2]                                    // r20=ptce_count[1]
+        ld4 r22=[r17]                                   // r22=ptce_stride[1]
+        mov r24=r0
+        ;;
+        adds r20=-1,r20
+        ;;
+#undef O
+2:
+        cmp.ltu p6,p7=r24,r19
+(p7)    br.cond.dpnt.few 4f
+        mov ar.lc=r20
+3:
+        ptc.e r18
+        ;;
+        add r18=r22,r18
+        br.cloop.sptk.few 3b
+        ;;
+        add r18=r21,r18
+        add r24=1,r24
+        ;;
+        br.sptk.few 2b
+4:
+        srlz.i
+        ;;
+	//purge TR entry for kernel text and data
+        movl r16=KERNEL_START
+        mov r18=KERNEL_TR_PAGE_SHIFT<<2
+        ;;
+        ptr.i r16, r18
+        ptr.d r16, r18
+        ;;
+        srlz.i
+        ;;
+
+	// purge TR entry for percpu data
+        movl r16=PERCPU_ADDR
+        mov r18=PERCPU_PAGE_SHIFT<<2
+        ;;
+        ptr.d r16,r18
+        ;;
+        srlz.d
+	;;
+
+        // purge TR entry for pal code
+        mov r16=in3
+        mov r18=IA64_GRANULE_SHIFT<<2
+        ;;
+        ptr.i r16,r18
+        ;;
+        srlz.i
+	;;
+
+        // purge TR entry for stack
+        mov r16=IA64_KR(CURRENT_STACK)
+        ;;
+        shl r16=r16,IA64_GRANULE_SHIFT
+        movl r19=PAGE_OFFSET
+        ;;
+        add r16=r19,r16
+        mov r18=IA64_GRANULE_SHIFT<<2
+        ;;
+        ptr.d r16,r18
+        ;;
+        srlz.i
+	;;
+
+	//copy segments
+	movl r16=PAGE_MASK
+        mov  r30=in0                    // in0 is page_list
+        br.sptk.few .dest_page
+	;;
+.loop:
+	ld8  r30=[in0], 8;;
+.dest_page:
+	tbit.z p0, p6=r30, 0;;    	// 0x1 dest page
+(p6)	and r17=r30, r16
+(p6)	br.cond.sptk.few .loop;;
+
+	tbit.z p0, p6=r30, 1;;		// 0x2 indirect page
+(p6)	and in0=r30, r16
+(p6)	br.cond.sptk.few .loop;;
+
+	tbit.z p0, p6=r30, 2;;		// 0x4 end flag
+(p6)	br.cond.sptk.few .end_loop;;
+
+	tbit.z p6, p0=r30, 3;;		// 0x8 source page
+(p6)	br.cond.sptk.few .loop
+
+	and r18=r30, r16
+
+	// simple copy page, may optimize later
+	movl r14=PAGE_SIZE/8 - 1;;
+	mov ar.lc=r14;;
+1:
+	ld8 r14=[r18], 8;;
+	st8 [r17]=r14, 8;;
+	fc.i r17
+	br.ctop.sptk.few 1b
+	br.sptk.few .loop
+	;;
+
+.end_loop:
+	sync.i			// for fc.i
+	;;
+	srlz.i
+	;;
+	srlz.d
+	;;
+	br.call.sptk.many b0=b6;;
+
+.align  32
+memory_stack:
+	.fill           8192, 1, 0
+memory_stack_end:
+register_stack:
+	.fill           8192, 1, 0
+register_stack_end:
+relocate_new_kernel_end:
+END(relocate_new_kernel)
+
+GLOBAL_ENTRY(kexec_fake_sal_rendez)
+	.prologue
+	alloc r31=ar.pfs,3,0,0,0
+	.body
+.rendez_entry:
+	rsm	psr.i | psr.ic
+	mov r25=ip
+	;;
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
+	/* Transition from virtual to physical mode */
+	srlz.i
+	;;
+	add	r17=5f-.rendez_entry, r25
+	movl	r16=(IA64_PSR_AC | IA64_PSR_BN | IA64_PSR_IC | IA64_PSR_MFL)
+	;;
+	tpa	r17=r17
+	mov	cr.ipsr=r16
+	;;
+	mov	cr.iip=r17
+	mov	cr.ifs=r0
+	;;
+	rfi
+	;;
+5:
+	mov     b6=in0			/* _start addr */
+	mov	r8=in1			/* ap_wakeup_vector */
+	mov	r26=in2			/* PAL addr */
+	;;
+	/* Purge kernel TRs */
+	movl	r16=KERNEL_START
+	mov	r18=KERNEL_TR_PAGE_SHIFT<<2
+	;;
+	ptr.i	r16,r18
+	ptr.d	r16,r18
+	;;
+	srlz.i
+	;;
+	srlz.d
+	;;
+	/* Purge percpu TR */
+	movl	r16=PERCPU_ADDR
+	mov	r18=PERCPU_PAGE_SHIFT<<2
+	;;
+	ptr.d	r16,r18
+	;;
+	srlz.d
+	;;
+	/* Purge PAL TR */
+	mov	r18=IA64_GRANULE_SHIFT<<2
+	;;
+	ptr.i	r26,r18
+	;;
+	srlz.i
+	;;
+	/* Purge stack TR */
+	mov	r16=IA64_KR(CURRENT_STACK)
+	;;
+	shl	r16=r16,IA64_GRANULE_SHIFT
+	movl	r19=PAGE_OFFSET
+	;;
+	add	r16=r19,r16
+	mov	r18=IA64_GRANULE_SHIFT<<2
+	;;
+	ptr.d	r16,r18
+	;;
+	srlz.i
+	;;
+
+	/* Ensure we can read and clear external interrupts */
+	mov	cr.tpr=r0
+	srlz.d
+
+	shr.u	r9=r8,6			/* which irr */
+	;;
+	and	r8=63,r8		/* bit offset into irr */
+	;;
+	mov	r10=1;;
+	;;
+	shl	r10=r10,r8		/* bit mask off irr we want */
+	cmp.eq	p6,p0=0,r9
+	;;
+(p6)	br.cond.sptk.few        check_irr0
+	cmp.eq	p7,p0=1,r9
+	;;
+(p7)	br.cond.sptk.few        check_irr1
+	cmp.eq	p8,p0=2,r9
+	;;
+(p8)	br.cond.sptk.few        check_irr2
+	cmp.eq	p9,p0=3,r9
+	;;
+(p9)	br.cond.sptk.few        check_irr3
+
+check_irr0:
+	mov	r8=cr.irr0
+	;;
+	and	r8=r8,r10
+	;;
+	cmp.eq	p6,p0=0,r8
+(p6)	br.cond.sptk.few	check_irr0
+	br.few	call_start
+	
+check_irr1:
+	mov	r8=cr.irr1
+	;;
+	and	r8=r8,r10
+	;;
+	cmp.eq	p6,p0=0,r8
+(p6)	br.cond.sptk.few	check_irr1
+	br.few	call_start
+	
+check_irr2:
+	mov	r8=cr.irr2
+	;;
+	and	r8=r8,r10
+	;;
+	cmp.eq	p6,p0=0,r8
+(p6)	br.cond.sptk.few	check_irr2
+	br.few	call_start
+	
+check_irr3:
+	mov	r8=cr.irr3
+	;;
+	and	r8=r8,r10
+	;;
+	cmp.eq	p6,p0=0,r8
+(p6)	br.cond.sptk.few	check_irr3
+	br.few	call_start
+	
+call_start:
+	mov	cr.eoi=r0
+	;;
+	srlz.d
+	;;
+	mov	r8=cr.ivr
+	;;
+	srlz.d
+	;;
+	cmp.eq	p0,p6=15,r8
+(p6)	br.cond.sptk.few	call_start
+	br.sptk.few		b6
+kexec_fake_sal_rendez_end:
+END(kexec_fake_sal_rendez)
+
+	.global relocate_new_kernel_size
+relocate_new_kernel_size:
+	data8	kexec_fake_sal_rendez_end - relocate_new_kernel
+
diff -Nraup linux-2.6.16/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
--- linux-2.6.16/arch/ia64/kernel/setup.c	2006-03-20 13:53:29.000000000 +0800
+++ b/arch/ia64/kernel/setup.c	2006-06-08 12:24:46.000000000 +0800
@@ -44,6 +44,8 @@
 #include <linux/platform.h>
 #include <linux/pm.h>
 #include <linux/cpufreq.h>
+#include <linux/kexec.h>
+#include <linux/crash_dump.h>
 
 #include <asm/ia32.h>
 #include <asm/machvec.h>
@@ -251,6 +253,32 @@ reserve_memory (void)
 	}
 #endif
 
+#ifdef CONFIG_KEXEC
+	/* crashkernel=size@addr specifies the location to reserve for
+	 * a crash kernel.  By reserving this memory we guarantee
+	 * that linux never set's it up as a DMA target.
+	 * Useful for holding code to do something appropriate
+	 * after a kernel panic.
+	 */
+	{
+		char *from = strstr(saved_command_line, "crashkernel=");
+		if (from) {
+			unsigned long size, base;
+			size = memparse(from + 12, &from);
+			if (*from == '@') {
+				base = memparse(from + 1, &from);
+				rsvd_region[n].start =
+					(unsigned long)__va(base);
+				rsvd_region[n].end =
+					(unsigned long)__va(base + size);
+				crashk_res.start = base;
+				crashk_res.end = base + size - 1;
+				n++;
+			}
+		}
+	}
+#endif
+
 	efi_memmap_init(&rsvd_region[n].start, &rsvd_region[n].end);
 	n++;
 
@@ -496,6 +524,16 @@ setup_arch (char **cmdline_p)
 	if (!strstr(saved_command_line, "nomca"))
 		ia64_mca_init();
 
+#ifdef CONFIG_CRASH_DUMP
+	{
+		char *from = strstr(saved_command_line, "elfcorehdr=");
+
+		if (from)
+			elfcorehdr_addr = memparse(from+11, &from);
+		saved_max_pfn = (unsigned long) -1;
+	}
+#endif
+
 	platform_setup(cmdline_p);
 	paging_init();
 }
diff -Nraup linux-2.6.16/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
--- linux-2.6.16/arch/ia64/kernel/smp.c	2006-03-20 13:53:29.000000000 +0800
+++ b/arch/ia64/kernel/smp.c	2006-06-08 12:23:31.000000000 +0800
@@ -30,6 +30,7 @@
 #include <linux/delay.h>
 #include <linux/efi.h>
 #include <linux/bitops.h>
+#include <linux/kexec.h>
 
 #include <asm/atomic.h>
 #include <asm/current.h>
@@ -84,6 +85,34 @@ unlock_ipi_calllock(void)
 	spin_unlock_irq(&call_lock);
 }
 
+#ifdef CONFIG_KEXEC
+/*
+ * Stop the CPU and put it in fake SAL rendezvous. This allows CPU to wake
+ * up with IPI from boot processor
+ */
+void
+kexec_stop_this_cpu (void *func)
+{
+	unsigned long pta, impl_va_bits, pal_base;
+
+	/*
+	 * Remove this CPU by putting it into fake SAL rendezvous
+	 */
+	cpu_clear(smp_processor_id(), cpu_online_map);
+	max_xtp();
+	ia64_eoi();
+
+	/* Disable VHPT */
+	impl_va_bits = ffz(~(local_cpu_data->unimpl_va_mask | (7UL << 61)));
+	pta = POW2(61) - POW2(vmlpt_bits);
+	ia64_set_pta(pta | (0 << 8) | (vmlpt_bits << 2) | 0);
+
+	local_irq_disable();
+	pal_base = __get_cpu_var(ia64_mca_pal_base);
+	kexec_fake_sal_rendez(func, ap_wakeup_vector, pal_base);
+}
+#endif
+
 static void
 stop_this_cpu (void)
 {
diff -Nraup linux-2.6.16/include/asm-ia64/kexec.h b/include/asm-ia64/kexec.h
--- linux-2.6.16/include/asm-ia64/kexec.h	1970-01-01 08:00:00.000000000 +0800
+++ b/include/asm-ia64/kexec.h	2006-06-08 12:24:04.000000000 +0800
@@ -0,0 +1,34 @@
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
+/* The native architecture */
+#define KEXEC_ARCH KEXEC_ARCH_IA_64
+
+#define MAX_NOTE_BYTES 1024
+
+#define pte_bits	3
+#define vmlpt_bits	(impl_va_bits - PAGE_SHIFT + pte_bits)
+#define POW2(n)		(1ULL << (n))
+
+DECLARE_PER_CPU(u64, ia64_mca_pal_base);
+const extern unsigned int relocate_new_kernel_size;
+volatile extern long kexec_rendez;
+extern void relocate_new_kernel(unsigned long, unsigned long, 
+		struct ia64_boot_param *, unsigned long);
+extern void kexec_fake_sal_rendez(void *start, unsigned long wake_up,
+		unsigned long pal_base);
+static inline void
+crash_setup_regs(struct pt_regs *newregs, struct pt_regs *oldregs)
+{
+}
+#endif /* _ASM_IA64_KEXEC_H */
diff -Nraup linux-2.6.16/include/asm-ia64/machvec_hpzx1.h b/include/asm-ia64/machvec_hpzx1.h
--- linux-2.6.16/include/asm-ia64/machvec_hpzx1.h	2006-03-20 13:53:29.000000000 +0800
+++ b/include/asm-ia64/machvec_hpzx1.h	2006-06-08 12:23:31.000000000 +0800
@@ -34,4 +34,6 @@ extern ia64_mv_dma_mapping_error	sba_dma
 #define platform_dma_supported			sba_dma_supported
 #define platform_dma_mapping_error		sba_dma_mapping_error
 
+extern void ioc_iova_disable(void);
+
 #endif /* _ASM_IA64_MACHVEC_HPZX1_h */
diff -Nraup linux-2.6.16/include/asm-ia64/meminit.h b/include/asm-ia64/meminit.h
--- linux-2.6.16/include/asm-ia64/meminit.h	2006-03-20 13:53:29.000000000 +0800
+++ b/include/asm-ia64/meminit.h	2006-06-08 12:24:04.000000000 +0800
@@ -16,11 +16,12 @@
  * 	- initrd (optional)
  * 	- command line string
  * 	- kernel code & data
+ * 	- crash dumping code reserved region
  * 	- Kernel memory map built from EFI memory map
  *
  * More could be added if necessary
  */
-#define IA64_MAX_RSVD_REGIONS 6
+#define IA64_MAX_RSVD_REGIONS 7
 
 struct rsvd_region {
 	unsigned long start;	/* virtual address of beginning of element */
diff -Nraup linux-2.6.16/include/asm-ia64/smp.h b/include/asm-ia64/smp.h
--- linux-2.6.16/include/asm-ia64/smp.h	2006-03-20 13:53:29.000000000 +0800
+++ b/include/asm-ia64/smp.h	2006-06-08 12:23:31.000000000 +0800
@@ -129,6 +129,9 @@ extern void smp_send_reschedule (int cpu
 extern void lock_ipi_calllock(void);
 extern void unlock_ipi_calllock(void);
 extern void identify_siblings (struct cpuinfo_ia64 *);
+#ifdef CONFIG_KEXEC
+extern void kexec_stop_this_cpu(void *);
+#endif
 
 #else
 
diff -Nraup linux-2.6.16/include/linux/irq.h b/include/linux/irq.h
--- linux-2.6.16/include/linux/irq.h	2006-03-20 13:53:29.000000000 +0800
+++ b/include/linux/irq.h	2006-06-08 12:23:31.000000000 +0800
@@ -94,6 +94,7 @@ irq_descp (int irq)
 #include <asm/hw_irq.h> /* the arch dependent stuff */
 
 extern int setup_irq(unsigned int irq, struct irqaction * new);
+extern void terminate_irqs(void);
 
 #ifdef CONFIG_GENERIC_HARDIRQS
 extern cpumask_t irq_affinity[NR_IRQS];
diff -Nraup linux-2.6.16/kernel/irq/manage.c b/kernel/irq/manage.c
--- linux-2.6.16/kernel/irq/manage.c	2006-03-20 13:53:29.000000000 +0800
+++ b/kernel/irq/manage.c	2006-06-08 12:23:31.000000000 +0800
@@ -377,3 +377,22 @@ int request_irq(unsigned int irq,
 
 EXPORT_SYMBOL(request_irq);
 
+/*
+ * Terminate any outstanding interrupts
+ */
+void terminate_irqs(void)
+{
+	struct irqaction * action;
+	irq_desc_t *idesc;
+	int i;
+
+	for (i=0; i < NR_IRQS; i++) {
+		idesc = irq_descp(i);
+		action = idesc->action;
+		if (!action)
+			continue;
+		if (idesc->handler->end)
+			idesc->handler->end(i);
+	}
+}
+

--=-OAwZ112ebexHlrRcE/CD
Content-Disposition: attachment; filename=kexec-tools-kdump-ia64.patch
Content-Type: text/x-patch; name=kexec-tools-kdump-ia64.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -Nraup a/kexec/arch/ia64/crashdump-ia64.c b/kexec/arch/ia64/crashdump-ia64.c
--- a/kexec/arch/ia64/crashdump-ia64.c	1970-01-01 08:00:00.000000000 +0800
+++ b/kexec/arch/ia64/crashdump-ia64.c	2006-06-03 11:56:58.000000000 +0800
@@ -0,0 +1,351 @@
+/*
+ * kexec: crashdum support
+ * Copyright (C) 2005-2006 Zou Nan hai <nanhai.zou@intel.com> Intel Corp
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation (version 2 of the License).
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+#include <stdio.h>
+#include <string.h>
+#include <stdlib.h>
+#include <errno.h>
+#include <limits.h>
+#include <elf.h>
+#include "../../kexec.h"
+#include "../../kexec-elf.h"
+#include "../../kexec-syscall.h"
+#include "kexec-ia64.h"
+#include "crashdump-ia64.h"
+
+int memory_ranges = 0;
+#define LOAD_OFFSET 	(0xa000000000000000UL + 0x100000000UL - (1UL<<26))
+#define MAX_LINE        160
+/* Stores a sorted list of RAM memory ranges for which to create elf headers.
+ * A separate program header is created for backup region */
+static struct memory_range crash_memory_range[CRASH_MAX_MEMORY_RANGES];
+/* Memory region reserved for storing panic kernel and other data. */
+static struct memory_range crash_reserved_mem;
+unsigned long elfcorehdr;
+static unsigned long kernel_code_start;
+struct loaded_segment {
+        unsigned long start;
+        unsigned long end;
+	unsigned long reserved;
+};
+
+#define MAX_LOAD_SEGMENTS	128
+struct loaded_segment loaded_segments[MAX_LOAD_SEGMENTS];
+
+unsigned long loaded_segments_num, loaded_segments_base;
+static int seg_comp(const void *a, const void *b)
+{
+        const struct loaded_segment *x = a, *y = b;
+        /* avoid overflow */
+        if (x->start > y->start) return 1;
+	if (x->start < y->start) return -1;
+	return 0;
+}
+
+/* purgatory code need this info to patch the EFI memmap
+ */
+static void add_loaded_segments_info(struct kexec_info *info, 
+	struct mem_ehdr *ehdr, unsigned long max_addr)
+{
+	 int i;
+         for(i = 0; i < ehdr->e_phnum; i++) {
+                unsigned long start, end;
+                struct mem_phdr *phdr;
+                phdr = &ehdr->e_phdr[i];
+                if (phdr->p_type != PT_LOAD)
+                        continue;
+                start = phdr->p_paddr;
+                end = phdr->p_paddr + phdr->p_memsz;
+
+		loaded_segments[loaded_segments_num].start =
+                        start&~(ELF_PAGE_SIZE-1);
+                loaded_segments[loaded_segments_num].end =
+                        (end + ELF_PAGE_SIZE - 1)&~(ELF_PAGE_SIZE - 1);
+		loaded_segments[loaded_segments_num].reserved = 0;
+		loaded_segments_num++;
+	}
+}
+
+static int get_crash_notes_section_addr(unsigned long *addr, int cpu)
+{
+        char crash_notes[128];
+        char line[MAX_LINE];
+        FILE *fp;
+	sprintf(crash_notes, "/sys/devices/system/cpu/cpu%d/crash_notes", cpu);
+        fp = fopen(crash_notes, "r");
+        if (!fp) {
+                fprintf(stderr, "Cannot open %s: %s\n",
+                        crash_notes, strerror(errno));
+                fprintf(stderr, "Try mounting sysfs\n");
+                return -1;
+        }
+	if (fscanf(fp, "%lx", addr) != 1) {
+		*addr = 0;
+		return -1;
+	}
+        return 0;
+}
+
+/* Removes crash reserve region from list of memory chunks for whom elf program
+ * headers have to be created. Assuming crash reserve region to be a single
+ * continuous area fully contained inside one of the memory chunks */
+static int exclude_crash_reserve_region(int *nr_ranges)
+{
+	int i, j, tidx = -1;
+	unsigned long cstart, cend;
+	struct memory_range temp_region;
+
+	/* Crash reserved region. */
+	cstart = crash_reserved_mem.start;
+	cend = crash_reserved_mem.end;
+
+	for (i = 0; i < (*nr_ranges); i++) {
+		unsigned long mstart, mend;
+		mstart = crash_memory_range[i].start;
+		mend = crash_memory_range[i].end;
+		if (cstart < mend && cend > mstart) {
+			if (cstart != mstart && cend != mend) {
+				/* Split memory region */
+				crash_memory_range[i].end = cstart - 1;
+				temp_region.start = cend + 1;
+				temp_region.end = mend;
+				temp_region.type = RANGE_RAM;
+				tidx = i+1;
+			} else if (cstart != mstart)
+				crash_memory_range[i].end = cstart - 1;
+			else
+				crash_memory_range[i].start = cend + 1;
+		}
+	}
+	/* Insert split memory region, if any. */
+	if (tidx >= 0) {
+		if (*nr_ranges == CRASH_MAX_MEMORY_RANGES) {
+			/* No space to insert another element. */
+			fprintf(stderr, "Error: Number of crash memory ranges"
+					" excedeed the max limit\n");
+			return -1;
+		}
+		for (j = (*nr_ranges - 1); j >= tidx; j--)
+			crash_memory_range[j+1] = crash_memory_range[j];
+		crash_memory_range[tidx].start = temp_region.start;
+		crash_memory_range[tidx].end = temp_region.end;
+		crash_memory_range[tidx].type = temp_region.type;
+		(*nr_ranges)++;
+	}
+	return 0;
+}
+
+static int prepare_crash_memory_elf64_headers(struct kexec_info *info,
+                                                void *buf, unsigned long size)
+{
+	Elf64_Ehdr *elf;
+	Elf64_Phdr *phdr;
+	int i;
+	long int nr_cpus = 0;
+	char *bufp = buf;
+	unsigned long notes_addr, notes_offset;
+
+	/* Setup ELF Header*/
+	elf = (Elf64_Ehdr *) bufp;
+	bufp += sizeof(Elf64_Ehdr);
+	memcpy(elf->e_ident, ELFMAG, SELFMAG);
+	elf->e_ident[EI_CLASS]  = ELFCLASS64;
+	elf->e_ident[EI_DATA]   = ELFDATA2LSB;
+	elf->e_ident[EI_VERSION]= EV_CURRENT;
+	elf->e_ident[EI_OSABI] = ELFOSABI_NONE;
+	memset(elf->e_ident+EI_PAD, 0, EI_NIDENT-EI_PAD);
+	elf->e_type     = ET_CORE;
+	elf->e_machine  = EM_IA_64;
+	elf->e_version  = EV_CURRENT;
+	elf->e_entry    = 0;
+	elf->e_phoff    = sizeof(Elf64_Ehdr);
+	elf->e_shoff    = 0;
+	elf->e_flags    = 0;
+	elf->e_ehsize   = sizeof(Elf64_Ehdr);
+	elf->e_phentsize= sizeof(Elf64_Phdr);
+	elf->e_phnum    = 0;
+	elf->e_shentsize= 0;
+	elf->e_shnum    = 0;
+	elf->e_shstrndx = 0;
+
+	/* PT_NOTE program headers. One per cpu*/
+	nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	if (nr_cpus < 0) {
+		return -1;
+	}
+
+        /* Need to find a better way to determine per cpu notes section size. */
+#define MAX_NOTE_BYTES  1024
+
+        for (i = 0; i < nr_cpus; i++) {
+        	if (get_crash_notes_section_addr (&notes_addr, i) < 0) 
+                	break;	
+		notes_offset = notes_addr;
+		phdr = (Elf64_Phdr *) bufp;
+                bufp += sizeof(Elf64_Phdr);
+                phdr->p_type    = PT_NOTE;
+                phdr->p_flags   = 0;
+                phdr->p_offset  = notes_offset;
+                phdr->p_vaddr   = phdr->p_paddr = notes_offset;
+                phdr->p_filesz  = phdr->p_memsz = MAX_NOTE_BYTES;
+                /* Do we need any alignment of segments? */
+                phdr->p_align   = 0;
+
+                /* Increment number of program headers. */
+                (elf->e_phnum)++;
+        }
+
+	for (i = 0; i < memory_ranges; i++) {
+		unsigned long mstart, mend;
+		mstart = crash_memory_range[i].start;
+		mend = crash_memory_range[i].end;
+		if (!mstart && !mend)
+			break;
+		phdr = (Elf64_Phdr *) bufp;
+		bufp += sizeof(Elf64_Phdr);
+		phdr->p_type    = PT_LOAD;
+		phdr->p_flags   = PF_R|PF_W|PF_X;
+		phdr->p_offset  = mstart;
+		/*add region 5 mapping for kernel*/
+		if (kernel_code_start >= mstart && kernel_code_start < mend) {
+			phdr->p_vaddr = mstart + LOAD_OFFSET;
+			phdr->p_paddr = mstart;
+			phdr->p_filesz  = phdr->p_memsz = mend - mstart + 1;
+			phdr->p_align   = 0;
+			(elf->e_phnum)++;
+
+			phdr = (Elf64_Phdr *) bufp;
+			bufp += sizeof(Elf64_Phdr);
+			phdr->p_type    = PT_LOAD;
+			phdr->p_flags   = PF_R|PF_W|PF_X;
+			phdr->p_offset  = mstart;
+		}
+		phdr->p_vaddr = mstart + PAGE_OFFSET;
+		phdr->p_paddr = mstart;
+		phdr->p_filesz  = phdr->p_memsz = mend - mstart + 1;
+		phdr->p_align   = 0;
+		(elf->e_phnum)++;
+	}
+	return 0;
+}
+
+static int get_crash_memory_ranges(struct memory_range **range, int *ranges)
+{
+	const char iomem[]= "/proc/iomem";
+        char line[MAX_LINE];
+        FILE *fp;
+        unsigned long start, end;
+
+        fp = fopen(iomem, "r");
+        if (!fp) {
+                fprintf(stderr, "Cannot open %s: %s\n",
+                        iomem, strerror(errno));
+                return -1;
+        }
+	while(fgets(line, sizeof(line), fp) != 0) {
+		char *str;
+		int type, consumed, count;
+		if (memory_ranges >= CRASH_MAX_MEMORY_RANGES)
+			break;
+		count = sscanf(line, "%lx-%lx : %n",
+				&start, &end, &consumed);
+		str = line + consumed;
+		if (count != 2)
+			continue;
+
+		if (memcmp(str, "System RAM\n", 11) == 0) {
+			type = RANGE_RAM;
+		} else if (memcmp(str, "Crash kernel\n", 13) == 0) {
+			/* Reserved memory region. New kernel can
+			 * use this region to boot into. */
+			crash_reserved_mem.start = start;
+			crash_reserved_mem.end = end;
+			crash_reserved_mem.type = RANGE_RAM;
+			continue;
+		}
+		else if (memcmp(str, "Kernel code\n", 12) == 0) {
+			kernel_code_start = start;
+			continue;
+		}else
+			continue;
+		crash_memory_range[memory_ranges].start = start;
+		crash_memory_range[memory_ranges].end = end;
+		crash_memory_range[memory_ranges].type = type;
+		memory_ranges++;
+	}
+        fclose(fp);
+	if (exclude_crash_reserve_region(&memory_ranges) < 0)
+		return -1;
+	*ranges = memory_ranges;
+	return 0;
+}
+
+static void 
+cmdline_add_elfcorehdr(char **cmdline, unsigned long addr)
+{
+	char *str = *cmdline;
+	char buf[64];
+	size_t len;
+	sprintf(buf, " elfcorehdr=%ldK", addr/1024);
+	len = strlen(str) + strlen(buf) + 1;
+	str = xmalloc(len);
+	sprintf(str, "%s%s", *cmdline, buf);
+	*cmdline = str;
+}
+
+int load_crashdump_segments(struct kexec_info *info, struct mem_ehdr *ehdr,
+                            unsigned long max_addr, unsigned long min_base, 
+			    char **cmdline)
+{
+	//struct memory_range *mem_range, *memmap_p;
+	struct memory_range *mem_range;
+	int nr_ranges;
+	size_t size;	
+	void *tmp;
+	if (info->kexec_flags & KEXEC_ON_CRASH ) {
+		if (get_crash_memory_ranges(&mem_range, &nr_ranges) == 0) {
+			size =  sizeof(Elf64_Ehdr) +
+				(nr_ranges + 1) * sizeof(Elf64_Phdr);
+			size = (size + EFI_PAGE_SIZE - 1) & ~(EFI_PAGE_SIZE - 1);
+			tmp = xmalloc(size);
+			memset(tmp, 0, size);
+			if (prepare_crash_memory_elf64_headers(info, tmp, size) < 0)
+				return -1;
+			elfcorehdr = add_buffer(info, tmp, size, size, EFI_PAGE_SIZE, min_base,
+					max_addr, -1);
+			loaded_segments[loaded_segments_num].start = elfcorehdr;
+			loaded_segments[loaded_segments_num].end = elfcorehdr + size;
+			loaded_segments[loaded_segments_num].reserved = 1;
+			loaded_segments_num++;
+			cmdline_add_elfcorehdr(cmdline, elfcorehdr);
+		}
+	}
+	add_loaded_segments_info(info, ehdr, max_addr);
+	size = sizeof(struct loaded_segment) * loaded_segments_num;
+	qsort(loaded_segments, loaded_segments_num,
+                        sizeof(struct loaded_segment), seg_comp);
+        loaded_segments_base = add_buffer(info, loaded_segments,
+                        size, size, 16, 0, max_addr, -1);
+
+        elf_rel_set_symbol(&info->rhdr, "__loaded_segments",
+                        &loaded_segments_base, sizeof(long));
+        elf_rel_set_symbol(&info->rhdr, "__loaded_segments_num",
+                         &loaded_segments_num, sizeof(long));
+	return 0;
+}
+
+
diff -Nraup a/kexec/arch/ia64/crashdump-ia64.h b/kexec/arch/ia64/crashdump-ia64.h
--- a/kexec/arch/ia64/crashdump-ia64.h	1970-01-01 08:00:00.000000000 +0800
+++ b/kexec/arch/ia64/crashdump-ia64.h	2006-06-03 11:56:58.000000000 +0800
@@ -0,0 +1,13 @@
+#ifndef CRASHDUMP_IA64_H
+#define CRASHDUMP_IA64_H
+
+#define PAGE_OFFSET             0xe000000000000000UL
+#define __pa(x)			((unsigned long)(x)-PAGE_OFFSET)
+extern int load_crashdump_segments(struct kexec_info *info, 
+		struct mem_ehdr *ehdr, unsigned long max_addr, 
+		unsigned long min_base, char **cmdline);
+
+#define CRASH_MAX_MEMMAP_NR     (KEXEC_MAX_SEGMENTS + 1)
+#define CRASH_MAX_MEMORY_RANGES (MAX_MEMORY_RANGES + 2)
+
+#endif
diff -Nraup a/kexec/arch/ia64/kexec-elf-ia64.c b/kexec/arch/ia64/kexec-elf-ia64.c
--- a/kexec/arch/ia64/kexec-elf-ia64.c	2004-12-22 04:01:37.000000000 +0800
+++ b/kexec/arch/ia64/kexec-elf-ia64.c	2006-06-03 11:58:45.000000000 +0800
@@ -6,6 +6,7 @@
  * Copyright (C) 2004 Silicon Graphics, Inc.
  *   Jesse Barnes <jbarnes@sgi.com>
  * Copyright (C) 2004 Khalid Aziz <khalid.aziz@hp.com> Hewlett Packard Co
+ * Copyright (C) 2005 Zou Nan hai <nanhai.zou@intel.com> Intel Corp
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -34,11 +35,14 @@
 #include <fcntl.h>
 #include <unistd.h>
 #include <getopt.h>
+#include <limits.h>
 #include <elf.h>
 #include <boot/elf_boot.h>
 #include <ip_checksum.h>
 #include "../../kexec.h"
+#include "../../kexec-syscall.h"
 #include "../../kexec-elf.h"
+#include "crashdump-ia64.h"
 #include <arch/options.h>
 
 static const int probe_debug = 0;
@@ -74,48 +78,79 @@ void elf_ia64_usage(void)
 {
 	printf(
 		"    --command-line=STRING Set the kernel command line to STRING.\n"
-		"    --append=STRING       Set the kernel command line to STRING.\n");
+		"    --append=STRING       Set the kernel command line to STRING.\n"
+		"    --initrd=STRING       Set the kernel initrd to STRING.\n");
+}
+
+/* Move the crash kerenl physical offset to reserved region
+ */
+static void move_loaded_segments(struct kexec_info *info, struct mem_ehdr *ehdr)
+{
+	 int i;
+	 long offset;
+	 struct mem_phdr *phdr;
+	 for(i = 0; i < ehdr->e_phnum; i++) {
+		 phdr = &ehdr->e_phdr[i];
+		 if (phdr->p_type == PT_LOAD) {
+		 	offset = mem_min - phdr->p_paddr;
+			break;
+		}
+	 }
+	 ehdr->e_entry += offset;
+	 for(i = 0; i < ehdr->e_phnum; i++) {
+		 phdr = &ehdr->e_phdr[i];
+		 if (phdr->p_type == PT_LOAD) 
+			phdr->p_paddr += offset;
+	 }
 }
 
 int elf_ia64_load(int argc, char **argv, const char *buf, off_t len,
 	struct kexec_info *info)
 {
 	struct mem_ehdr ehdr;
-	const char *command_line;
-	int command_line_len;
-	unsigned long entry, max_addr;
+	char *command_line = 0, *ramdisk=0;
+	char *ramdisk_buf;
+	off_t ramdisk_size = 0;
+	unsigned long command_line_len;
+	unsigned long entry, max_addr, gp_value;
+	unsigned long command_line_base, ramdisk_base;
+	unsigned long efi_memmap_base, efi_memmap_size;
 	int result;
 	int opt;
+	char *efi_memmap_buf;
 #define OPT_APPEND	(OPT_ARCH_MAX+0)
+#define OPT_RAMDISK	(OPT_ARCH_MAX+1)
 	static const struct option options[] = {
 		KEXEC_ARCH_OPTIONS
 		{"command-line", 1, 0, OPT_APPEND},
 		{"append",       1, 0, OPT_APPEND},
+		{"initrd",       1, 0, OPT_RAMDISK},
 		{0, 0, 0, 0},
 	};
 
 	static const char short_options[] = KEXEC_ARCH_OPT_STR "";
 
 	command_line = 0;
-	while ((opt = getopt_long(argc, argv, short_options, options, 0)) != -1) {
+	while ((opt = getopt_long(argc, argv, short_options, options, 0)) 
+			!= -1) {
 		switch (opt) {
-		default:
-			/* Ignore core options */
-			if (opt < OPT_ARCH_MAX) {
+			default:
+				/* Ignore core options */
+				if (opt < OPT_ARCH_MAX) {
+					break;
+				}
+			case '?':
+				usage();
+				return -1;
+			case OPT_APPEND:
+				command_line = optarg;
+				break;
+			case OPT_RAMDISK:
+				ramdisk = optarg;
 				break;
-			}
-		case '?':
-			usage();
-			return -1;
-		case OPT_APPEND:
-			command_line = optarg;
-			break;
 		}
 	}
 	command_line_len = 0;
-	if (command_line) {
-		command_line_len = strlen(command_line) + 1;
-	}
 
 	/* Parse the Elf file */
 	result = build_elf_exec_info(buf, len, &ehdr);
@@ -124,18 +159,85 @@ int elf_ia64_load(int argc, char **argv,
 		free_elf_info(&ehdr);
 		return result;
 	}
+	if (info->kexec_flags & KEXEC_ON_CRASH ) {
+		if ((mem_min == 0x00) && (mem_max = ULONG_MAX)) {
+                       fprintf(stderr, "Failed to find crash kernel region in /proc/iomem\n");
+                       return -1;
+               }
+               move_loaded_segments(info, &ehdr);
+       }
+
 	entry = ehdr.e_entry;
 	max_addr = elf_max_addr(&ehdr);
-
 	/* Load the Elf data */
 	result = elf_exec_load(&ehdr, info);
-	free_elf_info(&ehdr);
 	if (result < 0) {
 		fprintf(stderr, "ELF load failed\n");
 		return result;
 	}
-	
-	/* For now we don't have arguments to pass :( */
-	info->entry = (void *)entry;
+	/* Load the setup code */
+	elf_rel_build_load(info, &info->rhdr, purgatory, purgatory_size,
+			0, ULONG_MAX, -1);
+
+	if (load_crashdump_segments(info, &ehdr, max_addr, 0, 
+				&command_line) < 0)
+		return -1;
+
+	// reserve 8k for efi_memmap
+	efi_memmap_size = 1UL<<14; 
+	efi_memmap_buf = xmalloc(efi_memmap_size);
+	efi_memmap_base = add_buffer(info, efi_memmap_buf,
+			efi_memmap_size, efi_memmap_size, 4096, 0, 
+			max_addr, -1);
+
+	elf_rel_set_symbol(&info->rhdr, "__efi_memmap_base", 
+			&efi_memmap_base, sizeof(long));
+
+	elf_rel_set_symbol(&info->rhdr, "__efi_memmap_size", 
+			&efi_memmap_size, sizeof(long));
+	if (command_line) {
+		command_line_len = strlen(command_line) + 1;
+	}
+	if (command_line_len || (info->kexec_flags & KEXEC_ON_CRASH )) {
+		char *cmdline = xmalloc(command_line_len);
+		strcpy(cmdline, command_line);
+
+		if (info->kexec_flags & KEXEC_ON_CRASH) {
+			char buf[128];
+			sprintf(buf," max_addr=%lluM min_addr=%lluM", 
+					mem_max>>20, mem_min>>20);
+			command_line_len = strlen(cmdline) + strlen(buf) + 1;
+			cmdline = xrealloc(cmdline, command_line_len);  
+			strcat(cmdline, buf);
+		}
+
+		command_line_len = (command_line_len + 15)&(~15);
+		command_line_base = add_buffer(info, cmdline,
+				command_line_len, command_line_len,
+				getpagesize(), 0UL, 
+				max_addr, -1);
+		elf_rel_set_symbol(&info->rhdr, "__command_line_len",
+				&command_line_len, sizeof(long));
+		elf_rel_set_symbol(&info->rhdr, "__command_line",
+				&command_line_base, sizeof(long));
+	}
+	if (ramdisk) {
+		ramdisk_buf = slurp_file(ramdisk, &ramdisk_size);
+		ramdisk_base = add_buffer(info, ramdisk_buf, ramdisk_size,
+				ramdisk_size,
+				getpagesize(), 0, max_addr, -1);
+		elf_rel_set_symbol(&info->rhdr, "__ramdisk_base",
+				&ramdisk_base, sizeof(long));
+		elf_rel_set_symbol(&info->rhdr, "__ramdisk_size",
+				&ramdisk_size, sizeof(long));
+	}
+
+	gp_value = info->rhdr.rel_addr + 0x200000;
+	elf_rel_set_symbol(&info->rhdr, "__gp_value", &gp_value,
+			sizeof(gp_value));
+
+	elf_rel_set_symbol(&info->rhdr, "__kernel_entry", &entry, sizeof(entry));
+
+	free_elf_info(&ehdr);
 	return 0;
 }
diff -Nraup a/kexec/arch/ia64/kexec-elf-rel-ia64.c b/kexec/arch/ia64/kexec-elf-rel-ia64.c
--- a/kexec/arch/ia64/kexec-elf-rel-ia64.c	2004-12-21 06:43:23.000000000 +0800
+++ b/kexec/arch/ia64/kexec-elf-rel-ia64.c	2006-06-03 11:56:58.000000000 +0800
@@ -1,8 +1,32 @@
+/*
+ * Copyright (C) 2005-2006  Zou Nan hai (nanhai.zou@intel.com)
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation (version 2 of the License).
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+/*  pugatory relocation code
+ *  Most of the code in this file is
+ *  based on arch/ia64/kernel/module.c in Linux kernel
+ */
+
 #include <stdio.h>
 #include <elf.h>
 #include "../../kexec.h"
 #include "../../kexec-elf.h"
 
+#define MAX_LTOFF       ((uint64_t) (1 << 22))
+
 int machine_verify_elf_rel(struct mem_ehdr *ehdr)
 {
 	if (ehdr->ei_data != ELFDATA2LSB) {
@@ -17,12 +41,49 @@ int machine_verify_elf_rel(struct mem_eh
 	return 1;
 }
 
+static void
+ia64_patch (uint64_t insn_addr, uint64_t mask, uint64_t val)
+{
+        uint64_t m0, m1, v0, v1, b0, b1, *b = (uint64_t *) (insn_addr & -16);
+#       define insn_mask ((1UL << 41) - 1)
+        unsigned long shift;
+
+        b0 = b[0]; b1 = b[1];
+        shift = 5 + 41 * (insn_addr % 16); /* 5 bits of template, then 3 x 41-bit instructions */
+        if (shift >= 64) {
+                m1 = mask << (shift - 64);
+                v1 = val << (shift - 64);
+        } else {
+                m0 = mask << shift; m1 = mask >> (64 - shift);
+                v0 = val  << shift; v1 = val >> (64 - shift);
+                b[0] = (b0 & ~m0) | (v0 & m0);
+        }
+        b[1] = (b1 & ~m1) | (v1 & m1);
+}
+
+static void 
+put_unaligned64(unsigned long val, unsigned char *location) 
+{
+	unsigned char *src = (unsigned char *)&val;
+	int i;
+	for (i = 0; i < sizeof(long); i++)
+		*location++ = *src++;
+}
+
+static inline uint64_t
+bundle (const uint64_t insn)
+{
+        return insn & ~0xfUL;
+}
+
 void machine_apply_elf_rel(struct mem_ehdr *ehdr, unsigned long r_type,
 	void *location, unsigned long address, unsigned long value)
 {
+	uint64_t gp_value = ehdr->rel_addr + 0x200000;
 	switch(r_type) {
 	case R_IA64_NONE:
 		break;
+	case R_IA64_SEGREL64LSB:
 	case R_IA64_DIR64LSB:
 		*((uint64_t *)location) = value;
 		break;
@@ -31,15 +92,72 @@ void machine_apply_elf_rel(struct mem_eh
 		if (value != *((uint32_t *)location))
 			goto overflow;
 		break;
-	case R_IA64_PCREL21B:
+	case R_IA64_IMM64:
+		ia64_patch((uint64_t)location, 0x01fffefe000UL, 
+				/* bit 63 -> 36 */
+				(((value & 0x8000000000000000UL) >> 27) 
+				/* bit 21 -> 21 */
+				  | ((value & 0x0000000000200000UL) <<  0) 
+				/* bit 16 -> 22 */
+				  | ((value & 0x00000000001f0000UL) <<  6) 
+				/* bit 7 -> 27 */
+				  | ((value & 0x000000000000ff80UL) << 20) 
+				/* bit 0 -> 13 */
+				  | ((value & 0x000000000000007fUL) << 13)));
+		ia64_patch((uint64_t)location - 1, 0x1ffffffffffUL, value>>22);
+		break;
+	case R_IA64_IMM22:
+		if (value + (1 << 21) >= (1 << 22))
+                	die("value out of IMM22 range\n");
+		ia64_patch((uint64_t)location, 0x01fffcfe000UL,
+				/* bit 21 -> 36 */
+				(((value & 0x200000UL) << 15)
+				/* bit 16 -> 22 */
+				 | ((value & 0x1f0000UL) <<  6)
+				/* bit  7 -> 27 */
+				 | ((value & 0x00ff80UL) << 20)
+				/* bit  0 -> 13 */
+				 | ((value & 0x00007fUL) << 13) ));
+		break;
+	case R_IA64_PCREL21B: {
+		uint64_t delta = ((int64_t)value - (int64_t)address)/16;
+		if (delta + (1 << 20) >= (1 << 21))
+			die("value out of IMM21B range\n");
+		value = ((int64_t)(value - bundle(address)))/16;
+		ia64_patch((uint64_t)location, 0x11ffffe000UL,
+				(((value & 0x100000UL) << 16) /* bit 20 -> 36 */
+				 | ((value & 0x0fffffUL) << 13) /* bit  0 -> 13 */));
+		}
+		break;
+	case R_IA64_PCREL64LSB: {
+		value = value - address;
+		put_unaligned64(value, location);	
+	} break;
+	case R_IA64_GPREL22:
+	case R_IA64_LTOFF22X:
+		if (value - gp_value + MAX_LTOFF/2 >= MAX_LTOFF)
+			die("value out of gp relative range");
+		value -= gp_value;
+		ia64_patch((uint64_t)location, 0x01fffcfe000UL,
+				(((value & 0x200000UL) << 15) /* bit 21 -> 36 */
+				   |((value & 0x1f0000UL) <<  6) /* bit 16 -> 22 */
+				   |((value & 0x00ff80UL) << 20) /* bit  7 -> 27 */
+				   |((value & 0x00007fUL) << 13) /* bit  0 -> 13 */));
+		break;
+	case R_IA64_LDXMOV:
+		if (value - gp_value + MAX_LTOFF/2 >= MAX_LTOFF)
+			die("value out of gp relative range");
+		ia64_patch((uint64_t)location, 0x1fff80fe000UL, 0x10000000000UL);
+	        break;
 	case R_IA64_LTOFF22:
-	case R_IA64_SEGREL64LSB:
+
 	default:
-		die("Unknown rela relocation: %lu\n", r_type);
+		die("Unknown rela relocation: 0x%lx 0x%lx\n",
+				r_type, address);
 		break;
 	}
 	return;
- overflow:
+overflow:
 	die("overflow in relocation type %lu val %Lx\n", 
-		r_type, value);
+			r_type, value);
 }
diff -Nraup a/kexec/arch/ia64/kexec-ia64.c b/kexec/arch/ia64/kexec-ia64.c
--- a/kexec/arch/ia64/kexec-ia64.c	2006-06-03 11:56:06.000000000 +0800
+++ b/kexec/arch/ia64/kexec-ia64.c	2006-06-03 12:00:38.000000000 +0800
@@ -6,6 +6,8 @@
  * Copyright (C) 2004 Silicon Graphics, Inc.
  *   Jesse Barnes <jbarnes@sgi.com>
  *
+ * Copyright (C) 2005-2006 Zou Nan hai <nanhai.zou@intel.com> Intel Corp
+
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation (version 2 of the License).
@@ -27,40 +29,84 @@
 #include <stdint.h>
 #include <string.h>
 #include <getopt.h>
+#include <sched.h>
 #include <sys/utsname.h>
 #include "../../kexec.h"
 #include "../../kexec-syscall.h"
 #include "kexec-ia64.h"
 #include <arch/options.h>
 
-#define MAX_MEMORY_RANGES 64
 #define MAX_LINE 160
 static struct memory_range memory_range[MAX_MEMORY_RANGES];
 
 /* Return a sorted list of available memory ranges. */
 int get_memory_ranges(struct memory_range **range, int *ranges,
-				unsigned long kexec_flags)
+	   			unsigned long kexec_flags)
 {
-	int memory_ranges;
-	/*
-	 * /proc/iomem on ia64 does not show where all memory is. If
-	 * that is fixed up, we can make use of that to validate
-	 * the memory range kernel will be loade din. Until then.....
-	 * -- Khalid Aziz
-	 */
-	
-	/* Note that the ia64 architecture mandates all systems will
-	 * have at least 64MB at 0-64M.  The SGI altix does not follow
-	 * that restriction, but a reasonable guess is better than nothing
-	 * at all.
-	 * -- Eric Biederman
-	 */
-	fprintf(stderr, "Warning assuming memory at 0-64MB is present\n");
-	memory_ranges = 0;
-	memory_range[memory_ranges].start = 0x00010000;
-	memory_range[memory_ranges].end   = 0x10000000;
-	memory_range[memory_ranges].type  = RANGE_RAM;
-	memory_ranges++;
+	const char iomem[]= "/proc/iomem";
+	int memory_ranges = 0;
+	char line[MAX_LINE];
+	FILE *fp;
+	fp = fopen(iomem, "r");
+	if (!fp) {
+		fprintf(stderr, "Cannot open %s: %s\n", 
+			iomem, strerror(errno));
+		return -1;
+	}
+
+	while(fgets(line, sizeof(line), fp) != 0) {
+		unsigned long start, end;
+		char *str;
+		int type;
+		int consumed;
+		int count;
+		if (memory_ranges >= MAX_MEMORY_RANGES)
+			break;
+		count = sscanf(line, "%lx-%lx : %n",
+				&start, &end, &consumed);
+		if (count != 2) 
+			continue;
+		str = line + consumed;
+		end = end + 1;
+		if (memcmp(str, "System RAM\n", 11) == 0) {
+			type = RANGE_RAM;
+		} 
+		else if (memcmp(str, "reserved\n", 9) == 0) {
+			type = RANGE_RESERVED;
+		}
+		else if (memcmp(str, "Crash kernel\n", 13) == 0) {
+			/* Redefine the memory region boundaries if kernel
+			 * exports the limits and if it is panic kernel.
+			 * Override user values only if kernel exported values are
+			 * subset of user defined values.
+			 */
+
+			if (kexec_flags & KEXEC_ON_CRASH) {
+				if (start > mem_min)
+					mem_min = start;
+				if (end < mem_max)
+					mem_max = end;
+			}
+			continue;
+		} else
+			continue;
+		/*
+		 * Check if this memory range can be coalesced with
+		 * the previous range
+		 */
+		if ((memory_ranges > 0) &&
+				(start == memory_range[memory_ranges-1].end) &&
+				(type == memory_range[memory_ranges-1].type)) {
+			memory_range[memory_ranges-1].end = end;
+		}
+		else {
+			memory_range[memory_ranges].start = start;
+			memory_range[memory_ranges].end = end;
+			memory_range[memory_ranges].type = type;
+			memory_ranges++;
+		}
+	}
+	fclose(fp);
 	*range = memory_range;
 	*ranges = memory_ranges;
 	return 0;
@@ -77,9 +123,6 @@ void arch_usage(void)
 {
 }
 
-static struct {
-} arch_options = {
-};
 int arch_process_options(int argc, char **argv)
 {
 	static const struct option options[] = {
@@ -88,8 +131,11 @@ int arch_process_options(int argc, char 
 	};
 	static const char short_options[] = KEXEC_ARCH_OPT_STR;
 	int opt;
-	unsigned long value;
-	char *end;
+	/* execute from BP */
+        cpu_set_t affinity;
+	CPU_ZERO(&affinity);
+	CPU_SET(0, &affinity);
+        sched_setaffinity(0, sizeof(affinity), &affinity);
 
 	opterr = 0; /* Don't complain about unrecognized options here */
 	while((opt = getopt_long(argc, argv, short_options, options, 0)) != -1) {
@@ -116,32 +162,7 @@ int arch_compat_trampoline(struct kexec_
 	}
 	if (strcmp(utsname.machine, "ia64") == 0)
 	{
-		info->kexec_flags |= KEXEC_ARCH_X86_64;
-	}
-	else {
-		fprintf(stderr, "Unsupported machine type: %s\n",
-			utsname.machine);
-		return -1;
-	}
-	return 0;
-}
-
-int arch_compat_trampoline(struct kexec_info *info)
-{
-	int result;
-	struct utsname utsname;
-	result = uname(&utsname);
-	if (result < 0) {
-		fprintf(stderr, "uname failed: %s\n",
-			strerror(errno));
-		return -1;
-	}
-	if (strcmp(utsname.machine, "ia64") == 0)
-	{
-		/* For compatibility with older patches 
-		 * use KEXEC_ARCH_DEFAULT instead of KEXEC_ARCH_IA64 here.
-		 */
-		info->kexec_flags |= KEXEC_ARCH_DEFAULT;
+		info->kexec_flags |= KEXEC_ARCH_IA_64;
 	}
 	else {
 		fprintf(stderr, "Unsupported machine type: %s\n",
diff -Nraup a/kexec/arch/ia64/kexec-ia64.h b/kexec/arch/ia64/kexec-ia64.h
--- a/kexec/arch/ia64/kexec-ia64.h	2004-12-20 07:52:38.000000000 +0800
+++ b/kexec/arch/ia64/kexec-ia64.h	2006-06-03 11:56:58.000000000 +0800
@@ -5,5 +5,7 @@ int elf_ia64_probe(const char *buf, off_
 int elf_ia64_load(int argc, char **argv, const char *buf, off_t len,
 	struct kexec_info *info);
 void elf_ia64_usage(void);
-
+#define MAX_MEMORY_RANGES 1024
+#define EFI_PAGE_SIZE	  (1UL<<12)
+#define ELF_PAGE_SIZE	  (1UL<<16)
 #endif /* KEXEC_IA64_H */
diff -Nraup a/kexec/arch/ia64/Makefile b/kexec/arch/ia64/Makefile
--- a/kexec/arch/ia64/Makefile	2004-12-20 08:11:13.000000000 +0800
+++ b/kexec/arch/ia64/Makefile	2006-06-03 11:56:58.000000000 +0800
@@ -4,3 +4,5 @@
 KEXEC_C_SRCS+= kexec/arch/ia64/kexec-ia64.c 
 KEXEC_C_SRCS+= kexec/arch/ia64/kexec-elf-ia64.c 
 KEXEC_C_SRCS+= kexec/arch/ia64/kexec-elf-rel-ia64.c
+KEXEC_C_SRCS+= kexec/arch/ia64/crashdump-ia64.c
+
diff -Nraup a/kexec/kexec.c b/kexec/kexec.c
--- a/kexec/kexec.c	2006-06-03 11:56:06.000000000 +0800
+++ b/kexec/kexec.c	2006-06-03 11:56:58.000000000 +0800
@@ -96,6 +96,9 @@ int valid_memory_range(unsigned long sst
 			continue;
 		mstart = memory_range[i].start;
 		mend = memory_range[i].end;
+		if (i < memory_ranges - 1 && mend == memory_range[i+1].start)
+			mend = memory_range[i+1].end;
+
 		/* Check to see if we are fully contained */
 		if ((mstart <= sstart) && (mend >= send)) {
 			return 1;
@@ -187,7 +190,7 @@ unsigned long locate_hole(struct kexec_i
 	}
 
 	/* Compute the free memory ranges */
-	max_mem_ranges = memory_ranges + (info->nr_segments -1);
+	max_mem_ranges = memory_ranges + (info->nr_segments);
 	mem_range = malloc(max_mem_ranges *sizeof(struct memory_range));
 	mem_ranges = 0;
 		
diff -Nraup a/kexec/kexec-syscall.h b/kexec/kexec-syscall.h
--- a/kexec/kexec-syscall.h	2005-01-06 14:59:50.000000000 +0800
+++ b/kexec/kexec-syscall.h	2006-06-03 11:56:58.000000000 +0800
@@ -68,6 +68,6 @@ static inline long kexec_reboot(void)
 #define KEXEC_ARCH_PPC64   (21 << 16)
 #define KEXEC_ARCH_IA_64   (50 << 16)
 
-#define KEXEC_MAX_SEGMENTS 8
+#define KEXEC_MAX_SEGMENTS 16
 
 #endif /* KEXEC_SYSCALL_H */
diff -Nraup a/purgatory/arch/ia64/console-ia64.c b/purgatory/arch/ia64/console-ia64.c
--- a/purgatory/arch/ia64/console-ia64.c	2004-12-21 06:41:26.000000000 +0800
+++ b/purgatory/arch/ia64/console-ia64.c	2006-06-03 11:56:58.000000000 +0800
@@ -1,5 +1,47 @@
 #include <purgatory.h>
+#include "io.h"
+
+#define VGABASE         UNCACHED(0xb8000)
+
+/* code based on i386 console code
+ * TODO add serial support
+ */
+#define MAX_YPOS        25
+#define MAX_XPOS        80
+
+unsigned long current_ypos = 1, current_xpos = 0;
+
+static void putchar_vga(int ch)
+{
+	int  i, k, j;
+
+	if (current_ypos >= MAX_YPOS) {
+		/* scroll 1 line up */
+		for (k = 1, j = 0; k < MAX_YPOS; k++, j++) {
+			for (i = 0; i < MAX_XPOS; i++) {
+				writew(readw(VGABASE + 2*(MAX_XPOS*k + i)),
+						VGABASE + 2*(MAX_XPOS*j + i));
+			}
+		}
+		for (i = 0; i < MAX_XPOS; i++)
+			writew(0x720, VGABASE + 2*(MAX_XPOS*j + i));
+		current_ypos = MAX_YPOS-1;
+	}
+	if (ch == '\n') {
+		current_xpos = 0;
+		current_ypos++;
+	} else if (ch != '\r')  {
+		writew(((0x7 << 8) | (unsigned short) ch),
+				VGABASE + 2*(MAX_XPOS*current_ypos +
+					current_xpos++));
+		if (current_xpos >= MAX_XPOS) {
+			current_xpos = 0;
+			current_ypos++;
+		}
+	}
+}
+
 void putchar(int ch)
 {
-	/* Nothing for now */
+	putchar_vga(ch);
 }
diff -Nraup a/purgatory/arch/ia64/entry.S b/purgatory/arch/ia64/entry.S
--- a/purgatory/arch/ia64/entry.S	1970-01-01 08:00:00.000000000 +0800
+++ b/purgatory/arch/ia64/entry.S	2006-06-03 11:56:58.000000000 +0800
@@ -0,0 +1,67 @@
+/*
+ * purgatory:  setup code
+ *
+ * Copyright (C) 2005-2006  Zou Nan hai (nanhai.zou@intel.com)
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation (version 2 of the License).
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+#define DECLARE_DATA8(name)	\
+.global name;	\
+.size	name, 8;	\
+name:	data8 0x0
+
+.global __dummy_efi_function
+.align  32
+.proc  __dummy_efi_function
+__dummy_efi_function:
+	mov r8=r0;;
+	br.ret.sptk.many rp;;
+.global __dummy_efi_function_end
+__dummy_efi_function_end:
+.endp 	__dummy_efi_function
+
+.global purgatory_start
+.align  32
+.proc   purgatory_start
+purgatory_start:
+	movl r2=__gp_value;;
+	ld8 gp=[r2];;
+	br.call.sptk.many b0=purgatory
+	;;
+	alloc r2 = ar.pfs, 0, 0, 2, 0
+	;;
+	mov out0=r28
+	movl out1=__ramdisk_base;;
+	br.call.sptk.many b0=ia64_env_setup
+	movl r10=__kernel_entry;;
+	ld8 r14=[r10];;
+	mov b6=r14;;
+	mov ar.lc=r0
+	mov ar.ec=r0
+	cover;;
+	invala;;
+	br.call.sptk.many  b0=b6
+.endp   purgatory_start
+
+DECLARE_DATA8(__kernel_entry)
+DECLARE_DATA8(__ramdisk_base)
+DECLARE_DATA8(__ramdisk_size)
+DECLARE_DATA8(__command_line)
+DECLARE_DATA8(__command_line_len)
+DECLARE_DATA8(__efi_memmap_base)
+DECLARE_DATA8(__efi_memmap_size)
+DECLARE_DATA8(__loaded_segments)
+DECLARE_DATA8(__loaded_segments_num)
+
+DECLARE_DATA8(__gp_value)
diff -Nraup a/purgatory/arch/ia64/io.h b/purgatory/arch/ia64/io.h
--- a/purgatory/arch/ia64/io.h	1970-01-01 08:00:00.000000000 +0800
+++ b/purgatory/arch/ia64/io.h	2006-06-03 11:56:58.000000000 +0800
@@ -0,0 +1,94 @@
+#ifndef IO_H
+#define IO_H
+#define UNCACHED(x) (void *)((x)|(1UL<<63))
+#define MF()	asm volatile ("mf.a" ::: "memory")
+#define IO_SPACE_ENCODING(p)     ((((p) >> 2) << 12) | (p & 0xfff))
+
+static inline void *io_addr (unsigned long port)
+{
+        unsigned long offset;
+	unsigned long io_base;
+	asm volatile ("mov %0=ar.k0":"=r"(io_base));
+	offset = IO_SPACE_ENCODING(port);
+        return UNCACHED(io_base | offset);
+}
+
+static inline unsigned int inb (unsigned long port)
+{
+        volatile unsigned char *addr = io_addr(port);
+        unsigned char ret;
+        ret = *addr;
+        MF();
+        return ret;
+}
+
+static inline unsigned int inw (unsigned long port)
+{
+        volatile unsigned short *addr = io_addr(port);
+        unsigned short ret;
+
+        ret = *addr;
+	MF();
+        return ret;
+}
+
+static inline unsigned int ia64_inl (unsigned long port)
+{
+        volatile unsigned int *addr = __ia64_mk_io_addr(port);
+        unsigned int ret;
+        ret = *addr;
+	MF();
+        return ret;
+}
+
+static inline void outb (unsigned char val, unsigned long port)
+{
+        volatile unsigned char *addr = io_addr(port);
+
+        *addr = val;
+	MF();
+}
+
+static inline void outw (unsigned short val, unsigned long port)
+{
+        volatile unsigned short *addr = io_addr(port);
+
+        *addr = val;
+	MF();
+}
+
+static inline void outl (unsigned int val, unsigned long port)
+{
+        volatile unsigned int *addr = io_addr(port);
+
+        *addr = val;
+	MF();
+}
+
+
+static inline unsigned char readb(const volatile void  *addr)
+{
+        return *(volatile unsigned char *) addr;
+}
+static inline unsigned short readw(const volatile void  *addr)
+{
+        return *(volatile unsigned short *) addr;
+}
+static inline unsigned int readl(const volatile void  *addr)
+{
+        return *(volatile unsigned int *) addr;
+}
+
+static inline void writeb(unsigned char b, volatile void  *addr)
+{
+        *(volatile unsigned char *) addr = b;
+}
+static inline void writew(unsigned short b, volatile void  *addr)
+{
+        *(volatile unsigned short *) addr = b;
+}
+static inline void writel(unsigned int b, volatile void  *addr)
+{
+        *(volatile unsigned int *) addr = b;
+}
+#endif
diff -Nraup a/purgatory/arch/ia64/Makefile b/purgatory/arch/ia64/Makefile
--- a/purgatory/arch/ia64/Makefile	2004-12-21 06:44:22.000000000 +0800
+++ b/purgatory/arch/ia64/Makefile	2006-06-03 11:56:58.000000000 +0800
@@ -1,9 +1,9 @@
 #
 # Purgatory ia64
 #
-
-PURGATORY_S_SRCS+=
+PCFLAGS		+= -ffixed-r28
+PURGATORY_S_SRCS+= purgatory/arch/ia64/entry.S
 PURGATORY_C_SRCS+= purgatory/arch/ia64/purgatory-ia64.c
 PURGATORY_C_SRCS+= purgatory/arch/ia64/console-ia64.c
-PURGATORY_C_SRCS+=
+PURGATORY_C_SRCS+= purgatory/arch/ia64/vga.c
 
diff -Nraup a/purgatory/arch/ia64/purgatory-ia64.c b/purgatory/arch/ia64/purgatory-ia64.c
--- a/purgatory/arch/ia64/purgatory-ia64.c	2006-06-03 11:56:06.000000000 +0800
+++ b/purgatory/arch/ia64/purgatory-ia64.c	2006-06-03 11:56:58.000000000 +0800
@@ -1,9 +1,271 @@
+/*
+ * purgatory:  setup code
+ *
+ * Copyright (C) 2005-2006  Zou Nan hai (nanhai.zou@intel.com)
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation (version 2 of the License).
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
 #include <purgatory.h>
+#include <stdint.h>
+#include <string.h>
 #include "purgatory-ia64.h"
 
-void setup_arch(void)
+#define PAGE_OFFSET             0xe000000000000000UL
+
+#define EFI_PAGE_SHIFT          12
+#define EFI_PAGE_SIZE		(1UL<<EFI_PAGE_SHIFT)
+#define EFI_PAGE_ALIGN(x)	((x + EFI_PAGE_SIZE - 1)&~(EFI_PAGE_SIZE-1))
+/* Memory types: */
+#define EFI_RESERVED_TYPE                0
+#define EFI_LOADER_CODE                  1
+#define EFI_LOADER_DATA                  2
+#define EFI_BOOT_SERVICES_CODE           3
+#define EFI_BOOT_SERVICES_DATA           4
+#define EFI_RUNTIME_SERVICES_CODE        5
+#define EFI_RUNTIME_SERVICES_DATA        6
+#define EFI_CONVENTIONAL_MEMORY          7
+#define EFI_UNUSABLE_MEMORY              8
+#define EFI_ACPI_RECLAIM_MEMORY          9
+#define EFI_ACPI_MEMORY_NVS             10
+#define EFI_MEMORY_MAPPED_IO            11
+#define EFI_MEMORY_MAPPED_IO_PORT_SPACE 12
+#define EFI_PAL_CODE                    13
+#define EFI_MAX_MEMORY_TYPE             14
+
+typedef struct {
+        uint64_t signature;
+        uint32_t revision;
+        uint32_t headersize;
+        uint32_t crc32;
+        uint32_t reserved;
+} efi_table_hdr_t;
+
+typedef struct {
+        efi_table_hdr_t hdr;
+        unsigned long get_time;
+        unsigned long set_time;
+        unsigned long get_wakeup_time;
+        unsigned long set_wakeup_time;
+        unsigned long set_virtual_address_map;
+        unsigned long convert_pointer;
+        unsigned long get_variable;
+        unsigned long get_next_variable;
+        unsigned long set_variable;
+        unsigned long get_next_high_mono_count;
+        unsigned long reset_system;
+} efi_runtime_services_t;
+
+typedef struct {
+        efi_table_hdr_t hdr;
+        unsigned long fw_vendor;        /* physical addr of CHAR16 vendor string
+ */
+        uint32_t fw_revision;
+        unsigned long con_in_handle;
+        unsigned long con_in;
+        unsigned long con_out_handle;
+        unsigned long con_out;
+        unsigned long stderr_handle;
+        unsigned long stderr;
+        unsigned long runtime;
+        unsigned long boottime;
+        unsigned long nr_tables;
+        unsigned long tables;
+} efi_system_table_t;
+
+struct ia64_boot_param {
+        uint64_t command_line;             /* physical address of command line arguments */
+        uint64_t efi_systab;               /* physical address of EFI system table */
+        uint64_t efi_memmap;               /* physical address of EFI memory map */
+        uint64_t efi_memmap_size;          /* size of EFI memory map */
+        uint64_t efi_memdesc_size;         /* size of an EFI memory map descriptor */
+        uint32_t efi_memdesc_version;      /* memory descriptor version */
+        struct {
+                uint16_t num_cols; /* number of columns on console output device */
+                uint16_t num_rows; /* number of rows on console output device */
+                uint16_t orig_x;   /* cursor's x position */
+                uint16_t orig_y;   /* cursor's y position */
+        } console_info;
+        uint64_t fpswa;            /* physical address of the fpswa interface */
+        uint64_t initrd_start;
+        uint64_t initrd_size;
+};
+
+typedef struct {
+        uint32_t type;
+        uint32_t pad;
+        uint64_t phys_addr;
+        uint64_t virt_addr;
+        uint64_t num_pages;
+        uint64_t attribute;
+} efi_memory_desc_t;
+
+struct loaded_segment {
+        unsigned long start;
+        unsigned long end;
+        unsigned long reserved;
+};
+
+struct kexec_boot_params {
+	uint64_t ramdisk_base;
+	uint64_t ramdisk_size;
+	uint64_t command_line;
+	uint64_t command_line_len;
+	uint64_t efi_memmap_base;
+	uint64_t efi_memmap_size;
+	struct loaded_segment *loaded_segments;
+	unsigned long loaded_segments_num;
+};
+
+void 
+setup_arch(void)
 {
-	/* Nothing for now */
+	reset_vga();
+}
+
+inline unsigned long PA(unsigned long addr)
+{
+	return addr - PAGE_OFFSET;
+}
+
+void 
+patch_efi_memmap(struct kexec_boot_params *params, 
+		struct ia64_boot_param *boot_param)
+{
+	void *dest = (void *)params->efi_memmap_base; 
+	void *src  = (void *)boot_param->efi_memmap;
+	unsigned long len = boot_param->efi_memmap_size;
+	unsigned long memdesc_size = boot_param->efi_memdesc_size;
+	uint64_t orig_type;
+	efi_memory_desc_t *md1, *md2;
+	void *p1, *p2, *src_end = src + len;
+	int i;
+	for (p1 = src, p2 = dest; p1 < src_end; 
+			p1 += memdesc_size, p2 += memdesc_size) {
+		unsigned long mstart, mend;
+		md1 = p1;
+		md2 = p2;
+		if (md1->num_pages == 0) 
+			continue;
+		mstart = md1->phys_addr;
+		mend = md1->phys_addr + (md1->num_pages 
+				<< EFI_PAGE_SHIFT);
+		switch (md1->type) {
+			case EFI_LOADER_DATA:
+				*md2 = *md1;
+				md2->type = EFI_CONVENTIONAL_MEMORY;
+				break;
+			default:
+				*md2 = *md1;
+		}
+		// segments are already sorted and aligned to 4K 
+		orig_type = md2->type;
+		for (i = 0; i < params->loaded_segments_num; i++) {
+			struct loaded_segment *seg;
+			seg = &params->loaded_segments[i];
+			if (seg->start >= mstart && seg->start < mend) {
+				unsigned long start_pages, mid_pages, end_pages;
+				if (seg->end > mend) {
+					p1 += memdesc_size;
+					for(; p1 < src_end; 
+							p1 += memdesc_size) {
+						md1 = p1;
+						/* TODO check contig and attribute here */
+						mend = md1->phys_addr 
+							+ (md1->num_pages << EFI_PAGE_SHIFT);
+						if (seg->end < mend)
+							break;
+					}
+				}
+				start_pages = (seg->start - mstart) 
+					>> EFI_PAGE_SHIFT;
+				mid_pages = (seg->end - seg->start)
+					>> EFI_PAGE_SHIFT;
+				end_pages  = (mend - seg->end) 
+					>> EFI_PAGE_SHIFT;
+				if (start_pages) {
+					md2->num_pages = start_pages;
+					p2 += memdesc_size; 
+					md2 = p2;
+					*md2 = *md1;
+				}
+				md2->phys_addr = seg->start;
+				md2->num_pages = mid_pages;
+				md2->type = seg->reserved ? 
+					EFI_UNUSABLE_MEMORY:EFI_LOADER_DATA;
+				if (end_pages) {
+					p2 += memdesc_size; 
+					md2 = p2;
+					*md2 = *md1;
+					md2->phys_addr = seg->end;
+					md2->num_pages = end_pages;
+					md2->type = orig_type;
+					mstart = seg->end;
+				} else 
+					break;
+			}
+		}
+	}
+	
+	boot_param->efi_memmap_size = p2 - dest;
+}
+
+void 
+flush_icache_range(char *start, unsigned long len)
+{
+	unsigned long i;
+	for (i = 0;i < len; i += 32)
+	  asm volatile("fc.i %0"::"r"(start + i):"memory");
+	asm volatile (";;sync.i;;":::"memory");
+	asm volatile ("srlz.i":::"memory");
+}
+
+extern char __dummy_efi_function[], __dummy_efi_function_end[];
+
+
+void 
+ia64_env_setup(struct ia64_boot_param *boot_param,
+	struct kexec_boot_params *params)
+{
+	unsigned long len;
+        efi_system_table_t *systab;
+        efi_runtime_services_t *runtime;
+	unsigned long *set_virtual_address_map;
+	char *command_line = (char *)params->command_line;
+	uint64_t command_line_len = params->command_line_len;
+
+	// patch efi_runtime->set_virtual_address_map to a
+	// dummy function
+	len = __dummy_efi_function_end - __dummy_efi_function;
+	memcpy(command_line + command_line_len, 
+		__dummy_efi_function, len);
+	systab = (efi_system_table_t *)boot_param->efi_systab;
+	runtime = (efi_runtime_services_t *)PA(systab->runtime);
+	set_virtual_address_map =
+		(unsigned long *)PA(runtime->set_virtual_address_map);
+	*(set_virtual_address_map) =
+		(unsigned long)(command_line + command_line_len);
+	flush_icache_range(command_line + command_line_len, len);
+
+	patch_efi_memmap(params, boot_param);
+
+	boot_param->efi_memmap = params->efi_memmap_base;
+
+	boot_param->command_line = params->command_line;
+	boot_param->console_info.orig_x = 0;
+	boot_param->console_info.orig_y = 0;
+	boot_param->initrd_start = params->ramdisk_base;
+	boot_param->initrd_size =  params->ramdisk_size;
 }
 
 /* This function can be used to execute after the SHA256 verification. */
diff -Nraup a/purgatory/arch/ia64/purgatory-ia64.h b/purgatory/arch/ia64/purgatory-ia64.h
--- a/purgatory/arch/ia64/purgatory-ia64.h	2004-12-21 06:44:55.000000000 +0800
+++ b/purgatory/arch/ia64/purgatory-ia64.h	2006-06-03 11:56:58.000000000 +0800
@@ -1,6 +1,5 @@
 #ifndef PURGATORY_IA64_H
 #define PURGATORY_IA64_H
 
-/* nothing yet */
-
+void reset_vga(void);
 #endif /* PURGATORY_IA64_H */
diff -Nraup a/purgatory/arch/ia64/vga.c b/purgatory/arch/ia64/vga.c
--- a/purgatory/arch/ia64/vga.c	1970-01-01 08:00:00.000000000 +0800
+++ b/purgatory/arch/ia64/vga.c	2006-06-03 11:56:58.000000000 +0800
@@ -0,0 +1,143 @@
+#include "io.h"
+void reset_vga(void)
+{
+	/* Hello */
+	inb(0x3da);
+	outb(0, 0x3c0);
+
+	/* Sequencer registers */
+	outw(0x0300, 0x3c4);
+	outw(0x0001, 0x3c4);
+	outw(0x0302, 0x3c4);
+	outw(0x0003, 0x3c4);
+	outw(0x0204, 0x3c4);
+
+	/* Ensure CRTC regs 0-7 are unlocked by clearing bit 7 of CRTC[17] */
+	outw(0x0e11, 0x3d4);
+	/* CRTC registers */
+	outw(0x5f00, 0x3d4);
+	outw(0x4f01, 0x3d4);
+	outw(0x5002, 0x3d4);
+	outw(0x8203, 0x3d4);
+	outw(0x5504, 0x3d4);
+	outw(0x8105, 0x3d4);
+	outw(0xbf06, 0x3d4);
+	outw(0x1f07, 0x3d4);
+	outw(0x0008, 0x3d4);
+	outw(0x4f09, 0x3d4);
+	outw(0x200a, 0x3d4);
+	outw(0x0e0b, 0x3d4);
+	outw(0x000c, 0x3d4);
+	outw(0x000d, 0x3d4);
+	outw(0x010e, 0x3d4);
+	outw(0xe00f, 0x3d4);
+	outw(0x9c10, 0x3d4);
+	outw(0x8e11, 0x3d4);
+	outw(0x8f12, 0x3d4);
+	outw(0x2813, 0x3d4);
+	outw(0x1f14, 0x3d4);
+	outw(0x9615, 0x3d4);
+	outw(0xb916, 0x3d4);
+	outw(0xa317, 0x3d4);
+	outw(0xff18, 0x3d4);
+
+	/* Graphic registers */
+	outw(0x0000, 0x3ce);
+	outw(0x0001, 0x3ce);
+	outw(0x0002, 0x3ce);
+	outw(0x0003, 0x3ce);
+	outw(0x0004, 0x3ce);
+	outw(0x1005, 0x3ce);
+	outw(0x0e06, 0x3ce);
+	outw(0x0007, 0x3ce);
+	outw(0xff08, 0x3ce);
+
+	/* Attribute registers */
+	inb(0x3da);
+	outb(0x00, 0x3c0);
+	outb(0x00, 0x3c0);
+
+	inb(0x3da);
+	outb(0x01, 0x3c0);
+	outb(0x01, 0x3c0);
+
+	inb(0x3da);
+	outb(0x02, 0x3c0);
+	outb(0x02, 0x3c0);
+
+	inb(0x3da);
+	outb(0x03, 0x3c0);
+	outb(0x03, 0x3c0);
+
+	inb(0x3da);
+	outb(0x04, 0x3c0);
+	outb(0x04, 0x3c0);
+
+	inb(0x3da);
+	outb(0x05, 0x3c0);
+	outb(0x05, 0x3c0);
+
+	inb(0x3da);
+	outb(0x06, 0x3c0);
+	outb(0x14, 0x3c0);
+
+	inb(0x3da);
+	outb(0x07, 0x3c0);
+	outb(0x07, 0x3c0);
+
+	inb(0x3da);
+	outb(0x08, 0x3c0);
+	outb(0x38, 0x3c0);
+
+	inb(0x3da);
+	outb(0x09, 0x3c0);
+	outb(0x39, 0x3c0);
+
+	inb(0x3da);
+	outb(0x0a, 0x3c0);
+	outb(0x3a, 0x3c0);
+
+	inb(0x3da);
+	outb(0x0b, 0x3c0);
+	outb(0x3b, 0x3c0);
+
+	inb(0x3da);
+	outb(0x0c, 0x3c0);
+	outb(0x3c, 0x3c0);
+
+	inb(0x3da);
+	outb(0x0d, 0x3c0);
+	outb(0x3d, 0x3c0);
+
+	inb(0x3da);
+	outb(0x0e, 0x3c0);
+	outb(0x3e, 0x3c0);
+
+	inb(0x3da);
+	outb(0x0f, 0x3c0);
+	outb(0x3f, 0x3c0);
+
+	inb(0x3da);
+	outb(0x10, 0x3c0);
+	outb(0x0c, 0x3c0);
+
+	inb(0x3da);
+	outb(0x11, 0x3c0);
+	outb(0x00, 0x3c0);
+
+	inb(0x3da);
+	outb(0x12, 0x3c0);
+	outb(0x0f, 0x3c0);
+
+	inb(0x3da);
+	outb(0x13, 0x3c0);
+	outb(0x08, 0x3c0);
+
+	inb(0x3da);
+	outb(0x14, 0x3c0);
+	outb(0x00, 0x3c0);
+
+	/* Goodbye */
+	inb(0x3da);
+	outb(0x20, 0x3c0);
+}

--=-OAwZ112ebexHlrRcE/CD--
