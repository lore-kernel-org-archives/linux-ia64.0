From: dcn@sgi.com (Dean Nelson)
Date: Fri, 20 Aug 2004 15:22:04 +0000
Subject: [PATCH] add OEM SAL call functions
Message-Id: <4126171C.mailx2731118NN@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add wrapper functions for SAL_CALL(), SAL_CALL_NOLOCK(), and
SAL_CALL_REENTRANT() that allow OEM written modules to make calls
to OEM SAL functions.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux/arch/ia64/kernel/sal.c
=================================--- linux.orig/arch/ia64/kernel/sal.c	2004-08-17 13:31:18.000000000 -0500
+++ linux/arch/ia64/kernel/sal.c	2004-08-20 07:40:35.000000000 -0500
@@ -10,6 +10,7 @@
 
 #include <linux/kernel.h>
 #include <linux/init.h>
+#include <linux/module.h>
 #include <linux/spinlock.h>
 #include <linux/string.h>
 
@@ -262,3 +263,39 @@
 		p += SAL_DESC_SIZE(*p);
 	}
 }
+
+int
+oem_sal_call(struct ia64_sal_retval *isrvp, u64 oemfunc, u64 arg1, u64 arg2,
+	     u64 arg3, u64 arg4, u64 arg5, u64 arg6, u64 arg7)
+{
+	if (oemfunc < 0x02000000 || oemfunc > 0x03ffffff)
+		return -1;
+	SAL_CALL(*isrvp, oemfunc, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
+	return 0;
+}
+EXPORT_SYMBOL(oem_sal_call);
+
+int
+oem_sal_call_nolock(struct ia64_sal_retval *isrvp, u64 oemfunc, u64 arg1,
+		    u64 arg2, u64 arg3, u64 arg4, u64 arg5, u64 arg6, u64 arg7)
+{
+	if (oemfunc < 0x02000000 || oemfunc > 0x03ffffff)
+		return -1;
+	SAL_CALL_NOLOCK(*isrvp, oemfunc, arg1, arg2, arg3, arg4, arg5, arg6,
+			arg7);
+	return 0;
+}
+EXPORT_SYMBOL(oem_sal_call_nolock);
+
+int
+oem_sal_call_reentrant(struct ia64_sal_retval *isrvp, u64 oemfunc, u64 arg1,
+		       u64 arg2, u64 arg3, u64 arg4, u64 arg5, u64 arg6,
+		       u64 arg7)
+{
+	if (oemfunc < 0x02000000 || oemfunc > 0x03ffffff)
+		return -1;
+	SAL_CALL_REENTRANT(*isrvp, oemfunc, arg1, arg2, arg3, arg4, arg5, arg6,
+			   arg7);
+	return 0;
+}
+EXPORT_SYMBOL(oem_sal_call_reentrant);
Index: linux/include/asm-ia64/sal.h
=================================--- linux.orig/include/asm-ia64/sal.h	2004-06-16 00:20:04.000000000 -0500
+++ linux/include/asm-ia64/sal.h	2004-08-20 07:46:55.000000000 -0500
@@ -819,6 +819,13 @@
 	long r8; long r9; long r10; long r11;
 };
 
+extern int oem_sal_call(struct ia64_sal_retval *, u64, u64, u64, u64, u64, u64,
+			u64, u64);
+extern int oem_sal_call_nolock(struct ia64_sal_retval *, u64, u64, u64, u64,
+			       u64, u64, u64, u64);
+extern int oem_sal_call_reentrant(struct ia64_sal_retval *, u64, u64, u64, u64,
+				  u64, u64, u64, u64);
+
 #endif /* __ASSEMBLY__ */
 
 #endif /* _ASM_IA64_SAL_H */
