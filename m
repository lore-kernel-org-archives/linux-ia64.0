From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 22 Mar 2004 18:32:59 +0000
Subject: Re: 2.6.5-rc2 lots of warnings for dma_error
Message-Id: <200403221133.00006.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5631.1079924674@kao2.melbourne.sgi.com>
In-Reply-To: <5631.1079924674@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 22 March 2004 2:36 am, Andrew Morton wrote:
> This adds the necessary stubs for ia64 and builds OK with my config, but it
> needs a double-check.

In addition, I needed the following patch to build the ide-cd driver
because the ia64 generic target makes "dma_error" a #define.

diff -u -ur 2.6-mm/drivers/ide/ide-cd.c 2.6/drivers/ide/ide-cd.c
--- 2.6-mm/drivers/ide/ide-cd.c	2004-03-22 11:26:42.000000000 -0700
+++ 2.6/drivers/ide/ide-cd.c	2004-03-22 10:17:00.000000000 -0700
@@ -1044,7 +1044,7 @@
 	int ireason, len, sectors_to_transfer, nskip;
 	struct cdrom_info *info = drive->driver_data;
 	u8 lowcyl = 0, highcyl = 0;
-	int dma = info->dma, dma_error = 0;
+	int dma = info->dma, dma_err = 0;
 
 	struct request *rq = HWGROUP(drive)->rq;
 
@@ -1053,7 +1053,7 @@
 	 */
 	if (dma) {
 		info->dma = 0;
-		if ((dma_error = HWIF(drive)->ide_dma_end(drive)))
+		if ((dma_err = HWIF(drive)->ide_dma_end(drive)))
 			__ide_dma_off(drive);
 	}
 
@@ -1061,7 +1061,7 @@
 		return ide_stopped;
 
 	if (dma) {
-		if (!dma_error) {
+		if (!dma_err) {
 			ide_end_request(drive, 1, rq->nr_sectors);
 			return ide_stopped;
 		} else
@@ -1645,17 +1645,17 @@
 {
 	struct cdrom_info *info = drive->driver_data;
 	struct request *rq = HWGROUP(drive)->rq;
-	int dma_error, dma, stat, ireason, len, thislen;
+	int dma_err, dma, stat, ireason, len, thislen;
 	u8 lowcyl, highcyl;
 	xfer_func_t *xferfunc;
 	unsigned long flags;
 
 	/* Check for errors. */
-	dma_error = 0;
+	dma_err = 0;
 	dma = info->dma;
 	if (dma) {
 		info->dma = 0;
-		dma_error = HWIF(drive)->ide_dma_end(drive);
+		dma_err = HWIF(drive)->ide_dma_end(drive);
 	}
 
 	if (cdrom_decode_status(drive, 0, &stat)) {
@@ -1671,7 +1671,7 @@
 	 * using dma, transfer is complete now
 	 */
 	if (dma) {
-		if (dma_error) {
+		if (dma_err) {
 			printk("ide-cd: dma error\n");
 			__ide_dma_off(drive);
 			return DRIVER(drive)->error(drive, "dma error", stat);
@@ -1790,7 +1790,7 @@
 {
 	int stat, ireason, len, sectors_to_transfer, uptodate;
 	struct cdrom_info *info = drive->driver_data;
-	int dma_error = 0, dma = info->dma;
+	int dma_err = 0, dma = info->dma;
 	u8 lowcyl = 0, highcyl = 0;
 
 	struct request *rq = HWGROUP(drive)->rq;
@@ -1798,7 +1798,7 @@
 	/* Check for errors. */
 	if (dma) {
 		info->dma = 0;
-		if ((dma_error = HWIF(drive)->ide_dma_end(drive))) {
+		if ((dma_err = HWIF(drive)->ide_dma_end(drive))) {
 			printk("ide-cd: write dma error\n");
 			__ide_dma_off(drive);
 		}
@@ -1811,7 +1811,7 @@
 	 * using dma, transfer is complete now
 	 */
 	if (dma) {
-		if (dma_error)
+		if (dma_err)
 			return DRIVER(drive)->error(drive, "dma error", stat);
 
 		ide_end_request(drive, 1, rq->nr_sectors);
