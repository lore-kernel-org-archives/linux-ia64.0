From: Pat Gefre <pfg@sgi.com>
Date: Thu, 06 May 2004 23:05:05 +0000
Subject: [PATCH 2.6] Altix - remove node_first_cpu
Message-Id: <200405062305.i46N55lL278325@fsgi900.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David,

A patch to remove node_first_cpu from nodepda_s and its usage.

-- Pat

Patrick Gefre
Silicon Graphics, Inc.                     (E-Mail)  pfg@sgi.com
2750 Blue Water Rd                         (Voice)   (651) 683-3127
Eagan, MN 55121-1400                       (FAX)     (651) 683-3054



# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/05/06 16:38:23-05:00 pfg@sgi.com 
#   Remove node_first_cpu and usage thereof
# 
# include/asm-ia64/sn/nodepda.h
# 
# include/asm-ia64/sn/arch.h
# 
# drivers/char/sn_serial.c
# 
# arch/ia64/sn/kernel/setup.c
# 
# arch/ia64/sn/io/sn2/ml_SN_intr.c
# 
diff -Nru a/arch/ia64/sn/io/sn2/ml_SN_intr.c b/arch/ia64/sn/io/sn2/ml_SN_intr.c
--- a/arch/ia64/sn/io/sn2/ml_SN_intr.c	Thu May  6 17:09:35 2004
+++ b/arch/ia64/sn/io/sn2/ml_SN_intr.c	Thu May  6 17:09:35 2004
@@ -36,6 +36,25 @@
 extern cnodeid_t master_node_get(vertex_hdl_t vhdl);
 extern nasid_t master_nasid;
 
+cpuid_t
+sn_get_node_first_cpu(cnodeid_t cnode) {
+	int cpuid = -1, slice;
+
+	for (slice = CPUS_PER_NODE - 1; slice >= 0; slice--) {
+		cpuid = cnode_slice_to_cpuid(cnode, slice);
+		if (cpuid = NR_CPUS)
+			continue;
+		if (!cpu_online(cpuid))
+			continue;
+		break;
+	}
+	if (slice < 0) {
+		return CPU_NONE;
+	}
+	return cpuid;
+}
+
+
 /*  Initialize some shub registers for interrupts, both IO and error. */
 void intr_init_vecblk(cnodeid_t node)
 {
@@ -43,7 +62,6 @@
 	sh_ii_int0_config_u_t		ii_int_config;
 	cpuid_t				cpu;
 	cpuid_t				cpu0, cpu1;
-	nodepda_t			*lnodepda;
 	sh_ii_int0_enable_u_t		ii_int_enable;
 	sh_int_node_id_config_u_t	node_id_config;
 	sh_local_int5_config_u_t	local5_config;
@@ -60,15 +78,13 @@
 		HUB_S((unsigned long *)GLOBAL_MMR_ADDR(nasid, SH_INT_NODE_ID_CONFIG),
 			node_id_config.sh_int_node_id_config_regval);
 		cnode = nasid_to_cnodeid(master_nasid);
-		lnodepda = NODEPDA(cnode);
-		cpu = lnodepda->node_first_cpu;
+		cpu = sn_get_node_first_cpu(cnode);
 		cpu = cpu_physical_id(cpu);
 		SAL_CALL(ret_stuff, SN_SAL_REGISTER_CE, nasid, cpu, master_nasid,0,0,0,0);
 		if (ret_stuff.status < 0)
 			printk("%s: SN_SAL_REGISTER_CE SAL_CALL failed\n",__FUNCTION__);
 	} else {
-		lnodepda = NODEPDA(node);
-		cpu = lnodepda->node_first_cpu;
+		cpu = sn_get_node_first_cpu(node);
 		cpu = cpu_physical_id(cpu);
 	}
 
