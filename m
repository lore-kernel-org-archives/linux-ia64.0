From: Andrew Morton <akpm@osdl.org>
Date: Mon, 22 Mar 2004 20:21:08 +0000
Subject: Re: 2.6.5-rc2 lots of warnings for dma_error
Message-Id: <20040322122108.7edd14b8.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <5631.1079924674@kao2.melbourne.sgi.com>
In-Reply-To: <5631.1079924674@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
>
> On Monday 22 March 2004 2:36 am, Andrew Morton wrote:
>  > This adds the necessary stubs for ia64 and builds OK with my config, but it
>  > needs a double-check.
> 
>  In addition, I needed the following patch to build the ide-cd driver
>  because the ia64 generic target makes "dma_error" a #define.

gack, what a fiasco.

Here's a new patch which includes everyone's 2000 millicents' worth:


 25-akpm/arch/ia64/hp/common/sba_iommu.c   |    7 +++++++
 25-akpm/arch/ia64/lib/swiotlb.c           |    7 +++++++
 25-akpm/arch/ia64/sn/io/machvec/pci_dma.c |    7 +++++++
 25-akpm/drivers/ide/ide-cd.c              |   20 ++++++++++----------
 25-akpm/include/asm-ia64/dma-mapping.h    |    1 +
 25-akpm/include/asm-ia64/machvec.h        |    8 ++++++++
 25-akpm/include/asm-ia64/machvec_hpzx1.h  |    2 ++
 25-akpm/include/asm-ia64/machvec_sn2.h    |    2 ++
 8 files changed, 44 insertions(+), 10 deletions(-)

diff -puN include/asm-ia64/dma-mapping.h~ia64-dma_error-fix include/asm-ia64/dma-mapping.h
--- 25/include/asm-ia64/dma-mapping.h~ia64-dma_error-fix	2004-03-22 11:49:14.764057264 -0800
+++ 25-akpm/include/asm-ia64/dma-mapping.h	2004-03-22 11:49:14.776055440 -0800
@@ -18,6 +18,7 @@
 #define dma_sync_sg_for_cpu	platform_dma_sync_sg_for_cpu
 #define dma_sync_single_for_device platform_dma_sync_single_for_device
 #define dma_sync_sg_for_device	platform_dma_sync_sg_for_device
+#define dma_error		platform_dma_error
 
 #define dma_map_page(dev, pg, off, size, dir)				\
 	dma_map_single(dev, page_address(pg) + (off), (size), (dir))
diff -puN include/asm-ia64/machvec.h~ia64-dma_error-fix include/asm-ia64/machvec.h
--- 25/include/asm-ia64/machvec.h~ia64-dma_error-fix	2004-03-22 11:49:14.766056960 -0800
+++ 25-akpm/include/asm-ia64/machvec.h	2004-03-22 12:18:29.637275984 -0800
@@ -46,6 +46,7 @@ typedef void ia64_mv_dma_sync_single_for
 typedef void ia64_mv_dma_sync_sg_for_cpu (struct device *, struct scatterlist *, int, int);
 typedef void ia64_mv_dma_sync_single_for_device (struct device *, dma_addr_t, size_t, int);
 typedef void ia64_mv_dma_sync_sg_for_device (struct device *, struct scatterlist *, int, int);
