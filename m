From: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
Date: Thu, 28 Oct 2004 09:29:36 +0000
Subject: Re: [PATCH] top level scheduler domain for ia64
Message-Id: <20041028.182936.68047199.t-kochi@bq.jp.nec.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="--Next_Part(Thu_Oct_28_18:29:36_2004_590)--"
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
To: linux-ia64@vger.kernel.org

----Next_Part(Thu_Oct_28_18:29:36_2004_590)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi Jesse,

From: Jesse Barnes <jbarnes@engr.sgi.com>
Subject: [PATCH] top level scheduler domain for ia64
Date: Tue, 19 Oct 2004 14:27:27 -0700

> Some have noticed that the overlapping sched domains code doesn't quite work 
> as intended (it results in disjoint domains on some machines), and that a top
> level, machine spanning domain is needed.  This patch from John Hawkes adds 
> it to the ia64 code.  This allows processes to run on all CPUs in large 
> systems, though balancing is limited.  It should go to Linus soon now 
> otherwise large systems will only have ~16p (depending on topology) usable by 
> the scheduler.  I sanity checked it on a small system after rediffing John's 
> original, and he's done some testing on very large systems.

Our 32way machine still isn't configured well with the overwrapping
domain partitioning.  CPUs 0-15 belongs to domain (0 1 2 3 4 5 6)
and CPUs 16-31 belongs to domain (0 1 4 5 6 7), which is assymmetric
and at least does not reflect the real connection.

dmesg of the machine is attached.

The following patch makes the ia64 domain partitioning (maybe Altix
specific ;) optional and makes the magic number (6) configurable.

What do you think of this?

Signed-off-by: Takayoshi Kochi <t-kochi@bq.jp.nec.com>

Index: 269-bk/include/asm-ia64/processor.h
===================================================================
--- 269-bk/include/asm-ia64/processor.h	(revision 48)
+++ 269-bk/include/asm-ia64/processor.h	(working copy)
@@ -20,8 +20,10 @@
 #include <asm/ptrace.h>
 #include <asm/ustack.h>
 
+#ifdef CONFIG_IA64_SCHED_SPAN
 /* Our arch specific arch_init_sched_domain is in arch/ia64/kernel/domain.c */
 #define ARCH_HAS_SCHED_DOMAIN
