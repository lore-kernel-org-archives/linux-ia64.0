From: Christoph Hellwig <hch@lst.de>
Date: Thu, 25 Sep 2003 19:57:00 +0000
Subject: [PATCH] kill dead code from ml_iograph.c
Message-Id: <marc-linux-ia64-106451999732536@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

More IRIX creepism


--- 1.3/arch/ia64/sn/io/sn2/ml_iograph.c	Mon May 19 14:42:20 2003
+++ edited/arch/ia64/sn/io/sn2/ml_iograph.c	Fri Aug  8 12:01:40 2003
@@ -268,17 +268,6 @@
 	}
 }
 
-/*
- * Let boot processor know that we're done initializing our node's IO
- * and then exit.
- */
-/* ARGSUSED */
-static void
-io_init_done(cnodeid_t cnodeid,cpu_cookie_t c)
-{
-	/* Let boot processor know that we're done. */
-}
-
 /* 
  * Probe to see if this hub's xtalk link is active.  If so,
  * return the Crosstalk Identification of the widget that we talk to.  
@@ -687,11 +676,6 @@
 				DBG("Interfering with device probing!!!\n");
 		}
 #endif
-		/* io_init_done takes cpu cookie as 2nd argument 
-		 * to do a restorenoderun for the setnoderun done 
-		 * at the start of this thread 
-		 */
-		
 		DBG("**** io_init_node: Node's 0x%p hub widget has XWIDGET_PART_NUM_NONE ****\n", hubv);
 		return;
 		/* NOTREACHED */
@@ -795,15 +779,6 @@
 
 		(void)xwidget_register(&hwid, widgetv, npdap->basew_id, hubv, hubinfo->h_widgetid);
 
-		if (!is_xswitch) {
-			/* io_init_done takes cpu cookie as 2nd argument 
-			 * to do a restorenoderun for the setnoderun done 
-			 * at the start of this thread 
-			 */
-			io_init_done(cnodeid,c);
-			/* NOTREACHED */
-		}
-
 		/* 
 		 * Special handling for Crosstalk Switches (e.g. xbow).
 		 * We need to do things in roughly the following order:
@@ -848,35 +823,9 @@
 	io_init_xswitch_widgets(switchv, cnodeid);
 	io_link_xswitch_widgets(switchv, cnodeid);
 
-	/* io_init_done takes cpu cookie as 2nd argument 
-	 * to do a restorenoderun for the setnoderun done 
-	 * at the start of this thread 
-	 */
-	io_init_done(cnodeid,c);
-
 	DBG("\nio_init_node: DONE INITIALIZED ALL I/O FOR CNODEID %d\n\n", cnodeid);
 }
 
-
-#define IOINIT_STKSZ	(16 * 1024)
-
-#define __DEVSTR1 	"/../.master/"
-#define __DEVSTR2 	"/target/"
-#define __DEVSTR3 	"/lun/0/disk/partition/"
-#define	__DEVSTR4	"/../ef"
-
-/*
- * ioconfig starts numbering SCSI's at NUM_BASE_IO_SCSI_CTLR.
- */
-#define NUM_BASE_IO_SCSI_CTLR 6
-/*
- * This tells ioconfig where it can start numbering scsi controllers.
- * Below this base number, platform-specific handles the numbering.
- * XXX Irix legacy..controller numbering should be part of devfsd's job
- */
-int num_base_io_scsi_ctlr = 2; /* used by syssgi */
-vertex_hdl_t		base_io_scsi_ctlr_vhdl[NUM_BASE_IO_SCSI_CTLR];
-
 #include <asm/sn/ioerror_handling.h>
 /* #endif */
 
@@ -913,78 +862,6 @@
 }
 
 #define toint(x) ((int)(x) - (int)('0'))
-
-void
-devnamefromarcs(char *devnm)
-{
-	int 			val;
-	char 			tmpnm[MAXDEVNAME];
-	char 			*tmp1, *tmp2;
-	
-	val = strncmp(devnm, "dks", 3);
-	if (val != 0) 
-		return;
-	tmp1 = devnm + 3;
-	if (!isdigit(*tmp1))
-		return;
-
-	val = 0;
-	while (isdigit(*tmp1)) {
-		val = 10*val+toint(*tmp1);
-		tmp1++;
-	}
-
-	if(*tmp1 != 'd')
-		return;
-	else
-		tmp1++;
-
-	if ((val < 0) || (val >= num_base_io_scsi_ctlr)) {
-		int i;
-		int viable_found = 0;
-
-		DBG("Only controller numbers 0..%d  are supported for\n", NUM_BASE_IO_SCSI_CTLR-1);
-		DBG("prom \"root\" variables of the form dksXdXsX.\n");
-		DBG("To use another disk you must use the full hardware graph path\n\n");
-		DBG("Possible controller numbers for use in 'dksXdXsX' on this system: ");
-		for (i=0; i<NUM_BASE_IO_SCSI_CTLR; i++) {
-			if (base_io_scsi_ctlr_vhdl[i] != GRAPH_VERTEX_NONE) {
-				DBG("%d ", i);
-				viable_found=1;
-			}
-		}
-		if (viable_found)
-			DBG("\n");
-		else
-			DBG("none found!\n");
-
-		DELAY(15000000);
-		//prom_reboot();
-		panic("FIXME: devnamefromarcs: should call prom_reboot here.\n");
-		/* NOTREACHED */
-	}
-		
-	ASSERT(base_io_scsi_ctlr_vhdl[val] != GRAPH_VERTEX_NONE);
-	vertex_to_name(base_io_scsi_ctlr_vhdl[val],
-		       tmpnm,
-		       MAXDEVNAME);
-	tmp2 = 	tmpnm + strlen(tmpnm);
-	strcpy(tmp2, __DEVSTR2);
-	tmp2 += strlen(__DEVSTR2);
-	while (*tmp1 != 's') {
-		if((*tmp2++ = *tmp1++) = '\0')
-			return;
-	}	
-	tmp1++;
-	strcpy(tmp2, __DEVSTR3);
-	tmp2 += strlen(__DEVSTR3);
-	while ( (*tmp2++ = *tmp1++) )
-		;
-	tmp2--;
-	*tmp2++ = '/';
-	strcpy(tmp2, EDGE_LBL_BLOCK);
-	strcpy(devnm,tmpnm);
-}
 
 static
 struct io_brick_map_s io_brick_tab[] = {