+typedef int ia64_mv_dma_error (dma_addr_t dma_addr);
 typedef int ia64_mv_dma_supported (struct device *, u64);
 
 /*
@@ -110,6 +111,7 @@ extern void machvec_memory_fence (void);
 #  define platform_dma_sync_sg_for_cpu	ia64_mv.dma_sync_sg_for_cpu
 #  define platform_dma_sync_single_for_device ia64_mv.dma_sync_single_for_device
 #  define platform_dma_sync_sg_for_device ia64_mv.dma_sync_sg_for_device
+#  define platform_dma_error		ia64_mv.dma_error
 #  define platform_dma_supported	ia64_mv.dma_supported
 #  define platform_irq_desc		ia64_mv.irq_desc
 #  define platform_irq_to_vector	ia64_mv.irq_to_vector
@@ -158,6 +160,7 @@ struct ia64_machine_vector {
 	ia64_mv_dma_sync_sg_for_cpu *dma_sync_sg_for_cpu;
 	ia64_mv_dma_sync_single_for_device *dma_sync_single_for_device;
 	ia64_mv_dma_sync_sg_for_device *dma_sync_sg_for_device;
+	ia64_mv_dma_error *dma_error;
 	ia64_mv_dma_supported *dma_supported;
 	ia64_mv_irq_desc *irq_desc;
 	ia64_mv_irq_to_vector *irq_to_vector;
@@ -202,6 +205,7 @@ struct ia64_machine_vector {
 	platform_dma_sync_sg_for_cpu,		\
 	platform_dma_sync_single_for_device,	\
 	platform_dma_sync_sg_for_device,	\
+	platform_dma_error,			\
 	platform_dma_supported,			\
 	platform_irq_desc,			\
 	platform_irq_to_vector,			\
@@ -243,6 +247,7 @@ extern ia64_mv_dma_sync_single_for_cpu	s
 extern ia64_mv_dma_sync_sg_for_cpu	swiotlb_sync_sg_for_cpu;
 extern ia64_mv_dma_sync_single_for_device swiotlb_sync_single_for_device;
 extern ia64_mv_dma_sync_sg_for_device	swiotlb_sync_sg_for_device;
+extern ia64_mv_dma_error		swiotlb_dma_error;
 extern ia64_mv_dma_supported		swiotlb_dma_supported;
 
 /*
@@ -312,6 +317,9 @@ extern ia64_mv_dma_supported		swiotlb_dm
 #ifndef platform_dma_sync_sg_for_device
 # define platform_dma_sync_sg_for_device	swiotlb_sync_sg_for_device
 #endif
+#ifndef platform_dma_error
+# define platform_dma_error		swiotlb_dma_error
+#endif
 #ifndef platform_dma_supported
 # define  platform_dma_supported	swiotlb_dma_supported
 #endif
diff -puN include/asm-ia64/machvec_hpzx1.h~ia64-dma_error-fix include/asm-ia64/machvec_hpzx1.h
--- 25/include/asm-ia64/machvec_hpzx1.h~ia64-dma_error-fix	2004-03-22 11:49:14.771056200 -0800
+++ 25-akpm/include/asm-ia64/machvec_hpzx1.h	2004-03-22 12:18:53.961578128 -0800
@@ -9,6 +9,7 @@ extern ia64_mv_dma_unmap_single		sba_unm
 extern ia64_mv_dma_map_sg		sba_map_sg;
 extern ia64_mv_dma_unmap_sg		sba_unmap_sg;
 extern ia64_mv_dma_supported		sba_dma_supported;
+extern ia64_mv_dma_error		sba_dma_error;
 
 /*
  * This stuff has dual use!
@@ -31,5 +32,6 @@ extern ia64_mv_dma_supported		sba_dma_su
 #define platform_dma_sync_single_for_device ((ia64_mv_dma_sync_single_for_device *) machvec_memory_fence)
 #define platform_dma_sync_sg_for_device	((ia64_mv_dma_sync_sg_for_device *) machvec_memory_fence)
 #define platform_dma_supported		sba_dma_supported
+#define platform_dma_error		sba_dma_error
 
 #endif /* _ASM_IA64_MACHVEC_HPZX1_h */
diff -puN include/asm-ia64/machvec_sn2.h~ia64-dma_error-fix include/asm-ia64/machvec_sn2.h
--- 25/include/asm-ia64/machvec_sn2.h~ia64-dma_error-fix	2004-03-22 11:49:14.772056048 -0800
+++ 25-akpm/include/asm-ia64/machvec_sn2.h	2004-03-22 11:49:14.778055136 -0800
@@ -66,6 +66,7 @@ extern ia64_mv_dma_sync_single_for_cpu	s
 extern ia64_mv_dma_sync_sg_for_cpu	sn_dma_sync_sg_for_cpu;
 extern ia64_mv_dma_sync_single_for_device sn_dma_sync_single_for_device;
 extern ia64_mv_dma_sync_sg_for_device	sn_dma_sync_sg_for_device;
