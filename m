From: Keith Owens <kaos@sgi.com>
Date: Tue, 27 Apr 2004 00:00:51 +0000
Subject: [patch] 2.6.5 SN_SAL_PRINT_ERROR is reentrant
Message-Id: <9302.1083024051@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

SN_SAL_PRINT_ERROR is a reentrant SAL call.

Index: linux/include/asm-ia64/sn/sn_sal.h
=================================--- linux.orig/include/asm-ia64/sn/sn_sal.h	Mon Apr 26 15:20:18 2004
+++ linux/include/asm-ia64/sn/sn_sal.h	Tue Apr 27 09:55:57 2004
@@ -289,7 +289,7 @@
 	ret_stuff.v0 = 0;
 	ret_stuff.v1 = 0;
 	ret_stuff.v2 = 0;
-	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_PRINT_ERROR, (uint64_t)hook, (uint64_t)rec, 0, 0, 0, 0, 0);
+	SAL_CALL_REENTRANT(ret_stuff, SN_SAL_PRINT_ERROR, (uint64_t)hook, (uint64_t)rec, 0, 0, 0, 0, 0);
 
 	return ret_stuff.status;
 }

