From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 17 Aug 2001 17:22:10 +0000
Subject: [Linux-ia64] fix for typo
Message-Id: <marc-linux-ia64-105590698805087@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a fix for a small typo.  The kernel is not affected by it and
I'm not aware of any applications that are affected either.  In fact,
if you have any application that's using those flags directly, we need
to talk: there should be an API through which sigcontext is accessed
(no app should ever access sigcontext directly on IA-64).  But still,
the typo is a bug that needs to be fixed.  Thanks to Tony Luck for
noticing this.

	--david

--- include/asm-ia64/sigcontext.h~	Mon Aug 13 11:39:03 2001
+++ include/asm-ia64/sigcontext.h	Thu Aug 16 11:04:37 2001
@@ -2,13 +2,13 @@
 #define _ASM_IA64_SIGCONTEXT_H
 
 /*
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998, 1999, 2001 Hewlett-Packard Co
+ * Copyright (C) 1998, 1999, 2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
 #include <asm/fpu.h>
 
-#define IA64_SC_FLAG_ONSTACK_BIT		1	/* is handler running on signal stack? */
+#define IA64_SC_FLAG_ONSTACK_BIT		0	/* is handler running on signal stack? */
 #define IA64_SC_FLAG_IN_SYSCALL_BIT		1	/* did signal interrupt a syscall? */
 #define IA64_SC_FLAG_FPH_VALID_BIT		2	/* is state in f[32]-f[127] valid? */
 

