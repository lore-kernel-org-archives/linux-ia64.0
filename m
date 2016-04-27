From: David Daney <ddaney.cavm@gmail.com>
Date: Wed, 27 Apr 2016 18:07:06 +0000
Subject: [PATCH v6 04/14] acpi, numa: Move acpi_numa_arch_fixup() to ia64 only
Message-Id: <1461780436-27182-5-git-send-email-ddaney.cavm@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461780436-27182-1-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1461780436-27182-1-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org
Cc: Robert Richter <rrichter@cavium.com>, linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>

From: Robert Richter <rrichter@cavium.com>

Since acpi_numa_arch_fixup() is only used in arch ia64, move it there
to make a generic interface easier. This avoids empty function stubs
or some complex kconfig options for x86 and arm64.

Signed-off-by: Robert Richter <rrichter@cavium.com>
Reviewed-by: Hanjun Guo <hanjun.guo@linaro.org>
Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/ia64/include/asm/acpi.h | 3 +++
 arch/ia64/kernel/acpi.c      | 2 +-
 arch/ia64/kernel/setup.c     | 1 +
 arch/x86/mm/srat.c           | 2 --
 drivers/acpi/numa.c          | 2 --
 include/linux/acpi.h         | 1 -
 6 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/include/asm/acpi.h b/arch/ia64/include/asm/acpi.h
index aa0fdf1..a3d0211 100644
--- a/arch/ia64/include/asm/acpi.h
+++ b/arch/ia64/include/asm/acpi.h
@@ -140,6 +140,9 @@ static inline void per_cpu_scan_finalize(int min_cpus, int reserve_cpus)
 		}
 	}
 }
+
+extern void acpi_numa_fixup(void);
+
 #endif /* CONFIG_ACPI_NUMA */
 
 #endif /*__KERNEL__*/
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index b1698bc..92b7bc9 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -524,7 +524,7 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 	return 0;
 }
 
-void __init acpi_numa_arch_fixup(void)
+void __init acpi_numa_fixup(void)
 {
 	int i, j, node_from, node_to;
 
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 2029a38..afddb3e 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -552,6 +552,7 @@ setup_arch (char **cmdline_p)
 	early_acpi_boot_init();
 # ifdef CONFIG_ACPI_NUMA
 	acpi_numa_init();
+	acpi_numa_fixup();
 #  ifdef CONFIG_ACPI_HOTPLUG_CPU
 	prefill_possible_map();
 #  endif
diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
index b5f8218..90b6ed9 100644
--- a/arch/x86/mm/srat.c
+++ b/arch/x86/mm/srat.c
@@ -212,8 +212,6 @@ out_err:
 	return -1;
 }
 
-void __init acpi_numa_arch_fixup(void) {}
-
 int __init x86_acpi_numa_init(void)
 {
 	int ret;
diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 2de6068..f41f06b 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -316,8 +316,6 @@ int __init acpi_numa_init(void)
 	/* SLIT: System Locality Information Table */
 	acpi_table_parse(ACPI_SIG_SLIT, acpi_parse_slit);
 
-	acpi_numa_arch_fixup();
-
 	if (cnt < 0)
 		return cnt;
 	else if (!parsed_numa_memblks)
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 06ed7e5..ab6fd96 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -244,7 +244,6 @@ void acpi_numa_slit_init (struct acpi_table_slit *slit);
 void acpi_numa_processor_affinity_init (struct acpi_srat_cpu_affinity *pa);
 void acpi_numa_x2apic_affinity_init(struct acpi_srat_x2apic_cpu_affinity *pa);
 int acpi_numa_memory_affinity_init (struct acpi_srat_mem_affinity *ma);
-void acpi_numa_arch_fixup(void);
 
 #ifndef PHYS_CPUID_INVALID
 typedef u32 phys_cpuid_t;
-- 
1.7.11.7

