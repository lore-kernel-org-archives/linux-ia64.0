From: Zou Nan hai <nanhai.zou@intel.com>
Date: Tue, 29 Aug 2006 07:46:35 +0000
Subject: IA64 kexec/kdump 2.6.18-rc5 patch
Message-Id: <1156837594.2598.15.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,
	Below is the IA64 kexec/kdump patch against 2.6.18-rc5.

Fixes and enhancements in this patch include:

1. Fix I/D cache coherence problem.
   Kdump sometimes hit an I/D cache coherence issue on platform with separa=
te I/D cache.
   Although there is fc.i instruction in relocate_kernel.S.=20
   purgatory code and the second kernel code is copy into reserved region a=
t kexec_load=20
   when running "kexec -p".
   There need and an icache_flush when segments is copied into its destinat=
ion.
2. Change elf_prstatus to an per_cpu value to save stack size at crash path=
 according=20
   to Bob Montgomery's suggestion.
3. put AP to a loop of hint.pause instead of call pal_halt_light.


Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

diff -Nraup linux-2.6.18-rc5/arch/ia64/hp/common/sba_iommu.c linux-2.6.18-r=
c5-kdump/arch/ia64/hp/common/sba_iommu.c
--- linux-2.6.18-rc5/arch/ia64/hp/common/sba_iommu.c	2006-08-30 11:36:53.00=
0000000 +0800
+++ linux-2.6.18-rc5-kdump/arch/ia64/hp/common/sba_iommu.c	2006-08-30 10:34=
:25.000000000 +0800
@@ -1623,6 +1623,28 @@ ioc_iova_init(struct ioc *ioc)
 	READ_REG(ioc->ioc_hpa + IOC_IBASE);
 }
=20
+#ifdef CONFIG_KEXEC
+void
+ioc_iova_disable(void)
+{
+	struct ioc *ioc;
+
+	ioc =3D ioc_list;
+
+	while (ioc !=3D NULL) {
+		/* Disable IOVA translation */
+		WRITE_REG(ioc->ibase & 0xfffffffffffffffe, ioc->ioc_hpa + IOC_IBASE);
+		READ_REG(ioc->ioc_hpa + IOC_IBASE);
+
+		/* Clear I/O TLB of any possible entries */
+		WRITE_REG(ioc->ibase | (get_iovp_order(ioc->iov_size) + iovp_shift), ioc=
->ioc_hpa + IOC_PCOM);
+		READ_REG(ioc->ioc_hpa + IOC_PCOM);
+
+		ioc =3D ioc->next;
+	}
+}
+#endif
+
 static void __init
 ioc_resource_init(struct ioc *ioc)
 {
diff -Nraup linux-2.6.18-rc5/arch/ia64/Kconfig linux-2.6.18-rc5-kdump/arch/=
ia64/Kconfig
--- linux-2.6.18-rc5/arch/ia64/Kconfig	2006-08-30 11:36:53.000000000 +0800
+++ linux-2.6.18-rc5-kdump/arch/ia64/Kconfig	2006-08-30 10:34:25.000000000 =
+0800
@@ -427,6 +427,29 @@ config SGI_SN
=20
 source "drivers/sn/Kconfig"
=20
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
=20
 source "fs/Kconfig.binfmt"
diff -Nraup linux-2.6.18-rc5/arch/ia64/kernel/crash.c linux-2.6.18-rc5-kdum=
p/arch/ia64/kernel/crash.c
--- linux-2.6.18-rc5/arch/ia64/kernel/crash.c	1970-01-01 08:00:00.000000000=
 +0800
+++ linux-2.6.18-rc5-kdump/arch/ia64/kernel/crash.c	2006-08-30 10:42:47.000=
000000 +0800
@@ -0,0 +1,123 @@
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
+                               size_t csize, unsigned long offset, int use=
rbuf)
+{
+        void  *vaddr;
+
+        if (!csize)
+                return 0;
+        vaddr =3D __va(pfn<<PAGE_SHIFT);
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
+	kdump_disable_iosapic();
+#ifdef CONFIG_IA64_HP_ZX1
+	ioc_iova_disable();
+#endif
+}
+
+static inline Elf64_Word
+*append_elf_note(Elf64_Word *buf, char *name, unsigned type, void *data,
+		size_t data_len)
+{
+	struct elf_note *note =3D (struct elf_note *)buf;
+	note->n_namesz =3D strlen(name) + 1;
+	note->n_descsz =3D data_len;
+	note->n_type   =3D type;
+	buf +=3D (sizeof(*note) + 3)/4;
+	memcpy(buf, name, note->n_namesz);
+	buf +=3D (note->n_namesz + 3)/4;
+	memcpy(buf, data, data_len);
+	buf +=3D (data_len + 3)/4;
+	return buf;
+}
+
+static void
+final_note(void *buf)
+{
+	memset(buf, 0, sizeof(struct elf_note));
+}
+
+extern void ia64_dump_cpu_regs(void *);
+
+static DEFINE_PER_CPU(struct elf_prstatus, elf_prstatus);
+
+void
+crash_save_this_cpu()
+{
+	void *buf;
+	unsigned long cfm, sof, sol;
+
+	int cpu =3D smp_processor_id();
+	struct elf_prstatus *prstatus =3D &per_cpu(elf_prstatus, cpu);
+
+	elf_greg_t *dst =3D (elf_greg_t *)&(prstatus->pr_reg);
+	memset(prstatus, 0, sizeof(*prstatus));
+	prstatus->pr_pid =3D current->pid;
+
+	ia64_dump_cpu_regs(dst);
+        cfm =3D dst[43];
+        sol =3D (cfm >> 7) & 0x7f;
+        sof =3D cfm & 0x7f;
+        dst[46] =3D (unsigned long)ia64_rse_skip_regs((unsigned long *)dst=
[46],
+                        sof - sol);
+
+        buf =3D (u64 *) per_cpu_ptr(crash_notes, cpu);
+	if (!buf)
+		return;
+	buf =3D append_elf_note(buf, "CORE", NT_PRSTATUS, prstatus,
+		sizeof(*prstatus));
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
+	if (in_interrupt())
+		ia64_eoi();
+	device_shootdown();
+#ifdef CONFIG_SMP
+	kdump_smp_send_stop();
+#endif
+	udelay(1000000);
+}
diff -Nraup linux-2.6.18-rc5/arch/ia64/kernel/efi.c linux-2.6.18-rc5-kdump/=
arch/ia64/kernel/efi.c
--- linux-2.6.18-rc5/arch/ia64/kernel/efi.c	2006-08-30 11:36:53.000000000 +=
0800
+++ linux-2.6.18-rc5-kdump/arch/ia64/kernel/efi.c	2006-08-30 10:34:25.00000=
0000 +0800
@@ -26,6 +26,7 @@
 #include <linux/types.h>
 #include <linux/time.h>
 #include <linux/efi.h>
