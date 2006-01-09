From: Jeff Mahoney <jeffm@suse.com>
Date: Mon, 09 Jan 2006 17:15:14 +0000
Subject: [PATCH] ia64: including <asm/signal.h> alone causes compilation errors
Message-Id: <20060109171514.GA25096@locomotive.unixthugs.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>


 Including *just* <asm/signal.h> on ia64 will result in a compilation failure,
 where it will succeed on every other architecture.

 Every other arch includes <linux/compiler.h> either directly or via
 <linux/types.h> at the top of <asm-*/signal.h>. ia64 includes
 <linux/types.h> after including <asm-generic/signal.h>, which causes
 the __user in <asm-generic/signal.h> to get passed through untouched, causing
 compilation errors.

 This patch moves the #include <linux/types.h> up to the beginning of signal.h,
 as found on every other arch.

 A specific example of where this behavior is observed is the recent addition
 of OCFS2. fs/ocfs2/cluster/userdlm.c seems alone in only including
 <asm/signal.h>, which seems to be perfectly valid.

 While I could have just fixed this in the OCFS2 code, I thought that making
 ia64 more consistent with the rest of the kernel would be the better fix.

Signed-off-by: Jeff Mahoney <jeffm@suse.com>

diff -ruNpX dontdiff linux-2.6.15/include/asm-ia64/signal.h linux-2.6.15-ocfs2/include/asm-ia64/signal.h
--- linux-2.6.15/include/asm-ia64/signal.h	2006-01-02 22:21:10.000000000 -0500
+++ linux-2.6.15-ocfs2/include/asm-ia64/signal.h	2006-01-09 11:08:16.404700640 -0500
@@ -1,6 +1,8 @@
 #ifndef _ASM_IA64_SIGNAL_H
 #define _ASM_IA64_SIGNAL_H
 
+#include <linux/types.h>
+
 /*
  * Modified 1998-2001, 2003
  *	David Mosberger-Tang <davidm@hpl.hp.com>, Hewlett-Packard Co
@@ -122,8 +124,6 @@
 
 # ifndef __ASSEMBLY__
 
-#  include <linux/types.h>
-
 /* Avoid too many header ordering problems.  */
 struct siginfo;
 
-- 
Jeff Mahoney
SuSE Labs