+extern ia64_mv_dma_error	sn_dma_error;
 extern ia64_mv_dma_supported		sn_dma_supported;
 
 /*
@@ -111,6 +112,7 @@ extern ia64_mv_dma_supported		sn_dma_sup
 #define platform_dma_sync_sg_for_cpu	sn_dma_sync_sg_for_cpu
 #define platform_dma_sync_single_for_device sn_dma_sync_single_for_device
 #define platform_dma_sync_sg_for_device	sn_dma_sync_sg_for_device
+#define platform_dma_error		sn_dma_error
 #define platform_dma_supported		sn_dma_supported
 
 #include <asm/sn/sn2/io.h>
diff -puN arch/ia64/lib/swiotlb.c~ia64-dma_error-fix arch/ia64/lib/swiotlb.c
--- 25/arch/ia64/lib/swiotlb.c~ia64-dma_error-fix	2004-03-22 11:49:14.773055896 -0800
+++ 25-akpm/arch/ia64/lib/swiotlb.c	2004-03-22 11:49:14.778055136 -0800
@@ -498,6 +498,12 @@ swiotlb_sync_sg_for_device (struct devic
 			sync_single(hwdev, (void *) sg->dma_address, sg->dma_length, dir);
 }
 
+int
+swiotlb_dma_error(dma_addr_t dma_addr)
+{
+	return 0;
+}
+
 /*
  * Return whether the given PCI device DMA address mask can be supported properly.  For
  * example, if your device can only drive the low 24-bits during PCI bus mastering, then
@@ -518,6 +524,7 @@ EXPORT_SYMBOL(swiotlb_sync_single_for_cp
 EXPORT_SYMBOL(swiotlb_sync_single_for_device);
 EXPORT_SYMBOL(swiotlb_sync_sg_for_cpu);
 EXPORT_SYMBOL(swiotlb_sync_sg_for_device);
+EXPORT_SYMBOL(swiotlb_dma_error);
 EXPORT_SYMBOL(swiotlb_alloc_coherent);
 EXPORT_SYMBOL(swiotlb_free_coherent);
 EXPORT_SYMBOL(swiotlb_dma_supported);
diff -puN arch/ia64/sn/io/machvec/pci_dma.c~ia64-dma_error-fix arch/ia64/sn/io/machvec/pci_dma.c
--- 25/arch/ia64/sn/io/machvec/pci_dma.c~ia64-dma_error-fix	2004-03-22 11:49:14.775055592 -0800
+++ 25-akpm/arch/ia64/sn/io/machvec/pci_dma.c	2004-03-22 12:18:29.637275984 -0800
@@ -652,6 +652,13 @@ sn_dma_sync_sg_for_device(struct device 
 }
 EXPORT_SYMBOL(sn_dma_sync_sg_for_device);
 
+int
+sn_dma_error(dma_addr_t dma_addr)
+{
+	return 0;
+}
+
+EXPORT_SYMBOL(sn_dma_error);
 EXPORT_SYMBOL(sn_pci_unmap_single);
 EXPORT_SYMBOL(sn_pci_map_single);
 EXPORT_SYMBOL(sn_pci_dma_sync_single_for_cpu);
diff -puN arch/ia64/hp/common/sba_iommu.c~ia64-dma_error-fix arch/ia64/hp/common/sba_iommu.c
--- 25/arch/ia64/hp/common/sba_iommu.c~ia64-dma_error-fix	2004-03-22 12:18:53.934582232 -0800
+++ 25-akpm/arch/ia64/hp/common/sba_iommu.c	2004-03-22 12:18:53.960578280 -0800
@@ -1979,6 +1979,12 @@ sba_dma_supported (struct device *dev, u
 	return ((mask & 0xFFFFFFFFUL) = 0xFFFFFFFFUL);
 }
 
+int
+sba_dma_error (dma_addr_t dma_addr)
+{
+	return 0;
+}
+
 __setup("nosbagart", nosbagart);
 
 static int __init
@@ -2004,6 +2010,7 @@ sba_page_override(char *str)
 
 __setup("sbapagesize=",sba_page_override);
 
+EXPORT_SYMBOL(sba_dma_error);
 EXPORT_SYMBOL(sba_map_single);
 EXPORT_SYMBOL(sba_unmap_single);
 EXPORT_SYMBOL(sba_map_sg);
diff -puN drivers/ide/ide-cd.c~ia64-dma_error-fix drivers/ide/ide-cd.c
--- 25/drivers/ide/ide-cd.c~ia64-dma_error-fix	2004-03-22 12:19:33.862512264 -0800
+++ 25-akpm/drivers/ide/ide-cd.c	2004-03-22 12:19:33.867511504 -0800
@@ -1044,7 +1044,7 @@ static ide_startstop_t cdrom_read_intr (
 	int ireason, len, sectors_to_transfer, nskip;
 	struct cdrom_info *info = drive->driver_data;
 	u8 lowcyl = 0, highcyl = 0;
-	int dma = info->dma, dma_error = 0;
+	int dma = info->dma, dma_err = 0;
 
 	struct request *rq = HWGROUP(drive)->rq;
 
@@ -1053,7 +1053,7 @@ static ide_startstop_t cdrom_read_intr (
 	 */
 	if (dma) {
 		info->dma = 0;
-		if ((dma_error = HWIF(drive)->ide_dma_end(drive)))
+		if ((dma_err = HWIF(drive)->ide_dma_end(drive)))
 			__ide_dma_off(drive);
 	}
 