+#include <linux/kexec.h>
=20
 #include <asm/io.h>
 #include <asm/kregs.h>
@@ -41,7 +42,7 @@ extern efi_status_t efi_call_phys (void=20
 struct efi efi;
 EXPORT_SYMBOL(efi);
 static efi_runtime_services_t *runtime;
-static unsigned long mem_limit =3D ~0UL, max_addr =3D ~0UL;
+static unsigned long mem_limit =3D ~0UL, max_addr =3D ~0UL, min_addr =3D 0=
UL;
=20
 #define efi_call_virt(f, args...)	(*(f))(args)
=20
@@ -421,6 +422,8 @@ efi_init (void)
 			mem_limit =3D memparse(cp + 4, &cp);
 		} else if (memcmp(cp, "max_addr=3D", 9) =3D 0) {
 			max_addr =3D GRANULEROUNDDOWN(memparse(cp + 9, &cp));
+		} else if (memcmp(cp, "min_addr=3D", 9) =3D 0) {
+			min_addr =3D GRANULEROUNDDOWN(memparse(cp + 9, &cp));
 		} else {
 			while (*cp !=3D ' ' && *cp)
 				++cp;
@@ -428,6 +431,8 @@ efi_init (void)
 				++cp;
 		}
 	}
+	if (min_addr !=3D 0UL)
+		printk(KERN_INFO "Ignoring memory below %luMB\n", min_addr >> 20);
 	if (max_addr !=3D ~0UL)
 		printk(KERN_INFO "Ignoring memory above %luMB\n", max_addr >> 20);
=20
@@ -894,7 +899,8 @@ find_memmap_space (void)
 		as =3D max(contig_low, md->phys_addr);
 		ae =3D min(contig_high, efi_md_end(md));
=20
-		/* keep within max_addr=3D command line arg */
+		/* keep within max_addr=3D and min_addr=3D command line arg */
+		as =3D max(as, min_addr);
 		ae =3D min(ae, max_addr);
 		if (ae <=3D as)
 			continue;
@@ -1004,7 +1010,8 @@ efi_memmap_init(unsigned long *s, unsign
 		} else
 			ae =3D efi_md_end(md);
=20
-		/* keep within max_addr=3D command line arg */
+		/* keep within max_addr=3D and min_addr=3D command line arg */
+		as =3D max(as, min_addr);
 		ae =3D min(ae, max_addr);
 		if (ae <=3D as)
 			continue;
@@ -1116,6 +1123,12 @@ efi_initialize_iomem_resources(struct re
 			 */
 			insert_resource(res, code_resource);
 			insert_resource(res, data_resource);
+#ifdef CONFIG_KEXEC
+                        insert_resource(res, &efi_memmap_res);
+                        insert_resource(res, &boot_param_res);
+			if (crashk_res.end > crashk_res.start)
+				insert_resource(res, &crashk_res);
+#endif
 		}
 	}
 }
diff -Nraup linux-2.6.18-rc5/arch/ia64/kernel/entry.S linux-2.6.18-rc5-kdum=
p/arch/ia64/kernel/entry.S
--- linux-2.6.18-rc5/arch/ia64/kernel/entry.S	2006-08-30 11:36:53.000000000=
 +0800
+++ linux-2.6.18-rc5-kdump/arch/ia64/kernel/entry.S	2006-08-30 10:34:25.000=
000000 +0800
@@ -1575,7 +1575,7 @@ sys_call_table:
 	data8 sys_mq_timedreceive		// 1265
 	data8 sys_mq_notify
 	data8 sys_mq_getsetattr
-	data8 sys_ni_syscall			// reserved for kexec_load
+	data8 sys_kexec_load
 	data8 sys_ni_syscall			// reserved for vserver
 	data8 sys_waitid			// 1270
 	data8 sys_add_key
diff -Nraup linux-2.6.18-rc5/arch/ia64/kernel/iosapic.c linux-2.6.18-rc5-kd=
ump/arch/ia64/kernel/iosapic.c
--- linux-2.6.18-rc5/arch/ia64/kernel/iosapic.c	2006-08-30 11:36:53.0000000=
00 +0800
+++ linux-2.6.18-rc5-kdump/arch/ia64/kernel/iosapic.c	2006-08-30 10:34:25.0=
00000000 +0800
@@ -288,6 +288,25 @@ nop (unsigned int irq)
 	/* do nothing... */
 }
