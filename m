From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 30 Jul 2003 18:41:47 +0000
Subject: [PATCH] sn2 update
MIME-Version: 1
Content-Type: multipart/mixed; boundary="OgqxwSJOaUobr8KG"
Message-Id: <marc-linux-ia64-105959072221465@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Small sn2 update with some cleanups and bugfixes.

Thanks,
Jesse

 arch/ia64/sn/io/hwgfs/hcl.c           |   22 -
 arch/ia64/sn/io/hwgfs/interface.c     |    1
 arch/ia64/sn/io/io.c                  |   20 -
 arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c |  150 ---------
 arch/ia64/sn/io/xswitch.c             |   68 ----
 arch/ia64/sn/kernel/Makefile          |    4
 arch/ia64/sn/kernel/mca.c             |    9
 arch/ia64/sn/kernel/sv.c              |  551 ----------------------------------
 include/asm-ia64/sn/dmamap.h          |    4
 include/asm-ia64/sn/hcl.h             |    1
 include/asm-ia64/sn/ksys/l1.h         |    1
 include/asm-ia64/sn/nodepda.h         |    3
 include/asm-ia64/sn/sn2/sn_private.h  |    3
 include/asm-ia64/sn/sv.h              |  153 ---------
 14 files changed, 28 insertions(+), 962 deletions(-)

--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sn2-update-2.6.0-test2-ia64-bk.patch"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1397  -> 1.1398 
#	arch/ia64/sn/kernel/Makefile	1.14    -> 1.15   
#	include/asm-ia64/sn/sn2/sn_private.h	1.3     -> 1.4    
#	arch/ia64/sn/kernel/mca.c	1.5     -> 1.6    
#	arch/ia64/sn/kernel/sv.c	1.6     -> 1.7    
#	include/asm-ia64/sn/nodepda.h	1.5     -> 1.6    
#	arch/ia64/sn/io/xswitch.c	1.6     -> 1.7    
#	include/asm-ia64/sn/sv.h	1.4     -> 1.5    
#	include/asm-ia64/sn/ksys/l1.h	1.5     -> 1.6    
#	include/asm-ia64/sn/hcl.h	1.4     -> 1.5    
#	arch/ia64/sn/io/io.c	1.7     -> 1.8    
#	arch/ia64/sn/io/hwgfs/hcl.c	1.4     -> 1.5    
#	include/asm-ia64/sn/dmamap.h	1.4     -> 1.5    
#	arch/ia64/sn/io/hwgfs/interface.c	1.1     -> 1.2    
#	arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c	1.11    -> 1.12   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/07/30	jbarnes@tomahawk.engr.sgi.com	1.1398
# sn2 update
# --------------------------------------------
#
diff -Nru a/arch/ia64/sn/io/hwgfs/hcl.c b/arch/ia64/sn/io/hwgfs/hcl.c
--- a/arch/ia64/sn/io/hwgfs/hcl.c	Wed Jul 30 11:40:14 2003
+++ b/arch/ia64/sn/io/hwgfs/hcl.c	Wed Jul 30 11:40:14 2003
@@ -759,28 +759,6 @@
 }
 
 /*
- * hwgraph_path_lookup - return the handle for the given path.
- *
- */
-int
-hwgraph_path_lookup(vertex_hdl_t start_vertex_handle,
-			char *lookup_path,
-			vertex_hdl_t *vertex_handle_ptr,
-			char **remainder)
-{
-	*vertex_handle_ptr = hwgfs_find_handle(start_vertex_handle,	/* start dir */
-					lookup_path,		/* path */
-					0,			/* major */
-					0,			/* minor */
-					0,			/* char | block */
-					1);			/* traverse symlinks */
-	if (*vertex_handle_ptr == NULL)
-		return(-1);
-	else
-		return(0);
-}
-
-/*
  * hwgraph_traverse - Find and return the handle starting from de.
  *
  */
diff -Nru a/arch/ia64/sn/io/hwgfs/interface.c b/arch/ia64/sn/io/hwgfs/interface.c
--- a/arch/ia64/sn/io/hwgfs/interface.c	Wed Jul 30 11:40:14 2003
+++ b/arch/ia64/sn/io/hwgfs/interface.c	Wed Jul 30 11:40:14 2003
@@ -69,6 +69,7 @@
 			return error;
 
 		nd->dentry = lookup_create(nd, is_dir);
+		nd->flags |= LOOKUP_PARENT;
 		if (unlikely(IS_ERR(nd->dentry)))
 			return PTR_ERR(nd->dentry);
 
diff -Nru a/arch/ia64/sn/io/io.c b/arch/ia64/sn/io/io.c
--- a/arch/ia64/sn/io/io.c	Wed Jul 30 11:40:14 2003
+++ b/arch/ia64/sn/io/io.c	Wed Jul 30 11:40:14 2003
@@ -87,11 +87,7 @@
 	hub_set_piomode(nasid, HUB_PIO_CONVEYOR);
 
 	mutex_spinlock_init(&hubinfo->h_bwlock);
-/*
- * If this lock can be acquired from interrupts or bh's, add SV_INTS or SV_BHS,
- * respectively, to the flags here.
- */
-	sv_init(&hubinfo->h_bwwait, &hubinfo->h_bwlock, SV_ORDER_FIFO | SV_MON_SPIN); 
+	init_waitqueue_head(&hubinfo->h_bwwait);
 }
 
 /* 
@@ -215,10 +211,16 @@
 			if (flags & PIOMAP_NOSLEEP) {
 				bw_piomap = NULL;
 				goto done;
-			}
+			} else {
+				DECLARE_WAITQUEUE(wait, current);
 
-			sv_wait(&hubinfo->h_bwwait, 0, 0);
-			goto tryagain;
+				spin_unlock(&hubinfo->h_bwlock); 
+				set_current_state(TASK_UNINTERRUPTIBLE);
+				add_wait_queue_exclusive(&hubinfo->h_bwwait, &wait);
+				schedule();
+				remove_wait_queue(&hubinfo->h_bwwait, &wait);
+				goto tryagain;
+			}
 		}
 	}
 
@@ -316,7 +318,7 @@
 		} else
 			hub_piomap->hpio_flags &= ~HUB_PIOMAP_IS_VALID;
 
-		(void)sv_signal(&hubinfo->h_bwwait);
+		wake_up(&hubinfo->h_bwwait);
 	}
 
 	mutex_spinunlock(&hubinfo->h_bwlock, s);
diff -Nru a/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c b/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c
--- a/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c	Wed Jul 30 11:40:14 2003
+++ b/arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c	Wed Jul 30 11:40:14 2003
@@ -474,11 +474,6 @@
 	     */
 	    if (bad) {
 		pcibr_unlock(pcibr_soft, s);
-#ifdef PIC_LATER
-		PCIBR_DEBUG((PCIBR_DEBUG_DEVREG, pcibr_soft->bs_vhdl,
-			    "pcibr_try_set_device: mod blocked by %x\n",
-			    bad, device_bits));
-#endif
 		return bad;
 	    }
 	}
@@ -519,13 +514,7 @@
     }
     pcibr_unlock(pcibr_soft, s);
 
