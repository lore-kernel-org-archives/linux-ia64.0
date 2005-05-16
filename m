From: Russ Anderson <rja@sgi.com>
Date: Mon, 16 May 2005 22:19:20 +0000
Subject: [patch] Make Altix SAL call to POD reentrant
Message-Id: <200505162219.j4GMJKPS13711736@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Change the SAL call for POD mode to be reentrant.
This change is SN specific.

Signed-off-by: Russ Anderson (rja@sgi.com)

---------------------------------------------------------
Index: linux-2.6/include/asm-ia64/sn/sn_sal.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/sn_sal.h	2005-05-16 17:12:15.945378195 -0500
+++ linux-2.6/include/asm-ia64/sn/sn_sal.h	2005-05-16 17:13:30.769852426 -0500
@@ -472,7 +472,7 @@
 ia64_sn_pod_mode(void)
 {
 	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SN_SAL_POD_MODE, 0, 0, 0, 0, 0, 0, 0);
+	SAL_CALL_REENTRANT(isrv, SN_SAL_POD_MODE, 0, 0, 0, 0, 0, 0, 0);
 	if (isrv.status)
 		return 0;
 	return isrv.v0;
