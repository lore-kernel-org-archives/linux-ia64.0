From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 26 Aug 2003 02:18:46 +0000
Subject: HP_SIM with performance monitoring
MIME-Version: 1
Content-Type: multipart/mixed; boundary="J2SCkAp4GZ/dPZZf"
Message-Id: <marc-linux-ia64-106186435806640@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

I noticed that when trying to boot 2.6.0-test4 in the simulator with
perfmon turned on it ended up oopsing with a "General Exception: IA-64
Reserved Register/Field fault" in pfm_init_percpu() when it tried to
zero out the PMD registers.

I have no idea if the simulator implements perfmon support, but
noticed that there are PMC and PMD registers in the register window.
Am I right in saying the simulator has only 8, skipping odd registers,
where mckinley has 15 PMC and 17 PMD registers?

I can think of a number of things to fix it but am not sure which is
correct -- the GENERIC definitions look kind of correct; maybe
CONFIG_PERFMON should be turned off for HP_SIM; or create a dummy
PMC/PMD register definition (attached).  Any enlightenment
appreciated.

-i

--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="hpsim-pfmon.patch"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1291  -> 1.1292 
#	arch/ia64/kernel/perfmon.c	1.56    -> 1.57   
#	               (new)	        -> 1.1     arch/ia64/kernel/perfmon_hpsim.h
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/26	ianw@tartufi.gelato.unsw.edu.au	1.1292
# Update for simulator with perfmon
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
--- a/arch/ia64/kernel/perfmon.c	Tue Aug 26 11:49:40 2003
+++ b/arch/ia64/kernel/perfmon.c	Tue Aug 26 11:49:40 2003
@@ -659,7 +659,9 @@
 static void pfm_lazy_save_regs (struct task_struct *ta);
 #endif
 
-#if   defined(CONFIG_ITANIUM)
+#if   defined(CONFIG_IA64_HP_SIM)
+#include "perfmon_hpsim.h"
+#elif defined(CONFIG_ITANIUM)
 #include "perfmon_itanium.h"
 #elif defined(CONFIG_MCKINLEY)
 #include "perfmon_mckinley.h"
diff -Nru a/arch/ia64/kernel/perfmon_hpsim.h b/arch/ia64/kernel/perfmon_hpsim.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/ia64/kernel/perfmon_hpsim.h	Tue Aug 26 11:49:40 2003
@@ -0,0 +1,67 @@
+/*
+ * This file contains the HP SKI Simulator PMU register description tables
+ * and pmc checker used by perfmon.c.
+ *
+ * Copyright (C) 2002-2003  Hewlett Packard Co
+ *               Stephane Eranian <eranian@hpl.hp.com>
+ */
+
+
+#define RDEP(x)	(1UL<<(x))
+
+#ifndef CONFIG_IA64_HP_SIM
+#error "This file should only be included for the HP Simulator"
+#endif
+
+static pfm_reg_desc_t pfm_hpsim_pmc_desc[PMU_MAX_PMCS]={
+/* pmc0  */ { PFM_REG_NOTIMPL, 0, 0x1UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc1  */ { PFM_REG_NOTIMPL, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc2  */ { PFM_REG_NOTIMPL, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc3  */ { PFM_REG_NOTIMPL, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc4  */ { PFM_REG_NOTIMPL, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc5  */ { PFM_REG_NOTIMPL, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc6  */ { PFM_REG_NOTIMPL, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc7  */ { PFM_REG_NOTIMPL, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc8  */ { PFM_REG_NOTIMPL, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc9  */ { PFM_REG_NOTIMPL, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc10 */ { PFM_REG_NOTIMPL, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc11 */ { PFM_REG_NOTIMPL, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc12 */ { PFM_REG_NOTIMPL, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc13 */ { PFM_REG_NOTIMPL, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc14 */ { PFM_REG_NOTIMPL, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+	    { PFM_REG_END    , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}}, /* end marker */
+};
+
+static pfm_reg_desc_t pfm_hpsim_pmd_desc[PMU_MAX_PMDS]={
+/* pmd0  */ { PFM_REG_NOTIMPL , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}},
+/* pmd1  */ { PFM_REG_NOTIMPL , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}},
+/* pmd2  */ { PFM_REG_NOTIMPL , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}},
+/* pmd3  */ { PFM_REG_NOTIMPL , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}},
+/* pmd4  */ { PFM_REG_NOTIMPL , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}},
+/* pmd5  */ { PFM_REG_NOTIMPL , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}},
+/* pmd6  */ { PFM_REG_NOTIMPL , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}},
+/* pmd7  */ { PFM_REG_NOTIMPL , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}},
+/* pmd8  */ { PFM_REG_NOTIMPL , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}},
+/* pmd9  */ { PFM_REG_NOTIMPL , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}},
+/* pmd10 */ { PFM_REG_NOTIMPL , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}},
+/* pmd11 */ { PFM_REG_NOTIMPL , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}},
+/* pmd12 */ { PFM_REG_NOTIMPL , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}},
+/* pmd13 */ { PFM_REG_NOTIMPL , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}},
+/* pmd14 */ { PFM_REG_NOTIMPL , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}},
+	    { PFM_REG_END     , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}}, /* end marker */
+};
+
+/*
+ * impl_pmcs, impl_pmds are computed at runtime to minimize errors!
+ */
+static pmu_config_t pmu_conf={
+	.pmu_name   = "hpsim",
+	.pmu_family = 0xff, /* any */
+	.enabled    = 0,
+	.ovfl_val   = (1UL << 32) - 1,
+	.num_ibrs   = 0, /* does not use */
+	.num_dbrs   = 0, /* does not use */
+	.pmd_desc   = pfm_hpsim_pmd_desc,
+	.pmc_desc   = pfm_hpsim_pmc_desc
+};
+

--J2SCkAp4GZ/dPZZf--
