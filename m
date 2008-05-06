From: Jack Steiner <steiner@sgi.com>
Date: Tue, 06 May 2008 20:18:57 +0000
Subject: [PATCH 2/2] - IA64 machvec support for UV
Message-Id: <20080506201857.GA4830@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch adds the basic IA64 machvec infrastructure to support
the SGI "UV" platform.

Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 arch/ia64/Kconfig             |   13 +++++
 arch/ia64/Makefile            |    2 
 arch/ia64/kernel/acpi.c       |    7 ++-
 arch/ia64/uv/Makefile         |   12 +++++
 arch/ia64/uv/kernel/Makefile  |   13 +++++
 arch/ia64/uv/kernel/machvec.c |   11 ++++
 arch/ia64/uv/kernel/setup.c   |   98 ++++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/machvec.h    |    2 
 include/asm-ia64/machvec_uv.h |   26 +++++++++++
 9 files changed, 182 insertions(+), 2 deletions(-)

Index: linux/arch/ia64/Kconfig
=================================--- linux.orig/arch/ia64/Kconfig	2008-05-06 13:14:35.381858879 -0500
+++ linux/arch/ia64/Kconfig	2008-05-06 14:07:39.231016055 -0500
@@ -135,6 +135,7 @@ config IA64_GENERIC
 	  HP-zx1/sx1000		For HP systems
 	  HP-zx1/sx1000+swiotlb	For HP systems with (broken) DMA-constrained devices.
 	  SGI-SN2		For SGI Altix systems
+	  SGI-UV		For SGI UV systems
 	  Ski-simulator		For the HP simulator <http://www.hpl.hp.com/research/linux/ski/>
 
 	  If you don't know what to do, choose "generic".
@@ -170,6 +171,18 @@ config IA64_SGI_SN2
 	  to select this option.  If in doubt, select ia64 generic support
 	  instead.
 
+config IA64_SGI_UV`
+	bool "SGI-UV`"
+	select NUMA
+	select ACPI_NUMA
+	select SWIOTLB
+	help
+	  Selecting this option will optimize the kernel for use on UV based
+	  systems, but the resulting kernel binary will not run on other
+	  types of ia64 systems.  If you have an SGI UV system, it's safe
+	  to select this option.  If in doubt, select ia64 generic support
+	  instead.
+
 config IA64_HP_SIM
 	bool "Ski-simulator"
 	select SWIOTLB
Index: linux/arch/ia64/kernel/acpi.c
=================================--- linux.orig/arch/ia64/kernel/acpi.c	2008-05-06 13:14:35.401861327 -0500
+++ linux/arch/ia64/kernel/acpi.c	2008-05-06 14:07:39.263019943 -0500
@@ -117,7 +117,10 @@ acpi_get_sysname(void)
 	if (!strcmp(hdr->oem_id, "HP")) {
 		return "hpzx1";
 	} else if (!strcmp(hdr->oem_id, "SGI")) {
-		return "sn2";
+		if (!strcmp(hdr->oem_table_id + 4, "UV"))
+			return "uv";
+		else
+			return "sn2";
 	}
 
 	return "dig";
@@ -130,6 +133,8 @@ acpi_get_sysname(void)
 	return "hpzx1_swiotlb";
 # elif defined (CONFIG_IA64_SGI_SN2)
 	return "sn2";
+# elif defined (CONFIG_IA64_SGI_UV)
+	return "uv";
 # elif defined (CONFIG_IA64_DIG)
 	return "dig";
 # else
