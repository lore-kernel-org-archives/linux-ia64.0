From: Christoph Hellwig <hch@lst.de>
Date: Fri, 26 Sep 2003 09:46:47 +0000
Subject: [hch: Re: [PATCH] sn_ML_intr.c is a freakin mess]
Message-Id: <marc-linux-ia64-106456973409058@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

----- Forwarded message from Christoph Hellwig <hch> -----

Date: Fri, 26 Sep 2003 11:46:29 +0200
From: Christoph Hellwig <hch>
Subject: Re: [PATCH] sn_ML_intr.c is a freakin mess
To: jbarnes@sgi.com, davidm@napali.hpl.hp.com

On Fri, Sep 26, 2003 at 11:36:25AM +0200, Christoph Hellwig wrote:
> fed through Lindent and dead codepathes eliminated.

Sorry, wrong patch attached.  Here's the right one:

--- 1.10/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Mon Sep  8 14:12:36 2003
+++ edited/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Fri Sep 26 11:34:46 2003
@@ -438,14 +438,18 @@
 		extern void register_sn_procfs(void);
 #endif
 		extern void irix_io_init(void);
+		extern void sn_init_cpei_timer(void);
 		
 		init_hcl();
 		irix_io_init();
 		
 		for (cnode = 0; cnode < numnodes; cnode++) {
-			extern void intr_init_vecblk(nodepda_t *npda, cnodeid_t, int);
-			intr_init_vecblk(NODEPDA(cnode), cnode, 0);
+			extern void intr_init_vecblk(cnodeid_t);
+			intr_init_vecblk(cnode);
 		} 
+
+		sn_init_cpei_timer();
+
 #ifdef CONFIG_PROC_FS
 		register_sn_procfs();
 #endif
--- 1.5/arch/ia64/sn/io/sn2/ml_SN_intr.c	Tue Sep 16 20:40:54 2003
+++ edited/arch/ia64/sn/io/sn2/ml_SN_intr.c	Fri Sep 26 11:38:25 2003
@@ -1,5 +1,4 @@
-/* $Id: ml_SN_intr.c,v 1.1 2002/02/28 17:31:25 marcelo Exp $
- *
+/*
  * This file is subject to the terms and conditions of the GNU General Public
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
@@ -7,14 +6,6 @@
  * Copyright (C) 1992-1997, 2000-2003 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
-/*
- * intr.c-
- *	This file contains all of the routines necessary to set up and
- *	handle interrupts on an IPXX board.
- */
-
-#ident  "$Revision: 1.1 $"
-
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/interrupt.h>
@@ -45,75 +36,63 @@
 extern cnodeid_t master_node_get(vertex_hdl_t vhdl);
 extern nasid_t master_nasid;
 
