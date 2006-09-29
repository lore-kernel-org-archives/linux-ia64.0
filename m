From: Andrew Morton <akpm@osdl.org>
Date: Fri, 29 Sep 2006 22:26:46 +0000
Subject: Re: kexec/kdump and the ia64 test tree
Message-Id: <20060929152646.2e3dbbbb.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200609292146.k8TLkNex005603@agluck-lia64.sc.intel.com>
In-Reply-To: <200609292146.k8TLkNex005603@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Fri, 29 Sep 2006 14:46:23 -0700
Tony Luck <tony.luck@intel.com> wrote:

> The kexec/kdump patch in my test tree is very stale, plus it is time
> for some git maintenance on the test tree (to clean away all the
> "Auto-update from upstream" commits that my workflow generates). So
> I'm planning on resetting my "test" branch to Linus-latest + kdump/kexec
> (so git pull/fetch will barf on my test tree, you'll need to re-clone).
>=20
> Below I've include what I believe to be the latest version of the
> patch produced by:
>=20
> 1) Take 2.6.18
> 2) Apply Nan Hai patch for 2.6.18 (posted Sept 20th)
> 3) Pull in Linus-latest (c972398b ...) and resolve conflicts in smp.h, sy=
sctl.h
> 4) Apply Nan hai's "Fix OS_INIT" patch that fixed Indou-san's deadlock is=
sue (Sept 28th)
> 5) Fix a few warnings:
> 	arch/ia64/kernel/iosapic.c:
> 		`vec' may be used before set in kexec_disable_iosapic() ... I'm
> 		not totally confident that I fixed this right. Please look closely
> 		at what I did.
> 	arch/ia64/kernel/smp.c:
> 		Trivial fixes to stop compiler complaining that kdump_smp_send_stop()
> 		and kdump_smp_send_init() definitions were not prototypes.
> 6) Lots of white-space cleanup (mostly multiple spaces that should be tab=
s, but I
>    also threw the whole kdump_find_rsvd_region() in arch/ia64/kernel/efi.=
c through
>    scripts/Lindent as it was only using two-spaces for indentation.)
>=20
> Let me know if I've goofed up the patch during this process.
>=20
> I'm planning to reset my test tree on Monday (Oct 2nd).
>=20

Thanks Tony.

Rebuilding of the git tree is a non-issue for me - everyone does it all the
time and I just do `git-branch -D' and all is happy.

kexec and kdump are discussed on the fastboot list, which I've cc'ed here. =

IIRC there were concerns about earlier versions of this code.



diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 0b7f701..27b913a 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -433,6 +433,29 @@ config IA64_ESI
=20
 source "drivers/sn/Kconfig"
=20
+config KEXEC
+	bool "kexec system call (EXPERIMENTAL)"
+	depends on EXPERIMENTAL && !IA64_HP_SIM
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
+	  depends on EXPERIMENTAL && IA64_MCA_RECOVERY && !IA64_HP_SIM
+	  help
+	    Generate crash dump after being started by kexec.
+
 source "drivers/firmware/Kconfig"
=20
 source "fs/Kconfig.binfmt"
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 3149749..96686f8 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -28,6 +28,7 @@ obj-$(CONFIG_IA64_CYCLONE)	+=3D cyclone.o
 obj-$(CONFIG_CPU_FREQ)		+=3D cpufreq/
 obj-$(CONFIG_IA64_MCA_RECOVERY)	+=3D mca_recovery.o
 obj-$(CONFIG_KPROBES)		+=3D kprobes.o jprobes.o
+obj-$(CONFIG_KEXEC)		+=3D machine_kexec.o relocate_kernel.o crash.o
 obj-$(CONFIG_IA64_UNCACHED_ALLOCATOR)	+=3D uncached.o
 obj-$(CONFIG_AUDIT)		+=3D audit.o
 mca_recovery-y			+=3D mca_drv.o mca_drv_asm.o
diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
new file mode 100644
index 0000000..ad6013d
--- /dev/null
+++ b/arch/ia64/kernel/crash.c
@@ -0,0 +1,234 @@
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
+#include <linux/smp.h>
+#include <linux/delay.h>
+#include <linux/crash_dump.h>
+#include <linux/bootmem.h>
+#include <linux/kexec.h>
+#include <linux/elfcore.h>
+#include <linux/sysctl.h>
+#include <linux/init.h>
+
+#include <asm/kdebug.h>
+#include <asm/mca.h>
+#include <asm/uaccess.h>
+
+int kdump_status[NR_CPUS];
+atomic_t kdump_cpu_freezed;
+int kdump_on_init =3D 1;
+
+ssize_t
+copy_oldmem_page(unsigned long pfn, char *buf,
+		size_t csize, unsigned long offset, int userbuf)
+{
+	void  *vaddr;
+
+	if (!csize)
+		return 0;
+	vaddr =3D __va(pfn<<PAGE_SHIFT);
+	if (userbuf) {
+		if (copy_to_user(buf, (vaddr + offset), csize)) {
+			return -EFAULT;
+		}
+	} else
+		memcpy(buf, (vaddr + offset), csize);
+	return csize;
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
+	cfm =3D dst[43];
+	sol =3D (cfm >> 7) & 0x7f;
+	sof =3D cfm & 0x7f;
+	dst[46] =3D (unsigned long)ia64_rse_skip_regs((unsigned long *)dst[46],
+			sof - sol);
+
+	buf =3D (u64 *) per_cpu_ptr(crash_notes, cpu);
+	if (!buf)
+		return;
+	buf =3D append_elf_note(buf, "CORE", NT_PRSTATUS, prstatus,
+			sizeof(*prstatus));
+	final_note(buf);
+}
+
+static int
+kdump_wait_cpu_freeze(void)
+{
+	int cpu_num =3D num_online_cpus() - 1;
+	int timeout =3D 1000;
+	while(timeout-- > 0) {
+		if (atomic_read(&kdump_cpu_freezed) =3D cpu_num)
+			return 0;
+		udelay(1000);
+	}
+	return 1;
+}
+
+static int kdump_sending_init;
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
+	kexec_disable_iosapic();
+#ifdef CONFIG_SMP
+	kdump_smp_send_stop();
+	if (kdump_wait_cpu_freeze() && kdump_on_init) 	{
+		/* not all cpu response to IPI, send INIT to freeze them */
+		kdump_sending_init =3D 1;
+		mb();
+		kdump_smp_send_init();
+	}
+#endif
+}
+
+static void
+machine_kdump_on_init(void)
+{
+	local_irq_disable();
+	kexec_disable_iosapic();
+	machine_kexec(ia64_kimage);
+}
+
+void
+kdump_cpu_freeze(struct unw_frame_info *info, void *arg)
+{
+	local_irq_disable();
+	crash_save_this_cpu();
+	current->thread.ksp =3D (__u64)info->sw - 16;
+	atomic_inc(&kdump_cpu_freezed);
+	kdump_status[smp_processor_id()] =3D 1;
+	mb();
+	for (;;)
+		cpu_relax();
+}
+
+static int
+kdump_init_notifier(struct notifier_block *self, unsigned long val, void *=
data)
+{
+	struct ia64_mca_notify_die *nd;
+	struct die_args *args =3D data;
+
+	if (!kdump_on_init)
+		return NOTIFY_DONE;
+
+	if (val !=3D DIE_INIT_MONARCH_ENTER && val !=3D DIE_INIT_SLAVE_ENTER)
+		return NOTIFY_DONE;
+
+	nd =3D (struct ia64_mca_notify_die *)args->err;
+	/* Reason code 1 means machine check rendezous*/
+	if (nd->sos->rv_rc =3D 1)
+		return NOTIFY_DONE;
+
+	if (kdump_sending_init)
+		unw_init_running(kdump_cpu_freeze, NULL);
+
+	switch (val) {
+		case DIE_INIT_MONARCH_ENTER:
+			machine_kdump_on_init();
+			break;
+		case DIE_INIT_SLAVE_ENTER:
+			unw_init_running(kdump_cpu_freeze, NULL);
+			break;
+	}
+	return NOTIFY_DONE;
+}
+
+#ifdef CONFIG_SYSCTL
+static ctl_table kdump_on_init_table[] =3D {
+	{
+		.ctl_name =3D KERN_KDUMP_ON_INIT,
+		.procname =3D "kdump_on_init",
+		.data =3D &kdump_on_init,
+		.maxlen =3D sizeof(int),
+		.mode =3D 0644,
+		.proc_handler =3D &proc_dointvec,
+	},
+	{ .ctl_name =3D 0 }
+};
+
+static ctl_table sys_table[] =3D {
+	{
+	  .ctl_name =3D CTL_KERN,
+	  .procname =3D "kernel",
+	  .mode =3D 0555,
+	  .child =3D kdump_on_init_table,
+	},
+	{ .ctl_name =3D 0 }
+};
+#endif
+
+static int
+machine_crash_setup(void)
+{
+	char *from =3D strstr(saved_command_line, "elfcorehdr=3D");
+	static struct notifier_block kdump_init_notifier_nb =3D {
+		.notifier_call =3D kdump_init_notifier,
+	};
+	int ret;
+	if (from)
+		elfcorehdr_addr =3D memparse(from+11, &from);
+	saved_max_pfn =3D (unsigned long)-1;
+	if((ret =3D register_die_notifier(&kdump_init_notifier_nb)) !=3D 0)
+		return ret;
+#ifdef CONFIG_SYSCTL
+	register_sysctl_table(sys_table, 0);
+#endif
+	return 0;
+}
+
+__initcall(machine_crash_setup);
+
diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index bb8770a..a01ba73 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -26,6 +26,7 @@ #include <linux/init.h>
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
@@ -1116,6 +1123,58 @@ efi_initialize_iomem_resources(struct re
 			 */
 			insert_resource(res, code_resource);
 			insert_resource(res, data_resource);
+#ifdef CONFIG_KEXEC
+			insert_resource(res, &efi_memmap_res);
+			insert_resource(res, &boot_param_res);
+			if (crashk_res.end > crashk_res.start)
+				insert_resource(res, &crashk_res);
+#endif
 		}
 	}
 }