Index: linux/arch/ia64/uv/Makefile
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/arch/ia64/uv/Makefile	2008-05-06 14:07:39.287022859 -0500
@@ -0,0 +1,12 @@
+# arch/ia64/uv/Makefile
+#
+# This file is subject to the terms and conditions of the GNU General Public
+# License.  See the file "COPYING" in the main directory of this archive
+# for more details.
+#
+# Copyright (C) 2008 Silicon Graphics, Inc.  All Rights Reserved.
+#
+# Makefile for the sn uv subplatform
+#
+
+obj-y += kernel/
Index: linux/arch/ia64/uv/kernel/Makefile
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/arch/ia64/uv/kernel/Makefile	2008-05-06 14:07:39.311025775 -0500
@@ -0,0 +1,13 @@
+# arch/ia64/uv/kernel/Makefile
+#
+# This file is subject to the terms and conditions of the GNU General Public
+# License.  See the file "COPYING" in the main directory of this archive
+# for more details.
+#
+# Copyright (C) 2008 Silicon Graphics, Inc.  All Rights Reserved.
+#
+
+EXTRA_CFLAGS += -Iarch/ia64/sn/include
+
+obj-y				+= setup.o
+obj-$(CONFIG_IA64_GENERIC)      += machvec.o
Index: linux/arch/ia64/uv/kernel/machvec.c
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/arch/ia64/uv/kernel/machvec.c	2008-05-06 14:07:39.339029176 -0500
@@ -0,0 +1,11 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2008 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+#define MACHVEC_PLATFORM_NAME	uv
+#define MACHVEC_PLATFORM_HEADER	<asm/machvec_uv.h>
+#include <asm/machvec_init.h>
Index: linux/arch/ia64/uv/kernel/setup.c
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/arch/ia64/uv/kernel/setup.c	2008-05-06 14:07:39.363032092 -0500
@@ -0,0 +1,98 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * SGI UV Core Functions
+ *
+ * Copyright (C) 2008 Silicon Graphics, Inc. All rights reserved.
+ */
+
+#include <linux/module.h>
+#include <linux/percpu.h>
+#include <asm/sn/simulator.h>
+#include <asm/uv/uv_mmrs.h>
+#include <asm/uv/uv_hub.h>
+
+DEFINE_PER_CPU(struct uv_hub_info_s, __uv_hub_info);
+EXPORT_PER_CPU_SYMBOL_GPL(__uv_hub_info);
+
+
+struct redir_addr {
+	unsigned long redirect;
+	unsigned long alias;
+};
+
+#define DEST_SHIFT UVH_RH_GAM_ALIAS210_REDIRECT_CONFIG_0_MMR_DEST_BASE_SHFT
+
+static __initdata struct redir_addr redir_addrs[] = {
+	{UVH_RH_GAM_ALIAS210_REDIRECT_CONFIG_0_MMR, UVH_SI_ALIAS0_OVERLAY_CONFIG},
+	{UVH_RH_GAM_ALIAS210_REDIRECT_CONFIG_1_MMR, UVH_SI_ALIAS1_OVERLAY_CONFIG},
+	{UVH_RH_GAM_ALIAS210_REDIRECT_CONFIG_2_MMR, UVH_SI_ALIAS2_OVERLAY_CONFIG},
+};
+
+static __init void get_lowmem_redirect(unsigned long *base, unsigned long *size)
+{
+	union uvh_si_alias0_overlay_config_u alias;
+	union uvh_rh_gam_alias210_redirect_config_2_mmr_u redirect;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(redir_addrs); i++) {
+		alias.v = uv_read_local_mmr(redir_addrs[i].alias);
+		if (alias.s.base = 0) {
+			*size = (1UL << alias.s.m_alias);
+			redirect.v = uv_read_local_mmr(redir_addrs[i].redirect);
+			*base = (unsigned long)redirect.s.dest_base << DEST_SHIFT;
+			return;
+		}
+	}
+	BUG();
+}
+
+void __init uv_setup(char **cmdline_p)
+{
+	union uvh_si_addr_map_config_u m_n_config;
+	union uvh_node_id_u node_id;
+	unsigned long gnode_upper;
+	int nid, cpu, m_val, n_val;
+	unsigned long mmr_base, lowmem_redir_base, lowmem_redir_size;
+
+	if (IS_MEDUSA()) {
+		lowmem_redir_base = 0;
+		lowmem_redir_size = 0;
+		node_id.v = 0;
+		m_n_config.s.m_skt = 37;
+		m_n_config.s.n_skt = 0;
+		mmr_base = 0;
+	} else {
+		get_lowmem_redirect(&lowmem_redir_base, &lowmem_redir_size);
+		node_id.v = uv_read_local_mmr(UVH_NODE_ID);
+		m_n_config.v = uv_read_local_mmr(UVH_SI_ADDR_MAP_CONFIG);
+		mmr_base +			uv_read_local_mmr(UVH_RH_GAM_MMR_OVERLAY_CONFIG_MMR) &
+				~UV_MMR_ENABLE;
+	}
+
+	m_val = m_n_config.s.m_skt;
+	n_val = m_n_config.s.n_skt;
+	printk(KERN_DEBUG "UV: global MMR base 0x%lx\n", mmr_base);
+
+	gnode_upper = (((unsigned long)node_id.s.node_id) &
+		       ~((1 << n_val) - 1)) << m_val;
+
+	for_each_present_cpu(cpu) {
+		nid = cpu_to_node(cpu);
+		uv_cpu_hub_info(cpu)->lowmem_remap_base = lowmem_redir_base;
+		uv_cpu_hub_info(cpu)->lowmem_remap_top +			lowmem_redir_base + lowmem_redir_size;
+		uv_cpu_hub_info(cpu)->m_val = m_val;
+		uv_cpu_hub_info(cpu)->n_val = m_val;
+		uv_cpu_hub_info(cpu)->pnode_mask = (1 << n_val) -1;
+		uv_cpu_hub_info(cpu)->gpa_mask = (1 << (m_val + n_val)) - 1;
+		uv_cpu_hub_info(cpu)->gnode_upper = gnode_upper;
+		uv_cpu_hub_info(cpu)->global_mmr_base = mmr_base;
+		uv_cpu_hub_info(cpu)->coherency_domain_number = 0;/* ZZZ */
+		printk(KERN_DEBUG "UV cpu %d, nid %d\n", cpu, nid);
+	}
+}
+
Index: linux/include/asm-ia64/machvec.h
=================================--- linux.orig/include/asm-ia64/machvec.h	2008-05-06 13:14:40.534489485 -0500
+++ linux/include/asm-ia64/machvec.h	2008-05-06 14:07:39.435040840 -0500
@@ -126,6 +126,8 @@ extern void machvec_tlb_migrate_finish (
 #  include <asm/machvec_hpzx1_swiotlb.h>
 # elif defined (CONFIG_IA64_SGI_SN2)
 #  include <asm/machvec_sn2.h>
+# elif defined (CONFIG_IA64_SGI_UV)
+#  include <asm/machvec_uv.h>
 # elif defined (CONFIG_IA64_GENERIC)
 
 # ifdef MACHVEC_PLATFORM_HEADER
Index: linux/include/asm-ia64/machvec_uv.h
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/include/asm-ia64/machvec_uv.h	2008-05-06 14:07:39.459043755 -0500
@@ -0,0 +1,26 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * SGI UV Core Functions
+ *
+ * Copyright (C) 2008 Silicon Graphics, Inc. All rights reserved.
+ */
+
+#ifndef _ASM_IA64_MACHVEC_UV_H
+#define _ASM_IA64_MACHVEC_UV_H
+
+extern ia64_mv_setup_t uv_setup;
+
+/*
+ * This stuff has dual use!
+ *
+ * For a generic kernel, the macros are used to initialize the
+ * platform's machvec structure.  When compiling a non-generic kernel,
+ * the macros are used directly.
+ */
+#define platform_name			"uv"
+#define platform_setup			uv_setup
+
+#endif /* _ASM_IA64_MACHVEC_UV_H */
Index: linux/arch/ia64/Makefile
=================================--- linux.orig/arch/ia64/Makefile	2008-05-06 13:14:35.385859368 -0500
+++ linux/arch/ia64/Makefile	2008-05-06 14:07:39.483046671 -0500
@@ -63,7 +63,7 @@ drivers-$(CONFIG_PCI)		+= arch/ia64/pci/
 drivers-$(CONFIG_IA64_HP_SIM)	+= arch/ia64/hp/sim/
 drivers-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/
 drivers-$(CONFIG_IA64_HP_ZX1_SWIOTLB) += arch/ia64/hp/common/ arch/ia64/hp/zx1/
-drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ arch/ia64/hp/sim/ arch/ia64/sn/
+drivers-$(CONFIG_IA64_GENERIC)	+= arch/ia64/hp/common/ arch/ia64/hp/zx1/ arch/ia64/hp/sim/ arch/ia64/sn/ arch/ia64/uv/
 drivers-$(CONFIG_OPROFILE)	+= arch/ia64/oprofile/
 
 boot := arch/ia64/hp/sim/boot
