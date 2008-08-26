From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 26 Aug 2008 05:58:38 +0000
Subject: [PATCH 26/30] ia64/xen: define xen machine vector for domU.
Message-Id: <1219730322-11687-27-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

define xen machine vector for domU.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
Cc: "Luck, Tony" <tony.luck@intel.com>
---
 arch/ia64/Makefile                  |    2 ++
 arch/ia64/include/asm/machvec.h     |    2 ++
 arch/ia64/include/asm/machvec_xen.h |   22 ++++++++++++++++++++++
 arch/ia64/kernel/acpi.c             |    5 +++++
 arch/ia64/xen/Makefile              |    2 ++
 arch/ia64/xen/machvec.c             |    4 ++++
 6 files changed, 37 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/include/asm/machvec_xen.h
 create mode 100644 arch/ia64/xen/machvec.c

diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 905d25b..4024250 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -56,9 +56,11 @@ core-$(CONFIG_IA64_DIG) 	+= arch/ia64/dig/
 core-$(CONFIG_IA64_GENERIC) 	+= arch/ia64/dig/
 core-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/dig/
 core-$(CONFIG_IA64_HP_ZX1_SWIOTLB) += arch/ia64/dig/
+core-$(CONFIG_IA64_XEN_GUEST)	+= arch/ia64/dig/
 core-$(CONFIG_IA64_SGI_SN2)	+= arch/ia64/sn/
 core-$(CONFIG_IA64_SGI_UV)	+= arch/ia64/uv/
 core-$(CONFIG_KVM) 		+= arch/ia64/kvm/
+core-$(CONFIG_XEN)		+= arch/ia64/xen/
 
 drivers-$(CONFIG_PCI)		+= arch/ia64/pci/
 drivers-$(CONFIG_IA64_HP_SIM)	+= arch/ia64/hp/sim/
diff --git a/arch/ia64/include/asm/machvec.h b/arch/ia64/include/asm/machvec.h
index 2b850cc..de99cb2 100644
--- a/arch/ia64/include/asm/machvec.h
+++ b/arch/ia64/include/asm/machvec.h
@@ -128,6 +128,8 @@ extern void machvec_tlb_migrate_finish (struct mm_struct *);
 #  include <asm/machvec_sn2.h>
 # elif defined (CONFIG_IA64_SGI_UV)
 #  include <asm/machvec_uv.h>
+# elif defined (CONFIG_IA64_XEN_GUEST)
+#  include <asm/machvec_xen.h>
 # elif defined (CONFIG_IA64_GENERIC)
 
 # ifdef MACHVEC_PLATFORM_HEADER
diff --git a/arch/ia64/include/asm/machvec_xen.h b/arch/ia64/include/asm/machvec_xen.h
new file mode 100644
index 0000000..55f9228
--- /dev/null
+++ b/arch/ia64/include/asm/machvec_xen.h
@@ -0,0 +1,22 @@
+#ifndef _ASM_IA64_MACHVEC_XEN_h
+#define _ASM_IA64_MACHVEC_XEN_h
+
+extern ia64_mv_setup_t			dig_setup;
+extern ia64_mv_cpu_init_t		xen_cpu_init;
+extern ia64_mv_irq_init_t		xen_irq_init;
+extern ia64_mv_send_ipi_t		xen_platform_send_ipi;
+
+/*
+ * This stuff has dual use!
+ *
+ * For a generic kernel, the macros are used to initialize the
+ * platform's machvec structure.  When compiling a non-generic kernel,
+ * the macros are used directly.
+ */
+#define platform_name				"xen"
+#define platform_setup				dig_setup
+#define platform_cpu_init			xen_cpu_init
+#define platform_irq_init			xen_irq_init
+#define platform_send_ipi			xen_platform_send_ipi
+
+#endif /* _ASM_IA64_MACHVEC_XEN_h */
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 5d1eb7e..0093649 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -52,6 +52,7 @@
 #include <asm/numa.h>
 #include <asm/sal.h>
 #include <asm/cyclone.h>
+#include <asm/xen/hypervisor.h>
 
 #define BAD_MADT_ENTRY(entry, end) (                                        \
 		(!entry) || (unsigned long)entry + sizeof(*entry) > end ||  \
@@ -121,6 +122,8 @@ acpi_get_sysname(void)
 			return "uv";
 		else
 			return "sn2";
+	} else if (xen_pv_domain() && !strcmp(hdr->oem_id, "XEN")) {
+		return "xen";
 	}
 
 	return "dig";
@@ -137,6 +140,8 @@ acpi_get_sysname(void)
 	return "uv";
 # elif defined (CONFIG_IA64_DIG)
 	return "dig";
+# elif defined (CONFIG_IA64_XEN_GUEST)
+	return "xen";
 # else
 #	error Unknown platform.  Fix acpi.c.
 # endif
diff --git a/arch/ia64/xen/Makefile b/arch/ia64/xen/Makefile
index ed31c76..972d085 100644
--- a/arch/ia64/xen/Makefile
+++ b/arch/ia64/xen/Makefile
@@ -5,6 +5,8 @@
 obj-y := hypercall.o xenivt.o xensetup.o xen_pv_ops.o irq_xen.o \
 	 hypervisor.o xencomm.o xcom_hcall.o grant-table.o time.o
 
+obj-$(CONFIG_IA64_GENERIC) += machvec.o
+
 AFLAGS_xenivt.o += -D__IA64_ASM_PARAVIRTUALIZED_XEN
 
 # xen multi compile
diff --git a/arch/ia64/xen/machvec.c b/arch/ia64/xen/machvec.c
new file mode 100644
index 0000000..4ad588a
--- /dev/null
+++ b/arch/ia64/xen/machvec.c
@@ -0,0 +1,4 @@
+#define MACHVEC_PLATFORM_NAME           xen
+#define MACHVEC_PLATFORM_HEADER         <asm/machvec_xen.h>
+#include <asm/machvec_init.h>
+
-- 
1.6.0.rc0.42.g186458