=20
+#ifdef CONFIG_CRASH_DUMP
+void
+kdump_disable_iosapic(void)
+{
+	u32 low32;
+	struct iosapic_intr_info *info;
+	struct iosapic_rte_info *rte;
+	for (info =3D iosapic_intr_info; info <
+			iosapic_intr_info + IA64_NUM_VECTORS; ++info) {
+		low32 =3D info->low32 |=3D IOSAPIC_MASK;
+		list_for_each_entry(rte, &info->rtes,
+				rte_list) {
+			iosapic_write(rte->addr,
+					IOSAPIC_RTE_LOW(rte->rte_index), low32);
+		}
+	}
+}
+#endif
+
 static void
 mask_irq (unsigned int irq)
 {
diff -Nraup linux-2.6.18-rc5/arch/ia64/kernel/machine_kexec.c linux-2.6.18-=
rc5-kdump/arch/ia64/kernel/machine_kexec.c
--- linux-2.6.18-rc5/arch/ia64/kernel/machine_kexec.c	1970-01-01 08:00:00.0=
00000000 +0800
+++ linux-2.6.18-rc5-kdump/arch/ia64/kernel/machine_kexec.c	2006-08-30 10:3=
4:25.000000000 +0800
@@ -0,0 +1,139 @@
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
+static struct kimage *ia64_kimage;
+struct resource efi_memmap_res =3D {
+        .name  =3D "EFI Memory Map",
+        .start =3D 0,
+        .end   =3D 0,
+        .flags =3D IORESOURCE_BUSY | IORESOURCE_MEM
+};
+
+struct resource boot_param_res =3D {
+        .name  =3D "Boot parameter",
+        .start =3D 0,
+        .end   =3D 0,
+        .flags =3D IORESOURCE_BUSY | IORESOURCE_MEM
+};
+
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
+	func =3D (unsigned long *)&relocate_new_kernel;
+	/* Pre-load control code buffer to minimize work in kexec path */
+	control_code_buffer =3D page_address(image->control_code_page);
+	memcpy((void *)control_code_buffer, (const void *)func[0],
+			relocate_new_kernel_size);
+	flush_icache_range((unsigned long)control_code_buffer,
+			(unsigned long)control_code_buffer + relocate_new_kernel_size);
+	ia64_kimage =3D image;
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
+#ifdef CONFIG_HOTPLUG_CPU
+	{
+		int cpu;
+
+		for_each_online_cpu(cpu) {
+			if (cpu !=3D smp_processor_id())
+				cpu_down(cpu);
+		}
+	}
+#elif defined(CONFIG_SMP)
+	smp_call_function(kexec_stop_this_cpu, (void *)ia64_kimage->start, 0, 0);
+#endif
+#ifdef CONFIG_PCI
+	{
+		struct pci_dev *dev =3D NULL;
+		irq_desc_t *idesc;
+		/* Disable all PCI devices */
+		while ((dev =3D pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev)) !=3D NULL) {
+			if (!(dev->is_enabled))
+				continue;
+			idesc =3D irq_desc + dev->irq;
+			if (!idesc||!idesc->chip)
+				continue;
+			disable_irq_nosync(dev->irq);
+			idesc->chip->end(dev->irq);
+			idesc->action =3D NULL;
+			pci_disable_device(dev);
+		}
+	}
+#endif
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
+static void ia64_machine_kexec(struct unw_frame_info *info, void *arg)=20
+{
+	struct kimage *image =3D arg;
+	relocate_new_kernel_t rnk;
+	void *pal_addr =3D efi_get_pal_addr();
+	unsigned long code_addr =3D (unsigned long)page_address(image->control_co=
de_page);
+	if (image->type =3D KEXEC_TYPE_CRASH) {
+		crash_save_this_cpu();
+		current->thread.ksp =3D (__u64)info->sw - 16;
+	}
+
+	/* Interrupts aren't acceptable while we reboot */
+	ia64_set_itv(1<<16);
+	local_irq_disable();
+	rnk =3D (relocate_new_kernel_t)&code_addr;
+	(*rnk)(image->head, image->start, ia64_boot_param,
+		     GRANULEROUNDDOWN((unsigned long) pal_addr));
+	BUG();
+}=20
+
+void machine_kexec(struct kimage *image)
+{
+	unw_init_running(ia64_machine_kexec, image);
+	for(;;);
+}
diff -Nraup linux-2.6.18-rc5/arch/ia64/kernel/Makefile linux-2.6.18-rc5-kdu=
mp/arch/ia64/kernel/Makefile
--- linux-2.6.18-rc5/arch/ia64/kernel/Makefile	2006-08-30 11:36:53.00000000=
0 +0800
+++ linux-2.6.18-rc5-kdump/arch/ia64/kernel/Makefile	2006-08-30 10:34:25.00=
0000000 +0800
@@ -28,6 +28,7 @@ obj-$(CONFIG_IA64_CYCLONE)	+=3D cyclone.o
 obj-$(CONFIG_CPU_FREQ)		+=3D cpufreq/
 obj-$(CONFIG_IA64_MCA_RECOVERY)	+=3D mca_recovery.o
 obj-$(CONFIG_KPROBES)		+=3D kprobes.o jprobes.o
+obj-$(CONFIG_KEXEC)		+=3D machine_kexec.o relocate_kernel.o crash.o
 obj-$(CONFIG_IA64_UNCACHED_ALLOCATOR)	+=3D uncached.o
 obj-$(CONFIG_AUDIT)		+=3D audit.o
 mca_recovery-y			+=3D mca_drv.o mca_drv_asm.o