+
+#ifdef CONFIG_KEXEC
+/* find a block of memory aligned to 64M exclude reserved regions
+ * rsvd_regions are sorted
+ */
+unsigned long
+kdump_find_rsvd_region(unsigned long size, struct rsvd_region *r, int n)
+{
+	int i;
+	u64 start, end;
+	u64 alignment =3D 1UL << _PAGE_SIZE_64M;
+	void *efi_map_start, *efi_map_end, *p;
+	efi_memory_desc_t *md;
+	u64 efi_desc_size;
+
+	efi_map_start =3D __va(ia64_boot_param->efi_memmap);
+	efi_map_end   =3D efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size =3D ia64_boot_param->efi_memdesc_size;
+
+	for (p =3D efi_map_start; p < efi_map_end; p +=3D efi_desc_size) {
+		md =3D p;
+		if (!efi_wb(md))
+			continue;
+		start =3D ALIGN(md->phys_addr, alignment);
+		end =3D efi_md_end(md);
+		for (i =3D 0; i < n; i++) {
+			if (__pa(r[i].start) >=3D start && __pa(r[i].end) < end) {
+				if (__pa(r[i].start) > start + size)
+					return start;
+				start =3D ALIGN(__pa(r[i].end), alignment);
+				if (i < n - 1
+				    && __pa(r[i + 1].start) < start + size)
+					continue;
+				else
+					break;
+			}
+		}
+		if (end > start + size)
+			return start;
+	}
+
+	printk(KERN_WARNING
+	       "Cannot reserve 0x%lx byte of memory for crashdump\n", size);
+	return ~0UL;
+}
+#endif
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 12701cf..7e95e8f 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -1575,7 +1575,7 @@ sys_call_table:
 	data8 sys_mq_timedreceive		// 1265
 	data8 sys_mq_notify
 	data8 sys_mq_getsetattr
-	data8 sys_ni_syscall			// reserved for kexec_load
+	data8 sys_kexec_load
 	data8 sys_ni_syscall			// reserved for vserver
 	data8 sys_waitid			// 1270
 	data8 sys_add_key
diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index 9bf15fe..00cf506 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -288,6 +288,28 @@ nop (unsigned int irq)
 	/* do nothing... */
 }
