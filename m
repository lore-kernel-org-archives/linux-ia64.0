From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 12 May 2004 16:08:14 +0000
Subject: [PATCH] kill some more unused/redundant code
Message-Id: <200405120908.14931.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_uvkoAmo64SMvMQN"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_uvkoAmo64SMvMQN
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch kills some unused lines and redundant functions I noticed when 
doing the last patch.

Jesse

--Boundary-00=_uvkoAmo64SMvMQN
Content-Type: text/plain;
  charset="us-ascii";
  name="kill-unused-sn-code.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="kill-unused-sn-code.patch"

diff -Nru a/arch/ia64/sn/io/io.c b/arch/ia64/sn/io/io.c
--- a/arch/ia64/sn/io/io.c	Tue May 11 15:25:13 2004
+++ b/arch/ia64/sn/io/io.c	Tue May 11 15:25:13 2004
@@ -651,7 +651,7 @@
 	hubii_wcr_t ii_wcr;
 	int prbnum;
 
-	ASSERT(NASID_TO_COMPACT_NODEID(nasid) != INVALID_CNODEID);
+	ASSERT(nasid_to_cnodeid(nasid) != INVALID_CNODEID);
 
 	ii_iowa = REMOTE_HUB_L(nasid, IIO_OUTWIDGET_ACCESS);
 	REMOTE_HUB_S(nasid, IIO_OUTWIDGET_ACCESS, 0);
