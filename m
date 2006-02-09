From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 09 Feb 2006 00:36:41 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200602090036.k190afeG012795@agluck-lia64.sc.intel.com>
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

Thanks!

-Tony

 arch/ia64/kernel/efi.c              |   16 +++-----------
 arch/ia64/kernel/head.S             |    1 
 arch/ia64/kernel/setup.c            |    4 +++
 arch/ia64/kernel/time.c             |   27 ++++++++++++++++++++++++
 arch/ia64/sn/kernel/mca.c           |    5 ++--
 arch/ia64/sn/kernel/setup.c         |   40 ++++++++++++++++++++++++------------
 arch/ia64/sn/kernel/sn2/sn_hwperf.c |    5 +++-
 7 files changed, 70 insertions(+), 28 deletions(-)

Jes Sorensen:
      [IA64] prevent sn2 specific code to be run in generic kernels

Tony Luck:
      [IA64] Fix CONFIG_PRINTK_TIME

Zou Nan hai:
      [IA64] Fix a possible buffer overflow in efi.c
      [IA64] Fix wrong use of memparse in efi.c

diff-tree f478af9dc58c01880832a321c3eea7703772c420 (from d6e56a2a088935f3c1feee5ff5a06c67f2ec6002)
Author: Jes Sorensen <jes@sgi.com>
Date:   Wed Feb 8 10:19:28 2006 -0500

    [IA64] prevent sn2 specific code to be run in generic kernels
    
    Prevent SN2 specific code to be executed on non SN2 platforms when
    running a generic kernel.
    
    Signed-off-by: Jes Sorensen <jes@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/mca.c b/arch/ia64/sn/kernel/mca.c
index 9ab684d..3db62f2 100644
--- a/arch/ia64/sn/kernel/mca.c
+++ b/arch/ia64/sn/kernel/mca.c
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2004 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2000-2006 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 #include <linux/types.h>
@@ -137,7 +137,8 @@ int sn_salinfo_platform_oemdata(const u8
 
 static int __init sn_salinfo_init(void)
 {
-	salinfo_platform_oemdata = &sn_salinfo_platform_oemdata;
+	if (ia64_platform_is("sn2"))
+		salinfo_platform_oemdata = &sn_salinfo_platform_oemdata;
 	return 0;
 }
 
diff --git a/arch/ia64/sn/kernel/sn2/sn_hwperf.c b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
index 19b54fb..70db21f 100644
--- a/arch/ia64/sn/kernel/sn2/sn_hwperf.c
+++ b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2004-2005 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Silicon Graphics, Inc. All rights reserved.
  *
  * SGI Altix topology and hardware performance monitoring API.
  * Mark Goodwin <markgw@sgi.com>. 
@@ -973,6 +973,9 @@ static int __devinit sn_hwperf_misc_regi
 {
 	int e;
 
+	if (!ia64_platform_is("sn2"))
+		return 0;
+
 	sn_hwperf_init();
 
 	/*

diff-tree d6e56a2a088935f3c1feee5ff5a06c67f2ec6002 (from 9d78f43d1fd3e028bfd37510ce847d0896f71f78)
Author: Tony Luck <tony.luck@intel.com>
Date:   Tue Feb 7 15:25:57 2006 -0800

    [IA64] Fix CONFIG_PRINTK_TIME
    
    There were two problems with enabling the PRINTK_TIME config
    option:
    1) The first calls to printk() occur before per-cpu data virtual
    address is pinned into the TLB, so sched_clock() can fault.
    2) sched_clock() is based on ar.itc, which may not be synchronized
    across cpus.
    
    Ken Chen started this patch, Tony Luck tinkered with it, and Jes
    Sorensen perfected it.
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index fbc7ea3..f1778a8 100644
--- a/arch/ia64/kernel/head.S
+++ b/arch/ia64/kernel/head.S
@@ -352,6 +352,7 @@ start_ap:
 	mov ar.rsc=0		// place RSE in enforced lazy mode
 	;;
 	loadrs			// clear the dirty partition
+	mov IA64_KR(PER_CPU_DATA)=r0	// clear physical per-CPU base
 	;;
 	mov ar.bspstore=r2	// establish the new RSE stack
 	;;
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index c076657..35f7835 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -71,6 +71,8 @@ unsigned long __per_cpu_offset[NR_CPUS];
 EXPORT_SYMBOL(__per_cpu_offset);
 #endif
 
+extern void ia64_setup_printk_clock(void);
+
 DEFINE_PER_CPU(struct cpuinfo_ia64, cpu_info);
 DEFINE_PER_CPU(unsigned long, local_per_cpu_offset);
 DEFINE_PER_CPU(unsigned long, ia64_phys_stacked_size_p8);
@@ -445,6 +447,8 @@ setup_arch (char **cmdline_p)
 	/* process SAL system table: */
 	ia64_sal_init(efi.sal_systab);
 
+	ia64_setup_printk_clock();
+
 #ifdef CONFIG_SMP
 	cpu_physical_id(0) = hard_smp_processor_id();
 
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 028a2b9..a094ec4 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -278,3 +278,30 @@ udelay (unsigned long usecs)
 	}
 }
 EXPORT_SYMBOL(udelay);
