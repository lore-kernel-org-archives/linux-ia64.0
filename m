From: Christoph Hellwig <hch@lst.de>
Date: Mon, 15 Mar 2004 12:34:37 +0000
Subject: Re: [PATCH] update simscsi to 2.6 scsi APIs
Message-Id: <20040315123437.GA15195@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040315122954.GA15143@lst.de>
In-Reply-To: <20040315122954.GA15143@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 15, 2004 at 01:29:54PM +0100, Christoph Hellwig wrote:
> Use the proper (and cleaner) probing API instead of the old
> scsi_module.c hack, don't use the typedefs I plan to kill in 2.7 and
> mark everything static.

Sorry, wrong patch.  Here's a better one:

--- 1.15/arch/ia64/hp/sim/simscsi.c	Sat May 10 18:49:27 2003
+++ edited/arch/ia64/hp/sim/simscsi.c	Mon Mar 15 14:20:36 2004
@@ -8,23 +8,23 @@
  * 02/01/15 David Mosberger	Updated for v2.5.1
  * 99/12/18 David Mosberger	Added support for READ10/WRITE10 needed by linux v2.3.33
  */
-#include <linux/config.h>
 #include <linux/blkdev.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <linux/timer.h>
-
-#include <scsi/scsi.h>
-
 #include <asm/irq.h>
 
-#include "../drivers/scsi/scsi.h"
-#include "../drivers/scsi/hosts.h"
-#include "simscsi.h"
+#include <scsi/scsi.h>
+#include <scsi/scsi_cmnd.h>
+#include <scsi/scsi_device.h>
+#include <scsi/scsi_host.h>
 
 #define DEBUG_SIMSCSI	0
 
+#define SIMSCSI_REQ_QUEUE_LEN	64
+#define DEFAULT_SIMSCSI_ROOT	"/var/ski-disks/sd"
+
 /* Simulator system calls: */
 
 #define SSC_OPEN			50
@@ -47,7 +47,7 @@
 static struct Scsi_Host *host;
 
 static void simscsi_interrupt (unsigned long val);
-DECLARE_TASKLET(simscsi_tasklet, simscsi_interrupt, 0);
+static DECLARE_TASKLET(simscsi_tasklet, simscsi_interrupt, 0);
 
 struct disk_req {
 	unsigned long addr;
@@ -66,7 +66,7 @@
 };
 
 static struct queue_entry {
-	Scsi_Cmnd *sc;
+	struct scsi_cmnd *sc;
 } queue[SIMSCSI_REQ_QUEUE_LEN];
 
 static int rd, wr;
@@ -99,7 +99,7 @@
 static void
 simscsi_interrupt (unsigned long val)
 {
-	Scsi_Cmnd *sc;
+	struct scsi_cmnd *sc;
 
 	while ((sc = queue[rd].sc) != 0) {
 		atomic_dec(&num_reqs);
@@ -111,30 +111,7 @@
 	}
 }
 
-int
-simscsi_detect (Scsi_Host_Template *templ)
-{
-	templ->proc_name = "simscsi";
-	host = scsi_register(templ, 0);
-	if(host = NULL)
-		return 0;
-
-	return 1;	/* fake one SCSI host adapter */
-}
-
-int
-simscsi_release (struct Scsi_Host *host)
-{
-	return 0;	/* this is easy...  */
-}
-
-const char *
-simscsi_info (struct Scsi_Host *host)
-{
-	return "simulated SCSI host adapter";
-}
-
-int
+static int
 simscsi_biosparam (struct scsi_device *sdev, struct block_device *n,
 		sector_t capacity, int ip[])
 {
@@ -145,7 +122,7 @@
 }
 
 static void
-simscsi_readwrite (Scsi_Cmnd *sc, int mode, unsigned long offset, unsigned long len)
+simscsi_readwrite (struct scsi_cmnd *sc, int mode, unsigned long offset, unsigned long len)
 {
 	struct disk_stat stat;
 	struct disk_req req;
@@ -171,7 +148,7 @@
 }
 
 static void
