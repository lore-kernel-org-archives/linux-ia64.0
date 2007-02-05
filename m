From: Horms <horms@verge.net.au>
Date: Mon, 05 Feb 2007 01:17:22 +0000
Subject: [PATCH] [IA64] kexec: Minor enhancement to includes in crash.c
Message-Id: <20070205011717.GB31046@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

linux/uaccess.h was being included, but it seems that 
really the following includes are needed.

asm/page.h: for __va() and PAGE_SHIFT
asm/uaccess.h: for copy_to_user()

I guess that linux/uaccess.h pulls in both asm/page.h and asm/uaccess.h.
I notices this while backporting the code to xen's linux-2.6.16.33,
which does not have linux/uaccess.h. I'm posting it as I think it is a
correct, though somewhat cosmetic fix.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/kernel/crash_dump.c
=================================--- linux-2.6.orig/arch/ia64/kernel/crash_dump.c	2006-12-20 10:49:17.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/crash_dump.c	2006-12-20 10:49:20.000000000 +0900
@@ -9,7 +9,8 @@
 #include <linux/errno.h>
 #include <linux/types.h>
 
-#include <linux/uaccess.h>
+#include <asm/page.h>
+#include <asm/uaccess.h>
 
 /**
  * copy_oldmem_page - copy one page from "oldmem"
