From: Tony Luck <tony.luck@intel.com>
Date: Thu, 19 Aug 2004 17:23:46 +0000
Subject: calling oem sal functions
Message-Id: <4124E222.2080105@intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------080903060705030900040608"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------080903060705030900040608
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Dean,

I've been thinking about this, and it does seem unresonable that there
is no way for an OEM written module to make a call to an OEM SAL function.

Would something like the (compiles, but untested) attached patch work
for you?  The return value of 0/-1 just indicates whether the SAL call
was attempted.  Callers should look at the status field of the isrvp
structure to determine the actual success of the call.

Would you also need "_nolock" and "_reentrant" versions?

-Tony

--------------080903060705030900040608
Content-Type: text/plain;
 name="oemsal.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="oemsal.patch"

===== arch/ia64/kernel/sal.c 1.11 vs edited =====
--- 1.11/arch/ia64/kernel/sal.c	2004-07-09 00:11:46 +00:00
+++ edited/arch/ia64/kernel/sal.c	2004-08-19 17:02:07 +00:00
@@ -10,6 +10,7 @@
 
 #include <linux/kernel.h>
 #include <linux/init.h>
+#include <linux/module.h>
 #include <linux/spinlock.h>
 #include <linux/string.h>
 
@@ -262,3 +263,15 @@
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
+
+EXPORT_SYMBOL(oem_sal_call);

--------------080903060705030900040608--