-#ifdef PIC_LATER
-    PCIBR_DEBUG((PCIBR_DEBUG_DEVREG, pcibr_soft->bs_vhdl,
-		"pcibr_try_set_device: Device(%d): %x\n",
-		slot, new, device_bits));
-#else
     printk("pcibr_try_set_device: Device(%d): %x\n", slot, new);
-#endif
     return 0;
 }
 
@@ -824,14 +813,7 @@
     slot = PCIBR_INFO_SLOT_GET_INT(pciio_info);
 
     pcibr_soft = pcibr_soft_get(pcibr_vhdl);
-
-#ifdef PIC_LATER
-    /* This may be a loadable driver so lock out any pciconfig actions */
-    mrlock(pcibr_soft->bs_bus_lock, MR_UPDATE, PZERO);
-#endif
-
     pcibr_info->f_att_det_error = error;
-
     pcibr_soft->bs_slot[slot].slot_status &= ~SLOT_STATUS_MASK;
 
     if (error) {
@@ -839,11 +821,6 @@
     } else {
         pcibr_soft->bs_slot[slot].slot_status |= SLOT_STARTUP_CMPLT;
     }
-        
-#ifdef PIC_LATER
-    /* Release the bus lock */
-    mrunlock(pcibr_soft->bs_bus_lock);
-#endif
 }
 
 /*
@@ -875,14 +852,7 @@
     slot = PCIBR_INFO_SLOT_GET_INT(pciio_info);
 
     pcibr_soft = pcibr_soft_get(pcibr_vhdl);
-
-#ifdef PIC_LATER
-    /* This may be a loadable driver so lock out any pciconfig actions */
-    mrlock(pcibr_soft->bs_bus_lock, MR_UPDATE, PZERO);
-#endif
-
     pcibr_info->f_att_det_error = error;
-
     pcibr_soft->bs_slot[slot].slot_status &= ~SLOT_STATUS_MASK;
 
     if (error) {
@@ -890,11 +860,6 @@
     } else {
         pcibr_soft->bs_slot[slot].slot_status |= SLOT_SHUTDOWN_CMPLT;
     }
-
-#ifdef PIC_LATER
-    /* Release the bus lock */
-    mrunlock(pcibr_soft->bs_bus_lock);
-#endif
 }
 
 /* 
@@ -1245,9 +1210,6 @@
      * Initialize bridge and bus locks
      */
     spin_lock_init(&pcibr_soft->bs_lock);
-#ifdef PIC_LATER
-    mrinit(pcibr_soft->bs_bus_lock, "bus_lock");
-#endif
     /*
      * If we have one, process the hints structure.
      */
@@ -2250,17 +2212,10 @@
 	     * arguments fails so sprintf() it into a temporary string.
 	     */
 	    if (pcibr_debug_mask & PCIBR_DEBUG_PIOMAP) {
-#ifdef PIC_LATER
-	        sprintf(tmp_str, "pcibr_addr_pci_to_xio: map to %x[%x..%x] for "
-		        "slot %d allocates DevIO(%d) Device(%d) set to %x\n",
-		        space, space_desc, pci_addr, pci_addr + req_size - 1,
-		        slot, win, win, devreg, device_bits);
-#else
 	        sprintf(tmp_str, "pcibr_addr_pci_to_xio: map to [%lx..%lx] for "
 		        "slot %d allocates DevIO(%d) Device(%d) set to %lx\n",
 		        (unsigned long)pci_addr, (unsigned long)(pci_addr + req_size - 1),
 		        (unsigned int)slot, win, win, (unsigned long)devreg);
-#endif
 	        PCIBR_DEBUG((PCIBR_DEBUG_PIOMAP, pconn_vhdl, "%s", tmp_str));
 	    }
 	    goto done;
@@ -2291,11 +2246,6 @@
             pcibr_info->f_window[bar].w_devio_index = win;
 
 	if (pcibr_debug_mask & PCIBR_DEBUG_PIOMAP) {
-#ifdef PIC_LATER
-	    sprintf(tmp_str, "pcibr_addr_pci_to_xio: map to %x[%x..%x] for "
-		    "slot %d uses DevIO(%d)\n", space, space_desc, pci_addr,
-		    pci_addr + req_size - 1, slot, win);
-#endif
 	    PCIBR_DEBUG((PCIBR_DEBUG_PIOMAP, pconn_vhdl, "%s", tmp_str));
 	}
 	goto done;
@@ -2392,14 +2342,6 @@
 	    ;
 	} else if (bfo != 0) {		/* we have a conflict. */
 	    if (pcibr_debug_mask & PCIBR_DEBUG_PIOMAP) {
-#ifdef PIC_LATER
-	        sprintf(tmp_str, "pcibr_addr_pci_to_xio: swap conflict in %x, "
-		        "was%s%s, want%s%s\n", space, space_desc,
-		        bfo & PCIIO_BYTE_STREAM ? " BYTE_STREAM" : "",
-		        bfo & PCIIO_WORD_VALUES ? " WORD_VALUES" : "",
-		        bfn & PCIIO_BYTE_STREAM ? " BYTE_STREAM" : "",
-		        bfn & PCIIO_WORD_VALUES ? " WORD_VALUES" : "");
-#endif
 	        PCIBR_DEBUG((PCIBR_DEBUG_PIOMAP, pconn_vhdl, "%s", tmp_str));
 	    }
 	    xio_addr = XIO_NOWHERE;
@@ -2432,12 +2374,6 @@
 	    *bfp = bfn;			/* record the assignment */
 
 	    if (pcibr_debug_mask & PCIBR_DEBUG_PIOMAP) {
-#ifdef PIC_LATER
-	        sprintf(tmp_str, "pcibr_addr_pci_to_xio: swap for %x set "
-			"to%s%s\n", space, space_desc,
-		        bfn & PCIIO_BYTE_STREAM ? " BYTE_STREAM" : "",
-		        bfn & PCIIO_WORD_VALUES ? " WORD_VALUES" : "");
-#endif
 	        PCIBR_DEBUG((PCIBR_DEBUG_PIOMAP, pconn_vhdl, "%s", tmp_str));
 	    }
 	}
