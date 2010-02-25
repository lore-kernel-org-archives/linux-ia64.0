From: Alex Chiang <achiang@hp.com>
Date: Thu, 25 Feb 2010 21:09:52 +0000
Subject: [PATCH 1/2] [IA64] only build arch/ia64/kernel/acpi.o when CONFIG_ACPI
Message-Id: <20100225210952.23267.60908.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following commit broke the ia64 sim_defconfig build:
	3b2b84c0b81108a9a869a88bf2beeb5a95d81dd1
	ACPI: processor: driver doesn't need to evaluate _PDC

This is because it added:
	+#include <acpi/processor.h>

To arch/ia64/kernel/acpi.c. Unfortunately, the ia64_simdefconfig does
not turn on CONFIG_ACPI, and we get build errors.

The fix described in $subject seems to be the most sensible way to
untangle the mess.

The other issue is that acpi_get_sysname() is required for all configs,
most of which define CONFIG_ACPI, but are not CONFIG_IA64_GENERIC. Turn
it into an inline to cover the "non generic" ia64 configs; to prevent
a duplicate definition build error, we need to wrap the definition in
acpi.o inside an #ifdef.

Finally, move the pm_idle and pm_power_off exports into process.c (which
is always built), similar to other architectures, and allow the sim
defconfig to link.

Signed-off-by: Alex Chiang <achiang@hp.com>
---

 arch/ia64/include/asm/acpi.h |   25 +++++++++++++++++++++++++
 arch/ia64/kernel/Makefile    |    3 ++-
 arch/ia64/kernel/acpi.c      |   33 +--------------------------------
 arch/ia64/kernel/process.c   |    4 ++++
 4 files changed, 32 insertions(+), 33 deletions(-)

diff --git a/arch/ia64/include/asm/acpi.h b/arch/ia64/include/asm/acpi.h
index e97b255..d3b4830 100644
--- a/arch/ia64/include/asm/acpi.h
+++ b/arch/ia64/include/asm/acpi.h
@@ -99,7 +99,32 @@ ia64_acpi_release_global_lock (unsigned int *lock)
 #define acpi_processor_cstate_check(x) (x) /* no idle limits on IA64 :) */
 static inline void disable_acpi(void) { }
 
+#ifdef CONFIG_IA64_GENERIC
 const char *acpi_get_sysname (void);
+#else
+static inline const char *acpi_get_sysname (void)
+{
+# if defined (CONFIG_IA64_HP_SIM)
+	return "hpsim";
+# elif defined (CONFIG_IA64_HP_ZX1)
+	return "hpzx1";
+# elif defined (CONFIG_IA64_HP_ZX1_SWIOTLB)
+	return "hpzx1_swiotlb";
+# elif defined (CONFIG_IA64_SGI_SN2)
+	return "sn2";
+# elif defined (CONFIG_IA64_SGI_UV)
+	return "uv";
+# elif defined (CONFIG_IA64_DIG)
+	return "dig";
+# elif defined (CONFIG_IA64_XEN_GUEST)
+	return "xen";
+# elif defined(CONFIG_IA64_DIG_VTD)
+	return "dig_vtd";
+# else
+#	error Unknown platform.  Fix acpi.c.
+# endif
+}
+#endif
 int acpi_request_vector (u32 int_type);
 int acpi_gsi_to_irq (u32 gsi, unsigned int *irq);
 
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index e123634..78ad418 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -8,11 +8,12 @@ endif
 
 extra-y	:= head.o init_task.o vmlinux.lds
 
-obj-y := acpi.o entry.o efi.o efi_stub.o gate-data.o fsys.o ia64_ksyms.o irq.o irq_ia64.o	\
+obj-y := entry.o efi.o efi_stub.o gate-data.o fsys.o ia64_ksyms.o irq.o irq_ia64.o	\
 	 irq_lsapic.o ivt.o machvec.o pal.o paravirt_patchlist.o patch.o process.o perfmon.o ptrace.o sal.o		\
 	 salinfo.o setup.o signal.o sys_ia64.o time.o traps.o unaligned.o \
 	 unwind.o mca.o mca_asm.o topology.o dma-mapping.o
 
+obj-$(CONFIG_ACPI)		+= acpi.o
 obj-$(CONFIG_IA64_BRL_EMU)	+= brl_emu.o
 obj-$(CONFIG_IA64_GENERIC)	+= acpi-ext.o
 obj-$(CONFIG_IA64_HP_ZX1)	+= acpi-ext.o
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 40574ae..c16fb03 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -60,11 +60,6 @@
 
 #define PREFIX			"ACPI: "
 
-void (*pm_idle) (void);
-EXPORT_SYMBOL(pm_idle);
-void (*pm_power_off) (void);
-EXPORT_SYMBOL(pm_power_off);
-
 u32 acpi_rsdt_forced;
 unsigned int acpi_cpei_override;
 unsigned int acpi_cpei_phys_cpuid;
@@ -83,12 +78,10 @@ static unsigned long __init acpi_find_rsdp(void)
 		       "v1.0/r0.71 tables no longer supported\n");
 	return rsdp_phys;
 }
-#endif
 
 const char __init *
 acpi_get_sysname(void)
 {
-#ifdef CONFIG_IA64_GENERIC
 	unsigned long rsdp_phys;
 	struct acpi_table_rsdp *rsdp;
 	struct acpi_table_xsdt *xsdt;
@@ -143,30 +136,8 @@ acpi_get_sysname(void)
 #endif
 
 	return "dig";
-#else
-# if defined (CONFIG_IA64_HP_SIM)
-	return "hpsim";
-# elif defined (CONFIG_IA64_HP_ZX1)
-	return "hpzx1";
-# elif defined (CONFIG_IA64_HP_ZX1_SWIOTLB)
-	return "hpzx1_swiotlb";
-# elif defined (CONFIG_IA64_SGI_SN2)
-	return "sn2";
-# elif defined (CONFIG_IA64_SGI_UV)
-	return "uv";
-# elif defined (CONFIG_IA64_DIG)
-	return "dig";
-# elif defined (CONFIG_IA64_XEN_GUEST)
-	return "xen";
-# elif defined(CONFIG_IA64_DIG_VTD)
-	return "dig_vtd";
-# else
-#	error Unknown platform.  Fix acpi.c.
-# endif
-#endif
 }
-
-#ifdef CONFIG_ACPI
+#endif /* CONFIG_IA64_GENERIC */
 
 #define ACPI_MAX_PLATFORM_INTERRUPTS	256
 
@@ -1060,5 +1031,3 @@ void acpi_restore_state_mem(void) {}
  * do_suspend_lowlevel()
  */
 void do_suspend_lowlevel(void) {}
-
-#endif				/* CONFIG_ACPI */
diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index 9bcec99..454a6a4 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -60,6 +60,10 @@ unsigned long idle_halt;
 EXPORT_SYMBOL(idle_halt);
 unsigned long idle_nomwait;
 EXPORT_SYMBOL(idle_nomwait);
+void (*pm_idle) (void);
+EXPORT_SYMBOL(pm_idle);
+void (*pm_power_off) (void);
+EXPORT_SYMBOL(pm_power_off);
 
 void
 ia64_do_show_stack (struct unw_frame_info *info, void *arg)

