From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 28 Mar 2003 01:11:33 +0000
Subject: [Linux-ia64] asm-ia64/fpu.h portability improvement
Message-Id: <marc-linux-ia64-105590723705347@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch below makes the declaration of "struct ia64_fpreg" portable
accross compilers.  Bjorn, I think it would be good to make the same
change in 2.4.xx.

Even though it's a change to a kernel header file, this patch is
intended to fix a bug in glibc: without this patch, using a compiler
other than gcc will lead to a sigcontext/ucontext type which isn't
properly aligned.

	--david

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1128  -> 1.1129 
#	include/asm-ia64/fpu.h	1.2     -> 1.3    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/03/27	davidm@wailua.hpl.hp.com	1.1129
# ia64: Change struct ia64_fpreg so it will get 16-byte alignment with all
# 	ia64 compilers, not just GCC.
# --------------------------------------------
#
diff -Nru a/include/asm-ia64/fpu.h b/include/asm-ia64/fpu.h
--- a/include/asm-ia64/fpu.h	Thu Mar 27 17:05:38 2003
+++ b/include/asm-ia64/fpu.h	Thu Mar 27 17:05:38 2003
@@ -2,7 +2,7 @@
 #define _ASM_IA64_FPU_H
 
 /*
- * Copyright (C) 1998, 1999, 2002 Hewlett-Packard Co
+ * Copyright (C) 1998, 1999, 2002, 2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
@@ -57,8 +57,9 @@
 struct ia64_fpreg {
 	union {
 		unsigned long bits[2];
+		long double __dummy;	/* force 16-byte alignment */
 	} u;
-} __attribute__ ((aligned (16)));
+};
 
 # endif /* __ASSEMBLY__ */
 

