From: Dean Roe <roe@sgi.com>
Date: Tue, 14 Feb 2006 21:01:23 +0000
Subject: [PATCH] fix the size of __sn_cnodeid_to_nasid
Message-Id: <20060214210123.GA15369@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The __sn_cnodeid_to_nasid array was incorrectly sized at MAX_NUMNODES.
On a large system, this array could overflow.  The following patch
corrects this by defining it to MAX_COMPACT_NODES.

Signed-off-by: Dean Roe <roe@sgi.com>


Index: linux-2.6/arch/ia64/sn/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/setup.c
+++ linux-2.6/arch/ia64/sn/kernel/setup.c
@@ -75,7 +75,7 @@
 DEFINE_PER_CPU(struct sn_hub_info_s, __sn_hub_info);
 EXPORT_PER_CPU_SYMBOL(__sn_hub_info);
 
-DEFINE_PER_CPU(short, __sn_cnodeid_to_nasid[MAX_NUMNODES]);
+DEFINE_PER_CPU(short, __sn_cnodeid_to_nasid[MAX_COMPACT_NODES]);
 EXPORT_PER_CPU_SYMBOL(__sn_cnodeid_to_nasid);
 
 DEFINE_PER_CPU(struct nodepda_s *, __sn_nodepda);

Index: linux-2.6/include/asm-ia64/sn/arch.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/arch.h
+++ linux-2.6/include/asm-ia64/sn/arch.h
@@ -70,7 +70,7 @@
  * Compact node ID to nasid mappings kept in the per-cpu data areas of each
  * cpu.
  */
-DECLARE_PER_CPU(short, __sn_cnodeid_to_nasid[MAX_NUMNODES]);
+DECLARE_PER_CPU(short, __sn_cnodeid_to_nasid[MAX_COMPACT_NODES]);
 #define sn_cnodeid_to_nasid	(&__get_cpu_var(__sn_cnodeid_to_nasid[0]))
 