=20
+
+#ifdef CONFIG_KEXEC
+void
+kexec_disable_iosapic(void)
+{
+	struct iosapic_intr_info *info;
+	struct iosapic_rte_info *rte;
+	ia64_vector vec =3D 0;
+
+	for (info =3D iosapic_intr_info; info <
+			iosapic_intr_info + IA64_NUM_VECTORS; ++info, ++vec) {
+		list_for_each_entry(rte, &info->rtes,
+				rte_list) {
+			iosapic_write(rte->addr,
+					IOSAPIC_RTE_LOW(rte->rte_index),
+					IOSAPIC_MASK);
+			iosapic_eoi(rte->addr, vec);
+		}
+	}
+}
+#endif
+
 static void
 mask_irq (unsigned int irq)
 {
diff --git a/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_ke=
xec.c
new file mode 100644
index 0000000..2bbdabe
--- /dev/null
+++ b/arch/ia64/kernel/machine_kexec.c
@@ -0,0 +1,138 @@
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
+#include <linux/mm.h>
+#include <linux/kexec.h>
+#include <linux/cpu.h>
+#include <linux/irq.h>
+#include <asm/mmu_context.h>
+#include <asm/setup.h>
+#include <asm/delay.h>
+#include <asm/meminit.h>
+
+typedef void (*relocate_new_kernel_t)(unsigned long, unsigned long,
+		struct ia64_boot_param *, unsigned long);
+
+struct kimage *ia64_kimage;
+
+struct resource efi_memmap_res =3D {
+	.name  =3D "EFI Memory Map",
+	.start =3D 0,
+	.end   =3D 0,
+	.flags =3D IORESOURCE_BUSY | IORESOURCE_MEM
+};
+
+struct resource boot_param_res =3D {
+	.name  =3D "Boot parameter",
+	.start =3D 0,
+	.end   =3D 0,
+	.flags =3D IORESOURCE_BUSY | IORESOURCE_MEM
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
+	kexec_disable_iosapic();
+}
+
+/*
+ * Do not allocate memory (or fail in any way) in machine_kexec().
+ * We are past the point of no return, committed to rebooting now.
+ */
+extern void *efi_get_pal_addr(void);
+static void ia64_machine_kexec(struct unw_frame_info *info, void *arg)
+{
+	struct kimage *image =3D arg;
+	relocate_new_kernel_t rnk;
+	void *pal_addr =3D efi_get_pal_addr();
+	unsigned long code_addr =3D (unsigned long)page_address(image->control_co=
de_page);
+	unsigned long vector;
+	int ii;
+
+	if (image->type =3D KEXEC_TYPE_CRASH) {
+		crash_save_this_cpu();
+		current->thread.ksp =3D (__u64)info->sw - 16;
+	}
+
+	/* Interrupts aren't acceptable while we reboot */
+	local_irq_disable();
+
+	/* Mask CMC and Performance Monitor interrupts */
+	ia64_setreg(_IA64_REG_CR_PMV, 1 << 16);
+	ia64_setreg(_IA64_REG_CR_CMCV, 1 << 16);
+
+	/* Mask ITV and Local Redirect Registers */
+	ia64_set_itv(1 << 16);
+	ia64_set_lrr0(1 << 16);
+	ia64_set_lrr1(1 << 16);
+
+	/* terminate possible nested in-service interrupts */
+	for (ii =3D 0; ii < 16; ii++)
+		ia64_eoi();
+
+	/* unmask TPR and clear any pending interrupts */
+	ia64_setreg(_IA64_REG_CR_TPR, 0);
+	ia64_srlz_d();
+	vector =3D ia64_get_ivr();
+	while (vector !=3D IA64_SPURIOUS_INT_VECTOR) {
+		ia64_eoi();
+		vector =3D ia64_get_ivr();
+	}
+	rnk =3D (relocate_new_kernel_t)&code_addr;
+	(*rnk)(image->head, image->start, ia64_boot_param,
+		     GRANULEROUNDDOWN((unsigned long) pal_addr));
+	BUG();
+}
+
+void machine_kexec(struct kimage *image)
+{
+	unw_init_running(ia64_machine_kexec, image);
+	for(;;);
+}
diff --git a/arch/ia64/kernel/relocate_kernel.S b/arch/ia64/kernel/relocate=
_kernel.S
new file mode 100644
index 0000000..4c6ada4
--- /dev/null
+++ b/arch/ia64/kernel/relocate_kernel.S
@@ -0,0 +1,489 @@
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
+/*
+ * Must be relocatable PIC code callable as a C function
+*/
+GLOBAL_ENTRY(relocate_new_kernel)
+	.prologue
+	alloc r31=3Dar.pfs,4,0,0,0
+	.body
+.reloc_entry:
+{
+	rsm psr.i| psr.ic
+	mov r2=3Dip
+}
+	;;
+{
+	flushrs				// must be first insn in group
+	srlz.i
+}
+	;;
+	dep r2=3D0,r2,61,3		// to physical address
+	;;
+	//first switch to physical mode
+	add r3=1F-.reloc_entry, r2
+	movl r16 =3D IA64_PSR_AC|IA64_PSR_BN|IA64_PSR_IC
+	mov ar.rsc=3D0			// put RSE in enforced lazy mode
+	;;
+	add sp=3D(memory_stack_end - 16 - .reloc_entry),r2
+	add r8=3D(register_stack - .reloc_entry),r2
+	;;
+	mov r18=3Dar.rnat
+	mov ar.bspstore=3Dr8
+	;;
+	mov cr.ipsr=3Dr16
+	mov cr.iip=3Dr3
+	mov cr.ifs=3Dr0
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
+#define O(member)	IA64_CPUINFO_##member##_OFFSET
+	GET_THIS_PADDR(r2, cpu_info)	// load phys addr of cpu_info into r2
+	;;
+	addl r17=3DO(PTCE_STRIDE),r2
+	addl r2=3DO(PTCE_BASE),r2
+	;;
+	ld8 r18=3D[r2],(O(PTCE_COUNT)-O(PTCE_BASE));;	// r18=3Dptce_base
+	ld4 r19=3D[r2],4					// r19=3Dptce_count[0]
+	ld4 r21=3D[r17],4					// r21=3Dptce_stride[0]
+	;;
+	ld4 r20=3D[r2]					// r20=3Dptce_count[1]
+	ld4 r22=3D[r17]					// r22=3Dptce_stride[1]
+	mov r24=3Dr0
+	;;
+	adds r20=3D-1,r20
+	;;
+#undef O
+2:
+	cmp.ltu p6,p7=3Dr24,r19
+(p7)	br.cond.dpnt.few 4f
+	mov ar.lc=3Dr20
+3:
+	ptc.e r18
+	;;
+	add r18=3Dr22,r18
+	br.cloop.sptk.few 3b
+	;;
+	add r18=3Dr21,r18
+	add r24=3D1,r24
+	;;
+	br.sptk.few 2b
+4:
+	srlz.i
+	;;
+	//purge TR entry for kernel text and data
+	movl r16=3DKERNEL_START
+	mov r18=3DKERNEL_TR_PAGE_SHIFT<<2
+	;;
+	ptr.i r16, r18
+	ptr.d r16, r18
+	;;
+	srlz.i
+	;;
+
+	// purge TR entry for percpu data
+	movl r16=3DPERCPU_ADDR
+	mov r18=3DPERCPU_PAGE_SHIFT<<2
+	;;
+	ptr.d r16,r18
+	;;
+	srlz.d
+	;;
+
+	// purge TR entry for pal code
+	mov r16=3Din3
+	mov r18=3DIA64_GRANULE_SHIFT<<2
+	;;
+	ptr.i r16,r18
+	;;
+	srlz.i
+	;;
+
+	// purge TR entry for stack
+	mov r16=3DIA64_KR(CURRENT_STACK)
+	;;
+	shl r16=3Dr16,IA64_GRANULE_SHIFT
+	movl r19=3DPAGE_OFFSET
+	;;
+	add r16=3Dr19,r16
+	mov r18=3DIA64_GRANULE_SHIFT<<2
+	;;
+	ptr.d r16,r18
+	;;
+	srlz.i
+	;;
+
+	//copy segments
+	movl r16=3DPAGE_MASK
+	mov  r30=3Din0			// in0 is page_list
+	br.sptk.few .dest_page
+	;;
+.loop:
+	ld8  r30=3D[in0], 8;;
+.dest_page:
+	tbit.z p0, p6=3Dr30, 0;;		// 0x1 dest page
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
+.align 32
+memory_stack:
+	.fill	8192, 1, 0
+memory_stack_end:
+register_stack:
+	.fill	8192, 1, 0
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
+	/* See where I am running, and compute gp */
+	{
+		mov ar.rsc =3D 0		/* Put RSE in enforce lacy, LE mode */
+		mov gp =3D ip		/* gp =3D relocate_new_kernel */
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
+	mov	b6=3Din0			/* _start addr */
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
+(p6)	br.cond.sptk.few	check_irr0
+	cmp.eq	p7,p0=3D1,r9
+	;;
+(p7)	br.cond.sptk.few	check_irr1
+	cmp.eq	p8,p0=3D2,r9
+	;;
+(p8)	br.cond.sptk.few	check_irr2
+	cmp.eq	p9,p0=3D3,r9
+	;;
+(p9)	br.cond.sptk.few	check_irr3
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
+	.prologue
+	alloc loc0=3Dar.pfs,1,2,0,0
+	.body
+	mov	ar.rsc=3D0		// put RSE in enforced lazy mode
+	add	loc1=3D4*8, in0		// save r4 and r5 first
+	;;
+{
+	flushrs				// flush dirty regs to backing store
+	srlz.i
+}
+	st8 [loc1]=3Dr4, 8
+	;;
+	st8 [loc1]=3Dr5, 8
+	;;
+	add loc12*8, in0
+	mov r4=3Dar.rnat
+	;;
+	st8 [in0]=3Dr0, 8			// r0
+	st8 [loc1]=3Dr4, 8		// rnat
+	mov r5=3Dpr
+	;;
+	st8 [in0]=3Dr1, 8			// r1
+	st8 [loc1]=3Dr5, 8		// pr
+	mov r4=B0
+	;;
+	st8 [in0]=3Dr2, 8			// r2
+	st8 [loc1]=3Dr4, 8		// b0
+	mov r5=B1;
+	;;
+	st8 [in0]=3Dr3, 24		// r3
+	st8 [loc1]=3Dr5, 8		// b1
+	mov r4=B2
+	;;
+	st8 [in0]=3Dr6, 8			// r6
+	st8 [loc1]=3Dr4, 8		// b2
+	mov r5=B3
+	;;
+	st8 [in0]=3Dr7, 8			// r7
+	st8 [loc1]=3Dr5, 8		// b3
+	mov r4=B4
+	;;
+	st8 [in0]=3Dr8, 8			// r8
+	st8 [loc1]=3Dr4, 8		// b4
+	mov r5=B5
+	;;
+	st8 [in0]=3Dr9, 8			// r9
+	st8 [loc1]=3Dr5, 8		// b5
+	mov r4=B6
+	;;
+	st8 [in0]=3Dr10, 8		// r10
+	st8 [loc1]=3Dr5, 8		// b6
+	mov r5=B7
+	;;
+	st8 [in0]=3Dr11, 8		// r11
+	st8 [loc1]=3Dr5, 8		// b7
+	mov r4=B0
+	;;
+	st8 [in0]=3Dr12, 8		// r12
+	st8 [loc1]=3Dr4, 8		// ip
+	mov r5=3Dloc0
+	;;
+	st8 [in0]=3Dr13, 8		// r13
+	extr.u r5=3Dr5, 0, 38		// ar.pfs.pfm
+	mov r4=3Dr0			// user mask
+	;;
+	st8 [in0]=3Dr14, 8		// r14
+	st8 [loc1]=3Dr5, 8		// cfm
+	;;
+	st8 [in0]=3Dr15, 8		// r15
+	st8 [loc1]=3Dr4, 8		// user mask
+	mov r5=3Dar.rsc
+	;;
+	st8 [in0]=3Dr16, 8		// r16
+	st8 [loc1]=3Dr5, 8		// ar.rsc
+	mov r4=3Dar.bsp
+	;;
+	st8 [in0]=3Dr17, 8		// r17
+	st8 [loc1]=3Dr4, 8		// ar.bsp
+	mov r5=3Dar.bspstore
+	;;
+	st8 [in0]=3Dr18, 8		// r18
+	st8 [loc1]=3Dr5, 8		// ar.bspstore
+	mov r4=3Dar.rnat
+	;;
+	st8 [in0]=3Dr19, 8		// r19
+	st8 [loc1]=3Dr4, 8		// ar.rnat
+	mov r5=3Dar.ccv
+	;;
+	st8 [in0]=3Dr20, 8		// r20
+	st8 [loc1]=3Dr5, 8		// ar.ccv
+	mov r4=3Dar.unat
+	;;
+	st8 [in0]=3Dr21, 8		// r21
+	st8 [loc1]=3Dr4, 8		// ar.unat
+	mov r5 =3D ar.fpsr
+	;;
+	st8 [in0]=3Dr22, 8		// r22
+	st8 [loc1]=3Dr5, 8		// ar.fpsr
+	mov r4 =3D ar.unat
+	;;
+	st8 [in0]=3Dr23, 8		// r23
+	st8 [loc1]=3Dr4, 8		// unat
+	mov r5 =3D ar.fpsr
+	;;
+	st8 [in0]=3Dr24, 8		// r24
+	st8 [loc1]=3Dr5, 8		// fpsr
+	mov r4 =3D ar.pfs
+	;;
+	st8 [in0]=3Dr25, 8		// r25
+	st8 [loc1]=3Dr4, 8		// ar.pfs
+	mov r5 =3D ar.lc
+	;;
+	st8 [in0]=3Dr26, 8		// r26
+	st8 [loc1]=3Dr5, 8		// ar.lc
+	mov r4 =3D ar.ec
+	;;
+	st8 [in0]=3Dr27, 8		// r27
+	st8 [loc1]=3Dr4, 8		// ar.ec
+	mov r5 =3D ar.csd
+	;;
+	st8 [in0]=3Dr28, 8		// r28
+	st8 [loc1]=3Dr5, 8		// ar.csd
+	mov r4 =3D ar.ssd
+	;;
+	st8 [in0]=3Dr29, 8		// r29
+	st8 [loc1]=3Dr4, 8		// ar.ssd
+	;;
+	st8 [in0]=3Dr30, 8		// r30
+	;;
+	st8 [in0]=3Dr31, 8		// r31
+	mov ar.pfs=3Dloc0
+	;;
+	br.ret.sptk.many rp
+END(ia64_dump_cpu_regs)
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 84f93c0..1bdb3b6 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -43,6 +43,8 @@ #include <linux/efi.h>
 #include <linux/initrd.h>
 #include <linux/pm.h>
 #include <linux/cpufreq.h>
+#include <linux/kexec.h>
+#include <linux/crash_dump.h>
=20
 #include <asm/ia32.h>
 #include <asm/machvec.h>
@@ -253,6 +255,41 @@ #endif
 	efi_memmap_init(&rsvd_region[n].start, &rsvd_region[n].end);
 	n++;
=20
+#ifdef CONFIG_KEXEC
+	/* crashkernel=3Dsize@offset specifies the size to reserve for a crash
+	 * kernel.(offset is ingored for keep compatibility with other archs)
+	 * By reserving this memory we guarantee that linux never set's it
+	 * up as a DMA target.Useful for holding code to do something
+	 * appropriate after a kernel panic.
+	 */
+	{
+		char *from =3D strstr(saved_command_line, "crashkernel=3D");
+		unsigned long base, size;
+		if (from) {
+			size =3D memparse(from + 12, &from);
+			if (size) {
+				sort_regions(rsvd_region, n);
+				base =3D kdump_find_rsvd_region(size,
+				rsvd_region, n);
+				if (base !=3D ~0UL) {
+					rsvd_region[n].start +						(unsigned long)__va(base);
+					rsvd_region[n].end +						(unsigned long)__va(base + size);
+					n++;
+					crashk_res.start =3D base;
+					crashk_res.end =3D base + size - 1;
+				}
+			}
+		}
+		efi_memmap_res.start =3D ia64_boot_param->efi_memmap;
+		efi_memmap_res.end =3D efi_memmap_res.start +
+			ia64_boot_param->efi_memmap_size;
+		boot_param_res.start =3D __pa(ia64_boot_param);
+		boot_param_res.end =3D boot_param_res.start +
+			sizeof(*ia64_boot_param);
+	}
+#endif
 	/* end of memory marker */
 	rsvd_region[n].start =3D ~0UL;
 	rsvd_region[n].end   =3D ~0UL;
diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 657ac99..deb47d7 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -30,6 +30,7 @@ #include <linux/cache.h>
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
@@ -155,7 +185,11 @@ handle_IPI (int irq, void *dev_id, struc
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
@@ -213,6 +247,26 @@ send_IPI_self (int op)
 	send_IPI_single(smp_processor_id(), op);
 }
=20
+#ifdef CONFIG_CRASH_DUMP
+void
+kdump_smp_send_stop(void)
+{
+ 	send_IPI_allbutself(IPI_KDUMP_CPU_STOP);
+}
+
+void
+kdump_smp_send_init(void)
+{
+	unsigned int cpu, self_cpu;
+	self_cpu =3D smp_processor_id();
+	for_each_online_cpu(cpu) {
+		if (cpu !=3D self_cpu) {
+			if(kdump_status[cpu] =3D 0)
+				platform_send_ipi(cpu, 0, IA64_IPI_DM_INIT, 0);
+		}
+	}
+}
+#endif
 /*
  * Called with preeemption disabled.
  */
diff --git a/include/asm-ia64/kexec.h b/include/asm-ia64/kexec.h
new file mode 100644
index 0000000..7eb8ca2
--- /dev/null
+++ b/include/asm-ia64/kexec.h
@@ -0,0 +1,53 @@
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
+		unsigned long page_addr =3D (unsigned long)page_address(page); \
+		flush_icache_range(page_addr, page_addr + PAGE_SIZE); \
+	} while(0)
+
+extern struct kimage *ia64_kimage;
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
+extern void kdump_smp_send_init(void);
+extern void kexec_disable_iosapic(void);
+extern void crash_save_this_cpu(void);
+struct rsvd_region;
+extern unsigned long kdump_find_rsvd_region(unsigned long size,
+		struct rsvd_region *rsvd_regions, int n);
+extern void kdump_cpu_freeze(struct unw_frame_info *info, void *arg);
+extern int kdump_status[];
+extern atomic_t kdump_cpu_freezed;
+
+#endif /* _ASM_IA64_KEXEC_H */
diff --git a/include/asm-ia64/meminit.h b/include/asm-ia64/meminit.h
index c3b1f86..c8df759 100644
--- a/include/asm-ia64/meminit.h
+++ b/include/asm-ia64/meminit.h
@@ -15,11 +15,12 @@ #define meminit_h
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
diff --git a/include/asm-ia64/smp.h b/include/asm-ia64/smp.h
index 60fd4ae..8beb83b 100644
--- a/include/asm-ia64/smp.h
+++ b/include/asm-ia64/smp.h
@@ -127,6 +127,9 @@ extern void lock_ipi_calllock(void);
 extern void unlock_ipi_calllock(void);
 extern void identify_siblings (struct cpuinfo_ia64 *);
 extern int is_multithreading_enabled(void);
+#ifdef CONFIG_KEXEC
+extern void kexec_stop_this_cpu(void *);
+#endif
=20
 #else
=20
diff --git a/include/linux/kexec.h b/include/linux/kexec.h
index 6427949..c790e08 100644
--- a/include/linux/kexec.h
+++ b/include/linux/kexec.h
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
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 1b24bd4..1749cd7 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -152,6 +152,7 @@ enum
 	KERN_MAX_LOCK_DEPTHt,
 	KERN_NMI_WATCHDOGu, /* int: enable/disable nmi watchdog */
 	KERN_PANIC_ON_NMIv, /* int: whether we will panic on an unrecovered */
+	KERN_KDUMP_ON_INITw,	/* int: ia64 kdump with INIT */
 };
=20
=20
diff --git a/kernel/kexec.c b/kernel/kexec.c
index 50087ec..9b7ceda 100644
--- a/kernel/kexec.c
+++ b/kernel/kexec.c
@@ -851,6 +851,7 @@ static int kimage_load_crash_segment(str
 			memset(ptr + uchunk, 0, mchunk - uchunk);
 		}
 		result =3D copy_from_user(ptr, buf, uchunk);
+		kexec_flush_icache_page(page);
 		kunmap(page);
 		if (result) {
 			result =3D (result < 0) ? result : -EIO;