@@ -2740,10 +2676,6 @@
 		    size_t req_size)
 {
     pcibr_info_t            pcibr_info = pcibr_info_get(pconn_vhdl);
-#ifdef PIC_LATER
-    pcibr_soft_t            pcibr_soft = (pcibr_soft_t) pcibr_info->f_mfast;
-#endif
-
     pciio_piospace_t        piosp;
     unsigned long           s;
     char                    name[1024];
@@ -3395,10 +3327,6 @@
 void
 pcibr_dmamap_done(pcibr_dmamap_t pcibr_dmamap)
 {
-#ifdef PIC_LATER
-    pcibr_soft_t            pcibr_soft = pcibr_dmamap->bd_soft;
-    pciio_slot_t            slot = PCIBR_SLOT_TO_DEVICE(pcibr_soft,
-#endif
     /*
      * We could go through and invalidate ATEs here;
      * for performance reasons, we don't.
@@ -3719,72 +3647,8 @@
 int
 pcibr_reset(vertex_hdl_t conn)
 {
-#ifdef PIC_LATER
-    pciio_info_t            pciio_info = pciio_info_get(conn);
-    pciio_slot_t            pciio_slot = PCIBR_INFO_SLOT_GET_INT(pciio_info);
-    pcibr_soft_t            pcibr_soft = (pcibr_soft_t) pciio_info_mfast_get(pciio_info);
-    bridge_t               *bridge = pcibr_soft->bs_base;
-    bridgereg_t             ctlreg;
-    unsigned                cfgctl[8];
-    unsigned long           s;
-    int                     f, nf;
-    pcibr_info_h            pcibr_infoh;
-    pcibr_info_t            pcibr_info;
-    int                     win;
-    int                     error = 0;
-#endif	/* PIC_LATER */
-
 	BUG();
-#ifdef PIC_LATER
-    if (pcibr_soft->bs_slot[pciio_slot].has_host) {
-	pciio_slot = pcibr_soft->bs_slot[pciio_slot].host_slot;
-	pcibr_info = pcibr_soft->bs_slot[pciio_slot].bss_infos[0];
-    }
-
-    if ((pciio_slot >= pcibr_soft->bs_first_slot) &&
-        (pciio_slot <= pcibr_soft->bs_last_reset)) {
-	s = pcibr_lock(pcibr_soft);
-	nf = pcibr_soft->bs_slot[pciio_slot].bss_ninfo;
-	pcibr_infoh = pcibr_soft->bs_slot[pciio_slot].bss_infos;
-	for (f = 0; f < nf; ++f)
-	    if (pcibr_infoh[f])
-		cfgctl[f] = pcibr_func_config_get(bridge, pciio_slot, f,
-							PCI_CFG_COMMAND/4);
-
-        error = iobrick_pci_slot_rst(pcibr_soft->bs_l1sc,
-                             pcibr_widget_to_bus(pcibr_soft->bs_vhdl),
-                             PCIBR_DEVICE_TO_SLOT(pcibr_soft,pciio_slot),
-                             NULL);
-
-	ctlreg = bridge->b_wid_control;
-	bridge->b_wid_control = ctlreg & ~BRIDGE_CTRL_RST_PIN(pciio_slot);
-        nano_delay(&ts);
-	bridge->b_wid_control = ctlreg | BRIDGE_CTRL_RST_PIN(pciio_slot);
-        nano_delay(&ts);
-
-	for (f = 0; f < nf; ++f)
-	    if ((pcibr_info = pcibr_infoh[f]))
-		for (win = 0; win < 6; ++win)
-		    if (pcibr_info->f_window[win].w_base != 0)
-			pcibr_func_config_set(bridge, pciio_slot, f,
-					PCI_CFG_BASE_ADDR(win) / 4, 
-					pcibr_info->f_window[win].w_base);
-	for (f = 0; f < nf; ++f)
-	    if (pcibr_infoh[f])
-		pcibr_func_config_set(bridge, pciio_slot, f,
-					PCI_CFG_COMMAND / 4,
-					cfgctl[f]);
-	pcibr_unlock(pcibr_soft, s);
-
-	if (error)
-            return(-1);
-
-	return 0;
-    }
-    PCIBR_DEBUG_ALWAYS((PCIBR_DEBUG_DETACH, conn,
-    		"pcibr_reset unimplemented for slot %d\n", conn, pciio_slot));
-#endif	/* PIC_LATER */
-    return -1;
+	return -1;
 }
 
 pciio_endian_t
@@ -3836,13 +3700,7 @@
     }
     pcibr_unlock(pcibr_soft, s);
 
-#ifdef PIC_LATER
-    PCIBR_DEBUG_ALWAYS((PCIBR_DEBUG_DEVREG, pconn_vhdl,
-    		"pcibr_endian_set: Device(%d): %x\n",
-		pciio_slot, devreg, device_bits));
-#else
     printk("pcibr_endian_set: Device(%d): %x\n", pciio_slot, devreg);
-#endif
     return desired_end;
 }
 
@@ -4026,13 +3884,7 @@
 	    }
 	}
 	pcibr_unlock(pcibr_soft, s);
-#ifdef PIC_LATER
-	PCIBR_DEBUG_ALWAYS((PCIBR_DEBUG_DEVREG, pconn_vhdl,
-		    "pcibr_device_flags_set: Device(%d): %x\n",
-		    pciio_slot, devreg, device_bits));
-#else
 	printk("pcibr_device_flags_set: Device(%d): %x\n", pciio_slot, devreg);
-#endif
     }
     return (1);
 }
diff -Nru a/arch/ia64/sn/io/xswitch.c b/arch/ia64/sn/io/xswitch.c
--- a/arch/ia64/sn/io/xswitch.c	Wed Jul 30 11:40:14 2003
+++ b/arch/ia64/sn/io/xswitch.c	Wed Jul 30 11:40:14 2003
@@ -30,40 +30,8 @@
  */
 
 #include <asm/sn/xtalk/xbow.h>
-#define DEV_FUNC(dev,func)      xbow_##func
-
-#if !defined(DEV_FUNC)
-/*
- * There is more than one possible provider
- * for this platform. We need to examine the
- * master vertex of the current vertex for
- * a provider function structure, and indirect
- * through the appropriately named member.
- */
-#define	DEV_FUNC(dev,func)	xwidget_to_provider_fns(dev)->func
-
-static xswitch_provider_t *
-xwidget_to_provider_fns(vertex_hdl_t xconn)
-{
-    vertex_hdl_t            busv;
-    xswitch_info_t          xswitch_info;
-    xswitch_provider_t      provider_fns;
-
-    busv = hwgraph_connectpt_get(xconn_vhdl);
-    ASSERT(busv != GRAPH_VERTEX_NONE);
-
-    xswitch_info = xswitch_info_get(busv);
-    ASSERT(xswitch_info != NULL);
-
-    provider_fns = xswitch_info->xswitch_fns;
-    ASSERT(provider_fns != NULL);
-
-    return provider_fns;
-}
-#endif
 
 #define	XSWITCH_CENSUS_BIT(port)		(1<<(port))
-#define	XSWITCH_CENSUS_PORT_MIN			(0x0)
 #define	XSWITCH_CENSUS_PORT_MAX			(0xF)
 #define	XSWITCH_CENSUS_PORTS			(0x10)
 #define	XSWITCH_WIDGET_PRESENT(infop,port)	((infop)->census & XSWITCH_CENSUS_BIT(port))
