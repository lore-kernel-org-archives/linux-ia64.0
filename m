From: Bruce Losure <blosure@sgi.com>
Date: Thu, 24 Mar 2005 12:28:24 +0000
Subject: [PATCH 2.6.12 0/0] Altix only: Remove hubdev SAL call
Message-Id: <Pine.LNX.4.44.0503240618380.4759-100000@fsgi025.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi Tony,

This patch against ia64-test-2.6.12 fixes a bug where the tiocx code
was inadvertently un-doing some address modifications done in earlier
fixup code.    This patch just removes the offending code.

Please accept.

Signed-off-by: Bruce Losure <blosure@sgi.com>

Thanks,
-Bruce

Index: tiocx-test-2.6.12/arch/ia64/sn/kernel/tiocx.c
=================================--- tiocx-test-2.6.12.orig/arch/ia64/sn/kernel/tiocx.c	2005-03-23 18:49:50.585780038 -0600
+++ tiocx-test-2.6.12/arch/ia64/sn/kernel/tiocx.c	2005-03-23 18:56:06.670621925 -0600
@@ -330,19 +330,6 @@
 EXPORT_SYMBOL(tiocx_dma_addr);
 EXPORT_SYMBOL(tiocx_swin_base);
 
-static uint64_t tiocx_get_hubdev_info(u64 handle, u64 address)
-{
-
-	struct ia64_sal_retval ret_stuff;
-	ret_stuff.status = 0;
-	ret_stuff.v0 = 0;
-
-	ia64_sal_oemcall_nolock(&ret_stuff,
-				SN_SAL_IOIF_GET_HUBDEV_INFO,
-				handle, address, 0, 0, 0, 0, 0);
-	return ret_stuff.v0;
-}
-
 static void tio_conveyor_set(nasid_t nasid, int enable_flag)
 {
 	uint64_t ice_frz;
@@ -477,18 +464,12 @@
 
 		if (nasid & 0x1) {	/* TIO's are always odd */
 			struct hubdev_info *hubdev;
-			uint64_t status;
 			struct xwidget_info *widgetp;
 
 			DBG("Found TIO at nasid 0x%x\n", nasid);
 
 			hubdev  			    (struct hubdev_info *)(NODEPDA(cnodeid)->pdinfo);
-			status -			    tiocx_get_hubdev_info(nasid,
-						  (uint64_t) __pa(hubdev));
-			if (status)
-				continue;
 
 			widgetp = &hubdev->hdi_xwidget_info[TIOCX_CORELET];
 

