From: jes@trained-monkey.org (Jes Sorensen)
Date: Thu, 12 May 2005 11:47:23 +0000
Subject: [patch] 2.6.12-rc4-mm1 missing ia64_sal_oemcall_reentrant
Message-Id: <17027.16971.18411.788080@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

The following patch adds the missing ia64_sal_oemcall_reentrant function
so 2.6.12-rc4-mm1 builds and boots on the SN2 again.

Cheers,
Jes

Add missing ia64_sal_oemcall_reentrant function as per the prototype
found in include/asm-ia64/sal.h.

Signed-off-by: Jes Sorensen <jes@trained-monkey.org>

--- linux-2.6.12-rc4-mm1/arch/ia64/kernel/sal.c~	2005-05-12 04:06:48 -07:00
+++ linux-2.6.12-rc4-mm1/arch/ia64/kernel/sal.c	2005-05-12 04:27:19 -07:00
@@ -285,3 +285,15 @@
 			arg7);
 	return 0;
 }
+
+int
+ia64_sal_oemcall_reentrant(struct ia64_sal_retval *isrvp, u64 oemfunc,
+			   u64 arg1, u64 arg2, u64 arg3, u64 arg4, u64 arg5,
+			   u64 arg6, u64 arg7)
+{
+	if (oemfunc < IA64_SAL_OEMFUNC_MIN || oemfunc > IA64_SAL_OEMFUNC_MAX)
+		return -1;
+	SAL_CALL_REENTRANT(*isrvp, oemfunc, arg1, arg2, arg3, arg4,
+			   arg5, arg6, arg7);
+	return 0;
+}