@@ -94,28 +62,20 @@
 		      xwidgetnum_t port,
 		      vertex_hdl_t xwidget)
 {
-#if XSWITCH_CENSUS_PORT_MIN
-    if (port < XSWITCH_CENSUS_PORT_MIN)
-	return;
-#endif
     if (port > XSWITCH_CENSUS_PORT_MAX)
 	return;
 
-    xswitch_info->vhdl[port - XSWITCH_CENSUS_PORT_MIN] = xwidget;
+    xswitch_info->vhdl[port] = xwidget;
 }
 
 vertex_hdl_t
 xswitch_info_vhdl_get(xswitch_info_t xswitch_info,
 		      xwidgetnum_t port)
 {
-#if XSWITCH_CENSUS_PORT_MIN
-    if (port < XSWITCH_CENSUS_PORT_MIN)
-	return GRAPH_VERTEX_NONE;
-#endif
     if (port > XSWITCH_CENSUS_PORT_MAX)
 	return GRAPH_VERTEX_NONE;
 
-    return xswitch_info->vhdl[port - XSWITCH_CENSUS_PORT_MIN];
+    return xswitch_info->vhdl[port];
 }
 
 /*
@@ -128,28 +88,20 @@
 				   xwidgetnum_t port,
 				   vertex_hdl_t master_vhdl)
 {
-#if XSWITCH_CENSUS_PORT_MIN
-    if (port < XSWITCH_CENSUS_PORT_MIN)
-	return;
-#endif
     if (port > XSWITCH_CENSUS_PORT_MAX)
 	return;
 
-    xswitch_info->master_vhdl[port - XSWITCH_CENSUS_PORT_MIN] = master_vhdl;
+    xswitch_info->master_vhdl[port] = master_vhdl;
 }
 
 vertex_hdl_t
 xswitch_info_master_assignment_get(xswitch_info_t xswitch_info,
 				   xwidgetnum_t port)
 {
-#if XSWITCH_CENSUS_PORT_MIN
-    if (port < XSWITCH_CENSUS_PORT_MIN)
-	return GRAPH_VERTEX_NONE;
-#endif
     if (port > XSWITCH_CENSUS_PORT_MAX)
 	return GRAPH_VERTEX_NONE;
 
-    return xswitch_info->master_vhdl[port - XSWITCH_CENSUS_PORT_MIN];
+    return xswitch_info->master_vhdl[port];
 }
 
 void
@@ -170,9 +122,7 @@
 
 	NEW(xswitch_info);
 	xswitch_info->census = 0;
-	for (port = XSWITCH_CENSUS_PORT_MIN;
-	     port <= XSWITCH_CENSUS_PORT_MAX;
-	     port++) {
+	for (port = 0; port <= XSWITCH_CENSUS_PORT_MAX; port++) {
 	    xswitch_info_vhdl_set(xswitch_info, port,
 				  GRAPH_VERTEX_NONE);
 
@@ -204,11 +154,6 @@
 int
 xswitch_info_link_ok(xswitch_info_t xswitch_info, xwidgetnum_t port)
 {
-#if XSWITCH_CENSUS_PORT_MIN
-    if (port < XSWITCH_CENSUS_PORT_MIN)
-	return 0;
-#endif
-
     if (port > XSWITCH_CENSUS_PORT_MAX)
 	return 0;
 
@@ -218,6 +163,5 @@
 int
 xswitch_reset_link(vertex_hdl_t xconn_vhdl)
 {
-    return DEV_FUNC(xconn_vhdl, reset_link)
-	(xconn_vhdl);
+    return xbow_reset_link(xconn_vhdl);
 }
diff -Nru a/arch/ia64/sn/kernel/Makefile b/arch/ia64/sn/kernel/Makefile
--- a/arch/ia64/sn/kernel/Makefile	Wed Jul 30 11:40:14 2003
+++ b/arch/ia64/sn/kernel/Makefile	Wed Jul 30 11:40:14 2003
@@ -9,8 +9,6 @@
 
 EXTRA_CFLAGS := -DLITTLE_ENDIAN
 
-obj-y				:= probe.o setup.o sv.o bte.o irq.o mca.o \
-				   idle.o sn2/
-
+obj-y				+= probe.o setup.o bte.o irq.o mca.o idle.o sn2/
 obj-$(CONFIG_IA64_GENERIC)      += machvec.o
 obj-$(CONFIG_MODULES)           += sn_ksyms.o
diff -Nru a/arch/ia64/sn/kernel/mca.c b/arch/ia64/sn/kernel/mca.c
--- a/arch/ia64/sn/kernel/mca.c	Wed Jul 30 11:40:14 2003
+++ b/arch/ia64/sn/kernel/mca.c	Wed Jul 30 11:40:14 2003
@@ -121,14 +121,17 @@
 
 
 static void
-sn_cpei_timer_handler(unsigned long dummy) {
+sn_cpei_timer_handler(unsigned long dummy)
+{
 	sn_cpei_handler(-1, NULL, NULL);
 	mod_timer(&sn_cpei_timer, jiffies + CPEI_INTERVAL);
 }
 
 void
-sn_init_cpei_timer() {
+sn_init_cpei_timer(void)
+{
+	init_timer(&sn_cpei_timer);
 	sn_cpei_timer.expires = jiffies + CPEI_INTERVAL;
         sn_cpei_timer.function = sn_cpei_timer_handler;
-        add_timer(&sn_cpei_timer);
+	add_timer(&sn_cpei_timer);
 }
diff -Nru a/arch/ia64/sn/kernel/sv.c b/arch/ia64/sn/kernel/sv.c
--- a/arch/ia64/sn/kernel/sv.c	Wed Jul 30 11:40:14 2003
+++ b/arch/ia64/sn/kernel/sv.c	Wed Jul 30 11:40:14 2003
@@ -1,551 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (C) 2000-2003 Silicon Graphics, Inc.  All Rights Reserved.
- *
- * This implemenation of synchronization variables is heavily based on
- * one done by Steve Lord <lord@sgi.com>
- *
- * Paul Cassella <pwc@sgi.com>
- */
-
-#include <linux/kernel.h>
-#include <linux/sched.h>
-#include <linux/init.h>
-#include <linux/interrupt.h>
-
-#include <asm/semaphore.h>
-#include <asm/hardirq.h>
-#include <asm/current.h>
-
-#include <asm/sn/sv.h>
-
-/* Define this to have sv_test() run some simple tests.
-   kernel_thread() must behave as expected when this is called.  */
-#undef RUN_SV_TEST
-
-#define DEBUG
-
-/* Set up some macros so sv_wait(), sv_signal(), and sv_broadcast()
-   can sanity check interrupt state on architectures where we know
-   how. */
-#ifdef DEBUG
- #define SV_DEBUG_INTERRUPT_STATE
- #ifdef __mips64
-  #define SV_TEST_INTERRUPTS_ENABLED(flags) ((flags & 0x1) != 0)
-  #define SV_TEST_INTERRUPTS_DISABLED(flags) ((flags & 0x1) == 0)
-  #define SV_INTERRUPT_TEST_WORKERS 31
- #elif defined(__ia64)
-  #define SV_TEST_INTERRUPTS_ENABLED(flags) ((flags & 0x4000) != 0)
-  #define SV_TEST_INTERRUPTS_DISABLED(flags) ((flags & 0x4000) == 0)
-  #define SV_INTERRUPT_TEST_WORKERS 4 /* simulator's slow */
- #else
-  #undef  SV_DEBUG_INTERRUPT_STATE
-  #define SV_INTERRUPT_TEST_WORKERS 4 /* reasonable? default. */
- #endif /* __mips64 */
-#endif /* DEBUG */
-
-
-/* XXX FIXME hack hack hack.  Our mips64 tree is from before the
-   switch to WQ_FLAG_EXCLUSIVE, and our ia64 tree is from after it. */
-#ifdef TASK_EXCLUSIVE
-  #undef EXCLUSIVE_IN_QUEUE
-#else
-  #define EXCLUSIVE_IN_QUEUE
-  #define TASK_EXCLUSIVE 0 /* for the set_current_state() in sv_wait() */
-#endif
-
-
-static inline void sv_lock(sv_t *sv) {
-	spin_lock(&sv->sv_lock);
-}
-
-static inline void sv_unlock(sv_t *sv) {
-	spin_unlock(&sv->sv_lock);
-}
-
-/* up() is "extern inline", so we can't pass its address to sv_wait.
-   Use this function's address instead. */
-static void up_wrapper(struct semaphore *sem) {
-	up(sem);
-}
-
-/* spin_unlock() is sometimes a macro. */
-static void spin_unlock_wrapper(spinlock_t *s) {
-	spin_unlock(s);
-}
-
-/* XXX Perhaps sv_wait() should do the switch() each time and avoid
-   the extra indirection and the need for the _wrapper functions? */
-
-static inline void sv_set_mon_type(sv_t *sv, int type) {
-	switch (type) {
-	case SV_MON_SPIN:
-		sv->sv_mon_unlock_func =
-		  (sv_mon_unlock_func_t)spin_unlock_wrapper;
-		break;
-	case SV_MON_SEMA:
-		sv->sv_mon_unlock_func =
-		  (sv_mon_unlock_func_t)up_wrapper;
-		if(sv->sv_flags & SV_INTS) {
-			printk(KERN_ERR "sv_set_mon_type: The monitor lock "
-			       "cannot be shared with interrupts if it is a "
-			       "semaphore!\n");
-			BUG();
-		}
-		if(sv->sv_flags & SV_BHS) {
-			printk(KERN_ERR "sv_set_mon_type: The monitor lock "
-			       "cannot be shared with bottom-halves if it is "
-			       "a semaphore!\n");
-			BUG();
-		}
-		break;
-#if 0 
-	/*
-	 * If needed, and will need to think about interrupts.  This
-	 * may be needed, for example, if someone wants to use sv's
-	 * with something like dev_base; writers need to hold two
-	 * locks. 
-	 */
-	case SV_MON_CUSTOM: 
-		{
-		struct sv_mon_custom *c = lock;
-		sv->sv_mon_unlock_func = c->sv_mon_unlock_func;
-		sv->sv_mon_lock        = c->sv_mon_lock;
-		break;
-		}
-#endif
-		
-	default:
-		printk(KERN_ERR "sv_set_mon_type: unknown type %d (0x%x)! "
-		       "(flags 0x%x)\n", type, type, sv->sv_flags);
-		BUG();
-		break;
-	}
-	sv->sv_flags |= type;
-}
-
-static inline void sv_set_ord(sv_t *sv, int ord) {
-	if (!ord)
-		ord = SV_ORDER_DEFAULT;
-
-	if (ord != SV_ORDER_FIFO && ord != SV_ORDER_LIFO) {
-		printk(KERN_EMERG "sv_set_ord: unknown order %d (0x%x)! ",
-		       ord, ord);
-		BUG();
-	}
-
-	sv->sv_flags |= ord;
-}
-
-void sv_init(sv_t *sv, sv_mon_lock_t *lock, int flags) 
-{
-	int ord = flags & SV_ORDER_MASK;
-	int type = flags & SV_MON_MASK;
-
-	/* Copy all non-order, non-type flags */
-	sv->sv_flags = (flags & ~(SV_ORDER_MASK | SV_MON_MASK));
-
-	if((sv->sv_flags & (SV_INTS | SV_BHS)) == (SV_INTS | SV_BHS)) {
-	  printk(KERN_ERR "sv_init: do not set both SV_INTS and SV_BHS, only SV_INTS.\n");
-	  BUG();
-	}
-
-	sv_set_ord(sv, ord);
-	sv_set_mon_type(sv, type);
-
-	/* If lock is NULL, we'll get it from sv_wait_compat() (and
-           ignore it in sv_signal() and sv_broadcast()). */
-	sv->sv_mon_lock = lock;
-
-	spin_lock_init(&sv->sv_lock);
-	init_waitqueue_head(&sv->sv_waiters);
-}
-
-/*
- * The associated lock must be locked on entry.  It is unlocked on return.
- *
- * Return values:
- *
- * n < 0 : interrupted,  -n jiffies remaining on timeout, or -1 if timeout == 0
- * n = 0 : timeout expired
- * n > 0 : sv_signal()'d, n jiffies remaining on timeout, or 1 if timeout == 0
- */
-signed long sv_wait(sv_t *sv, int sv_wait_flags, unsigned long timeout) 
-{
-	DECLARE_WAITQUEUE( wait, current );
-	unsigned long flags;
-	signed long ret = 0;
-
-#ifdef SV_DEBUG_INTERRUPT_STATE
-	{
-	unsigned long flags;
-	local_save_flags(flags);
-
-	if(sv->sv_flags & SV_INTS) {
-		if(SV_TEST_INTERRUPTS_ENABLED(flags)) {
-			printk(KERN_ERR "sv_wait: SV_INTS and interrupts "
-			       "enabled (flags: 0x%lx)\n", flags);
-			BUG();
-		}
-	} else {
-		if (SV_TEST_INTERRUPTS_DISABLED(flags)) {
-			printk(KERN_WARNING "sv_wait: !SV_INTS and interrupts "
-			       "disabled! (flags: 0x%lx)\n", flags);
-		}
-	}
-	}
-#endif  /* SV_DEBUG_INTERRUPT_STATE */
-
-	sv_lock(sv);
-
-	sv->sv_mon_unlock_func(sv->sv_mon_lock);
-
-	/* Add ourselves to the wait queue and set the state before
-	 * releasing the sv_lock so as to avoid racing with the
-	 * wake_up() in sv_signal() and sv_broadcast(). 
-	 */
-
-	/* don't need the _irqsave part, but there is no wq_write_lock() */
-	write_lock_irqsave(&sv->sv_waiters.lock, flags);
-
-#ifdef EXCLUSIVE_IN_QUEUE
-	wait.flags |= WQ_FLAG_EXCLUSIVE;
-#endif
-
-	switch(sv->sv_flags & SV_ORDER_MASK) {
-	case SV_ORDER_FIFO:
-		__add_wait_queue_tail(&sv->sv_waiters, &wait);
-		break;
-	case SV_ORDER_FILO:
-		__add_wait_queue(&sv->sv_waiters, &wait);
-		break;
-	default:
-		printk(KERN_ERR "sv_wait: unknown order!  (sv: 0x%p, flags: 0x%x)\n",
-					(void *)sv, sv->sv_flags);
-		BUG();
-	}
-	write_unlock_irqrestore(&sv->sv_waiters.lock, flags);
-
-	if(sv_wait_flags & SV_WAIT_SIG)
-		set_current_state(TASK_EXCLUSIVE | TASK_INTERRUPTIBLE  );
-	else
-		set_current_state(TASK_EXCLUSIVE | TASK_UNINTERRUPTIBLE);
-
-	spin_unlock(&sv->sv_lock);
-
-	if(sv->sv_flags & SV_INTS)
-		local_irq_enable();
-	else if(sv->sv_flags & SV_BHS)
-		local_bh_enable();
-
-	if (timeout)
-		ret = schedule_timeout(timeout);
-	else
-		schedule();
-
-	if(current->state != TASK_RUNNING) /* XXX Is this possible? */ {
-		printk(KERN_ERR "sv_wait: state not TASK_RUNNING after "
-		       "schedule().\n");
-		set_current_state(TASK_RUNNING);
-	}
-
-	remove_wait_queue(&sv->sv_waiters, &wait);
-
-	/* Return cases:
-	   - woken by a sv_signal/sv_broadcast
-	   - woken by a signal
-	   - woken by timeout expiring
-	*/
-
-	/* XXX This isn't really accurate; we may have been woken
-           before the signal anyway.... */
-	if(signal_pending(current))
-		return timeout ? -ret : -1;
-	return timeout ? ret : 1;
-}
-
-
-void sv_signal(sv_t *sv) 
-{
-	/* If interrupts can acquire this lock, they can also acquire the
-	   sv_mon_lock, which we must already have to have called this, so
-	   interrupts must be disabled already.  If interrupts cannot
-	   contend for this lock, we don't have to worry about it. */
-
-#ifdef SV_DEBUG_INTERRUPT_STATE
-	if(sv->sv_flags & SV_INTS) {
-		unsigned long flags;
-		local_save_flags(flags);
-		if(SV_TEST_INTERRUPTS_ENABLED(flags))
-			printk(KERN_ERR "sv_signal: SV_INTS and "
-			"interrupts enabled! (flags: 0x%lx)\n", flags);
-	}
-#endif /* SV_DEBUG_INTERRUPT_STATE */
-
-	sv_lock(sv);
-	wake_up(&sv->sv_waiters);
-	sv_unlock(sv);
-}
-
-void sv_broadcast(sv_t *sv) 
-{
-#ifdef SV_DEBUG_INTERRUPT_STATE
-	if(sv->sv_flags & SV_INTS) {
-		unsigned long flags;
-		local_save_flags(flags);
-		if(SV_TEST_INTERRUPTS_ENABLED(flags))
-			printk(KERN_ERR "sv_broadcast: SV_INTS and "
-			       "interrupts enabled! (flags: 0x%lx)\n", flags);
-	}
-#endif /* SV_DEBUG_INTERRUPT_STATE */
-
-	sv_lock(sv);
-	wake_up_all(&sv->sv_waiters);
-	sv_unlock(sv);
-}
-
-void sv_destroy(sv_t *sv) 
-{
-	if(!spin_trylock(&sv->sv_lock)) {
-		printk(KERN_ERR "sv_destroy: someone else has sv 0x%p locked!\n", (void *)sv);
-		BUG();
-	}
-
-	/* XXX Check that the waitqueue is empty? 
-	       Mark the sv destroyed?
-	*/
-}
-
-
-#ifdef RUN_SV_TEST
-
-static DECLARE_MUTEX_LOCKED(talkback);
-static DECLARE_MUTEX_LOCKED(sem);
-sv_t sv;
-sv_t sv_filo;
-
-static int sv_test_1_w(void *arg) 
-{
-	printk("sv_test_1_w: acquiring spinlock 0x%p...\n", arg);
-
-	spin_lock((spinlock_t*)arg);
-	printk("sv_test_1_w: spinlock acquired, waking sv_test_1_s.\n");
-
-	up(&sem);
-
-	printk("sv_test_1_w: sv_spin_wait()'ing.\n");
-
-	sv_spin_wait(&sv, arg);
-
-	printk("sv_test_1_w: talkback.\n");
-	up(&talkback);
-
-	printk("sv_test_1_w: exiting.\n");
-	return 0;
-}
-
-static int sv_test_1_s(void *arg) 
-{
-	printk("sv_test_1_s: waiting for semaphore.\n");
-	down(&sem);
-	printk("sv_test_1_s: semaphore acquired.  Acquiring spinlock.\n");
-	spin_lock((spinlock_t*)arg);
-	printk("sv_test_1_s: spinlock acquired.  sv_signaling.\n");
-	sv_signal(&sv);
-	printk("sv_test_1_s: talkback.\n");
-	up(&talkback);
-	printk("sv_test_1_s: exiting.\n");
-	return 0;
-
-}
-
-static int count;
-static DECLARE_MUTEX(monitor);
-
-static int sv_test_2_w(void *arg) 
-{
-	int dummy = count++;
-	sv_t *sv = (sv_t *)arg;
-
-	down(&monitor);
-	up(&talkback);
-	printk("sv_test_2_w: thread %d started, sv_waiting.\n", dummy);
-	sv_sema_wait(sv, &monitor);
-	printk("sv_test_2_w: thread %d woken, exiting.\n", dummy);
-	up(&sem);
-	return 0;
-}
-
-static int sv_test_2_s_1(void *arg) 
-{
-	int i;
-	sv_t *sv = (sv_t *)arg;
-
-	down(&monitor);
-	for(i = 0; i < 3; i++) {
-		printk("sv_test_2_s_1: waking one thread.\n");
-		sv_signal(sv);
-		down(&sem);
-	}
-
-	printk("sv_test_2_s_1: signaling and broadcasting again.  Nothing should happen.\n");
-	sv_signal(sv);
-	sv_broadcast(sv);
-	sv_signal(sv);
-	sv_broadcast(sv);
-
-	printk("sv_test_2_s_1: talkbacking.\n");
-	up(&talkback);
-	up(&monitor);
-	return 0;
-}
-
-static int sv_test_2_s(void *arg) 
-{
-	int i;
-	sv_t *sv = (sv_t *)arg;
-
-	down(&monitor);
-	for(i = 0; i < 3; i++) {
-		printk("sv_test_2_s: waking one thread (should be %d.)\n", i);
-		sv_signal(sv);
-		down(&sem);
-	}
-
-	printk("sv_test_3_s: waking remaining threads with broadcast.\n");
-	sv_broadcast(sv);
-	for(; i < 10; i++)
-		down(&sem);
-
-	printk("sv_test_3_s: sending talkback.\n");
-	up(&talkback);
-
-	printk("sv_test_3_s: exiting.\n");
-	up(&monitor);
-	return 0;
-}
-
-
-static void big_test(sv_t *sv) 
-{
-	int i;
-
-	count = 0;
-
-	for(i = 0; i < 3; i++) {
-		printk("big_test: spawning thread %d.\n", i);
-		kernel_thread(sv_test_2_w, sv, 0);
-		down(&talkback);
-	}
-
-	printk("big_test: spawning first wake-up thread.\n");
-	kernel_thread(sv_test_2_s_1, sv, 0);
-
-	down(&talkback);
-	printk("big_test: talkback happened.\n");
-
-
-	for(i = 3; i < 13; i++) {
-		printk("big_test: spawning thread %d.\n", i);
-		kernel_thread(sv_test_2_w, sv, 0);
-		down(&talkback);
-	}
-
-	printk("big_test: spawning wake-up thread.\n");
-	kernel_thread(sv_test_2_s, sv, 0);
-
-	down(&talkback);
-}
-
-sv_t int_test_sv;
-spinlock_t int_test_spin = SPIN_LOCK_UNLOCKED;
-int int_test_ready;
-static int irqtestcount;
-
-static int interrupt_test_worker(void *unused) 
-{
-	int id = ++irqtestcount;
-	int it = 0;
-			unsigned long flags, flags2;
-
-	printk("ITW: thread %d started.\n", id);
-
-	while(1) {
-		local_save_flags(flags2);
-		if(jiffies % 3) {
-			printk("ITW %2d %5d: irqsaving          (%lx)\n", id, it, flags2);
-			spin_lock_irqsave(&int_test_spin, flags);
-		} else {
-			printk("ITW %2d %5d: spin_lock_irqing   (%lx)\n", id, it, flags2);
-			spin_lock_irq(&int_test_spin);
-		}
-
-		local_save_flags(flags2);
-		printk("ITW %2d %5d: locked, sv_waiting (%lx).\n", id, it, flags2);
-		sv_wait(&int_test_sv, 0, 0);
-
-		local_save_flags(flags2);
-		printk("ITW %2d %5d: wait finished      (%lx), pausing\n", id, it, flags2);
-		set_current_state(TASK_INTERRUPTIBLE);
-		schedule_timeout(jiffies & 0xf);
-		if(current->state != TASK_RUNNING)
-		  printk("ITW:  current->state isn't RUNNING after schedule!\n");
-		it++;
-	}
-}
-
-static void interrupt_test(void) 
-{
-	int i;
-
-	printk("interrupt_test: initing sv.\n");
-	sv_init(&int_test_sv, &int_test_spin, SV_MON_SPIN | SV_INTS);
-
-	for(i = 0; i < SV_INTERRUPT_TEST_WORKERS; i++) {
-		printk("interrupt_test: starting test thread %d.\n", i);
-		kernel_thread(interrupt_test_worker, 0, 0);
-	}
-	printk("interrupt_test: done with init part.\n");
-	int_test_ready = 1;
-}
-
-int sv_test(void) 
-{
-	spinlock_t s = SPIN_LOCK_UNLOCKED;
-
-	sv_init(&sv, &s, SV_MON_SPIN);
-	printk("sv_test: starting sv_test_1_w.\n");
-	kernel_thread(sv_test_1_w, &s, 0);
-	printk("sv_test: starting sv_test_1_s.\n");
-	kernel_thread(sv_test_1_s, &s, 0);
-
-	printk("sv_test: waiting for talkback.\n");
-	down(&talkback); down(&talkback);
-	printk("sv_test: talkback happened, sv_destroying.\n");
-	sv_destroy(&sv);
-
-	count = 0;
-
-	printk("sv_test: beginning big_test on sv.\n");
-
-	sv_init(&sv, &monitor, SV_MON_SEMA);
-	big_test(&sv);
-	sv_destroy(&sv);
-
-	printk("sv_test: beginning big_test on sv_filo.\n");
-	sv_init(&sv_filo, &monitor, SV_MON_SEMA | SV_ORDER_FILO);
-	big_test(&sv_filo);
-	sv_destroy(&sv_filo);
-
-	interrupt_test();
-
-	printk("sv_test: done.\n");
-	return 0;
-}
-
-__initcall(sv_test);
-
-#endif /* RUN_SV_TEST */
diff -Nru a/include/asm-ia64/sn/dmamap.h b/include/asm-ia64/sn/dmamap.h
--- a/include/asm-ia64/sn/dmamap.h	Wed Jul 30 11:40:14 2003
+++ b/include/asm-ia64/sn/dmamap.h	Wed Jul 30 11:40:14 2003
@@ -9,8 +9,6 @@
 #ifndef _ASM_IA64_SN_DMAMAP_H
 #define _ASM_IA64_SN_DMAMAP_H
 