diff -Nraup linux-2.6.18-rc5/arch/ia64/kernel/relocate_kernel.S linux-2.6.1=
8-rc5-kdump/arch/ia64/kernel/relocate_kernel.S
--- linux-2.6.18-rc5/arch/ia64/kernel/relocate_kernel.S	1970-01-01 08:00:00=
.000000000 +0800
+++ linux-2.6.18-rc5-kdump/arch/ia64/kernel/relocate_kernel.S	2006-08-30 10=
:34:25.000000000 +0800
@@ -0,0 +1,490 @@
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
+	alloc r31=3Dar.pfs,4,0,0,0
+        .body
+.reloc_entry:
+{
+	rsm psr.i| psr.ic
+	mov r2=3Dip
+}
+	;;
+{
+        flushrs                         // must be first insn in group
+        srlz.i
+}
+	;;
+	dep r2=3D0,r2,61,3		//to physical address
+	;;
+	//first switch to physical mode
+	add r3=1F-.reloc_entry, r2
+	movl r16 =3D IA64_PSR_AC|IA64_PSR_BN|IA64_PSR_IC
+	mov ar.rsc=3D0	          	// put RSE in enforced lazy mode
+	;;
+	add sp=3D(memory_stack_end - 16 - .reloc_entry),r2
+	add r8=3D(register_stack - .reloc_entry),r2
+	;;
+	mov r18=3Dar.rnat
+	mov ar.bspstore=3Dr8
+	;;
+        mov cr.ipsr=3Dr16
+        mov cr.iip=3Dr3
+        mov cr.ifs=3Dr0
+	srlz.i
+	;;
+	mov ar.rnat=3Dr18
+	rfi
+	;;
+1:
+	//physical mode code begin
+	mov b6=3Din1
+	dep r28=3D0,in2,61,3	//to physical address
+
+	// purge all TC entries
+#define O(member)       IA64_CPUINFO_##member##_OFFSET
+        GET_THIS_PADDR(r2, cpu_info)    // load phys addr of cpu_info into=
 r2
