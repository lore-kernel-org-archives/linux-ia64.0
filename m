From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 29 Jul 2008 07:14:22 +0000
Subject: Is topology_core_siblings for use by drivers?
Message-Id: <20080729071422.GD28989@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org


allmodconfig currently dies with:

ERROR: "cpu_core_map" [drivers/net/sfc/sfc.ko] undefined!

$ grep -r cpu_core_map include/asm-ia64/
include/asm-ia64/smp.h:extern cpumask_t cpu_core_map[NR_CPUS];
include/asm-ia64/topology.h:#define topology_core_siblings(cpu) (cpu_core_map[cpu])

OK ... it's not exported to modules.  Do other architectures have this
problem?

$ grep topology_core_siblings include/asm-*/topology.h
include/asm-ia64/topology.h:#define topology_core_siblings(cpu) (cpu_core_map[cpu])
include/asm-powerpc/topology.h:#define topology_core_siblings(cpu) (per_cpu(cpu_core_map, cpu))
include/asm-s390/topology.h:#define topology_core_siblings(cpu) (cpu_core_map[cpu])
include/asm-x86/topology.h:#define topology_core_siblings(cpu) (per_cpu(cpu_core_map, cpu))

s390, I guess.  But they don't have PCI device drivers.

If device drivers are supposed to call this, please apply this patch:

----

Export cpu_core_map so modules can call topology_core_siblings()

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>

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
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
