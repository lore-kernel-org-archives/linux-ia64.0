From: dcn@sgi.com (Dean Nelson)
Date: Fri, 20 Aug 2004 19:22:20 +0000
Subject: [PATCH] add ia64 OEM SAL call functions
Message-Id: <41264F6C.mailx6BB114RPW@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add wrapper functions for SAL_CALL(), SAL_CALL_NOLOCK(), and
SAL_CALL_REENTRANT() that allow OEM written modules to make
calls to ia64 OEM SAL functions.

Signed-off-by: Dean Nelson <dcn@sgi.com>



Index: linux/arch/ia64/kernel/sal.c
=================================--- linux.orig/arch/ia64/kernel/sal.c	2004-08-17 13:31:18.000000000 -0500
+++ linux/arch/ia64/kernel/sal.c	2004-08-20 13:29:28.000000000 -0500
@@ -10,6 +10,7 @@
 
 #include <linux/kernel.h>
 #include <linux/init.h>
+#include <linux/module.h>
 #include <linux/spinlock.h>
 #include <linux/string.h>
 
@@ -262,3 +263,40 @@
 		p += SAL_DESC_SIZE(*p);
 	}
 }
+
+int
+ia64_sal_oemcall(struct ia64_sal_retval *isrvp, u64 oemfunc, u64 arg1,
+		 u64 arg2, u64 arg3, u64 arg4, u64 arg5, u64 arg6, u64 arg7)
+{
+	if (oemfunc < IA64_SAL_OEMFUNC_MIN || oemfunc > IA64_SAL_OEMFUNC_MAX)
+		return -1;
+	SAL_CALL(*isrvp, oemfunc, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
+	return 0;
+}
+EXPORT_SYMBOL(ia64_sal_oemcall);
+
+int
+ia64_sal_oemcall_nolock(struct ia64_sal_retval *isrvp, u64 oemfunc, u64 arg1,
+			u64 arg2, u64 arg3, u64 arg4, u64 arg5, u64 arg6,
+			u64 arg7)
+{
+	if (oemfunc < IA64_SAL_OEMFUNC_MIN || oemfunc > IA64_SAL_OEMFUNC_MAX)
+		return -1;
+	SAL_CALL_NOLOCK(*isrvp, oemfunc, arg1, arg2, arg3, arg4, arg5, arg6,
+			arg7);
+	return 0;
+}
+EXPORT_SYMBOL(ia64_sal_oemcall_nolock);
+
+int
+ia64_sal_oemcall_reentrant(struct ia64_sal_retval *isrvp, u64 oemfunc,
+			   u64 arg1, u64 arg2, u64 arg3, u64 arg4, u64 arg5,
+			   u64 arg6, u64 arg7)
+{
+	if (oemfunc < IA64_SAL_OEMFUNC_MIN || oemfunc > IA64_SAL_OEMFUNC_MAX)
+		return -1;
+	SAL_CALL_REENTRANT(*isrvp, oemfunc, arg1, arg2, arg3, arg4, arg5, arg6,
+			   arg7);
+	return 0;
+}
+EXPORT_SYMBOL(ia64_sal_oemcall_reentrant);
Index: linux/include/asm-ia64/sal.h
=================================--- linux.orig/include/asm-ia64/sal.h	2004-06-16 00:20:04.000000000 -0500
+++ linux/include/asm-ia64/sal.h	2004-08-20 13:29:17.000000000 -0500
@@ -819,6 +819,16 @@
 	long r8; long r9; long r10; long r11;
 };
 
+#define IA64_SAL_OEMFUNC_MIN		0x02000000
+#define IA64_SAL_OEMFUNC_MAX		0x03ffffff
+
+extern int ia64_sal_oemcall(struct ia64_sal_retval *, u64, u64, u64, u64, u64,
+			    u64, u64, u64);
+extern int ia64_sal_oemcall_nolock(struct ia64_sal_retval *, u64, u64, u64,
+				   u64, u64, u64, u64, u64);
+extern int ia64_sal_oemcall_reentrant(struct ia64_sal_retval *, u64, u64, u64,
+				      u64, u64, u64, u64, u64);
+
 #endif /* __ASSEMBLY__ */
 
 #endif /* _ASM_IA64_SAL_H */