+        ;;
+        addl r17=3DO(PTCE_STRIDE),r2
+        addl r2=3DO(PTCE_BASE),r2
+        ;;
+        ld8 r18=3D[r2],(O(PTCE_COUNT)-O(PTCE_BASE));;    	// r18=3Dptce_ba=
se
+        ld4 r19=3D[r2],4                                  // r19=3Dptce_co=
unt[0]
+        ld4 r21=3D[r17],4                                 // r21=3Dptce_st=
ride[0]
+        ;;
+        ld4 r20=3D[r2]                                    // r20=3Dptce_co=
unt[1]
+        ld4 r22=3D[r17]                                   // r22=3Dptce_st=
ride[1]
+        mov r24=3Dr0
+        ;;
+        adds r20=3D-1,r20
+        ;;
+#undef O
+2:
+        cmp.ltu p6,p7=3Dr24,r19
+(p7)    br.cond.dpnt.few 4f
+        mov ar.lc=3Dr20
+3:
+        ptc.e r18
+        ;;
+        add r18=3Dr22,r18
+        br.cloop.sptk.few 3b
+        ;;
+        add r18=3Dr21,r18
+        add r24=3D1,r24
+        ;;
+        br.sptk.few 2b
+4:
+        srlz.i
+        ;;
+	//purge TR entry for kernel text and data
+        movl r16=3DKERNEL_START
+        mov r18=3DKERNEL_TR_PAGE_SHIFT<<2
+        ;;
+        ptr.i r16, r18
+        ptr.d r16, r18
+        ;;
+        srlz.i
+        ;;
+
+	// purge TR entry for percpu data
+        movl r16=3DPERCPU_ADDR
+        mov r18=3DPERCPU_PAGE_SHIFT<<2
+        ;;
+        ptr.d r16,r18
+        ;;
+        srlz.d
+	;;
+
+        // purge TR entry for pal code
+        mov r16=3Din3
+        mov r18=3DIA64_GRANULE_SHIFT<<2
+        ;;
+        ptr.i r16,r18
+        ;;
+        srlz.i
+	;;
+
+        // purge TR entry for stack
+        mov r16=3DIA64_KR(CURRENT_STACK)
+        ;;
+        shl r16=3Dr16,IA64_GRANULE_SHIFT
+        movl r19=3DPAGE_OFFSET
+        ;;
+        add r16=3Dr19,r16
+        mov r18=3DIA64_GRANULE_SHIFT<<2
+        ;;
+        ptr.d r16,r18
+        ;;
+        srlz.i
+	;;
+
+	//copy segments
+	movl r16=3DPAGE_MASK
+        mov  r30=3Din0                    // in0 is page_list
+        br.sptk.few .dest_page
+	;;
+.loop:
+	ld8  r30=3D[in0], 8;;
+.dest_page:
+	tbit.z p0, p6=3Dr30, 0;;    	// 0x1 dest page
+(p6)	and r17=3Dr30, r16
+(p6)	br.cond.sptk.few .loop;;
+
+	tbit.z p0, p6=3Dr30, 1;;		// 0x2 indirect page
+(p6)	and in0=3Dr30, r16
+(p6)	br.cond.sptk.few .loop;;
+
+	tbit.z p0, p6=3Dr30, 2;;		// 0x4 end flag
+(p6)	br.cond.sptk.few .end_loop;;
+
+	tbit.z p6, p0=3Dr30, 3;;		// 0x8 source page
+(p6)	br.cond.sptk.few .loop
+
+	and r18=3Dr30, r16
+
+	// simple copy page, may optimize later
+	movl r14=3DPAGE_SIZE/8 - 1;;
+	mov ar.lc=3Dr14;;
+1:
+	ld8 r14=3D[r18], 8;;
+	st8 [r17]=3Dr14, 8;;
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
+	br.call.sptk.many b0=B6;;
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
+	alloc r31=3Dar.pfs,3,0,0,0
+	.body
+.rendez_entry:
+	rsm	psr.i | psr.ic
+	mov r25=3Dip
+	;;
+	{
+		flushrs
+		srlz.i
+	}
+	;;
+       /* See where I am running, and compute gp */
+	{
+		mov     ar.rsc =3D 0      /* Put RSE in enforce lacy, LE mode */
+		mov     gp =3D ip         /* gp =3D relocate_new_kernel */
+	}
+
+	movl r8=3D0x00000100000000
+	;;
+	mov cr.iva=3Dr8
+	/* Transition from virtual to physical mode */
+	srlz.i
+	;;
+	add	r17_-.rendez_entry, r25
+	movl	r16=3D(IA64_PSR_AC | IA64_PSR_BN | IA64_PSR_IC | IA64_PSR_MFL)
+	;;
+	tpa	r17=3Dr17
+	mov	cr.ipsr=3Dr16
+	;;
+	mov	cr.iip=3Dr17
+	mov	cr.ifs=3Dr0
+	;;
+	rfi
+	;;
+5:
+	mov     b6=3Din0			/* _start addr */
+	mov	r8=3Din1			/* ap_wakeup_vector */
+	mov	r26=3Din2			/* PAL addr */
+	;;
+	/* Purge kernel TRs */
+	movl	r16=3DKERNEL_START
+	mov	r18=3DKERNEL_TR_PAGE_SHIFT<<2
+	;;
+	ptr.i	r16,r18
+	ptr.d	r16,r18
+	;;
+	srlz.i
+	;;
+	srlz.d
+	;;
+	/* Purge percpu TR */
+	movl	r16=3DPERCPU_ADDR
+	mov	r18=3DPERCPU_PAGE_SHIFT<<2
+	;;
+	ptr.d	r16,r18
+	;;
+	srlz.d
+	;;
+	/* Purge PAL TR */
+	mov	r18=3DIA64_GRANULE_SHIFT<<2
+	;;
+	ptr.i	r26,r18
+	;;
+	srlz.i
+	;;
+	/* Purge stack TR */
+	mov	r16=3DIA64_KR(CURRENT_STACK)
+	;;
+	shl	r16=3Dr16,IA64_GRANULE_SHIFT
+	movl	r19=3DPAGE_OFFSET
+	;;
+	add	r16=3Dr19,r16
+	mov	r18=3DIA64_GRANULE_SHIFT<<2
+	;;
+	ptr.d	r16,r18
+	;;
+	srlz.i
+	;;
+
+	/* Ensure we can read and clear external interrupts */
+	mov	cr.tpr=3Dr0
+	srlz.d
+
+	shr.u	r9=3Dr8,6			/* which irr */
+	;;
+	and	r8c,r8		/* bit offset into irr */
+	;;
+	mov	r10=3D1;;
+	;;
+	shl	r10=3Dr10,r8		/* bit mask off irr we want */
+	cmp.eq	p6,p0=3D0,r9
+	;;
+(p6)	br.cond.sptk.few        check_irr0
+	cmp.eq	p7,p0=3D1,r9
+	;;
+(p7)	br.cond.sptk.few        check_irr1
+	cmp.eq	p8,p0=3D2,r9
+	;;
+(p8)	br.cond.sptk.few        check_irr2
+	cmp.eq	p9,p0=3D3,r9
+	;;
+(p9)	br.cond.sptk.few        check_irr3
+
+check_irr0:
+	mov	r8=3Dcr.irr0
+	;;
+	and	r8=3Dr8,r10
+	;;
+	cmp.eq	p6,p0=3D0,r8
+(p6)	br.cond.sptk.few	check_irr0
+	br.few	call_start
+
+check_irr1:
+	mov	r8=3Dcr.irr1
+	;;
+	and	r8=3Dr8,r10
+	;;
+	cmp.eq	p6,p0=3D0,r8
+(p6)	br.cond.sptk.few	check_irr1
+	br.few	call_start
+
+check_irr2:
+	mov	r8=3Dcr.irr2
+	;;
+	and	r8=3Dr8,r10
+	;;
+	cmp.eq	p6,p0=3D0,r8
+(p6)	br.cond.sptk.few	check_irr2
+	br.few	call_start
+
+check_irr3:
+	mov	r8=3Dcr.irr3
+	;;
+	and	r8=3Dr8,r10
+	;;
+	cmp.eq	p6,p0=3D0,r8
+(p6)	br.cond.sptk.few	check_irr3
+	br.few	call_start
+
+call_start:
+	mov	cr.eoi=3Dr0
+	;;
+	srlz.d
+	;;
+	mov	r8=3Dcr.ivr
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
+GLOBAL_ENTRY(ia64_dump_cpu_regs)
+        .prologue
+        alloc loc0=3Dar.pfs,1,2,0,0
+        .body
+        mov     ar.rsc=3D0                // put RSE in enforced lazy mode
+        add     loc1=3D4*8, in0           // save r4 and r5 first
+        ;;
+{
+        flushrs                         // flush dirty regs to backing sto=
re
+        srlz.i
+}
+        st8 [loc1]=3Dr4, 8
+        ;;
+        st8 [loc1]=3Dr5, 8
+        ;;
+        add loc12*8, in0
+        mov r4=3Dar.rnat
+        ;;
+        st8 [in0]=3Dr0, 8			// r0
+        st8 [loc1]=3Dr4, 8		// rnat
+        mov r5=3Dpr
+        ;;
+        st8 [in0]=3Dr1, 8			// r1
+        st8 [loc1]=3Dr5, 8		// pr
+        mov r4=B0
+        ;;
+        st8 [in0]=3Dr2, 8			// r2
+        st8 [loc1]=3Dr4, 8		// b0
+        mov r5=B1;
+        ;;
+        st8 [in0]=3Dr3, 24		// r3
+        st8 [loc1]=3Dr5, 8		// b1
+        mov r4=B2
+        ;;
+        st8 [in0]=3Dr6, 8			// r6
+        st8 [loc1]=3Dr4, 8		// b2
+	mov r5=B3
+        ;;
+        st8 [in0]=3Dr7, 8			// r7
+        st8 [loc1]=3Dr5, 8		// b3
+        mov r4=B4
+        ;;
+        st8 [in0]=3Dr8, 8			// r8
+        st8 [loc1]=3Dr4, 8		// b4
+        mov r5=B5
+        ;;
+        st8 [in0]=3Dr9, 8			// r9
+        st8 [loc1]=3Dr5, 8		// b5
+        mov r4=B6
+        ;;
+        st8 [in0]=3Dr10, 8		// r10
+        st8 [loc1]=3Dr5, 8		// b6
+        mov r5=B7
+        ;;
+        st8 [in0]=3Dr11, 8		// r11
+        st8 [loc1]=3Dr5, 8		// b7
+        mov r4=B0
+        ;;
+        st8 [in0]=3Dr12, 8		// r12
+        st8 [loc1]=3Dr4, 8		// ip
+        mov r5=3Dloc0
+	;;
+        st8 [in0]=3Dr13, 8		// r13
+        extr.u r5=3Dr5, 0, 38		// ar.pfs.pfm
+	mov r4=3Dr0			// user mask
+        ;;
+        st8 [in0]=3Dr14, 8		// r14
+        st8 [loc1]=3Dr5, 8		// cfm
+        ;;
+        st8 [in0]=3Dr15, 8		// r15
+        st8 [loc1]=3Dr4, 8        	// user mask
+	mov r5=3Dar.rsc
+        ;;
+        st8 [in0]=3Dr16, 8		// r16
+        st8 [loc1]=3Dr5, 8        	// ar.rsc
+        mov r4=3Dar.bsp
+        ;;
+        st8 [in0]=3Dr17, 8		// r17
+        st8 [loc1]=3Dr4, 8        	// ar.bsp
+        mov r5=3Dar.bspstore
+        ;;
+        st8 [in0]=3Dr18, 8		// r18
+        st8 [loc1]=3Dr5, 8        	// ar.bspstore
+        mov r4=3Dar.rnat
+        ;;
+        st8 [in0]=3Dr19, 8		// r19
+        st8 [loc1]=3Dr4, 8        	// ar.rnat
+        mov r5=3Dar.ccv
+        ;;
+        st8 [in0]=3Dr20, 8		// r20
+	st8 [loc1]=3Dr5, 8        	// ar.ccv
+        mov r4=3Dar.unat
+        ;;
+        st8 [in0]=3Dr21, 8		// r21
+        st8 [loc1]=3Dr4, 8        	// ar.unat
+        mov r5 =3D ar.fpsr
+        ;;
+        st8 [in0]=3Dr22, 8		// r22
+        st8 [loc1]=3Dr5, 8        	// ar.fpsr
+        mov r4 =3D ar.unat
+        ;;
+        st8 [in0]=3Dr23, 8		// r23
+        st8 [loc1]=3Dr4, 8        	// unat
+        mov r5 =3D ar.fpsr
+        ;;
+        st8 [in0]=3Dr24, 8		// r24
+        st8 [loc1]=3Dr5, 8        	// fpsr
+        mov r4 =3D ar.pfs
+        ;;
+        st8 [in0]=3Dr25, 8		// r25
+        st8 [loc1]=3Dr4, 8        	// ar.pfs
+        mov r5 =3D ar.lc
+        ;;
+        st8 [in0]=3Dr26, 8		// r26
+        st8 [loc1]=3Dr5, 8        	// ar.lc
+        mov r4 =3D ar.ec
+        ;;
+        st8 [in0]=3Dr27, 8		// r27
+        st8 [loc1]=3Dr4, 8        	// ar.ec
+        mov r5 =3D ar.csd
+        ;;
+        st8 [in0]=3Dr28, 8		// r28
+        st8 [loc1]=3Dr5, 8        	// ar.csd
+        mov r4 =3D ar.ssd
+        ;;
+        st8 [in0]=3Dr29, 8		// r29
+        st8 [loc1]=3Dr4, 8        	// ar.ssd
+        ;;
+        st8 [in0]=3Dr30, 8		// r30
+        ;;
+	st8 [in0]=3Dr31, 8		// r31
+        mov ar.pfs=3Dloc0
+        ;;
+        br.ret.sptk.many rp
+END(ia64_dump_cpu_regs)
+
+
diff -Nraup linux-2.6.18-rc5/arch/ia64/kernel/setup.c linux-2.6.18-rc5-kdum=
p/arch/ia64/kernel/setup.c
--- linux-2.6.18-rc5/arch/ia64/kernel/setup.c	2006-08-30 11:36:53.000000000=
 +0800
