From: Keith Owens <kaos@sgi.com>
Date: Wed, 03 Nov 2004 00:59:18 +0000
Subject: [patch 2.6.10-rc1] Do not disable interrupts in ia64_sn_plat_specific_err_print
Message-Id: <6539.1099443558@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64_sn_plat_specific_err_print() ends up calling vfree() which
requires IPI which can deadlock if interrupts are disabled.  Do not
disable interrupts in ia64_sn_plat_specific_err_print().

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/include/asm-ia64/sn/sn_sal.h
=================================--- linux.orig/include/asm-ia64/sn/sn_sal.h	Wed Nov  3 11:02:27 2004
+++ linux/include/asm-ia64/sn/sn_sal.h	Wed Nov  3 11:54:21 2004
@@ -313,7 +313,7 @@ ia64_sn_plat_specific_err_print(int (*ho
 	ret_stuff.v0 = 0;
 	ret_stuff.v1 = 0;
 	ret_stuff.v2 = 0;
-	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_PRINT_ERROR, (uint64_t)hook, (uint64_t)rec, 0, 0, 0, 0, 0);
+	SAL_CALL_REENTRANT(ret_stuff, SN_SAL_PRINT_ERROR, (uint64_t)hook, (uint64_t)rec, 0, 0, 0, 0, 0);
 
 	return ret_stuff.status;
 }