diff -Nru a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
--- a/arch/ia64/sn/kernel/setup.c	Thu May  6 17:09:35 2004
+++ b/arch/ia64/sn/kernel/setup.c	Thu May  6 17:09:35 2004
@@ -451,10 +451,6 @@
 	}
 	pda->shub_1_1_found = shub_1_1_found;
 	
-	if (local_node_data->active_cpu_count = 1)
-		nodepda->node_first_cpu = cpuid;
-
-
 
 	/*
 	 * We must use different memory allocators for first cpu (bootmem 
@@ -474,7 +470,7 @@
 	pda->mem_write_status_addr = (volatile u64 *)
 			LOCAL_MMR_ADDR((slice < 2 ? SH_MEMORY_WRITE_STATUS_0 : SH_MEMORY_WRITE_STATUS_1 ) );
 
-	if (nodepda->node_first_cpu = cpuid) {
+	if (local_node_data->active_cpu_count++ = 0) {
 		int	buddy_nasid;
 		buddy_nasid = cnodeid_to_nasid(numa_node_id() = numnodes-1 ? 0 : numa_node_id()+ 1);
 		pda->pio_shub_war_cam_addr = (volatile unsigned long*)GLOBAL_MMR_ADDR(nasid, SH_PI_CAM_CONTROL);
diff -Nru a/drivers/char/sn_serial.c b/drivers/char/sn_serial.c
--- a/drivers/char/sn_serial.c	Thu May  6 17:09:35 2004
+++ b/drivers/char/sn_serial.c	Thu May  6 17:09:35 2004
@@ -500,9 +500,10 @@
 	nasid_t console_nasid;
 	unsigned int console_irq;
 	int result;
+	extern cpuid_t sn_get_node_first_cpu(cnodeid_t cnode);
 
 	console_nasid = ia64_sn_get_console_nasid();
-	intr_cpuid = NODEPDA(NASID_TO_COMPACT_NODEID(console_nasid))->node_first_cpu;
+	intr_cpuid = sn_get_node_first_cpu(NASID_TO_COMPACT_NODEID(console_nasid));
 	intr_cpuloc = cpu_physical_id(intr_cpuid);
 	console_irq = CPU_VECTOR_TO_IRQ(intr_cpuloc, SGI_UART_VECTOR);
 
diff -Nru a/include/asm-ia64/sn/arch.h b/include/asm-ia64/sn/arch.h
--- a/include/asm-ia64/sn/arch.h	Thu May  6 17:09:35 2004
+++ b/include/asm-ia64/sn/arch.h	Thu May  6 17:09:35 2004
@@ -20,7 +20,7 @@
 typedef u64	mmr_t;
 typedef u64	nic_t;
 
-#define CNODE_TO_CPU_BASE(_cnode)	(NODEPDA(_cnode)->node_first_cpu)
+#define CNODE_TO_CPU_BASE(_cnode)	(sn_get_node_first_cpu(_cnode))
 
 #define NASID_TO_COMPACT_NODEID(nasid)  (nasid_to_cnodeid(nasid))
 #define COMPACT_TO_NASID_NODEID(cnode)  (cnodeid_to_nasid(cnode))
diff -Nru a/include/asm-ia64/sn/nodepda.h b/include/asm-ia64/sn/nodepda.h
--- a/include/asm-ia64/sn/nodepda.h	Thu May  6 17:09:35 2004
+++ b/include/asm-ia64/sn/nodepda.h	Thu May  6 17:09:35 2004
@@ -36,13 +36,6 @@
 
 
 struct nodepda_s {
-
-
-	cpuid_t         node_first_cpu; /* Starting cpu number for node */
-					/* WARNING: no guarantee that   */
-					/*  the second cpu on a node is */
-					/*  node_first_cpu+1.           */
-
 	vertex_hdl_t 	xbow_vhdl;
 	nasid_t		xbow_peer;	/* NASID of our peer hub on xbow */
 	struct semaphore xbow_sema;	/* Sema for xbow synchronization */