+++ linux-2.6.18-rc5-kdump/arch/ia64/kernel/setup.c	2006-08-30 10:34:25.000=
000000 +0800
@@ -43,6 +43,8 @@
 #include <linux/initrd.h>
 #include <linux/pm.h>
 #include <linux/cpufreq.h>
+#include <linux/kexec.h>
+#include <linux/crash_dump.h>
=20
 #include <asm/ia32.h>
 #include <asm/machvec.h>
@@ -250,6 +252,38 @@ reserve_memory (void)
 	}
 #endif
=20
+#ifdef CONFIG_KEXEC
+	/* crashkernel=3Dsize@addr specifies the location to reserve for
+	 * a crash kernel.  By reserving this memory we guarantee
+	 * that linux never set's it up as a DMA target.
+	 * Useful for holding code to do something appropriate
+	 * after a kernel panic.
+	 */
+	{
+		char *from =3D strstr(saved_command_line, "crashkernel=3D");
+		if (from) {
+			unsigned long size, base;
+			size =3D memparse(from + 12, &from);
+			if (*from =3D '@') {
+				base =3D memparse(from + 1, &from);
+				rsvd_region[n].start +					(unsigned long)__va(base);
+				rsvd_region[n].end +					(unsigned long)__va(base + size);
+				crashk_res.start =3D base;
+				crashk_res.end =3D base + size - 1;
+				n++;
+			}
+		}
+		efi_memmap_res.start =3D ia64_boot_param->efi_memmap;
+                efi_memmap_res.end =3D efi_memmap_res.start +
+                        ia64_boot_param->efi_memmap_size;
+                boot_param_res.start =3D __pa(ia64_boot_param);
+                boot_param_res.end =3D boot_param_res.start +
+                        sizeof(*ia64_boot_param);
+	}
+#endif
+
 	efi_memmap_init(&rsvd_region[n].start, &rsvd_region[n].end);
 	n++;
