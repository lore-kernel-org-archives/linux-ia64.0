From: Yinghai Lu <yinghai@kernel.org>
Date: Thu, 04 Apr 2013 23:46:21 +0000
Subject: [PATCH v3 17/22] x86, ACPI, numa, ia64: split SLIT handling out
Message-Id: <1365119186-23487-18-git-send-email-yinghai@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1365119186-23487-1-git-send-email-yinghai@kernel.org>
In-Reply-To: <1365119186-23487-1-git-send-email-yinghai@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Thomas Renninger <trenn@suse.de>, Tang Chen <tangchen@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-acpi@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

We need to handle slit later, as it need to allocate buffer for distance
matrix. Also we do not need SLIT info before init_mem_mapping.

So move SLIT parsing later.

x86_acpi_numa_init become x86_acpi_numa_init_srat/x86_acpi_numa_init_slit.

It should not break ia64 by replacing acpi_numa_init with
acpi_numa_init_srat/acpi_numa_init_slit/acpi_num_arch_fixup.

-v2: Change name to acpi_numa_init_srat/acpi_numa_init_slit according tj.
     remove the reset_numa_distance() in numa_init(), as get we only set
     distance in slit handling.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Cc: Rafael J. Wysocki <rjw@sisk.pl>
Cc: linux-acpi@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/setup.c    |  4 +++-
 arch/x86/include/asm/acpi.h |  3 ++-
 arch/x86/mm/numa.c          | 14 ++++++++++++--
 arch/x86/mm/srat.c          | 11 +++++++----
 drivers/acpi/numa.c         | 13 +++++++------
 include/linux/acpi.h        |  3 ++-
 6 files changed, 33 insertions(+), 15 deletions(-)

diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 2029cc0..6a2efb5 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -558,7 +558,9 @@ setup_arch (char **cmdline_p)
 	acpi_table_init();
 	early_acpi_boot_init();
 # ifdef CONFIG_ACPI_NUMA
-	acpi_numa_init();
+	acpi_numa_init_srat();
+	acpi_numa_init_slit();
+	acpi_numa_arch_fixup();
 #  ifdef CONFIG_ACPI_HOTPLUG_CPU
 	prefill_possible_map();
 #  endif
diff --git a/arch/x86/include/asm/acpi.h b/arch/x86/include/asm/acpi.h
index b31bf97..651db0b 100644
--- a/arch/x86/include/asm/acpi.h
+++ b/arch/x86/include/asm/acpi.h
@@ -178,7 +178,8 @@ static inline void disable_acpi(void) { }
 
 #ifdef CONFIG_ACPI_NUMA
 extern int acpi_numa;
-extern int x86_acpi_numa_init(void);
+int x86_acpi_numa_init_srat(void);
+void x86_acpi_numa_init_slit(void);
 #endif /* CONFIG_ACPI_NUMA */
 
 #define acpi_unlazy_tlb(x)	leave_mm(x)
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 90fd123..182e085 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -598,7 +598,6 @@ static int __init numa_init(int (*init_func)(void))
 
 	nodes_clear(numa_nodes_parsed);
 	memset(&numa_meminfo, 0, sizeof(numa_meminfo));
-	numa_reset_distance();
 
 	ret = init_func();
 	if (ret < 0)
@@ -636,6 +635,10 @@ static int __init dummy_numa_init(void)
 	return 0;
 }
 
+#ifdef CONFIG_ACPI_NUMA
+static bool srat_used __initdata;
+#endif
+
 /**
  * x86_numa_init - Initialize NUMA
  *
@@ -651,8 +654,10 @@ static void __init early_x86_numa_init(void)
 			return;
 #endif
 #ifdef CONFIG_ACPI_NUMA
-		if (!numa_init(x86_acpi_numa_init))
+		if (!numa_init(x86_acpi_numa_init_srat)) {
+			srat_used = true;
 			return;
+		}
 #endif
 #ifdef CONFIG_AMD_NUMA
 		if (!numa_init(amd_numa_init))
@@ -670,6 +675,11 @@ void __init x86_numa_init(void)
 
 	early_x86_numa_init();
 
+#ifdef CONFIG_ACPI_NUMA
+	if (srat_used)
+		x86_acpi_numa_init_slit();
+#endif
+
 	numa_emulation(&numa_meminfo, numa_distance_cnt);
 
 	node_possible_map = numa_nodes_parsed;
diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
index cdd0da9..443f9ef 100644
--- a/arch/x86/mm/srat.c
+++ b/arch/x86/mm/srat.c
@@ -185,14 +185,17 @@ out_err:
 	return -1;
 }
 
-void __init acpi_numa_arch_fixup(void) {}
-
-int __init x86_acpi_numa_init(void)
+int __init x86_acpi_numa_init_srat(void)
 {
 	int ret;
 
-	ret = acpi_numa_init();
+	ret = acpi_numa_init_srat();
 	if (ret < 0)
 		return ret;
 	return srat_disabled() ? -EINVAL : 0;
 }
+
+void __init x86_acpi_numa_init_slit(void)
+{
+	acpi_numa_init_slit();
+}
diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 33e609f..6460db4 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -282,7 +282,7 @@ acpi_table_parse_srat(enum acpi_srat_type id,
 					    handler, max_entries);
 }
 
-int __init acpi_numa_init(void)
+int __init acpi_numa_init_srat(void)
 {
 	int cnt = 0;
 
@@ -303,11 +303,6 @@ int __init acpi_numa_init(void)
 					    NR_NODE_MEMBLKS);
 	}
 
-	/* SLIT: System Locality Information Table */
-	acpi_table_parse(ACPI_SIG_SLIT, acpi_parse_slit);
-
-	acpi_numa_arch_fixup();
-
 	if (cnt < 0)
 		return cnt;
 	else if (!parsed_numa_memblks)
@@ -315,6 +310,12 @@ int __init acpi_numa_init(void)
 	return 0;
 }
 
+void __init acpi_numa_init_slit(void)
+{
+	/* SLIT: System Locality Information Table */
+	acpi_table_parse(ACPI_SIG_SLIT, acpi_parse_slit);
+}
+
 int acpi_get_pxm(acpi_handle h)
 {
 	unsigned long long pxm;
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 4b943e6..4a78235 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -85,7 +85,8 @@ int early_acpi_boot_init(void);
 int acpi_boot_init (void);
 void acpi_boot_table_init (void);
 int acpi_mps_check (void);
-int acpi_numa_init (void);
+int acpi_numa_init_srat(void);
+void acpi_numa_init_slit(void);
 
 int acpi_table_init (void);
 int acpi_table_parse(char *id, acpi_tbl_table_handler handler);
-- 
1.8.1.4