-//  Initialize some shub registers for interrupts, both IO and error.
-//  
-
-
-
-void
-intr_init_vecblk( nodepda_t *npda,
-		cnodeid_t node,
-		int sn)
+/*  Initialize some shub registers for interrupts, both IO and error. */
+void intr_init_vecblk(cnodeid_t node)
 {
-	int 			nasid = cnodeid_to_nasid(node);
-	sh_ii_int0_config_u_t	ii_int_config;
-	cpuid_t			cpu;
-	cpuid_t			cpu0, cpu1;
-	nodepda_t		*lnodepda;
-	sh_ii_int0_enable_u_t	ii_int_enable;
+	int 				nasid = cnodeid_to_nasid(node);
+	sh_ii_int0_config_u_t		ii_int_config;
+	cpuid_t				cpu;
+	cpuid_t				cpu0, cpu1;
+	nodepda_t			*lnodepda;
+	sh_ii_int0_enable_u_t		ii_int_enable;
 	sh_int_node_id_config_u_t	node_id_config;
 	sh_local_int5_config_u_t	local5_config;
 	sh_local_int5_enable_u_t	local5_enable;
-	extern void sn_init_cpei_timer(void);
-	static int timer_added = 0;
-
 
 	if (is_headless_node(node) ) {
-		int cnode;
 		struct ia64_sal_retval ret_stuff;
+		int cnode;
 
-		// retarget all interrupts on this node to the master node.
+		/* retarget all interrupts on this node to the master node. */
 		node_id_config.sh_int_node_id_config_regval = 0;
 		node_id_config.sh_int_node_id_config_s.node_id = master_nasid;
 		node_id_config.sh_int_node_id_config_s.id_sel = 1;
-		HUB_S( (unsigned long *)GLOBAL_MMR_ADDR(nasid, SH_INT_NODE_ID_CONFIG),
+		HUB_S((unsigned long *)GLOBAL_MMR_ADDR(nasid, SH_INT_NODE_ID_CONFIG),
 			node_id_config.sh_int_node_id_config_regval);
 		cnode = nasid_to_cnodeid(master_nasid);
 		lnodepda = NODEPDA(cnode);
 		cpu = lnodepda->node_first_cpu;
 		cpu = cpu_physical_id(cpu);
 		SAL_CALL(ret_stuff, SN_SAL_REGISTER_CE, nasid, cpu, master_nasid,0,0,0,0);
-		if (ret_stuff.status < 0) {
+		if (ret_stuff.status < 0)
 			printk("%s: SN_SAL_REGISTER_CE SAL_CALL failed\n",__FUNCTION__);
-		}
 	} else {
 		lnodepda = NODEPDA(node);
 		cpu = lnodepda->node_first_cpu;
 		cpu = cpu_physical_id(cpu);
 	}
 
-	// Get the physical id's of the cpu's on this node.
+	/* Get the physical id's of the cpu's on this node. */
 	cpu0 = nasid_slice_to_cpu_physical_id(nasid, 0);
 	cpu1 = nasid_slice_to_cpu_physical_id(nasid, 2);
 
 	HUB_S( (unsigned long *)GLOBAL_MMR_ADDR(nasid, SH_PI_ERROR_MASK), 0);
 	HUB_S( (unsigned long *)GLOBAL_MMR_ADDR(nasid, SH_PI_CRBP_ERROR_MASK), 0);
 
-	// Config and enable UART interrupt, all nodes.
-
+	/* Config and enable UART interrupt, all nodes. */
 	local5_config.sh_local_int5_config_regval = 0;
 	local5_config.sh_local_int5_config_s.idx = SGI_UART_VECTOR;
 	local5_config.sh_local_int5_config_s.pid = cpu0;
-	HUB_S( (unsigned long *)GLOBAL_MMR_ADDR(nasid, SH_LOCAL_INT5_CONFIG),
+	HUB_S((unsigned long *)GLOBAL_MMR_ADDR(nasid, SH_LOCAL_INT5_CONFIG),
 		local5_config.sh_local_int5_config_regval);
 
 	local5_enable.sh_local_int5_enable_regval = 0;
 	local5_enable.sh_local_int5_enable_s.uart_int = 1;
-	HUB_S( (unsigned long *)GLOBAL_MMR_ADDR(nasid, SH_LOCAL_INT5_ENABLE),
+	HUB_S((unsigned long *)GLOBAL_MMR_ADDR(nasid, SH_LOCAL_INT5_ENABLE),
 		local5_enable.sh_local_int5_enable_regval);
 
 
-	// The II_INT_CONFIG register for cpu 0.
+	/* The II_INT_CONFIG register for cpu 0. */
 	ii_int_config.sh_ii_int0_config_regval = 0;
 	ii_int_config.sh_ii_int0_config_s.type = 0;
 	ii_int_config.sh_ii_int0_config_s.agt = 0;
@@ -124,7 +103,7 @@
 		ii_int_config.sh_ii_int0_config_regval);
 
 
-	// The II_INT_CONFIG register for cpu 1.
+	/* The II_INT_CONFIG register for cpu 1. */
 	ii_int_config.sh_ii_int0_config_regval = 0;
 	ii_int_config.sh_ii_int0_config_s.type = 0;
 	ii_int_config.sh_ii_int0_config_s.agt = 0;
@@ -135,7 +114,7 @@
 		ii_int_config.sh_ii_int0_config_regval);
 
 
-	// Enable interrupts for II_INT0 and 1.
+	/* Enable interrupts for II_INT0 and 1. */
 	ii_int_enable.sh_ii_int0_enable_regval = 0;
 	ii_int_enable.sh_ii_int0_enable_s.ii_enable = 1;
 
@@ -143,148 +122,99 @@
 		ii_int_enable.sh_ii_int0_enable_regval);
 	HUB_S((unsigned long *)GLOBAL_MMR_ADDR(nasid, SH_II_INT1_ENABLE),
 		ii_int_enable.sh_ii_int0_enable_regval);
-
-
-	if (!timer_added) { // can only init the timer once.
-		timer_added = 1;
-		sn_init_cpei_timer();
-	}
 }
 
