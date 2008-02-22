From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 05:10:36 +0000
Subject: [PATCH 17/28] ia64/xen: domU initialization code.
Message-Id: <12036570473547-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/Makefile         |   12 ++++-
 arch/ia64/kernel/setup.c   |  121 ++++++++++++++++++++++++++++++++++++++++++++
 arch/ia64/kernel/smpboot.c |    4 ++
 arch/ia64/xen/Makefile     |    4 ++
 4 files changed, 139 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index b916ccf..36be3bf 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -45,6 +45,12 @@ ifeq ($(call cc-version),0304)
 endif
 
 KBUILD_CFLAGS += $(cflags-y)
+
+cppflags-$(CONFIG_XEN) += \
+	-D__XEN_INTERFACE_VERSION__=$(CONFIG_XEN_INTERFACE_VERSION)
+
+KBUILD_CPPFLAGS += $(cppflags-y)
+
 head-y := arch/ia64/kernel/head.o arch/ia64/kernel/init_task.o
 
 libs-y				+= arch/ia64/lib/
@@ -54,7 +60,9 @@ core-$(CONFIG_IA64_DIG) 	+= arch/ia64/dig/
 core-$(CONFIG_IA64_GENERIC) 	+= arch/ia64/dig/
 core-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/dig/
 core-$(CONFIG_IA64_HP_ZX1_SWIOTLB) += arch/ia64/dig/
+core-$(CONFIG_IA64_XEN)		+= arch/ia64/dig/
 core-$(CONFIG_IA64_SGI_SN2)	+= arch/ia64/sn/
+core-$(CONFIG_XEN)		+= arch/ia64/xen/
 
 drivers-$(CONFIG_PCI)		+= arch/ia64/pci/
 drivers-$(CONFIG_IA64_HP_SIM)	+= arch/ia64/hp/sim/
@@ -87,8 +95,8 @@ CLEAN_FILES += vmlinux.gz bootloader
 boot:	lib/lib.a vmlinux
 	$(Q)$(MAKE) $(build)=$(boot) $@
 
-install: vmlinux.gz
-	sh $(srctree)/arch/ia64/install.sh $(KERNELRELEASE) $< System.map "$(INSTALL_PATH)"
+install:
+	-yes | sh $(srctree)/arch/ia64/install.sh $(KERNELRELEASE) vmlinux.gz System.map "$(INSTALL_PATH)"
 
 define archhelp
   echo '* compressed	- Build compressed kernel image'
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index ebd1a09..0c103b5 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -61,6 +61,12 @@
 #include <asm/system.h>
 #include <asm/unistd.h>
 #include <asm/hpsim.h>
+#ifdef CONFIG_XEN
+#include <xen/features.h>
+#include <asm/xen/hypervisor.h>
+#include <asm/xen/xencomm.h>
+#endif
+#include <linux/dma-mapping.h>
 
 #if defined(CONFIG_SMP) && (IA64_CPU_SIZE > PAGE_SIZE)
 # error "struct cpuinfo_ia64 too big!"
@@ -71,6 +77,34 @@ unsigned long __per_cpu_offset[NR_CPUS];
 EXPORT_SYMBOL(__per_cpu_offset);
 #endif
 
