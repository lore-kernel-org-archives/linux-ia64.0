From: Olaf Hering <olaf@aepfle.de>
Date: Fri, 16 Feb 2007 22:06:54 +0000
Subject: [PATCH] Remove stack hard limit on ia64
Message-Id: <20070216220654.GA11135@aepfle.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

From: schwab@suse.de

Un-Breaks pthreads, since Oct 2003.


Signed-off-by: Olaf Hering <olaf@aepfle.de>

---
 include/asm-ia64/resource.h |    1 -
 1 file changed, 1 deletion(-)

Index: linux-2.6/include/asm-ia64/resource.h
=================================--- linux-2.6.orig/include/asm-ia64/resource.h
+++ linux-2.6/include/asm-ia64/resource.h
@@ -2,7 +2,6 @@
 #define _ASM_IA64_RESOURCE_H
 
 #include <asm/ustack.h>
-#define _STK_LIM_MAX	DEFAULT_USER_STACK_SIZE
 #include <asm-generic/resource.h>
 
 #endif /* _ASM_IA64_RESOURCE_H */