-#include <asm/sn/sv.h>
-
 #ifdef __cplusplus
 extern "C" {
 #endif
@@ -65,8 +63,6 @@
 
 extern int a24_mapsize;
 extern int a32_mapsize;
-
-extern sv_t dmamapout;
 
 #ifdef __cplusplus
 }
diff -Nru a/include/asm-ia64/sn/hcl.h b/include/asm-ia64/sn/hcl.h
--- a/include/asm-ia64/sn/hcl.h	Wed Jul 30 11:40:14 2003
+++ b/include/asm-ia64/sn/hcl.h	Wed Jul 30 11:40:14 2003
@@ -99,7 +99,6 @@
 extern int hwgraph_info_get_exported_LBL(vertex_hdl_t, char *, int *, arbitrary_info_t *);
 extern int hwgraph_info_get_next_LBL(vertex_hdl_t, char *, arbitrary_info_t *,
                                 labelcl_info_place_t *);
-extern int hwgraph_path_lookup(vertex_hdl_t, char *, vertex_hdl_t *, char **);
 extern int hwgraph_info_export_LBL(vertex_hdl_t, char *, int);
 extern int hwgraph_info_unexport_LBL(vertex_hdl_t, char *);
 extern int hwgraph_info_remove_LBL(vertex_hdl_t, char *, arbitrary_info_t *);