-simscsi_sg_readwrite (Scsi_Cmnd *sc, int mode, unsigned long offset)
+simscsi_sg_readwrite (struct scsi_cmnd *sc, int mode, unsigned long offset)
 {
 	int list_len = sc->use_sg;
 	struct scatterlist *sl = (struct scatterlist *)sc->buffer;
@@ -208,7 +185,7 @@
  * Added 02/26/99 S.Eranian
  */
 static void
-simscsi_readwrite6 (Scsi_Cmnd *sc, int mode)
+simscsi_readwrite6 (struct scsi_cmnd *sc, int mode)
 {
 	unsigned long offset;
 
@@ -244,7 +221,7 @@
 }
 
 static void
-simscsi_readwrite10 (Scsi_Cmnd *sc, int mode)
+simscsi_readwrite10 (struct scsi_cmnd *sc, int mode)
 {
 	unsigned long offset;
 
@@ -256,8 +233,8 @@
 		simscsi_readwrite(sc, mode, offset, ((sc->cmnd[7] << 8) | sc->cmnd[8])*512);
 }
 
-int
-simscsi_queuecommand (Scsi_Cmnd *sc, void (*done)(Scsi_Cmnd *))
+static int
+simscsi_queuecommand (struct scsi_cmnd *sc, void (*done)(struct scsi_cmnd *))
 {
 	unsigned int target_id = sc->device->id;
 	char fname[MAX_ROOT_LEN+16];
@@ -380,18 +357,16 @@
 	return 0;
 }
 
-int
-simscsi_host_reset (Scsi_Cmnd *sc)
+static int
+simscsi_host_reset (struct scsi_cmnd *sc)
 {
 	printk(KERN_ERR "simscsi_host_reset: not implemented\n");
 	return 0;
 }
 
-static Scsi_Host_Template driver_template = {
-	.name			= "simscsi",
-	.detect			= simscsi_detect,
-	.release		= simscsi_release,
-	.info			= simscsi_info,	
+static struct scsi_host_template driver_template = {
+	.name			= "simulated SCSI host adapter",
+	.proc_name		= "simscsi",
 	.queuecommand		= simscsi_queuecommand,
 	.eh_host_reset_handler	= simscsi_host_reset,
 	.bios_param		= simscsi_biosparam,
@@ -402,4 +377,28 @@
 	.cmd_per_lun		= SIMSCSI_REQ_QUEUE_LEN,
 	.use_clustering		= DISABLE_CLUSTERING,
 };
-#include "../drivers/scsi/scsi_module.c"
+
+static int __init
+simscsi_init(void)
+{
+	int error;
+
+	host = scsi_host_alloc(&driver_template, 0);
+	if (!host)
+		return -ENOMEM;
+
+	error = scsi_add_host(host, NULL);
+	if (!error)
+		scsi_scan_host(host);
+	return error;
+}
+
+static void __exit
+simscsi_exit(void)
+{
+	scsi_remove_host(host);
+	scsi_host_put(host);
+}
+
+module_init(simscsi_init);
+module_exit(simscsi_exit);
=== arch/ia64/hp/sim/simscsi.h 1.7 vs edited ==--- 1.7/arch/ia64/hp/sim/simscsi.h	Sun May  4 11:56:42 2003
+++ edited/arch/ia64/hp/sim/simscsi.h	Mon Mar 15 14:09:22 2004
@@ -1,23 +0,0 @@
-/*
- * Simulated SCSI driver.
- *
- * Copyright (C) 1999, 2002 Hewlett-Packard Co
- *	David Mosberger-Tang <davidm@hpl.hp.com>
- */
-#ifndef SIMSCSI_H
-#define SIMSCSI_H
-
-#define SIMSCSI_REQ_QUEUE_LEN	64
-
-#define DEFAULT_SIMSCSI_ROOT	"/var/ski-disks/sd"
-
-extern int simscsi_detect (Scsi_Host_Template *);
-extern int simscsi_release (struct Scsi_Host *);
-extern const char *simscsi_info (struct Scsi_Host *);
-extern int simscsi_queuecommand (Scsi_Cmnd *, void (*done)(Scsi_Cmnd *));
-extern int simscsi_abort (Scsi_Cmnd *);
-extern int simscsi_reset (Scsi_Cmnd *, unsigned int);
-extern int simscsi_biosparam (struct scsi_device *, struct block_device *,
-		sector_t, int[]);
-
-#endif /* SIMSCSI_H */