+#endif
 
 #define IA64_NUM_DBG_REGS	8
 /*
Index: 269-bk/arch/ia64/Kconfig
===================================================================
--- 269-bk/arch/ia64/Kconfig	(revision 48)
+++ 269-bk/arch/ia64/Kconfig	(working copy)
@@ -188,6 +188,24 @@
 	  or have huge holes in the physical address space for other reasons.
 	  See <file:Documentation/vm/numa> for more.
 
+config IA64_SCHED_SPAN
+	bool "Bounded spanning of scheduling domains for large NUMA"
+	depends on NUMA
+	default y if IA64_SGI_SN2
+	help
+	  Say Y to support bounded spanning of scheduling domains for large
+	  NUMA systems, which will bound the number of nodes to span
+	  for a top-level scheduling domain.  If not set, the top-level
+	  domain spans over all nodes.
+
+config IA64_SD_NODES_PER_DOMAIN
+	int "Nodes to span"
+	depends on IA64_SCHED_SPAN
+	default "6"
+	help
+	  This is the number of nodes to span for a top-level scheduling
+	  domain.
+
 config IA64_CYCLONE
 	bool "Cyclone (EXA) Time Source support"
 	help
Index: 269-bk/arch/ia64/kernel/domain.c
===================================================================
--- 269-bk/arch/ia64/kernel/domain.c	(revision 49)
+++ 269-bk/arch/ia64/kernel/domain.c	(working copy)
@@ -12,8 +12,6 @@
 #include <linux/init.h>
 #include <linux/topology.h>
 
-#define SD_NODES_PER_DOMAIN 6
-
 #ifdef CONFIG_NUMA
 /**
  * find_next_best_node - find the next node to include in a sched_domain
@@ -77,7 +75,7 @@
 	cpus_or(span, span, nodemask);
 	set_bit(node, used_nodes);
 
-	for (i = 1; i < SD_NODES_PER_DOMAIN; i++) {
+	for (i = 1; i < CONFIG_IA64_SD_NODES_PER_DOMAIN; i++) {
 		int next_node = find_next_best_node(node, used_nodes);
 		nodemask = node_to_cpumask(next_node);
 		cpus_or(span, span, nodemask);
@@ -158,7 +156,7 @@
 
 #ifdef CONFIG_NUMA
 		if (num_online_cpus()
-				> SD_NODES_PER_DOMAIN*cpus_weight(nodemask)) {
+		    > CONFIG_IA64_SD_NODES_PER_DOMAIN*cpus_weight(nodemask)) {
 			sd = &per_cpu(allnodes_domains, i);
 			*sd = SD_ALLNODES_INIT;
 			sd->span = cpu_default_map;
Index: 269-bk/arch/ia64/kernel/Makefile
===================================================================
--- 269-bk/arch/ia64/kernel/Makefile	(revision 48)
+++ 269-bk/arch/ia64/kernel/Makefile	(working copy)
@@ -14,7 +14,8 @@
 obj-$(CONFIG_IA64_PALINFO)	+= palinfo.o
 obj-$(CONFIG_IOSAPIC)		+= iosapic.o
 obj-$(CONFIG_MODULES)		+= module.o
-obj-$(CONFIG_SMP)		+= smp.o smpboot.o domain.o
+obj-$(CONFIG_SMP)		+= smp.o smpboot.o
+obj-$(CONFIG_IA64_SCHED_SPAN)	+= domain.o
 obj-$(CONFIG_PERFMON)		+= perfmon_default_smpl.o
 obj-$(CONFIG_IA64_CYCLONE)	+= cyclone.o
 obj-$(CONFIG_IA64_MCA_RECOVERY)	+= mca_recovery.o


---
Takayoshi Kochi

----Next_Part(Thu_Oct_28_18:29:36_2004_590)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename=dmesg-domain

Brought up 32 CPUs
Total of 32 processors activated (47813.16 BogoMIPS).
CPU0:
 domain 0: span 0000000f
  groups: 00000001 00000002 00000004 00000008
  domain 1: span 00ffffff
   groups: 0000000f 000000f0 00000f00 0000f000 000f0000 00f00000
   domain 2: span ffffffff
    groups: 0000000f 000000f0 00000f00 0000f000 000f0000 00f00000 0f000000 f0000000
CPU1:
 domain 0: span 0000000f
  groups: 00000002 00000004 00000008 00000001
  domain 1: span 00ffffff
   groups: 0000000f 000000f0 00000f00 0000f000 000f0000 00f00000
   domain 2: span ffffffff
    groups: 0000000f 000000f0 00000f00 0000f000 000f0000 00f00000 0f000000 f0000000
CPU2:
 domain 0: span 0000000f
  groups: 00000004 00000008 00000001 00000002
  domain 1: span 00ffffff
   groups: 0000000f 000000f0 00000f00 0000f000 000f0000 00f00000
   domain 2: span ffffffff
    groups: 0000000f 000000f0 00000f00 0000f000 000f0000 00f00000 0f000000 f0000000
CPU3:
 domain 0: span 0000000f
  groups: 00000008 00000001 00000002 00000004
  domain 1: span 00ffffff
   groups: 0000000f 000000f0 00000f00 0000f000 000f0000 00f00000
   domain 2: span ffffffff
    groups: 0000000f 000000f0 00000f00 0000f000 000f0000 00f00000 0f000000 f0000000
CPU4:
 domain 0: span 000000f0
  groups: 00000010 00000020 00000040 00000080
  domain 1: span 00ffffff
   groups: 000000f0 00000f00 0000f000 000f0000 00f00000 0000000f
   domain 2: span ffffffff
    groups: 000000f0 00000f00 0000f000 000f0000 00f00000 0f000000 f0000000 0000000f
CPU5:
 domain 0: span 000000f0
  groups: 00000020 00000040 00000080 00000010
  domain 1: span 00ffffff
   groups: 000000f0 00000f00 0000f000 000f0000 00f00000 0000000f
   domain 2: span ffffffff
    groups: 000000f0 00000f00 0000f000 000f0000 00f00000 0f000000 f0000000 0000000f
CPU6:
 domain 0: span 000000f0
  groups: 00000040 00000080 00000010 00000020
  domain 1: span 00ffffff
   groups: 000000f0 00000f00 0000f000 000f0000 00f00000 0000000f
   domain 2: span ffffffff
    groups: 000000f0 00000f00 0000f000 000f0000 00f00000 0f000000 f0000000 0000000f
CPU7:
 domain 0: span 000000f0
  groups: 00000080 00000010 00000020 00000040
  domain 1: span 00ffffff
   groups: 000000f0 00000f00 0000f000 000f0000 00f00000 0000000f
   domain 2: span ffffffff
    groups: 000000f0 00000f00 0000f000 000f0000 00f00000 0f000000 f0000000 0000000f
CPU8:
 domain 0: span 00000f00
  groups: 00000100 00000200 00000400 00000800
  domain 1: span 00ffffff
   groups: 00000f00 0000f000 000f0000 00f00000 0000000f 000000f0
   domain 2: span ffffffff
    groups: 00000f00 0000f000 000f0000 00f00000 0f000000 f0000000 0000000f 000000f0
CPU9:
 domain 0: span 00000f00
  groups: 00000200 00000400 00000800 00000100
  domain 1: span 00ffffff
   groups: 00000f00 0000f000 000f0000 00f00000 0000000f 000000f0
   domain 2: span ffffffff
    groups: 00000f00 0000f000 000f0000 00f00000 0f000000 f0000000 0000000f 000000f0
CPU10:
 domain 0: span 00000f00
  groups: 00000400 00000800 00000100 00000200
  domain 1: span 00ffffff
   groups: 00000f00 0000f000 000f0000 00f00000 0000000f 000000f0
   domain 2: span ffffffff
    groups: 00000f00 0000f000 000f0000 00f00000 0f000000 f0000000 0000000f 000000f0
CPU11:
 domain 0: span 00000f00
  groups: 00000800 00000100 00000200 00000400
  domain 1: span 00ffffff
   groups: 00000f00 0000f000 000f0000 00f00000 0000000f 000000f0
   domain 2: span ffffffff
    groups: 00000f00 0000f000 000f0000 00f00000 0f000000 f0000000 0000000f 000000f0
CPU12:
 domain 0: span 0000f000
  groups: 00001000 00002000 00004000 00008000
  domain 1: span 00ffffff
   groups: 0000f000 000f0000 00f00000 0000000f 000000f0 00000f00
   domain 2: span ffffffff
    groups: 0000f000 000f0000 00f00000 0f000000 f0000000 0000000f 000000f0 00000f00
CPU13:
 domain 0: span 0000f000
  groups: 00002000 00004000 00008000 00001000
  domain 1: span 00ffffff
   groups: 0000f000 000f0000 00f00000 0000000f 000000f0 00000f00
   domain 2: span ffffffff
    groups: 0000f000 000f0000 00f00000 0f000000 f0000000 0000000f 000000f0 00000f00
CPU14:
 domain 0: span 0000f000
  groups: 00004000 00008000 00001000 00002000
  domain 1: span 00ffffff
   groups: 0000f000 000f0000 00f00000 0000000f 000000f0 00000f00
   domain 2: span ffffffff
    groups: 0000f000 000f0000 00f00000 0f000000 f0000000 0000000f 000000f0 00000f00
CPU15:
 domain 0: span 0000f000
  groups: 00008000 00001000 00002000 00004000
  domain 1: span 00ffffff
   groups: 0000f000 000f0000 00f00000 0000000f 000000f0 00000f00
   domain 2: span ffffffff
    groups: 0000f000 000f0000 00f00000 0f000000 f0000000 0000000f 000000f0 00000f00
CPU16:
 domain 0: span 000f0000
  groups: 00010000 00020000 00040000 00080000
  domain 1: span ffff00ff
   groups: 000f0000 00f00000 0f000000 f0000000 0000000f 000000f0
   domain 2: span ffffffff
    groups: 000f0000 00f00000 0f000000 f0000000 0000000f 000000f0 00000f00 0000f000
CPU17:
 domain 0: span 000f0000
  groups: 00020000 00040000 00080000 00010000
  domain 1: span ffff00ff
   groups: 000f0000 00f00000 0f000000 f0000000 0000000f 000000f0
   domain 2: span ffffffff
    groups: 000f0000 00f00000 0f000000 f0000000 0000000f 000000f0 00000f00 0000f000
CPU18:
 domain 0: span 000f0000
  groups: 00040000 00080000 00010000 00020000
  domain 1: span ffff00ff
   groups: 000f0000 00f00000 0f000000 f0000000 0000000f 000000f0
   domain 2: span ffffffff
    groups: 000f0000 00f00000 0f000000 f0000000 0000000f 000000f0 00000f00 0000f000
CPU19:
 domain 0: span 000f0000
  groups: 00080000 00010000 00020000 00040000
  domain 1: span ffff00ff
   groups: 000f0000 00f00000 0f000000 f0000000 0000000f 000000f0
   domain 2: span ffffffff
    groups: 000f0000 00f00000 0f000000 f0000000 0000000f 000000f0 00000f00 0000f000
CPU20:
 domain 0: span 00f00000
  groups: 00100000 00200000 00400000 00800000
  domain 1: span ffff00ff
   groups: 00f00000 0f000000 f0000000 0000000f 000000f0 000f0000
   domain 2: span ffffffff
    groups: 00f00000 0f000000 f0000000 0000000f 000000f0 00000f00 0000f000 000f0000
CPU21:
 domain 0: span 00f00000
  groups: 00200000 00400000 00800000 00100000
  domain 1: span ffff00ff
   groups: 00f00000 0f000000 f0000000 0000000f 000000f0 000f0000
   domain 2: span ffffffff
    groups: 00f00000 0f000000 f0000000 0000000f 000000f0 00000f00 0000f000 000f0000
CPU22:
 domain 0: span 00f00000
  groups: 00400000 00800000 00100000 00200000
  domain 1: span ffff00ff
   groups: 00f00000 0f000000 f0000000 0000000f 000000f0 000f0000
   domain 2: span ffffffff
    groups: 00f00000 0f000000 f0000000 0000000f 000000f0 00000f00 0000f000 000f0000
CPU23:
 domain 0: span 00f00000
  groups: 00800000 00100000 00200000 00400000
  domain 1: span ffff00ff
   groups: 00f00000 0f000000 f0000000 0000000f 000000f0 000f0000
   domain 2: span ffffffff
    groups: 00f00000 0f000000 f0000000 0000000f 000000f0 00000f00 0000f000 000f0000
CPU24:
 domain 0: span 0f000000
  groups: 01000000 02000000 04000000 08000000
  domain 1: span ffff00ff
   groups: 0f000000 f0000000 0000000f 000000f0 000f0000 00f00000
   domain 2: span ffffffff
    groups: 0f000000 f0000000 0000000f 000000f0 00000f00 0000f000 000f0000 00f00000
CPU25:
 domain 0: span 0f000000
  groups: 02000000 04000000 08000000 01000000
  domain 1: span ffff00ff
   groups: 0f000000 f0000000 0000000f 000000f0 000f0000 00f00000
   domain 2: span ffffffff
    groups: 0f000000 f0000000 0000000f 000000f0 00000f00 0000f000 000f0000 00f00000
CPU26:
 domain 0: span 0f000000
  groups: 04000000 08000000 01000000 02000000
  domain 1: span ffff00ff
   groups: 0f000000 f0000000 0000000f 000000f0 000f0000 00f00000
   domain 2: span ffffffff
    groups: 0f000000 f0000000 0000000f 000000f0 00000f00 0000f000 000f0000 00f00000
CPU27:
 domain 0: span 0f000000
  groups: 08000000 01000000 02000000 04000000
  domain 1: span ffff00ff
   groups: 0f000000 f0000000 0000000f 000000f0 000f0000 00f00000
   domain 2: span ffffffff
    groups: 0f000000 f0000000 0000000f 000000f0 00000f00 0000f000 000f0000 00f00000
CPU28:
 domain 0: span f0000000
  groups: 10000000 20000000 40000000 80000000
  domain 1: span ffff00ff
   groups: f0000000 0000000f 000000f0 000f0000 00f00000 0f000000
   domain 2: span ffffffff
    groups: f0000000 0000000f 000000f0 00000f00 0000f000 000f0000 00f00000 0f000000
CPU29:
 domain 0: span f0000000
  groups: 20000000 40000000 80000000 10000000
  domain 1: span ffff00ff
   groups: f0000000 0000000f 000000f0 000f0000 00f00000 0f000000
   domain 2: span ffffffff
    groups: f0000000 0000000f 000000f0 00000f00 0000f000 000f0000 00f00000 0f000000
CPU30:
 domain 0: span f0000000
  groups: 40000000 80000000 10000000 20000000
  domain 1: span ffff00ff
   groups: f0000000 0000000f 000000f0 000f0000 00f00000 0f000000
   domain 2: span ffffffff
    groups: f0000000 0000000f 000000f0 00000f00 0000f000 000f0000 00f00000 0f000000
CPU31:
 domain 0: span f0000000
  groups: 80000000 10000000 20000000 40000000
  domain 1: span ffff00ff
   groups: f0000000 0000000f 000000f0 000f0000 00f00000 0f000000
   domain 2: span ffffffff
    groups: f0000000 0000000f 000000f0 00000f00 0000f000 000f0000 00f00000 0f000000

----Next_Part(Thu_Oct_28_18:29:36_2004_590)----
