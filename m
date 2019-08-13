From: Christoph Hellwig <hch@lst.de>
Date: Tue, 13 Aug 2019 07:24:58 +0000
Subject: [PATCH 12/28] qla2xxx: remove SGI SN2 support
Message-Id: <20190813072514.23299-13-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190813072514.23299-1-hch@lst.de>
In-Reply-To: <20190813072514.23299-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Mike Travis <mike.travis@hpe.com>, Dimitri Sivanich <sivanich@hpe.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, linux-ide@vger.kernel.org, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org

The SGI SN2 support is about to be removed, so drop the bits specific to
it from this driver.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/scsi/qla2xxx/qla_init.c | 14 --------------
 1 file changed, 14 deletions(-)

diff --git a/drivers/scsi/qla2xxx/qla_init.c b/drivers/scsi/qla2xxx/qla_init.c
index da83034d4759..d4c3baec9172 100644
--- a/drivers/scsi/qla2xxx/qla_init.c
+++ b/drivers/scsi/qla2xxx/qla_init.c
@@ -4575,20 +4575,6 @@ qla2x00_nvram_config(scsi_qla_host_t *vha)
 		rval = 1;
 	}
 
-#if defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_SGI_SN2)
-	/*
-	 * The SN2 does not provide BIOS emulation which means you can't change
-	 * potentially bogus BIOS settings. Force the use of default settings
-	 * for link rate and frame size.  Hope that the rest of the settings
-	 * are valid.
-	 */
-	if (ia64_platform_is("sn2")) {
-		nv->frame_payload_size = 2048;
-		if (IS_QLA23XX(ha))
-			nv->special_options[1] = BIT_7;
-	}
-#endif
-
 	/* Reset Initialization control block */
 	memset(icb, 0, ha->init_cb_size);
 
-- 
2.20.1