+#ifdef CONFIG_XEN
+static void
+xen_panic_hypercall(struct unw_frame_info *info, void *arg)
+{
+	current->thread.ksp = (__u64)info->sw - 16;
+	HYPERVISOR_shutdown(SHUTDOWN_crash);
+	/* we're never actually going to get here... */
+}
+
+static int
+xen_panic_event(struct notifier_block *this, unsigned long event, void *ptr)
+{
+	unw_init_running(xen_panic_hypercall, NULL);
+	/* we're never actually going to get here... */
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block xen_panic_block = {
+	xen_panic_event, NULL, 0 /* try to go last */
+};
+
+void xen_pm_power_off(void)
+{
+	local_irq_disable();
+	HYPERVISOR_shutdown(SHUTDOWN_poweroff);
+}
+#endif
+
 DEFINE_PER_CPU(struct cpuinfo_ia64, cpu_info);
 DEFINE_PER_CPU(unsigned long, local_per_cpu_offset);
 unsigned long ia64_cycles_per_usec;
@@ -288,6 +322,14 @@ reserve_memory (void)
 	rsvd_region[n].end   = (unsigned long) ia64_imva(_end);
 	n++;
 
+#ifdef CONFIG_XEN
+	if (is_running_on_xen()) {
+		rsvd_region[n].start = (unsigned long)__va((HYPERVISOR_shared_info->arch.start_info_pfn << PAGE_SHIFT));
+		rsvd_region[n].end   = rsvd_region[n].start + PAGE_SIZE;
+		n++;
+	}
+#endif
+
 #ifdef CONFIG_BLK_DEV_INITRD
 	if (ia64_boot_param->initrd_start) {
 		rsvd_region[n].start = (unsigned long)__va(ia64_boot_param->initrd_start);
@@ -466,6 +508,24 @@ setup_arch (char **cmdline_p)
 {
 	unw_init();
 
+#ifdef CONFIG_XEN
+	if (is_running_on_xen()) {
+		struct shared_info *s = HYPERVISOR_shared_info;
+		xen_start_info = __va(s->arch.start_info_pfn << PAGE_SHIFT);
+
+		/* Must be done before any hypercall.  */
+		xencomm_initialize();
+
+		xen_setup_features();
+		/* Register a call for panic conditions. */
+		atomic_notifier_chain_register(&panic_notifier_list,
+					       &xen_panic_block);
+		pm_power_off = xen_pm_power_off;
+
+		xen_ia64_enable_opt_feature();
+	}
+#endif
+
 	ia64_patch_vtop((u64) __start___vtop_patchlist, (u64) __end___vtop_patchlist);
 
 	*cmdline_p = __va(ia64_boot_param->command_line);
@@ -518,6 +578,59 @@ setup_arch (char **cmdline_p)
 	acpi_boot_init();
 #endif
 
+#ifdef CONFIG_XEN
+	if (is_running_on_xen()) {
+		printk(KERN_INFO
+		       "Running on Xen! start_info_pfn=0x%lx nr_pages=%ld "
+		       "flags=0x%x\n",
+		       HYPERVISOR_shared_info->arch.start_info_pfn,
+		       xen_start_info->nr_pages, xen_start_info->flags);
+
+		/*
+		 * If a console= is NOT specified, we assume using the
+		 * xencons console is desired.  By default, this is xvc0
+		 * for both dom0 and domU.
+		 */
+		if (!strstr(*cmdline_p, "console=")) {
+			char *p, *q, name[5] = "xvc";
+			int offset = 0;
+
+#if defined(CONFIG_VGA_CONSOLE)
+			/*
+			 * conswitchp might be set intelligently from the
+			 * PCDP code.  If set to VGA console, use it.
+			 */
+			if (is_initial_xendomain() && conswitchp = &vga_con)
+				strncpy(name, "tty", 3);
+#endif
+
+			p = strstr(*cmdline_p, "xencons=");
+
+			if (p) {
+				p += 8;
+				if (!strncmp(p, "ttyS", 4)) {
+					strncpy(name, p, 4);
+					p += 4;
+					offset = simple_strtol(p, &q, 10);
+					if (p = q)
+						offset = 0;
+				} else if (!strncmp(p, "tty", 3) ||
+					   !strncmp(p, "xvc", 3)) {
+					strncpy(name, p, 3);
+					p += 3;
+					offset = simple_strtol(p, &q, 10);
+					if (p = q)
+						offset = 0;
+				} else if (!strncmp(p, "off", 3))
+					offset = -1;
+			}
+
+			if (offset >= 0)
+				add_preferred_console(name, offset, NULL);
+		}
+	}
+#endif
+
 #ifdef CONFIG_VT
 	if (!conswitchp) {
 # if defined(CONFIG_DUMMY_CONSOLE)
@@ -537,6 +650,14 @@ setup_arch (char **cmdline_p)
 #endif
 
 	/* enable IA-64 Machine Check Abort Handling unless disabled */
+#ifdef CONFIG_XEN
+	if (is_running_on_xen() && !is_initial_xendomain()) {
+		nomca = 1;
+#if !defined(CONFIG_VT) || !defined(CONFIG_DUMMY_CONSOLE)
+		conswitchp = NULL;
+#endif
+	}
+#endif
 	if (!nomca)
 		ia64_mca_init();
 
diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 32ee597..2da0a00 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -642,6 +642,10 @@ void __devinit smp_prepare_boot_cpu(void)
 	cpu_set(smp_processor_id(), cpu_online_map);
 	cpu_set(smp_processor_id(), cpu_callin_map);
 	per_cpu(cpu_state, smp_processor_id()) = CPU_ONLINE;
+#ifdef CONFIG_XEN
+	if (is_running_on_xen())
+		xen_setup_vcpu_info_placement();
+#endif
 }
 
 #ifdef CONFIG_HOTPLUG_CPU
diff --git a/arch/ia64/xen/Makefile b/arch/ia64/xen/Makefile
index c219358..91ffafe 100644
--- a/arch/ia64/xen/Makefile
+++ b/arch/ia64/xen/Makefile
@@ -2,6 +2,10 @@
 # Makefile for Xen components
 #
 
+obj-y := hypercall.o xenivt.o xenentry.o xensetup.o xenpal.o \
+	 hypervisor.o util.o xencomm.o xcom_hcall.o xcom_asm.o
+
+obj-$(CONFIG_IA64_GENERIC) += machvec.o
 obj-$(CONFIG_PARAVIRT_ALT) += paravirt_xen.o privops_asm.o privops_c.o
 obj-$(CONFIG_PARAVIRT_NOP_B_PATCH) += paravirt_xen.o
 obj-$(CONFIG_PARAVIRT_ENTRY) += paravirt_xen.o
-- 
1.5.3

