From: Russ Anderson <rja@sgi.com>
Date: Wed, 29 Oct 2008 22:29:18 +0000
Subject: [PATCH trivial] ia64: Fix gru compiler warning
Message-Id: <20081029222918.GA71188@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-next@vger.kernel.org

Fix compiler warning in sgi-gru driver.

Signed-off-by: Russ Anderson <rja@sgi.com>

---
Andrew,

This patch gets rid of the gru compiler warnings.


In file included from drivers/misc/sgi-gru/gruhandles.h:25,
                 from drivers/misc/sgi-gru/grutables.h:151,
                 from drivers/misc/sgi-gru/grufile.c:41:
drivers/misc/sgi-gru/gru_instructions.h: In function `gru_flush_cache':
drivers/misc/sgi-gru/gru_instructions.h:292: warning: passing arg 1 of pointer to
function makes integer from pointer without a cast



 drivers/misc/sgi-gru/gru_instructions.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: test/drivers/misc/sgi-gru/gru_instructions.h
=================================--- test.orig/drivers/misc/sgi-gru/gru_instructions.h	2008-10-29 11:19:56.000000000 -0500
+++ test/drivers/misc/sgi-gru/gru_instructions.h	2008-10-29 14:23:43.230943026 -0500
@@ -29,7 +29,7 @@
 #if defined(CONFIG_IA64)
 #include <linux/compiler.h>
 #include <asm/intrinsics.h>
-#define __flush_cache(p)		ia64_fc(p)
+#define __flush_cache(p)		ia64_fc((unsigned long)p)
 /* Use volatile on IA64 to ensure ordering via st4.rel */
 #define gru_ordered_store_int(p,v)					\
 		do {							\
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
