From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 11 May 2004 18:39:09 +0000
Subject: Re: bk pull on ia64 linux tree
Message-Id: <200405111139.09765.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_N3RoA4tEEIz7qtr"
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_N3RoA4tEEIz7qtr
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday, May 11, 2004 12:06 am, Christoph Hellwig wrote:
> On Tue, May 11, 2004 at 12:02:34AM -0700, David Mosberger wrote:
> > <pfg@sgi.com> (04/05/06 1.1587.10.10)
> >    [PATCH] ia64: SN2 - remove node_first_cpu member
> >
> >    Remove node_first_cpu member from nodepda_s and replace its usage with
> > calls to sn_get_node_first_cpu().
>
> This should still use the topology API even if Pat decided to ignore the
> review.

Right.  Here's a patch to kill it.

sn_get_node_first_cpu() is redundant, so kill it.  Since calls to this routine 
happen rather late in the boot process, using the generic topology functions 
is safe.  Fixup the callers and kill the function.

Jesse

--Boundary-00=_N3RoA4tEEIz7qtr
Content-Type: text/plain;
  charset="iso-8859-1";
  name="kill-sn-first-cpu.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="kill-sn-first-cpu.patch"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1620  -> 1.1621 
#	include/asm-ia64/sn/arch.h	1.8     -> 1.9    
#	arch/ia64/sn/io/sn2/ml_SN_intr.c	1.11    -> 1.12   
#	drivers/char/sn_serial.c	1.12    -> 1.13   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/05/11	jbarnes@tomahawk.engr.sgi.com	1.1621
# kill redundant function
# --------------------------------------------
#
diff -Nru a/arch/ia64/sn/io/sn2/ml_SN_intr.c b/arch/ia64/sn/io/sn2/ml_SN_intr.c
--- a/arch/ia64/sn/io/sn2/ml_SN_intr.c	Tue May 11 11:28:00 2004
+++ b/arch/ia64/sn/io/sn2/ml_SN_intr.c	Tue May 11 11:28:00 2004
@@ -12,6 +12,7 @@
 #include <asm/smp.h>
 #include <asm/irq.h>
 #include <asm/hw_irq.h>
+#include <asm/topology.h>
 #include <asm/sn/sgi.h>
 #include <asm/sn/iograph.h>
 #include <asm/sn/hcl.h>
@@ -36,25 +37,6 @@
 extern cnodeid_t master_node_get(vertex_hdl_t vhdl);
 extern nasid_t master_nasid;
 
-cpuid_t
-sn_get_node_first_cpu(cnodeid_t cnode) {
-	int cpuid = -1, slice;
-
-	for (slice = CPUS_PER_NODE - 1; slice >= 0; slice--) {
-		cpuid = cnode_slice_to_cpuid(cnode, slice);
-		if (cpuid == NR_CPUS)
-			continue;
-		if (!cpu_online(cpuid))
-			continue;
-		break;
-	}
-	if (slice < 0) {
-		return CPU_NONE;
-	}
-	return cpuid;
-}
-
-
 /*  Initialize some shub registers for interrupts, both IO and error. */
 void intr_init_vecblk(cnodeid_t node)
 {
@@ -78,13 +60,13 @@
 		HUB_S((unsigned long *)GLOBAL_MMR_ADDR(nasid, SH_INT_NODE_ID_CONFIG),
 			node_id_config.sh_int_node_id_config_regval);
 		cnode = nasid_to_cnodeid(master_nasid);
-		cpu = sn_get_node_first_cpu(cnode);
+		cpu = first_cpu(node_to_cpumask(cnode));
 		cpu = cpu_physical_id(cpu);
 		SAL_CALL(ret_stuff, SN_SAL_REGISTER_CE, nasid, cpu, master_nasid,0,0,0,0);
 		if (ret_stuff.status < 0)
 			printk("%s: SN_SAL_REGISTER_CE SAL_CALL failed\n",__FUNCTION__);
 	} else {
-		cpu = sn_get_node_first_cpu(node);
+		cpu = first_cpu(node_to_cpumask(node));
 		cpu = cpu_physical_id(cpu);
 	}
 
diff -Nru a/drivers/char/sn_serial.c b/drivers/char/sn_serial.c
--- a/drivers/char/sn_serial.c	Tue May 11 11:28:00 2004
+++ b/drivers/char/sn_serial.c	Tue May 11 11:28:00 2004
@@ -500,10 +500,9 @@
 	nasid_t console_nasid;
 	unsigned int console_irq;
 	int result;
-	extern cpuid_t sn_get_node_first_cpu(cnodeid_t cnode);
 
 	console_nasid = ia64_sn_get_console_nasid();
-	intr_cpuid = sn_get_node_first_cpu(NASID_TO_COMPACT_NODEID(console_nasid));
+	intr_cpuid = first_cpu(node_to_cpumask(NASID_TO_COMPACT_NODEID(console_nasid)));
 	intr_cpuloc = cpu_physical_id(intr_cpuid);
 	console_irq = CPU_VECTOR_TO_IRQ(intr_cpuloc, SGI_UART_VECTOR);
 
diff -Nru a/include/asm-ia64/sn/arch.h b/include/asm-ia64/sn/arch.h
--- a/include/asm-ia64/sn/arch.h	Tue May 11 11:28:00 2004
+++ b/include/asm-ia64/sn/arch.h	Tue May 11 11:28:00 2004
@@ -20,8 +20,6 @@
 typedef u64	mmr_t;
 typedef u64	nic_t;
 
-#define CNODE_TO_CPU_BASE(_cnode)	(sn_get_node_first_cpu(_cnode))
-
 #define NASID_TO_COMPACT_NODEID(nasid)  (nasid_to_cnodeid(nasid))
 #define COMPACT_TO_NASID_NODEID(cnode)  (cnodeid_to_nasid(cnode))
 
@@ -34,9 +32,7 @@
 #define	INVALID_PARTID		((partid_t)-1)
 
 extern cpuid_t cnodetocpu(cnodeid_t);
-void   sn_flush_all_caches(long addr, long bytes);
-
-extern int     is_fine_dirmode(void);
-
+extern void sn_flush_all_caches(long addr, long bytes);
+extern int is_fine_dirmode(void);
 
 #endif /* _ASM_IA64_SN_ARCH_H */

--Boundary-00=_N3RoA4tEEIz7qtr--
