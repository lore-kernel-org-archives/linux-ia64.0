From: Prarit Bhargava <prarit@sgi.com>
Date: Tue, 10 May 2005 19:40:06 +0000
Subject: [PATCH]: IA64: sparse cleanup of TIOCA files
Message-Id: <42810E16.6010708@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------000105030704040600030008"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------000105030704040600030008
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------000105030704040600030008
Content-Type: text/plain;
 name="cgsparsea.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cgsparsea.diff"

[PATCH]: IA64: sparse cleanup of TIOCA files

This patch is a sparse compile cleanup of tioca_provider.c, sn_hwperf.h, and
tioca_provider.h.  Each of these files had sparse warnings when
compiled.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

Index: arch/ia64/sn/pci/tioca_provider.c
===================================================================
--- eed337ef5e9ae7d62caa84b7974a11fddc7f06e0/arch/ia64/sn/pci/tioca_provider.c  (mode:100644 sha1:8dae9eb45456d97525a6745a766f903eee2323d6)
+++ uncommitted/arch/ia64/sn/pci/tioca_provider.c  (mode:100644)
@@ -336,7 +336,7 @@
 	if (!ct_addr)
 		return 0;
 
-	bus_addr = (dma_addr_t) (ct_addr & 0xffffffffffff);
+	bus_addr = (dma_addr_t) (ct_addr & 0xffffffffffffUL);
 	node_upper = ct_addr >> 48;
 
 	if (node_upper > 64) {
@@ -464,7 +464,7 @@
  * For mappings created using the direct modes (64 or 48) there are no
  * resources to release.
  */
-void
+static void
 tioca_dma_unmap(struct pci_dev *pdev, dma_addr_t bus_addr, int dir)
 {
 	int i, entry;
@@ -514,7 +514,7 @@
  * The mapping mode used is based on the devices dma_mask.  As a last resort
  * use the GART mapped mode.
  */
-uint64_t
+static uint64_t
 tioca_dma_map(struct pci_dev *pdev, uint64_t paddr, size_t byte_count)
 {
 	uint64_t mapaddr;
@@ -580,7 +580,7 @@
  * On successful setup, returns the kernel version of tioca_common back to
  * the caller.
  */
-void *
+static void *
 tioca_bus_fixup(struct pcibus_bussoft *prom_bussoft)
 {
 	struct tioca_common *tioca_common;
Index: include/asm-ia64/sn/sn2/sn_hwperf.h
===================================================================
--- eed337ef5e9ae7d62caa84b7974a11fddc7f06e0/include/asm-ia64/sn/sn2/sn_hwperf.h  (mode:100644 sha1:b0c4d6dd77baf396e59c51b48972fe663ee1ea22)
+++ uncommitted/include/asm-ia64/sn/sn2/sn_hwperf.h  (mode:100644)
@@ -223,4 +223,6 @@
 #define SN_HWPERF_OP_RECONFIGURE	253
 #define SN_HWPERF_OP_INVAL		254
 
+int sn_topology_open(struct inode *inode, struct file *file);
+int sn_topology_release(struct inode *inode, struct file *file);
 #endif				/* SN_HWPERF_H */
Index: include/asm-ia64/sn/tioca_provider.h
===================================================================
--- eed337ef5e9ae7d62caa84b7974a11fddc7f06e0/include/asm-ia64/sn/tioca_provider.h  (mode:100644 sha1:b6acc22ab2395ba04dbef557311622333d5590ec)
+++ uncommitted/include/asm-ia64/sn/tioca_provider.h  (mode:100644)
@@ -201,6 +201,7 @@
 }
 
 extern uint32_t	tioca_gart_found;
+extern struct list_head tioca_list;
 extern int tioca_init_provider(void);
 extern void tioca_fastwrite_enable(struct tioca_kernel *tioca_kern);
 #endif /* _ASM_IA64_SN_TIO_CA_AGP_PROVIDER_H */

--------------000105030704040600030008--