+
+static unsigned long long ia64_itc_printk_clock(void)
+{
+	if (ia64_get_kr(IA64_KR_PER_CPU_DATA))
+		return sched_clock();
+	return 0;
+}
+
+static unsigned long long ia64_default_printk_clock(void)
+{
+	return (unsigned long long)(jiffies_64 - INITIAL_JIFFIES) *
+		(1000000000/HZ);
+}
+
+unsigned long long (*ia64_printk_clock)(void) = &ia64_default_printk_clock;
+
+unsigned long long printk_clock(void)
+{
+	return ia64_printk_clock();
+}
+
+void __init
+ia64_setup_printk_clock(void)
+{
+	if (!(sal_platform_features & IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT))
+		ia64_printk_clock = ia64_itc_printk_clock;
+}
diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index ee36bff..6ea5b8a 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -67,6 +67,7 @@ extern unsigned long last_time_offset;
 extern void (*ia64_mark_idle) (int);
 extern void snidle(int);
 extern unsigned char acpi_kbd_controller_present;
+extern unsigned long long (*ia64_printk_clock)(void);
 
 unsigned long sn_rtc_cycles_per_second;
 EXPORT_SYMBOL(sn_rtc_cycles_per_second);
@@ -372,6 +373,16 @@ sn_scan_pcdp(void)
 	}
 }
 
+static unsigned long sn2_rtc_initial;
+
+static unsigned long long ia64_sn2_printk_clock(void)
+{
+	unsigned long rtc_now = rtc_time();
+
+	return (rtc_now - sn2_rtc_initial) *
+		(1000000000 / sn_rtc_cycles_per_second);
+}
+
 /**
  * sn_setup - SN platform setup routine
  * @cmdline_p: kernel command line
@@ -386,6 +397,7 @@ void __init sn_setup(char **cmdline_p)
 	u32 version = sn_sal_rev();
 	extern void sn_cpu_init(void);
 
+	sn2_rtc_initial = rtc_time();
 	ia64_sn_plat_set_error_handling_features();	// obsolete
 	ia64_sn_set_os_feature(OSF_MCA_SLV_TO_OS_INIT_SLV);
 	ia64_sn_set_os_feature(OSF_FEAT_LOG_SBES);
@@ -437,19 +449,6 @@ void __init sn_setup(char **cmdline_p)
 	 */
 	build_cnode_tables();
 