=20
@@ -484,6 +518,16 @@ setup_arch (char **cmdline_p)
 	if (!nomca)
 		ia64_mca_init();
=20
+#ifdef CONFIG_CRASH_DUMP
+	{
+		char *from =3D strstr(saved_command_line, "elfcorehdr=3D");
+
+		if (from)
+			elfcorehdr_addr =3D memparse(from+11, &from);
+		saved_max_pfn =3D (unsigned long) -1;
+	}
+#endif
+
 	platform_setup(cmdline_p);
 	paging_init();
 }
diff -Nraup linux-2.6.18-rc5/arch/ia64/kernel/smp.c linux-2.6.18-rc5-kdump/=
arch/ia64/kernel/smp.c
--- linux-2.6.18-rc5/arch/ia64/kernel/smp.c	2006-06-18 09:49:35.000000000 +=
0800
+++ linux-2.6.18-rc5-kdump/arch/ia64/kernel/smp.c	2006-08-30 10:36:01.00000=
0000 +0800
@@ -30,6 +30,7 @@
 #include <linux/delay.h>
 #include <linux/efi.h>
 #include <linux/bitops.h>
+#include <linux/kexec.h>
=20
 #include <asm/atomic.h>
 #include <asm/current.h>
@@ -66,6 +67,7 @@ static volatile struct call_data_struct=20
=20
 #define IPI_CALL_FUNC		0
 #define IPI_CPU_STOP		1
+#define IPI_KDUMP_CPU_STOP	3
=20
 /* This needs to be cacheline aligned because it is written to by *other* =
CPUs.  */
 static DEFINE_PER_CPU(u64, ipi_operation) ____cacheline_aligned;
@@ -84,6 +86,34 @@ unlock_ipi_calllock(void)
 	spin_unlock_irq(&call_lock);
 }
=20
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
+	impl_va_bits =3D ffz(~(local_cpu_data->unimpl_va_mask | (7UL << 61)));
+	pta =3D POW2(61) - POW2(vmlpt_bits);
+	ia64_set_pta(pta | (0 << 8) | (vmlpt_bits << 2) | 0);
+
+	local_irq_disable();
+	pal_base =3D __get_cpu_var(ia64_mca_pal_base);
+	kexec_fake_sal_rendez(func, ap_wakeup_vector, pal_base);
+}
+#endif
+
 static void
 stop_this_cpu (void)
 {
@@ -96,6 +126,19 @@ stop_this_cpu (void)
 	cpu_halt();
 }
