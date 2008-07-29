From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 29 Jul 2008 11:12:26 +0000
Subject: [PATCH] ia64: export cpu_core_map
Message-Id: <20080729111225.GA10471@solarflare.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

cpu_core_map is referenced by the topology_core_siblings() macro, which is
now used by the sfc driver.  Matthew Wilcox reported that the driver failed
to link because that symbol is not exported.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
I have not yet tested this as we have limited ia64 kit here.  Matthew,
please could you check that this builds at least?

Ben.
---
diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 03f1a99..6cb0927 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -138,6 +138,7 @@ cpumask_t cpu_possible_map = CPU_MASK_NONE;
 EXPORT_SYMBOL(cpu_possible_map);
 
 cpumask_t cpu_core_map[NR_CPUS] __cacheline_aligned;
+EXPORT_SYMBOL(cpu_core_map);
 DEFINE_PER_CPU_SHARED_ALIGNED(cpumask_t, cpu_sibling_map);
 EXPORT_PER_CPU_SYMBOL(cpu_sibling_map);
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
 ot speaking for my employer; that's the marketing department's job.
