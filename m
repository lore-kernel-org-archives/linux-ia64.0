From: Robin Holt <holt@sgi.com>
Date: Tue, 29 Jul 2008 01:36:50 +0000
Subject: [Patch] fix ia64 build failure when CONFIG_SFC=m
Message-Id: <20080729013650.GH9663@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: bhutchings@solarflare.com, jgarzik@redhat.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, netdev@vger.kernel.org

CONFIG_SFC=m uses topology_core_siblings() which, for ia64, expects
cpu_core_map to be exported.  It is not.  This patch exports the needed
symbol.

Signed-off-by: Robin Holt <holt@sgi.com>

Index: contention_unroll/arch/ia64/kernel/smpboot.c
=================================--- contention_unroll.orig/arch/ia64/kernel/smpboot.c	2008-07-28 18:19:56.000000000 -0500
+++ contention_unroll/arch/ia64/kernel/smpboot.c	2008-07-28 20:25:54.240198328 -0500
@@ -138,6 +138,7 @@ cpumask_t cpu_possible_map = CPU_MASK_NO
 EXPORT_SYMBOL(cpu_possible_map);
 
 cpumask_t cpu_core_map[NR_CPUS] __cacheline_aligned;
+EXPORT_SYMBOL(cpu_core_map);
 DEFINE_PER_CPU_SHARED_ALIGNED(cpumask_t, cpu_sibling_map);
 EXPORT_PER_CPU_SYMBOL(cpu_sibling_map);
 