=20
+#ifdef CONFIG_CRASH_DUMP
+static void=20
+kdump_cpu_freeze(struct unw_frame_info *info, void *arg)
+{
+	local_irq_disable();
+	crash_save_this_cpu();
+	current->thread.ksp =3D (__u64)info->sw - 16;
+	for (;;)
+                ia64_hint(ia64_hint_pause);
+}
+#endif
+
+
 void
 cpu_die(void)
 {
@@ -155,7 +198,11 @@ handle_IPI (int irq, void *dev_id, struc
 			      case IPI_CPU_STOP:
 				stop_this_cpu();
 				break;
-
+#ifdef CONFIG_CRASH_DUMP
+			      case IPI_KDUMP_CPU_STOP:
+				unw_init_running(kdump_cpu_freeze, NULL);
+				break;
+#endif
 			      default:
 				printk(KERN_CRIT "Unknown IPI on CPU %d: %lu\n", this_cpu, which);
 				break;
@@ -213,6 +260,13 @@ send_IPI_self (int op)
 	send_IPI_single(smp_processor_id(), op);
 }
=20
+#ifdef CONFIG_CRASH_DUMP
+void
+kdump_smp_send_stop()
+{
+ 	send_IPI_allbutself(IPI_KDUMP_CPU_STOP);
+}
+#endif
 /*
  * Called with preeemption disabled.
  */
diff -Nraup linux-2.6.18-rc5/include/asm-ia64/kexec.h linux-2.6.18-rc5-kdum=
p/include/asm-ia64/kexec.h
--- linux-2.6.18-rc5/include/asm-ia64/kexec.h	1970-01-01 08:00:00.000000000=
 +0800
+++ linux-2.6.18-rc5-kdump/include/asm-ia64/kexec.h	2006-08-30 10:35:01.000=
000000 +0800
@@ -0,0 +1,45 @@
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
+#define kexec_flush_icache_page(page) do { \
+                unsigned long page_addr =3D (unsigned long)page_address(pa=
ge); \
+                flush_icache_range(page_addr, page_addr + PAGE_SIZE); \
+        } while(0)
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
+extern struct resource efi_memmap_res;
+extern struct resource boot_param_res;
+extern void kdump_smp_send_stop(void);
+extern void kdump_disable_iosapic(void);
+extern void crash_save_this_cpu(void);
+
+#endif /* _ASM_IA64_KEXEC_H */
diff -Nraup linux-2.6.18-rc5/include/asm-ia64/machvec_hpzx1.h linux-2.6.18-=
rc5-kdump/include/asm-ia64/machvec_hpzx1.h
--- linux-2.6.18-rc5/include/asm-ia64/machvec_hpzx1.h	2006-06-18 09:49:35.0=
00000000 +0800
+++ linux-2.6.18-rc5-kdump/include/asm-ia64/machvec_hpzx1.h	2006-08-30 10:3=
4:25.000000000 +0800
@@ -34,4 +34,6 @@ extern ia64_mv_dma_mapping_error	sba_dma
 #define platform_dma_supported			sba_dma_supported
 #define platform_dma_mapping_error		sba_dma_mapping_error
=20
+extern void ioc_iova_disable(void);
+
 #endif /* _ASM_IA64_MACHVEC_HPZX1_h */
diff -Nraup linux-2.6.18-rc5/include/asm-ia64/meminit.h linux-2.6.18-rc5-kd=
ump/include/asm-ia64/meminit.h
--- linux-2.6.18-rc5/include/asm-ia64/meminit.h	2006-08-30 11:36:57.0000000=
00 +0800
+++ linux-2.6.18-rc5-kdump/include/asm-ia64/meminit.h	2006-08-30 10:34:25.0=
00000000 +0800
@@ -15,11 +15,12 @@
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
=20
 struct rsvd_region {
 	unsigned long start;	/* virtual address of beginning of element */
diff -Nraup linux-2.6.18-rc5/include/asm-ia64/smp.h linux-2.6.18-rc5-kdump/=
include/asm-ia64/smp.h
--- linux-2.6.18-rc5/include/asm-ia64/smp.h	2006-08-30 11:36:57.000000000 +=
0800
+++ linux-2.6.18-rc5-kdump/include/asm-ia64/smp.h	2006-08-30 10:34:25.00000=
0000 +0800
@@ -128,6 +128,9 @@ extern void smp_send_reschedule (int cpu
 extern void lock_ipi_calllock(void);
 extern void unlock_ipi_calllock(void);
 extern void identify_siblings (struct cpuinfo_ia64 *);
+#ifdef CONFIG_KEXEC
+extern void kexec_stop_this_cpu(void *);
+#endif
=20
 #else
=20
diff -Nraup linux-2.6.18-rc5/include/linux/kexec.h linux-2.6.18-rc5-kdump/i=
nclude/linux/kexec.h
--- linux-2.6.18-rc5/include/linux/kexec.h	2006-08-30 11:37:00.000000000 +0=
800
+++ linux-2.6.18-rc5-kdump/include/linux/kexec.h	2006-08-30 10:35:01.000000=
000 +0800
@@ -108,6 +108,10 @@ int kexec_should_crash(struct task_struc
 extern struct kimage *kexec_image;
 extern struct kimage *kexec_crash_image;
=20
+#ifndef kexec_flush_icache_page
+#define kexec_flush_icache_page(page)
+#endif
+
 #define KEXEC_ON_CRASH  0x00000001
 #define KEXEC_ARCH_MASK 0xffff0000
=20
@@ -131,6 +135,7 @@ extern struct resource crashk_res;
 typedef u32 note_buf_t[MAX_NOTE_BYTES/4];
 extern note_buf_t *crash_notes;
=20
+
 #else /* !CONFIG_KEXEC */
 struct pt_regs;
 struct task_struct;
diff -Nraup linux-2.6.18-rc5/kernel/irq/manage.c linux-2.6.18-rc5-kdump/ker=
nel/irq/manage.c
--- linux-2.6.18-rc5/kernel/irq/manage.c	2006-08-30 11:37:00.000000000 +0800
+++ linux-2.6.18-rc5-kdump/kernel/irq/manage.c	2006-08-30 10:34:25.00000000=
0 +0800
@@ -475,4 +475,3 @@ int request_irq(unsigned int irq,
 	return retval;
 }
 EXPORT_SYMBOL(request_irq);
-
diff -Nraup linux-2.6.18-rc5/kernel/kexec.c linux-2.6.18-rc5-kdump/kernel/k=
exec.c
--- linux-2.6.18-rc5/kernel/kexec.c	2006-08-30 11:37:00.000000000 +0800
+++ linux-2.6.18-rc5-kdump/kernel/kexec.c	2006-08-30 10:35:01.000000000 +08=
00
@@ -851,6 +851,7 @@ static int kimage_load_crash_segment(str
 			memset(ptr + uchunk, 0, mchunk - uchunk);
 		}
 		result =3D copy_from_user(ptr, buf, uchunk);
+		kexec_flush_icache_page(page);
 		kunmap(page);
 		if (result) {
 			result =3D (result < 0) ? result : -EIO;








=20
 =09