diff -Nru a/include/asm-ia64/sn/ksys/l1.h b/include/asm-ia64/sn/ksys/l1.h
--- a/include/asm-ia64/sn/ksys/l1.h	Wed Jul 30 11:40:14 2003
+++ b/include/asm-ia64/sn/ksys/l1.h	Wed Jul 30 11:40:14 2003
@@ -14,7 +14,6 @@
 #include <asm/sn/vector.h>
 #include <asm/sn/addrs.h>
 #include <asm/atomic.h>
-#include <asm/sn/sv.h>
 
 /* L1 Target Addresses */
 /*
diff -Nru a/include/asm-ia64/sn/nodepda.h b/include/asm-ia64/sn/nodepda.h
--- a/include/asm-ia64/sn/nodepda.h	Wed Jul 30 11:40:14 2003
+++ b/include/asm-ia64/sn/nodepda.h	Wed Jul 30 11:40:14 2003
@@ -127,8 +127,7 @@
  * Check if given a compact node id the corresponding node has all the
  * cpus disabled. 
  */
-#define is_headless_node(cnode)		((cnode == CNODEID_NONE) ||			\
-					 (node_data(cnode)->active_cpu_count == 0))
+#define is_headless_node(cnode)		(!test_bit(cnode, &node_has_active_cpus))
 
 /*
  * Check if given a node vertex handle the corresponding node has all the
diff -Nru a/include/asm-ia64/sn/sn2/sn_private.h b/include/asm-ia64/sn/sn2/sn_private.h
--- a/include/asm-ia64/sn/sn2/sn_private.h	Wed Jul 30 11:40:14 2003
+++ b/include/asm-ia64/sn/sn2/sn_private.h	Wed Jul 30 11:40:14 2003
@@ -97,7 +97,6 @@
 /* init.c */
 extern cnodeid_t get_compact_nodeid(void);	/* get compact node id */
 extern void init_platform_nodepda(nodepda_t *npda, cnodeid_t node);