@@ -1061,7 +1061,7 @@ static ide_startstop_t cdrom_read_intr (
 		return ide_stopped;
 
 	if (dma) {
-		if (!dma_error) {
+		if (!dma_err) {
 			ide_end_request(drive, 1, rq->nr_sectors);
 			return ide_stopped;
 		} else
@@ -1645,17 +1645,17 @@ static ide_startstop_t cdrom_newpc_intr(
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
@@ -1671,7 +1671,7 @@ static ide_startstop_t cdrom_newpc_intr(
 	 * using dma, transfer is complete now
 	 */
 	if (dma) {
-		if (dma_error) {
+		if (dma_err) {
 			printk("ide-cd: dma error\n");
 			__ide_dma_off(drive);
 			return DRIVER(drive)->error(drive, "dma error", stat);
@@ -1790,7 +1790,7 @@ static ide_startstop_t cdrom_write_intr(
 {
 	int stat, ireason, len, sectors_to_transfer, uptodate;
 	struct cdrom_info *info = drive->driver_data;
-	int dma_error = 0, dma = info->dma;
+	int dma_err = 0, dma = info->dma;
 	u8 lowcyl = 0, highcyl = 0;
 
 	struct request *rq = HWGROUP(drive)->rq;
@@ -1798,7 +1798,7 @@ static ide_startstop_t cdrom_write_intr(
 	/* Check for errors. */
 	if (dma) {
 		info->dma = 0;
-		if ((dma_error = HWIF(drive)->ide_dma_end(drive))) {
+		if ((dma_err = HWIF(drive)->ide_dma_end(drive))) {
 			printk("ide-cd: write dma error\n");
 			__ide_dma_off(drive);
 		}
@@ -1811,7 +1811,7 @@ static ide_startstop_t cdrom_write_intr(
 	 * using dma, transfer is complete now
 	 */
 	if (dma) {
-		if (dma_error)
+		if (dma_err)
 			return DRIVER(drive)->error(drive, "dma error", stat);
 
 		ide_end_request(drive, 1, rq->nr_sectors);

_

