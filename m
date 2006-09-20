From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 20 Sep 2006 19:53:47 +0000
Subject: [PATCH] export cpu_sibling_map
Message-Id: <20060920195347.GD27323@frankl.hpl.hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="bCsyhTFzCvuiizWE"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--bCsyhTFzCvuiizWE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello Tony,

For Montecito PMU support, I need to determine, in a kernel module, whether
or not threads are enabled. The only reliable way of doing this is to
compute the bit-weight of cpu_sibling_map[]. This symbol is exported on
x86 systems, but not on IA-64 so far. This patch exports the symbol.

Changelog:
	- export cpu_sibling_map[] to kernel modules

signed-off-by: stephane eranian <eranian@hpl.hp.com>

-- 
-Stephane

--bCsyhTFzCvuiizWE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="smp_sibling_map.diff"

diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -139,6 +139,7 @@ EXPORT_SYMBOL(cpu_possible_map);
 
 cpumask_t cpu_core_map[NR_CPUS] __cacheline_aligned;
 cpumask_t cpu_sibling_map[NR_CPUS] __cacheline_aligned;
+EXPORT_SYMBOL(cpu_sibling_map);
 int smp_num_siblings = 1;
 int smp_num_cpucores = 1;
 

--bCsyhTFzCvuiizWE--
