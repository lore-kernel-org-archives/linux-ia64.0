From: aip@turbolinux.com
Date: Tue, 05 Sep 2000 17:50:38 +0000
Subject: [Linux-ia64] [PATCH] fix casting problem in megaraid driver
MIME-Version: 1
Content-Type: multipart/mixed; boundary="k1lZvvs/B4yU6o8G"
Message-Id: <marc-linux-ia64-105590678205452@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205441@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205441@msgid-missing>
To: linux-ia64@vger.kernel.org

--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


This patch fixes bug where mbox's pointer was cast to integer, caused
segfault.

-Andrew

--k1lZvvs/B4yU6o8G
Content-Type: application/x-patch
Content-Disposition: attachment; filename="linux-2.4.0test7-ia64-megaraid.patch"

diff -Nur linux-2.4.0test7/drivers/scsi/megaraid.c linux-2.4.0test7.megaraid/drivers/scsi/megaraid.c
--- linux-2.4.0test7/drivers/scsi/megaraid.c	Mon Jun 19 13:42:40 2000
+++ linux-2.4.0test7.megaraid/drivers/scsi/megaraid.c	Thu Aug 31 16:14:09 2000
@@ -129,6 +129,11 @@
  *    occasionally hang. We check such cards and report them. You can
  *    get firmware upgrades to flash the board to 3.10 for free.
  *
+ * Version 1.08
+ *    Fixed bug where pointer of mbox was cast to integer in
+ *    mega_register_mailbox causing segfault. 
+ *    Aug 31 2000 Andrew Ip <aip@turbolinux.com>   
+ *
  * BUGS:
  *     Some older 2.1 kernels (eg. 2.1.90) have a bug in pci.c that
  *     fails to detect the controller as a pci device on the system.
@@ -1282,13 +1287,13 @@
  *   10 01 numstatus byte
  *   11 01 status byte
  *--------------------------------------------------------------------*/
-static int mega_register_mailbox (mega_host_config * megaCfg, u32 paddr)
+static int mega_register_mailbox (mega_host_config * megaCfg, u64 paddr)
 {
   /* align on 16-byte boundry */
   megaCfg->mbox = &megaCfg->mailbox64.mailbox;
-  megaCfg->mbox = (mega_mailbox *) ((((u32) megaCfg->mbox) + 16) & 0xfffffff0);
+  megaCfg->mbox = (mega_mailbox *) ((((u64) megaCfg->mbox) + 16) & 0xfffffffffffffff0);
   megaCfg->mbox64 = (mega_mailbox64 *) (megaCfg->mbox - 4);
-  paddr = (paddr + 4 + 16) & 0xfffffff0;
+  paddr = (paddr + 4 + 16) & 0xfffffffffffffff0;
 
   /* Register mailbox area with the firmware */
   if (!(megaCfg->flag & BOARD_QUARTZ)) {

--k1lZvvs/B4yU6o8G--