diff -Nru a/arch/ia64/sn/io/machvec/pci_bus_cvlink.c b/arch/ia64/sn/io/machvec/pci_bus_cvlink.c
--- a/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Tue May 11 15:25:13 2004
+++ b/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Tue May 11 15:25:13 2004
@@ -712,7 +712,7 @@
 			
 			/* Is this PCI bus associated with this moduleid? */
 			moduleid = NODE_MODULEID(
-				NASID_TO_COMPACT_NODEID(pcibr_soft->bs_nasid));
+				nasid_to_cnodeid(pcibr_soft->bs_nasid));
 			if (modules[i]->id == moduleid) {
 				struct pcibr_list_s *new_element;
 
@@ -791,8 +791,7 @@
 	struct list_head *ln;
 	struct pci_bus *pci_bus = NULL;
 	struct pci_dev *pci_dev = NULL;
-	extern int numnodes;
-	int cnode, ret;
+	int ret;
 #ifdef CONFIG_PROC_FS
 	extern void register_sn_procfs(void);
 #endif
diff -Nru a/arch/ia64/sn/io/platform_init/sgi_io_init.c b/arch/ia64/sn/io/platform_init/sgi_io_init.c
--- a/arch/ia64/sn/io/platform_init/sgi_io_init.c	Tue May 11 15:25:13 2004
+++ b/arch/ia64/sn/io/platform_init/sgi_io_init.c	Tue May 11 15:25:13 2004
@@ -26,7 +26,6 @@
 extern void io_module_init(void);
 extern int pci_bus_to_hcl_cvlink(void);
 
-cpuid_t master_procid;
 nasid_t console_nasid = (nasid_t) - 1;
 char master_baseio_wid;
 
@@ -47,10 +46,10 @@
 	ii_ibcr_u_t ii_ibcr;
 	ii_ilcsr_u_t ii_ilcsr;
 
-	nasid = COMPACT_TO_NASID_NODEID(cnode);
+	nasid = cnodeid_to_nasid(cnode);
 
 	ASSERT(nasid != INVALID_NASID);
-	ASSERT(NASID_TO_COMPACT_NODEID(nasid) == cnode);
+	ASSERT(nasid_to_cnodeid(nasid) == cnode);
 
 	npdap = NODEPDA(cnode);
 
@@ -150,7 +149,7 @@
 check_nasid_equiv(nasid_t nasida, nasid_t nasidb)
 {
 	if ((nasida == nasidb)
-	    || (nasida == NODEPDA(NASID_TO_COMPACT_NODEID(nasidb))->xbow_peer))
+	    || (nasida == NODEPDA(nasid_to_cnodeid(nasidb))->xbow_peer))
 		return 1;
 	else
 		return 0;
diff -Nru a/arch/ia64/sn/io/sn2/klgraph.c b/arch/ia64/sn/io/sn2/klgraph.c
--- a/arch/ia64/sn/io/sn2/klgraph.c	Tue May 11 15:25:13 2004
+++ b/arch/ia64/sn/io/sn2/klgraph.c	Tue May 11 15:25:13 2004
@@ -65,7 +65,7 @@
         cpuid_t cpu_id;
 	nasid_t nasid;
 
-	nasid = COMPACT_TO_NASID_NODEID(cnode);
+	nasid = cnodeid_to_nasid(cnode);
         cpu_id = nasid_slice_to_cpuid(nasid, cpu->cpu_info.physid);
         if(cpu_id != -1){
 		snprintf(name, 120, "%s/%s/%c", EDGE_LBL_DISABLED, EDGE_LBL_CPU, 'a' + cpu->cpu_info.physid);
@@ -88,7 +88,7 @@
         cpuid_t cpu_id;
 	nasid_t nasid;
 
-	nasid = COMPACT_TO_NASID_NODEID(cnode);
+	nasid = cnodeid_to_nasid(cnode);
         cpu_id = nasid_slice_to_cpuid(nasid, cpu->cpu_info.physid);
 
         snprintf(name, 120, "%s/%d/%c",
@@ -145,7 +145,7 @@
 			continue;
 		}
 
-		hub_cnode = NASID_TO_COMPACT_NODEID(hub_nasid);
+		hub_cnode = nasid_to_cnodeid(hub_nasid);
 
 		if (hub_cnode == INVALID_CNODEID) {
 			continue;
@@ -178,7 +178,7 @@
 		 */
 		if (hub_nasid != nasid) {
 			NODEPDA(hub_cnode)->xbow_peer = nasid;
-			NODEPDA(NASID_TO_COMPACT_NODEID(nasid))->xbow_peer =
+			NODEPDA(nasid_to_cnodeid(nasid))->xbow_peer =
 				hub_nasid;
 		}
 	}
@@ -200,7 +200,7 @@
 	klcpu_t *cpu;
 	vertex_hdl_t cpu_dir;
 
-	nasid = COMPACT_TO_NASID_NODEID(cnode);
+	nasid = cnodeid_to_nasid(cnode);
 	brd = find_lboard_any((lboard_t *)KL_CONFIG_INFO(nasid), KLTYPE_SNIA);
 	ASSERT(brd);
 
@@ -280,7 +280,7 @@
 	int rv;
 
 	for (cnode = 0; cnode < numnodes; cnode++) {
-		nasid = COMPACT_TO_NASID_NODEID(cnode);
+		nasid = cnodeid_to_nasid(cnode);
 		brd = find_lboard_class_any((lboard_t *)KL_CONFIG_INFO(nasid),
 				KLTYPE_ROUTER);
 
@@ -363,7 +363,7 @@
 				 port));
 			continue;
 		}