-	/*
-	 * Old PROMs do not provide an ACPI FADT. Disable legacy keyboard
-	 * support here so we don't have to listen to failed keyboard probe
-	 * messages.
-	 */
-	if (version <= 0x0209 && acpi_kbd_controller_present) {
-		printk(KERN_INFO "Disabling legacy keyboard support as prom "
-		       "is too old and doesn't provide FADT\n");
-		acpi_kbd_controller_present = 0;
-	}
-
-	printk("SGI SAL version %x.%02x\n", version >> 8, version & 0x00FF);
-
 	status  	    ia64_sal_freq_base(SAL_FREQ_BASE_REALTIME_CLOCK, &ticks_per_sec,
 			       &drift);
@@ -463,6 +462,21 @@ void __init sn_setup(char **cmdline_p)
 
 	platform_intr_list[ACPI_INTERRUPT_CPEI] = IA64_CPE_VECTOR;
 
+	ia64_printk_clock = ia64_sn2_printk_clock;
+
+	/*
+	 * Old PROMs do not provide an ACPI FADT. Disable legacy keyboard
+	 * support here so we don't have to listen to failed keyboard probe
+	 * messages.
+	 */
+	if (version <= 0x0209 && acpi_kbd_controller_present) {
+		printk(KERN_INFO "Disabling legacy keyboard support as prom "
+		       "is too old and doesn't provide FADT\n");
+		acpi_kbd_controller_present = 0;
+	}
+
+	printk("SGI SAL version %x.%02x\n", version >> 8, version & 0x00FF);
+
 	/*
 	 * we set the default root device to /dev/hda
 	 * to make simulation easy

diff-tree 9d78f43d1fd3e028bfd37510ce847d0896f71f78 (from ecdd5dabd33d67066d476467e447cdcadab90550)
Author: Zou Nan hai <nanhai.zou@intel.com>
Date:   Tue Feb 7 11:35:46 2006 +0800

    [IA64] Fix wrong use of memparse in efi.c
    
    The check of (end != cp) after memparse in efi.c looks wrong to me.
    The result is that we can't use mem= and max_addr= kernel parameter at
    the same time.
    
    The following patch removed the check just like other arches do.
    
    Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index d51c2f2..9990320 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -410,24 +410,16 @@ efi_init (void)
 	efi_config_table_t *config_tables;
 	efi_char16_t *c16;
 	u64 efi_desc_size;
-	char *cp, *end, vendor[100] = "unknown";
+	char *cp, vendor[100] = "unknown";
 	extern char saved_command_line[];
 	int i;
 
 	/* it's too early to be able to use the standard kernel command line support... */
 	for (cp = saved_command_line; *cp; ) {
 		if (memcmp(cp, "mem=", 4) = 0) {
-			cp += 4;
-			mem_limit = memparse(cp, &end);
-			if (end != cp)
-				break;
-			cp = end;
+			mem_limit = memparse(cp + 4, &cp);
 		} else if (memcmp(cp, "max_addr=", 9) = 0) {
-			cp += 9;
-			max_addr = GRANULEROUNDDOWN(memparse(cp, &end));
-			if (end != cp)
-				break;
-			cp = end;
+			max_addr = GRANULEROUNDDOWN(memparse(cp + 9, &cp));
 		} else {
 			while (*cp != ' ' && *cp)
 				++cp;

diff-tree ecdd5dabd33d67066d476467e447cdcadab90550 (from d43da75fd6be4197c280903e1553eafcc39218e2)
Author: Zou Nan hai <nanhai.zou@intel.com>
Date:   Tue Feb 7 11:25:55 2006 +0800

    [IA64] Fix a possible buffer overflow in efi.c
    
    Make sure to save space for the trailing '\0'.
    
    Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index c485a3b..d51c2f2 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -458,7 +458,7 @@ efi_init (void)
 	/* Show what we know for posterity */
 	c16 = __va(efi.systab->fw_vendor);
 	if (c16) {
-		for (i = 0;i < (int) sizeof(vendor) && *c16; ++i)
+		for (i = 0;i < (int) sizeof(vendor) - 1 && *c16; ++i)
 			vendor[i] = *c16++;
 		vendor[i] = '\0';
 	}
