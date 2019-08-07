From: Christoph Hellwig <hch@lst.de>
Date: Wed, 07 Aug 2019 13:30:31 +0000
Subject: [PATCH 11/29] qla1280: remove SGI SN2 support
Message-Id: <20190807133049.20893-12-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190807133049.20893-1-hch@lst.de>
In-Reply-To: <20190807133049.20893-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The SGI SN2 support is about to be removed, so drops the bits
specific to it from this driver.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/scsi/qla1280.c | 37 -------------------------------------
 drivers/scsi/qla1280.h |  3 ---
 2 files changed, 40 deletions(-)

diff --git a/drivers/scsi/qla1280.c b/drivers/scsi/qla1280.c
index e5760c4a27f0..832af4213046 100644
--- a/drivers/scsi/qla1280.c
+++ b/drivers/scsi/qla1280.c
@@ -357,10 +357,6 @@
 #include <scsi/scsi_host.h>
 #include <scsi/scsi_tcq.h>
 
-#if defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_SGI_SN2)
-#include <asm/sn/io.h>
-#endif
-
 
 /*
  * Compile time Options:
@@ -380,11 +376,6 @@
 
 #define NVRAM_DELAY()			udelay(500)	/* 2 microseconds */
 
-#if defined(__ia64__) && !defined(ia64_platform_is)
-#define ia64_platform_is(foo)		(!strcmp(x, platform_name))
-#endif
-
-
 #define IS_ISP1040(ha) (ha->pdev->device = PCI_DEVICE_ID_QLOGIC_ISP1020)
 #define IS_ISP1x40(ha) (ha->pdev->device = PCI_DEVICE_ID_QLOGIC_ISP1020 || \
 			ha->pdev->device = PCI_DEVICE_ID_QLOGIC_ISP1240)
@@ -1427,15 +1418,6 @@ qla1280_initialize_adapter(struct scsi_qla_host *ha)
 	ha->flags.reset_active = 0;
 	ha->flags.abort_isp_active = 0;
 
-#if defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_SGI_SN2)
-	if (ia64_platform_is("sn2")) {
-		printk(KERN_INFO "scsi(%li): Enabling SN2 PCI DMA "
-		       "dual channel lockup workaround\n", ha->host_no);
-		ha->flags.use_pci_vchannel = 1;
-		driver_setup.no_nvram = 1;
-	}
-#endif
-
 	/* TODO: implement support for the 1040 nvram format */
 	if (IS_ISP1040(ha))
 		driver_setup.no_nvram = 1;
@@ -2251,13 +2233,6 @@ qla1280_nvram_config(struct scsi_qla_host *ha)
 	mb[1] = nv->firmware_feature.f.enable_fast_posting;
 	mb[1] |= nv->firmware_feature.f.report_lvd_bus_transition << 1;
 	mb[1] |= nv->firmware_feature.f.disable_synchronous_backoff << 5;
-#if defined(CONFIG_IA64_GENERIC) || defined (CONFIG_IA64_SGI_SN2)
-	if (ia64_platform_is("sn2")) {
-		printk(KERN_INFO "scsi(%li): Enabling SN2 PCI DMA "
-		       "workaround\n", ha->host_no);
-		mb[1] |= nv->firmware_feature.f.unused_9 << 9; /* XXX */
-	}
-#endif
 	status |= qla1280_mailbox_command(ha, BIT_1 | BIT_0, mb);
 
 	/* Retry count and delay. */
@@ -2888,12 +2863,6 @@ qla1280_64bit_start_scsi(struct scsi_qla_host *ha, struct srb * sp)
 				break;
 
 			dma_handle = sg_dma_address(s);
-#if defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_SGI_SN2)
-			if (ha->flags.use_pci_vchannel)
-				sn_pci_set_vchan(ha->pdev,
-						 (unsigned long *)&dma_handle,
-						 SCSI_BUS_32(cmd));
-#endif
 			*dword_ptr++  				cpu_to_le32(lower_32_bits(dma_handle));
 			*dword_ptr++ @@ -2950,12 +2919,6 @@ qla1280_64bit_start_scsi(struct scsi_qla_host *ha, struct srb * sp)
 				if (cnt = 5)
 					break;
 				dma_handle = sg_dma_address(s);
-#if defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_SGI_SN2)
-				if (ha->flags.use_pci_vchannel)
-					sn_pci_set_vchan(ha->pdev,
-							 (unsigned long *)&dma_handle,
-							 SCSI_BUS_32(cmd));
-#endif
 				*dword_ptr++  					cpu_to_le32(lower_32_bits(dma_handle));
 				*dword_ptr++ diff --git a/drivers/scsi/qla1280.h b/drivers/scsi/qla1280.h
index b496206362a9..a1a8aefc7cc3 100644
--- a/drivers/scsi/qla1280.h
+++ b/drivers/scsi/qla1280.h
@@ -1055,9 +1055,6 @@ struct scsi_qla_host {
 		uint32_t reset_active:1;		/* 3 */
 		uint32_t abort_isp_active:1;		/* 4 */
 		uint32_t disable_risc_code_load:1;	/* 5 */
-#ifdef __ia64__
-		uint32_t use_pci_vchannel:1;
-#endif
 	} flags;
 
 	struct nvram nvram;
-- 
2.20.1
