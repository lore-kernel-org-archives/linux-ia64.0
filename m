From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 27 Jun 2008 22:30:20 +0000
Subject: [PATCH] Bugfix for system with 32 cpus
Message-Id: <57C9024A16AD2D4C97DC78E552063EA306382EAB@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

commit 180f2319663d6aece02fc0284a02944ad2cc7c98
Author: Tony Luck <tony.luck@intel.com>
Date:   Fri Jun 27 14:04:21 2008 -0700

    [IA64] Bugfix for system with 32 cpus

    On a system where there are no hot pluggable cpus "additional_cpus"
    is still set to -1 at the point where we call per_cpu_scan_finalize().
    If we didn't find an SRAT table and so pick the default "32" for the
    number of cpus, when we get to:
        high_cpu = min(high_cpu + reserve_cpus, NR_CPUS);
    we will end up initializing for just 31 cpus ... and so we will
    die horribly when bringing up cpu#32.

    Problem introduced by: 2c6e6db41f01b6b4eb98809350827c9678996698
    "Minimize per_cpu reservations."

    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 4ae15c8..632cda8 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -547,7 +547,8 @@ setup_arch (char **cmdline_p)
 # ifdef CONFIG_ACPI_NUMA
        acpi_numa_init();
        per_cpu_scan_finalize((cpus_weight(early_cpu_possible_map) = 0 ?
-               32 : cpus_weight(early_cpu_possible_map)), additional_cpus);
+               32 : cpus_weight(early_cpu_possible_map)),
+               additional_cpus > 0 ? additional_cpus : 0);
 # endif
 #else
 # ifdef CONFIG_SMP


