From: Keith Owens <kaos@sgi.com>
Date: Mon, 10 May 2004 05:55:36 +0000
Subject: [patch] 2.6.6 SN2 specific prom flag in mca.c
Message-Id: <11478.1084168536@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

SN2 prom needs an extra flag on the MCA setup call.

Index: 2.6.6/arch/ia64/kernel/mca.c
=================================--- 2.6.6.orig/arch/ia64/kernel/mca.c	2004-04-05 12:43:31.000000000 -0500
+++ 2.6.6/arch/ia64/kernel/mca.c	2004-04-05 12:52:48.000000000 -0500
@@ -1207,6 +1207,9 @@
 	s64 rc;
 	struct ia64_sal_retval isrv;
 	u64 timeout = IA64_MCA_RENDEZ_TIMEOUT;	/* platform specific */
+	u64 mca_flags = SAL_MC_PARAM_RZ_ALWAYS;	/* platform specific */
+	if (ia64_platform_is("sn2"))
+		mca_flags |= 0x8;		/* SGI prom specific */
 
 	IA64_MCA_DEBUG("%s: begin\n", __FUNCTION__);
 
@@ -1224,7 +1227,7 @@
 					      SAL_MC_PARAM_MECHANISM_INT,
 					      IA64_MCA_RENDEZ_VECTOR,
 					      timeout,
-					      SAL_MC_PARAM_RZ_ALWAYS);
+					      mca_flags);
 		rc = isrv.status;
 		if (rc = 0)
 			break;

