From: "Lee, Jung-Ik" <jung-ik.lee@intel.com>
Date: Wed, 06 Nov 2002 00:09:17 +0000
Subject: [Linux-ia64] patch for 2.5.45 fusion mptscsih
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C28528.BF12C6A0"
Message-Id: <marc-linux-ia64-105590709805336@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C28528.BF12C6A0
Content-Type: text/plain;
	charset="iso-8859-1"

The attached patch fixes message/fusion/mptscsih.h that causes kernel build
error.

 mptscsih.h |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

thanks,
J.I.


------_=_NextPart_000_01C28528.BF12C6A0
Content-Type: application/octet-stream;
	name="fusion_2545.diff"
Content-Disposition: attachment;
	filename="fusion_2545.diff"

diff -ur linux-2.5.45.org/drivers/message/fusion/mptscsih.h linux-2.5.45-ia64-021031-phpa/drivers/message/fusion/mptscsih.h
--- linux-2.5.45.org/drivers/message/fusion/mptscsih.h	Wed Oct 30 16:43:46 2002
+++ linux-2.5.45-ia64-021031-phpa/drivers/message/fusion/mptscsih.h	Tue Nov  5 13:33:03 2002
@@ -267,8 +268,7 @@
 	.sg_tablesize			= MPT_SCSI_SG_DEPTH,	\
 	.max_sectors			= MPT_SCSI_MAX_SECTORS,	\
 	.cmd_per_lun			= MPT_SCSI_CMD_PER_LUN,	\
-	.use_clustering			= ENABLE_CLUSTERING,	\
-	.slave_attach			x_scsi_slave_attach,	\
+	.use_clustering			= ENABLE_CLUSTERING	\
 }
 
 #else  /* LINUX_VERSION_CODE >= KERNEL_VERSION(2,5,1) */

------_=_NextPart_000_01C28528.BF12C6A0--