-// (Un)Reserve an irq on this cpu.
-
-static int
-do_intr_reserve_level(cpuid_t cpu,
-			int bit,
-			int reserve)
+static int intr_reserve_level(cpuid_t cpu, int bit)
 {
-	int i;
 	irqpda_t	*irqs = irqpdaindr;
 	int		min_shared;
+	int		i;
 
-	if (reserve) {
-		if (bit < 0) {
-			for (i = IA64_SN2_FIRST_DEVICE_VECTOR; i <= IA64_SN2_LAST_DEVICE_VECTOR; i++) {
-				if (irqs->irq_flags[i] = 0) {
+	if (bit < 0) {
+		for (i = IA64_SN2_FIRST_DEVICE_VECTOR; i <= IA64_SN2_LAST_DEVICE_VECTOR; i++) {
+			if (irqs->irq_flags[i] = 0) {
+				bit = i;
+				break;
+			}
+		}
+	}
+
+	if (bit < 0) {  /* ran out of irqs.  Have to share.  This will be rare. */
+		min_shared = 256;
+		for (i=IA64_SN2_FIRST_DEVICE_VECTOR; i < IA64_SN2_LAST_DEVICE_VECTOR; i++) {
+			/* Share with the same device class */
+			/* XXX: gross layering violation.. */
+			if (irqpdaindr->curr->vendor = irqpdaindr->device_dev[i]->vendor &&
+				irqpdaindr->curr->device = irqpdaindr->device_dev[i]->device &&
+				irqpdaindr->share_count[i] < min_shared) {
+					min_shared = irqpdaindr->share_count[i];
 					bit = i;
-					break;
-				}
 			}
 		}
-		if (bit < 0) {  /* ran out of irqs.  Have to share.  This will be rare. */
-			min_shared = 256;
+	
+		min_shared = 256;
+		if (bit < 0) {  /* didn't find a matching device, just pick one. This will be */
+				/* exceptionally rare. */
 			for (i=IA64_SN2_FIRST_DEVICE_VECTOR; i < IA64_SN2_LAST_DEVICE_VECTOR; i++) {
-				/* Share with the same device class */
-				if (irqpdaindr->curr->vendor = irqpdaindr->device_dev[i]->vendor &&
-					irqpdaindr->curr->device = irqpdaindr->device_dev[i]->device &&
-					irqpdaindr->share_count[i] < min_shared) {
-						min_shared = irqpdaindr->share_count[i];
-						bit = i;
-				}
-			}
-			min_shared = 256;
-			if (bit < 0) {  /* didn't find a matching device, just pick one. This will be */
-					/* exceptionally rare. */
-				for (i=IA64_SN2_FIRST_DEVICE_VECTOR; i < IA64_SN2_LAST_DEVICE_VECTOR; i++) {
-					if (irqpdaindr->share_count[i] < min_shared) {
-						min_shared = irqpdaindr->share_count[i];
-						bit = i;
-					}
+				if (irqpdaindr->share_count[i] < min_shared) {
+					min_shared = irqpdaindr->share_count[i];
+					bit = i;
 				}
 			}
-			irqpdaindr->share_count[bit]++;
-		}
-		if (irqs->irq_flags[bit] & SN2_IRQ_SHARED) {
-			irqs->irq_flags[bit] |= SN2_IRQ_RESERVED;
-			return bit;
 		}
-		if (irqs->irq_flags[bit] & SN2_IRQ_RESERVED) {
-			return -1;
-		} else {
-			irqs->num_irq_used++;
-			irqs->irq_flags[bit] |= SN2_IRQ_RESERVED;
-			return bit;
-		}
-	} else {
-		if (irqs->irq_flags[bit] & SN2_IRQ_RESERVED) {
-			irqs->num_irq_used--;
-			irqs->irq_flags[bit] &= ~SN2_IRQ_RESERVED;
-			return bit;
-		} else {
+		irqpdaindr->share_count[bit]++;
+	}
+
+	if (!(irqs->irq_flags[bit] & SN2_IRQ_SHARED)) {
+		if (irqs->irq_flags[bit] & SN2_IRQ_RESERVED)
 			return -1;
-		}
+		irqs->num_irq_used++;
 	}
-}
 
-int
-intr_reserve_level(cpuid_t cpu,
-		int bit,
-		int resflags,
-		vertex_hdl_t owner_dev,
-		char *name)
-{
-	return(do_intr_reserve_level(cpu, bit, 1));
+	irqs->irq_flags[bit] |= SN2_IRQ_RESERVED;
+	return bit;
 }
 
-void
-intr_unreserve_level(cpuid_t cpu,
+void intr_unreserve_level(cpuid_t cpu,
 		int bit)
 {
-	(void)do_intr_reserve_level(cpu, bit, 0);
-}
-
-// Mark an irq on this cpu as (dis)connected.
-
-static int
-do_intr_connect_level(cpuid_t cpu,
-			int bit,
-			int connect)
-{
 	irqpda_t	*irqs = irqpdaindr;
 
-	if (connect) {
-		if (irqs->irq_flags[bit] & SN2_IRQ_SHARED) {
-			irqs->irq_flags[bit] |= SN2_IRQ_CONNECTED;
-			return bit;
-		}
-		if (irqs->irq_flags[bit] & SN2_IRQ_CONNECTED) {
-			return -1;
-		} else {
-			irqs->irq_flags[bit] |= SN2_IRQ_CONNECTED;
-			return bit;
-		}
-	} else {
-		if (irqs->irq_flags[bit] & SN2_IRQ_CONNECTED) {
-			irqs->irq_flags[bit] &= ~SN2_IRQ_CONNECTED;
-			return bit;
-		} else {
-			return -1;
-		}
+	if (irqs->irq_flags[bit] & SN2_IRQ_RESERVED) {
+		irqs->num_irq_used--;
+		irqs->irq_flags[bit] &= ~SN2_IRQ_RESERVED;
 	}
-	return(bit);
 }
 
-int
-intr_connect_level(cpuid_t cpu,
-		int bit,
-		ilvl_t is,
-		intr_func_t intr_prefunc)
+int intr_connect_level(cpuid_t cpu, int bit)
 {
-	return(do_intr_connect_level(cpu, bit, 1));
+	irqpda_t	*irqs = irqpdaindr;
+
+	if (!(irqs->irq_flags[bit] & SN2_IRQ_SHARED) &&
+	     (irqs->irq_flags[bit] & SN2_IRQ_CONNECTED))
+		return -1;
+ 
+	irqs->irq_flags[bit] |= SN2_IRQ_CONNECTED;
+	return bit;
 }
 
-int
-intr_disconnect_level(cpuid_t cpu,
-		int bit)
+int intr_disconnect_level(cpuid_t cpu, int bit)
 {
-	return(do_intr_connect_level(cpu, bit, 0));
-}
+	irqpda_t	*irqs = irqpdaindr;
 
-// Choose a cpu on this node.
-// We choose the one with the least number of int's assigned to it.
+	if (!(irqs->irq_flags[bit] & SN2_IRQ_CONNECTED))
+		return -1;
+	irqs->irq_flags[bit] &= ~SN2_IRQ_CONNECTED;
+	return bit;
+}
 
-static cpuid_t
-do_intr_cpu_choose(cnodeid_t cnode) {
+/*
+ * Choose a cpu on this node.
+ *
+ * We choose the one with the least number of int's assigned to it.
+ */
+static cpuid_t intr_cpu_choose_from_node(cnodeid_t cnode)
+{
 	cpuid_t		cpu, best_cpu = CPU_NONE;
 	int		slice, min_count = 1000;
 	irqpda_t	*irqs;
@@ -293,13 +223,10 @@
 		int intrs;
 
 		cpu = cnode_slice_to_cpuid(cnode, slice);
-		if (cpu = num_online_cpus()) {
+		if (cpu = num_online_cpus())
 			continue;
-		}
-
-		if (!cpu_online(cpu)) {
+		if (!cpu_online(cpu))
 			continue;
-		}
 
 		irqs = irqpdaindr;
 		intrs = irqs->num_irq_used;
@@ -307,9 +234,12 @@
 		if (min_count > intrs) {
 			min_count = intrs;
 			best_cpu = cpu;
-			if ( enable_shub_wars_1_1() ) {
-				/* Rather than finding the best cpu, always return the first cpu*/
-				/* This forces all interrupts to the same cpu */
+			if (enable_shub_wars_1_1()) {
+				/*
+				 * Rather than finding the best cpu, always
+				 * return the first cpu.  This forces all
+				 * interrupts to the same cpu
+				 */
 				break;
 			}
 		}
@@ -317,130 +247,76 @@
 	return best_cpu;
 }
 
-static cpuid_t
-intr_cpu_choose_from_node(cnodeid_t cnode)
-{
-	return(do_intr_cpu_choose(cnode));
-}
-
-// See if we can use this cpu/vect.
-
-static cpuid_t
-intr_bit_reserve_test(cpuid_t cpu,
-			int favor_subnode,
-			cnodeid_t cnode,
-			int req_bit,
-			int resflags,
-			vertex_hdl_t owner_dev,
-			char *name,
-			int *resp_bit)
+/*
+ * We couldn't put it on the closest node.  Try to find another one.
+ * Do a stupid round-robin assignment of the node.
+ */
+static cpuid_t intr_cpu_choose_node(void)
 {
-	ASSERT( (cpu = CPU_NONE) || (cnode = CNODEID_NONE) );
-
-	if (cnode != CNODEID_NONE) {
-		cpu = intr_cpu_choose_from_node(cnode);
+	static cnodeid_t last_node = -1;	/* XXX: racy */
+	cnodeid_t candidate_node;
+	cpuid_t cpuid;
+
+	if (last_node >= numnodes)
+		last_node = 0;
+
+	for (candidate_node = last_node + 1; candidate_node != last_node;
+			candidate_node++) {
+		if (candidate_node = numnodes)
+			candidate_node = 0;
+		cpuid = intr_cpu_choose_from_node(candidate_node);
+		if (cpuid != CPU_NONE)
+			return cpuid;
 	}
 
-	if (cpu != CPU_NONE) {
-		*resp_bit = do_intr_reserve_level(cpu, req_bit, 1);
-		if (*resp_bit >= 0) {
-			return(cpu);
-		}
-	}
 	return CPU_NONE;
 }
 
-// Find the node to assign for this interrupt.
-
-cpuid_t
-intr_heuristic(vertex_hdl_t dev,
-		device_desc_t dev_desc,
-		int	req_bit,
-		int resflags,
-		vertex_hdl_t owner_dev,
-		char *name,
-		int *resp_bit)
+/*
+ * Find the node to assign for this interrupt.
+ *
+ * SN2 + pcibr addressing limitation:
+ *   Due to this limitation, all interrupts from a given bridge must
+ *   go to the name node.  The interrupt must also be targetted for
+ *   the same processor.  This limitation does not exist on PIC.
+ *   But, the processor limitation will stay.  The limitation will be
+ *   similar to the bedrock/xbridge limit regarding PI's
+ */
+cpuid_t intr_heuristic(vertex_hdl_t dev, int req_bit, int *resp_bit)
 {
 	cpuid_t		cpuid;
 	cpuid_t		candidate = CPU_NONE;
-	cnodeid_t	candidate_node;
 	vertex_hdl_t	pconn_vhdl;
 	pcibr_soft_t	pcibr_soft;
 	int 		bit;
 
-/* SN2 + pcibr addressing limitation */
-/* Due to this limitation, all interrupts from a given bridge must go to the name node.*/
-/* The interrupt must also be targetted for the same processor. */
-/* This limitation does not exist on PIC. */
-/* But, the processor limitation will stay.  The limitation will be similar to */
-/* the bedrock/xbridge limit regarding PI's */
-
-	if ( (hwgraph_edge_get(dev, EDGE_LBL_PCI, &pconn_vhdl) = GRAPH_SUCCESS) &&
-		( (pcibr_soft = pcibr_soft_get(pconn_vhdl) ) != NULL) ) {
-			if (pcibr_soft->bsi_err_intr) {
-				candidate =  ((hub_intr_t)pcibr_soft->bsi_err_intr)->i_cpuid;
-			}
+	/* XXX: gross layering violation.. */
+	if (hwgraph_edge_get(dev, EDGE_LBL_PCI, &pconn_vhdl) = GRAPH_SUCCESS) {
+		pcibr_soft = pcibr_soft_get(pconn_vhdl);
+		if (pcibr_soft && pcibr_soft->bsi_err_intr)
+			candidate = ((hub_intr_t)pcibr_soft->bsi_err_intr)->i_cpuid;
 	}
 
-
 	if (candidate != CPU_NONE) {
-		// The cpu was chosen already when we assigned the error interrupt.
-		bit = intr_reserve_level(candidate, 
-					req_bit, 
-					resflags, 
-					owner_dev, 
-					name);
-		if (bit < 0) {
-			cpuid = CPU_NONE;
-		} else {
-			cpuid = candidate;
+		/*
+		 * The cpu was chosen already when we assigned
+		 * the error interrupt.
+		 */
+		bit = intr_reserve_level(candidate, req_bit);
+		if (bit >= 0) {
 			*resp_bit = bit;
+			return candidate;
 		}
-	} else {
-		// Need to choose one.  Try the controlling c-brick first.
-		cpuid = intr_bit_reserve_test(CPU_NONE,
-						0,
-						master_node_get(dev),
-						req_bit,
-						0,
-						owner_dev,
-						name,
-						resp_bit);
-	}
 
-	if (cpuid != CPU_NONE) {
-		return cpuid;
-	}
-
-	if (candidate  != CPU_NONE) {
 		printk("Cannot target interrupt to target node (%ld).\n",candidate);
-		return CPU_NONE; } else {
-		/* printk("Cannot target interrupt to closest node (%d) 0x%p\n",
-			master_node_get(dev), (void *)owner_dev); */
-	}
-
-	// We couldn't put it on the closest node.  Try to find another one.
-	// Do a stupid round-robin assignment of the node.
-
-	{
-		static cnodeid_t last_node = -1;
-		if (last_node >= numnodes) last_node = 0;
-		for (candidate_node = last_node + 1; candidate_node != last_node; candidate_node++) {
-			if (candidate_node = numnodes) candidate_node = 0;
-			cpuid = intr_bit_reserve_test(CPU_NONE,
-							0,
-							candidate_node,
-							req_bit,
-							0,
-							owner_dev,
-							name,
-							resp_bit);
-			if (cpuid != CPU_NONE) {
-				return cpuid;
-			}
-		}
+		return CPU_NONE;
 	}
 
-	printk("cannot target interrupt: 0x%p\n",(void *)owner_dev);
-	return CPU_NONE;
+	/*
+	 * Need to choose one.  Try the controlling c-brick first.
+	 */
+	cpuid = intr_cpu_choose_from_node(master_node_get(dev));
+	if (cpuid != CPU_NONE)
+		return cpuid;
+	return intr_cpu_choose_node();
 }
--- 1.3/arch/ia64/sn/io/sn2/shub_intr.c	Fri May 16 13:18:18 2003
+++ edited/arch/ia64/sn/io/sn2/shub_intr.c	Fri Sep 26 11:34:47 2003
@@ -1,5 +1,4 @@
-/* $Id: shub_intr.c,v 1.1 2002/02/28 17:31:25 marcelo Exp $
- *
+/*
  * This file is subject to the terms and conditions of the GNU General Public
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
@@ -61,8 +60,7 @@
 	xwidget_info_t	xwidget_info;
 	ilvl_t		intr_swlevel = 0;
 
-	cpu = intr_heuristic(dev, dev_desc, -1, 0, owner_dev, NULL, &vector);
-
+	cpu = intr_heuristic(dev, -1, &vector);
 	if (cpu = CPU_NONE) {
 		printk("Unable to allocate interrupt for 0x%p\n", (void *)owner_dev);
 		return(0);
@@ -150,10 +148,9 @@
 
 	ASSERT(intr_hdl->i_flags & HUB_INTR_IS_ALLOCED);
 
-	rv = intr_connect_level(cpu, vector, intr_hdl->i_swlevel, NULL);
-	if (rv < 0) {
+	rv = intr_connect_level(cpu, vector);
+	if (rv < 0)
 		return rv;
-	}
 
 	intr_hdl->i_xtalk_info.xi_setfunc = setfunc;
 	intr_hdl->i_xtalk_info.xi_sfarg = setfunc_arg;
--- 1.6/arch/ia64/sn/io/sn2/shuberror.c	Mon Aug  4 19:02:37 2003
+++ edited/arch/ia64/sn/io/sn2/shuberror.c	Fri Sep 26 11:34:47 2003
@@ -145,14 +145,13 @@
     /* Select a possible interrupt target where there is a free interrupt
      * bit and also reserve the interrupt bit for this IO error interrupt
      */
-    intr_cpu = intr_heuristic(hub_v,0,SGI_II_ERROR,0,hub_v,
-			      "HUB IO error interrupt",&bit);
+    intr_cpu = intr_heuristic(hub_v, SGI_II_ERROR, &bit);
     if (intr_cpu = CPU_NONE) {
-	printk("hubii_eint_init: intr_reserve_level failed, cnode %d", cnode);
+	printk("hubii_eint_init: intr_heuristic failed, cnode %d", cnode);
 	return;
     }
 	
-    rv = intr_connect_level(intr_cpu, SGI_II_ERROR, 0, NULL);
+    rv = intr_connect_level(intr_cpu, SGI_II_ERROR);
     request_irq(SGI_II_ERROR, hubii_eint_handler, SA_SHIRQ, "SN_hub_error", (void *)hub_v);
     irq_descp(bit)->status |= SN2_IRQ_PER_HUB;
     ASSERT_ALWAYS(rv >= 0);
--- 1.4/include/asm-ia64/sn/sn2/sn_private.h	Wed Jul 30 13:40:14 2003
+++ edited/include/asm-ia64/sn/sn2/sn_private.h	Fri Sep 26 11:34:47 2003
@@ -49,14 +49,10 @@
 #endif
 
 /* intr.c */
-extern int intr_reserve_level(cpuid_t cpu, int level, int err, vertex_hdl_t owner_dev, char *name);
 extern void intr_unreserve_level(cpuid_t cpu, int level);
-extern int intr_connect_level(cpuid_t cpu, int bit, ilvl_t mask_no, 
-			intr_func_t intr_prefunc);
+extern int intr_connect_level(cpuid_t cpu, int bit);
 extern int intr_disconnect_level(cpuid_t cpu, int bit);
-extern cpuid_t intr_heuristic(vertex_hdl_t dev, device_desc_t dev_desc,
-			      int req_bit,int intr_resflags,vertex_hdl_t owner_dev,
-			      char *intr_name,int *resp_bit);
+extern cpuid_t intr_heuristic(vertex_hdl_t dev, int req_bit, int *resp_bit);
 extern void intr_block_bit(cpuid_t cpu, int bit);
 extern void intr_unblock_bit(cpuid_t cpu, int bit);
 extern void setrtvector(intr_func_t);

----- End forwarded message -----