-		if (NASID_TO_COMPACT_NODEID(router->rou_port[port].port_nasid) 
+		if (nasid_to_cnodeid(router->rou_port[port].port_nasid) 
 		    == INVALID_CNODEID) {
 			continue;
 		}
@@ -414,7 +414,7 @@
 	lboard_t *brd;
 
 	for (cnode = 0; cnode < numnodes; cnode++) {
-		nasid = COMPACT_TO_NASID_NODEID(cnode);
+		nasid = cnodeid_to_nasid(cnode);
 		brd = find_lboard_class_any((lboard_t *)KL_CONFIG_INFO(nasid),
 				KLTYPE_ROUTER);
 
@@ -423,7 +423,7 @@
 
 		do {
 
-			nasid = COMPACT_TO_NASID_NODEID(cnode);
+			nasid = cnodeid_to_nasid(cnode);
 
 			klhwg_connect_one_router(hwgraph_root, brd,
 						 cnode, nasid);
@@ -451,7 +451,7 @@
 	int port;
 
 	for (cnode = 0; cnode < numionodes; cnode++) {
-		nasid = COMPACT_TO_NASID_NODEID(cnode);
+		nasid = cnodeid_to_nasid(cnode);
 
 		brd = find_lboard_any((lboard_t *)KL_CONFIG_INFO(nasid), KLTYPE_SNIA);
 
@@ -463,7 +463,7 @@
 				continue; /* Port not active */
 			}
 
-			if (NASID_TO_COMPACT_NODEID(hub->hub_port[port].port_nasid) == INVALID_CNODEID)
+			if (nasid_to_cnodeid(hub->hub_port[port].port_nasid) == INVALID_CNODEID)
 				continue;
 
 			/* Generate a hardware graph path for this board. */
diff -Nru a/arch/ia64/sn/io/sn2/ml_SN_init.c b/arch/ia64/sn/io/sn2/ml_SN_init.c
--- a/arch/ia64/sn/io/sn2/ml_SN_init.c	Tue May 11 15:25:13 2004
+++ b/arch/ia64/sn/io/sn2/ml_SN_init.c	Tue May 11 15:25:13 2004
@@ -31,13 +31,9 @@
 	hubinfo_t hubinfo;
 	nasid_t nasid;
 
-	extern void router_map_init(nodepda_t *);
-	extern void router_queue_init(nodepda_t *,cnodeid_t);
-	extern void intr_init_vecblk(nodepda_t *, cnodeid_t, int);
-
 	/* Allocate per-node platform-dependent data */
 	
-	nasid = COMPACT_TO_NASID_NODEID(node);
+	nasid = cnodeid_to_nasid(node);
 	if (node >= numnodes) /* Headless/memless IO nodes */
 		hubinfo = (hubinfo_t)alloc_bootmem_node(NODE_DATA(0), sizeof(struct hubinfo_s));
 	else
@@ -81,7 +77,7 @@
 	for (cnode = 0; cnode < numionodes; cnode++) {
 		npda = nodepdaindr[cnode];
 		hubinfo = (hubinfo_t)npda->pdinfo;
-		hubinfo->h_nasid = COMPACT_TO_NASID_NODEID(cnode);
+		hubinfo->h_nasid = cnodeid_to_nasid(cnode);
 		hubinfo->h_widgetid = hub_widget_id(hubinfo->h_nasid);
 	}
 }
diff -Nru a/arch/ia64/sn/io/sn2/ml_iograph.c b/arch/ia64/sn/io/sn2/ml_iograph.c
--- a/arch/ia64/sn/io/sn2/ml_iograph.c	Tue May 11 15:25:13 2004
+++ b/arch/ia64/sn/io/sn2/ml_iograph.c	Tue May 11 15:25:13 2004
@@ -313,7 +313,7 @@
 
 	hubinfo_get(hubv, &hubinfo);
 	nasid = hubinfo->h_nasid;
-	cnode = NASID_TO_COMPACT_NODEID(nasid);
+	cnode = nasid_to_cnodeid(nasid);
 	hub_widgetid = hubinfo->h_widgetid;
 
 	/*
@@ -567,7 +567,7 @@
 	 * and hence widget id is Not 0.
 	 */
 	widget_partnum = (((*(volatile int32_t *)(NODE_SWIN_BASE
-			(COMPACT_TO_NASID_NODEID(cnodeid), 0) + 
+			(cnodeid_to_nasid(cnodeid), 0) + 
 			WIDGET_ID))) & WIDGET_PART_NUM) 
 			>> WIDGET_PART_NUM_SHFT;
 
@@ -584,7 +584,7 @@
 	} else {
 		void	*bridge;
 
-		bridge = (void *)NODE_SWIN_BASE(COMPACT_TO_NASID_NODEID(cnodeid), 0);
+		bridge = (void *)NODE_SWIN_BASE(cnodeid_to_nasid(cnodeid), 0);
 		npdap->basew_id = pcireg_bridge_control_get(bridge) & WIDGET_WIDGET_ID;
 
 		printk(" ****io_init_node: Unknown Widget Part Number 0x%x Widget ID 0x%x attached to Hubv 0x%p ****\n", widget_partnum, npdap->basew_id, (void *)hubv);
@@ -637,7 +637,7 @@
 
 		/* If there's someone else on this crossbow, recognize him */
 		if (npdap->xbow_peer != INVALID_NASID) {
-			nodepda_t *peer_npdap = NODEPDA(NASID_TO_COMPACT_NODEID(npdap->xbow_peer));
+			nodepda_t *peer_npdap = NODEPDA(nasid_to_cnodeid(npdap->xbow_peer));
 			peer_sema = &peer_npdap->xbow_sema;
 			volunteer_for_widgets(switchv, peer_npdap->node_vertex);
 		}
diff -Nru a/arch/ia64/sn/io/sn2/module.c b/arch/ia64/sn/io/sn2/module.c
--- a/arch/ia64/sn/io/sn2/module.c	Tue May 11 15:25:13 2004
+++ b/arch/ia64/sn/io/sn2/module.c	Tue May 11 15:25:13 2004
@@ -196,7 +196,7 @@
      * We do not support memoryless compute nodes.
      */
     for (node = 0; node < numnodes; node++) {
-	nasid = COMPACT_TO_NASID_NODEID(node);
+	nasid = cnodeid_to_nasid(node);
 	board = find_lboard_nasid((lboard_t *) KL_CONFIG_INFO(nasid), nasid, KLTYPE_SNIA);
 	ASSERT(board);
 
@@ -214,7 +214,7 @@
 	nasid_t		nasid;
 	char		serial_number[16];
 
-        nasid = COMPACT_TO_NASID_NODEID(node);
+        nasid = cnodeid_to_nasid(node);
 	board = find_lboard_nasid((lboard_t *) KL_CONFIG_INFO(nasid), 
 				nasid, KLTYPE_SNIA);
 	ASSERT(board);
diff -Nru a/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c b/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c
--- a/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c	Tue May 11 15:25:13 2004
+++ b/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c	Tue May 11 15:25:13 2004
@@ -758,7 +758,7 @@
     cnodeid_t		cnodeid = 0;	/* We need api for diroff api */
     nasid_t		nasid;
 
-    nasid = COMPACT_TO_NASID_NODEID(cnodeid);
+    nasid = cnodeid_to_nasid(cnodeid);
     paddr = NODE_OFFSET(nasid) + 0;
 
     /* Assume that if we ask for a DMA mapping to zero the XIO host will
@@ -2092,7 +2092,7 @@
 	pciio_info_t	pciio_info = pciio_info_get(pconn_vhdl);
 	pcibr_soft_t	pcibr_soft = (pcibr_soft_t) pciio_info_mfast_get(pciio_info);
 
-	return NASID_TO_COMPACT_NODEID(NASID_GET(pcibr_soft->bs_dir_xbase));
+	return nasid_to_cnodeid(NASID_GET(pcibr_soft->bs_dir_xbase));
 }
 
 /*ARGSUSED */
@@ -2645,7 +2645,7 @@
                         brd = KLCF_NEXT(brd);
 	}
 	/* if it's dual ported, check the peer also */
-	nasid = NODEPDA(NASID_TO_COMPACT_NODEID(nasid))->xbow_peer;
+	nasid = NODEPDA(nasid_to_cnodeid(nasid))->xbow_peer;
 	if (nasid < 0) return 0;
 	brd = (lboard_t *)KL_CONFIG_INFO(nasid);
 	while (brd) {
diff -Nru a/arch/ia64/sn/io/sn2/pic.c b/arch/ia64/sn/io/sn2/pic.c
--- a/arch/ia64/sn/io/sn2/pic.c	Tue May 11 15:25:13 2004
+++ b/arch/ia64/sn/io/sn2/pic.c	Tue May 11 15:25:13 2004
@@ -124,7 +124,7 @@
 static vertex_hdl_t
 pic_bus1_redist(nasid_t nasid, vertex_hdl_t conn_v)
 {
-	cnodeid_t cnode = NASID_TO_COMPACT_NODEID(nasid);
+	cnodeid_t cnode = nasid_to_cnodeid(nasid);
 	cnodeid_t xbow_peer = -1;
 	char pathname[256], peer_path[256], tmpbuf[256];
 	char *p;
@@ -137,7 +137,7 @@
 		/* create a path for this widget on the peer Cbrick */
 		/* pcibr widget hw/module/001c11/slab/0/Pbrick/xtalk/12 */
 		/* sprintf(pathname, "%v", conn_v); */
-		xbow_peer = NASID_TO_COMPACT_NODEID(NODEPDA(cnode)->xbow_peer);
+		xbow_peer = nasid_to_cnodeid(NODEPDA(cnode)->xbow_peer);
 		pos = hwgfs_generate_path(conn_v, tmpbuf, 256);
 		strcpy(pathname, &tmpbuf[pos]);
 		p = pathname + strlen("hw/module/001c01/slab/0/");
diff -Nru a/arch/ia64/sn/io/sn2/shuberror.c b/arch/ia64/sn/io/sn2/shuberror.c
--- a/arch/ia64/sn/io/sn2/shuberror.c	Tue May 11 15:25:13 2004
+++ b/arch/ia64/sn/io/sn2/shuberror.c	Tue May 11 15:25:13 2004
@@ -157,7 +157,7 @@
     hubio_eint.ii_iidsr_regval = 0;
     hubio_eint.ii_iidsr_fld_s.i_enable = 1;
     hubio_eint.ii_iidsr_fld_s.i_level = bit;/* Take the least significant bits*/
-    hubio_eint.ii_iidsr_fld_s.i_node = COMPACT_TO_NASID_NODEID(cnode);
+    hubio_eint.ii_iidsr_fld_s.i_node = cnodeid_to_nasid(cnode);
     hubio_eint.ii_iidsr_fld_s.i_pi_id = cpuid_to_subnode(intr_cpu);
     REMOTE_HUB_S(hinfo->h_nasid, IIO_IIDSR, hubio_eint.ii_iidsr_regval);
 
@@ -450,7 +450,7 @@
 	int		rc;
 
 	nasid = hinfo->h_nasid;
-	cnode = NASID_TO_COMPACT_NODEID(nasid);
+	cnode = nasid_to_cnodeid(nasid);
 
 	/*
 	 * XXX - Add locking for any recovery actions
diff -Nru a/arch/ia64/sn/io/sn2/shubio.c b/arch/ia64/sn/io/sn2/shubio.c
--- a/arch/ia64/sn/io/sn2/shubio.c	Tue May 11 15:25:13 2004
+++ b/arch/ia64/sn/io/sn2/shubio.c	Tue May 11 15:25:13 2004
@@ -76,7 +76,7 @@
 	/* Get the error state of the hub */
 	e_state = error_state_get(hub_v);
 
-	cnode = NASID_TO_COMPACT_NODEID(nasid);
+	cnode = nasid_to_cnodeid(nasid);
 
 	xswitch = NODEPDA(cnode)->basew_xc;
 
@@ -119,7 +119,7 @@
 		return(0);
 
 	/* Get the nasid for the cnode */
-	src_nasid = COMPACT_TO_NASID_NODEID(src_node);
+	src_nasid = cnodeid_to_nasid(src_node);
 	if (src_nasid == INVALID_NASID)
 		return(0);
 
diff -Nru a/drivers/char/sn_serial.c b/drivers/char/sn_serial.c
--- a/drivers/char/sn_serial.c	Tue May 11 15:25:13 2004
+++ b/drivers/char/sn_serial.c	Tue May 11 15:25:13 2004
@@ -502,7 +502,7 @@
 	int result;
 
 	console_nasid = ia64_sn_get_console_nasid();
-	intr_cpuid = first_cpu(node_to_cpumask(NASID_TO_COMPACT_NODEID(console_nasid)));
+	intr_cpuid = first_cpu(node_to_cpumask(nasid_to_cnodeid(console_nasid)));
 	intr_cpuloc = cpu_physical_id(intr_cpuid);
 	console_irq = CPU_VECTOR_TO_IRQ(intr_cpuloc, SGI_UART_VECTOR);
 
diff -Nru a/include/asm-ia64/sn/arch.h b/include/asm-ia64/sn/arch.h
--- a/include/asm-ia64/sn/arch.h	Tue May 11 15:25:13 2004
+++ b/include/asm-ia64/sn/arch.h	Tue May 11 15:25:13 2004
@@ -20,10 +20,6 @@
 typedef u64	mmr_t;
 typedef u64	nic_t;
 
-#define NASID_TO_COMPACT_NODEID(nasid)  (nasid_to_cnodeid(nasid))
-#define COMPACT_TO_NASID_NODEID(cnode)  (cnodeid_to_nasid(cnode))
-
-
 #define INVALID_NASID		((nasid_t)-1)
 #define INVALID_CNODEID		((cnodeid_t)-1)
 #define INVALID_PNODEID		((pnodeid_t)-1)
diff -Nru a/include/asm-ia64/sn/intr.h b/include/asm-ia64/sn/intr.h
--- a/include/asm-ia64/sn/intr.h	Tue May 11 15:25:13 2004
+++ b/include/asm-ia64/sn/intr.h	Tue May 11 15:25:13 2004
@@ -8,9 +8,11 @@
 #ifndef _ASM_IA64_SN_INTR_H
 #define _ASM_IA64_SN_INTR_H
 
+#include <asm/sn/types.h>
 #include <asm/sn/sn2/intr.h>
 
 extern void sn_send_IPI_phys(long, int, int);
+extern void intr_init_vecblk(cnodeid_t node);
 
 #define CPU_VECTOR_TO_IRQ(cpuid,vector) (vector)
 #define SN_CPU_FROM_IRQ(irq)	(0)
diff -Nru a/include/asm-ia64/sn/module.h b/include/asm-ia64/sn/module.h
--- a/include/asm-ia64/sn/module.h	Tue May 11 15:25:13 2004
+++ b/include/asm-ia64/sn/module.h	Tue May 11 15:25:13 2004
@@ -184,10 +184,6 @@
 extern int		nummodules;
 
 extern module_t	       *module_lookup(moduleid_t id);
-
-extern int		get_kmod_sys_snum(cmoduleid_t cmod,
-					  char *snum);
-
 extern void		format_module_id(char *buffer, moduleid_t m, int fmt);
 extern int		parse_module_id(char *buffer);
 
diff -Nru a/include/asm-ia64/sn/sn2/sn_private.h b/include/asm-ia64/sn/sn2/sn_private.h
--- a/include/asm-ia64/sn/sn2/sn_private.h	Tue May 11 15:25:13 2004
+++ b/include/asm-ia64/sn/sn2/sn_private.h	Tue May 11 15:25:13 2004
@@ -233,7 +233,7 @@
  * address.
  */
 #define paddr_dimm(_pa)		((_pa & MD_BANK_MASK) >> MD_BANK_SHFT)
-#define paddr_cnode(_pa)	(NASID_TO_COMPACT_NODEID(NASID_GET(_pa)))
+#define paddr_cnode(_pa)	(nasid_to_cnodeid(NASID_GET(_pa)))
 extern void membank_pathname_get(paddr_t, char *);
 
 extern void crbx(nasid_t nasid, void (*pf) (char *, ...));
diff -Nru a/include/asm-ia64/sn/types.h b/include/asm-ia64/sn/types.h
--- a/include/asm-ia64/sn/types.h	Tue May 11 15:25:13 2004
+++ b/include/asm-ia64/sn/types.h	Tue May 11 15:25:13 2004
@@ -15,11 +15,9 @@
 typedef unsigned int    moduleid_t;     /* user-visible module number type */
 typedef unsigned int    cmoduleid_t;    /* kernel compact module id type */
 typedef signed char     slabid_t;
-typedef unsigned char	clusterid_t;	/* Clusterid of the cell */
 
 typedef unsigned long iopaddr_t;
 typedef unsigned long paddr_t;
-typedef unsigned long pfn_t;
 typedef short cnodeid_t;
 
 #endif /* _ASM_IA64_SN_TYPES_H */

--Boundary-00=_uvkoAmo64SMvMQN--