-extern void per_cpu_init(void);
 extern int is_fine_dirmode(void);
 extern void update_node_information(cnodeid_t);
  
@@ -177,7 +176,7 @@
 	/* structures for PIO management */
 	xwidgetnum_t			h_widgetid;	/* my widget # (as viewed from xbow) */
 	struct hub_piomap_s		h_small_window_piomap[HUB_WIDGET_ID_MAX+1];
-	sv_t				h_bwwait;	/* wait for big window to free */
+	wait_queue_head_t		h_bwwait;	/* wait for big window to free */
 	spinlock_t			h_bwlock;	/* guard big window piomap's */
 	spinlock_t			h_crblock;      /* gaurd CRB error handling */
 	int				h_num_big_window_fixed;	/* count number of FIXED maps */
diff -Nru a/include/asm-ia64/sn/sv.h b/include/asm-ia64/sn/sv.h
--- a/include/asm-ia64/sn/sv.h	Wed Jul 30 11:40:14 2003
+++ b/include/asm-ia64/sn/sv.h	Wed Jul 30 11:40:14 2003
@@ -1,153 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (C) 2000-2003 Silicon Graphics, Inc.  All Rights Reserved.
- *
- * This implemenation of synchronization variables is heavily based on
- * one done by Steve Lord <lord@sgi.com>
- *
- * Paul Cassella <pwc@sgi.com>
- */
-
-#ifndef _ASM_IA64_SN_SV_H
-#define _ASM_IA64_SN_SV_H
-
-#include <linux/spinlock.h>
-#include <asm/semaphore.h>
-
-#ifndef ASSERT
-
-#define ASSERT(x) do {							  \
-                    if(!(x)) {						  \
-		      printk(KERN_ERR "%s\n", "Assertion failed: " # x);  \
-		      BUG();						  \
-		    }							  \
-                  } while(0)
-#define _SV_ASSERT
-#endif
-
-typedef void sv_mon_lock_t;
-typedef void (*sv_mon_unlock_func_t)(sv_mon_lock_t *lock);
-
-/* sv_flags values: */
-
-#define SV_ORDER_FIFO        0x001
-#define SV_ORDER_FILO        0x002
-#define SV_ORDER_LIFO        SV_ORDER_FILO
-
-/* If at some point one order becomes preferable to others, we can
-   switch to it if the caller of sv_init doesn't specify. */
-#define SV_ORDER_DEFAULT     SV_ORDER_FIFO
-
-#define SV_ORDER_MASK        0x00f
-
-
-#define SV_MON_SEMA          0x010
-#define SV_MON_SPIN          0x020
-
-#define SV_MON_MASK          0x0f0
-
-
-/*
-   If the monitor lock can be aquired from interrupts.  Note that this
-   is a superset of the cases in which the sv can be touched from
-   interrupts.
-
-   This is currently only valid when the monitor lock is a spinlock.
-
-   If this is used, sv_wait, sv_signal, and sv_broadcast must all be
-   called with interrupts disabled, which has to happen anyway to have
-   acquired the monitor spinlock. 
- */
-#define SV_INTS              0x100
-
-/* ditto for bottom halves */
-#define SV_BHS               0x200
-
-
-
-/* sv_wait_flag values: */
-#define SV_WAIT_SIG          0x001 /* Allow sv_wait to be interrupted by a signal */
-
-typedef struct sv_s {
-	wait_queue_head_t sv_waiters;
-	sv_mon_lock_t *sv_mon_lock;   /* Lock held for exclusive access to monitor. */
-	sv_mon_unlock_func_t sv_mon_unlock_func;
-	spinlock_t sv_lock;  /* Spinlock protecting the sv itself. */
-	int sv_flags;
-} sv_t;
-
-#define DECLARE_SYNC_VARIABLE(sv, l, f) sv_t sv = sv_init(&sv, l, f)
-
-/* 
- * @sv the sync variable to initialize
- * @monitor_lock the lock enforcing exclusive running in the monitor
- * @flags one of
- *   SV_MON_SEMA monitor_lock is a semaphore
- *   SV_MON_SPIN monitor_lock is a spinlock
- * and a bitwise or of some subset of
- *   SV_INTS - the monitor lock can be acquired from interrupts (and
- *             hence, whenever we hold it, interrupts are disabled or
- *             we're in an interrupt.)  This is only valid when
- *             SV_MON_SPIN is set.
- */
-void sv_init(sv_t *sv, sv_mon_lock_t *monitor_lock, int flags);
-
-/*
- * Set SV_WAIT_SIG in sv_wait_flags to let the sv_wait be interrupted by signals.
- *
- * timeout is how long to wait before giving up, or 0 to wait
- * indefinitely.  It is given in jiffies, and is relative.
- *
- * The associated lock must be locked on entry.  It is unlocked on return.
- *
- * Return values:
- *
- * n < 0 : interrupted,  -n jiffies remaining on timeout, or -1 if timeout == 0
- * n = 0 : timeout expired
- * n > 0 : sv_signal()'d, n jiffies remaining on timeout, or 1 if timeout == 0
- */
-extern signed long sv_wait(sv_t *sv, int sv_wait_flags,
-			   unsigned long timeout /* relative jiffies */);
-
-static inline int sv_wait_compat(sv_t *sv, sv_mon_lock_t *lock, int sv_wait_flags,
-				 unsigned long timeout, int sv_mon_type)
-{
-	ASSERT(sv_mon_type == (sv->sv_flags & SV_MON_MASK));
-	if(sv->sv_mon_lock)
-		ASSERT(lock == sv->sv_mon_lock);
-	else
-		sv->sv_mon_lock = lock;
-
-	return sv_wait(sv, sv_wait_flags, timeout);
-}
-
-
-/* These work like Irix's sv_wait() and sv_wait_sig(), except the
-   caller must call the one correpsonding to the type of the monitor
-   lock. */
-#define sv_spin_wait(sv, lock)                              \
-        sv_wait_compat(sv, lock, 0, 0, SV_MON_SPIN)
-#define sv_spin_wait_sig(sv, lock)                          \
-        sv_wait_compat(sv, lock, SV_WAIT_SIG, 0, SV_MON_SPIN)
-
-#define sv_sema_wait(sv, lock)                              \
-        sv_wait_compat(sv, lock, 0, 0, SV_MON_SEMA)
-#define sv_sema_wait_sig(sv, lock)                          \
-        sv_wait_compat(sv, lock, SV_WAIT_SIG, 0, SV_MON_SEMA)
-
-/* These work as in Irix. */
-void sv_signal(sv_t *sv);
-void sv_broadcast(sv_t *sv);
-
-/* This works as in Irix. */
-void sv_destroy(sv_t *sv);
-
-#ifdef _SV_ASSERT
-#undef ASSERT
-#undef _SV_ASSERT
-#endif
-
-#endif /* _ASM_IA64_SN_SV_H */

--OgqxwSJOaUobr8KG--
