From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 27 Aug 2003 01:17:11 +0000
Subject: Re: HP_SIM with performance monitoring
MIME-Version: 1
Content-Type: multipart/mixed; boundary="LyciRD1jyfeSSjG0"
Message-Id: <marc-linux-ia64-106194708523465@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106186435806640@msgid-missing>
In-Reply-To: <marc-linux-ia64-106186435806640@msgid-missing>
To: linux-ia64@vger.kernel.org


--LyciRD1jyfeSSjG0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Aug 26, 2003 at 11:16:49AM -0700, Stephane Eranian wrote:
> Yes, something along the lines of your patch would be a clean way of fixing
> the problem. However, I would do something similar to what is in 
> perfmon_generic.h. Simply define the PMDS as counters (PFM_REG_COUNTING). 
> It will not hurt because they actually do not count anything. And create 
> the PMC table as counter (PFM_REG_COUNTING).

Ok attached patch does it like that.

-i
--LyciRD1jyfeSSjG0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="hpsim-pfmon-2.patch"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1291  -> 1.1293 
#	arch/ia64/kernel/perfmon.c	1.56    -> 1.57   
#	               (new)	        -> 1.2     arch/ia64/kernel/perfmon_hpsim.h
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/26	ianw@tartufi.gelato.unsw.edu.au	1.1292
# Update for simulator with perfmon
# --------------------------------------------
# 03/08/27	ianw@tartufi.gelato.unsw.edu.au	1.1293
# Update after changes suggested by Stephane
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
--- a/arch/ia64/kernel/perfmon.c	Wed Aug 27 11:12:53 2003
+++ b/arch/ia64/kernel/perfmon.c	Wed Aug 27 11:12:53 2003
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
+++ b/arch/ia64/kernel/perfmon_hpsim.h	Wed Aug 27 11:12:53 2003
@@ -0,0 +1,73 @@
+/*
+ * This file contains the HP SKI Simulator PMU register description tables
+ * and pmc checker used by perfmon.c.
+ *
+ * Copyright (C) 2002-2003  Hewlett Packard Co
+ *               Stephane Eranian <eranian@hpl.hp.com>
+ * 
+ * Note the simulator does not (currently) implement these registers.
+ * This file is included as a dummy template so the kernel does not
+ * try to initalize registers the simulator can't handle.
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
+/* pmc0  */ { PFM_REG_CONTROL , 0, 0x1UL, -1UL, NULL, NULL, {0UL, 0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc1  */ { PFM_REG_CONTROL , 0, 0x0UL, -1UL, NULL, NULL, {0UL, 0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc2  */ { PFM_REG_CONTROL , 0, 0x0UL, -1UL, NULL, NULL, {0UL, 0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc3  */ { PFM_REG_CONTROL , 0, 0x0UL, -1UL, NULL, NULL, {0UL, 0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc4  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {RDEP(4), 0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc5  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {RDEP(5), 0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc6  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {RDEP(6), 0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc7  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {RDEP(7), 0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc8  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {RDEP(8), 0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc9  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {RDEP(9), 0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc10 */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {RDEP(10), 0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc11 */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {RDEP(11), 0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc12 */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {RDEP(12), 0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc13 */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {RDEP(13), 0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc14 */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {RDEP(14), 0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc15 */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {RDEP(15), 0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+	    { PFM_REG_END     , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}}, /* end marker */
+};
+
+static pfm_reg_desc_t pfm_hpsim_pmd_desc[PMU_MAX_PMDS]={
+/* pmd0  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(0),0UL, 0UL, 0UL}},
+/* pmd1  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(1),0UL, 0UL, 0UL}},
+/* pmd2  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(2),0UL, 0UL, 0UL}},
+/* pmd3  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(3),0UL, 0UL, 0UL}},
+/* pmd4  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(4),0UL, 0UL, 0UL}},
+/* pmd5  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(5),0UL, 0UL, 0UL}},
+/* pmd6  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(6),0UL, 0UL, 0UL}},
+/* pmd7  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(7),0UL, 0UL, 0UL}},
+/* pmd8  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(8),0UL, 0UL, 0UL}},
+/* pmd9  */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(9),0UL, 0UL, 0UL}},
+/* pmd10 */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(10),0UL, 0UL, 0UL}},
+/* pmd11 */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(11),0UL, 0UL, 0UL}},
+/* pmd12 */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(12),0UL, 0UL, 0UL}},
+/* pmd13 */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(13),0UL, 0UL, 0UL}},
+/* pmd14 */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(14),0UL, 0UL, 0UL}},
+/* pmd15 */ { PFM_REG_COUNTING, 0, 0x0UL, -1UL, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {RDEP(15),0UL, 0UL, 0UL}},
+	    { PFM_REG_END     , 0, 0x0UL, -1UL, NULL, NULL, {0,}, {0,}}, /* end marker */
+};
+
+/*
+ * impl_pmcs, impl_pmds are computed at runtime to minimize errors!
+ */
+static pmu_config_t pmu_conf={
+	.pmu_name   = "hpsim",
+	.pmu_family = 0x7, /* Ski emulator reports as Itanium */
+	.enabled    = 0,
+	.ovfl_val   = (1UL << 32) - 1,
+	.num_ibrs   = 0, /* does not use */
+	.num_dbrs   = 0, /* does not use */
+	.pmd_desc   = pfm_hpsim_pmd_desc,
+	.pmc_desc   = pfm_hpsim_pmc_desc
+};
+

--LyciRD1jyfeSSjG0--
