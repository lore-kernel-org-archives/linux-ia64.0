From: akpm@linux-foundation.org
Date: Tue, 13 Nov 2007 09:22:51 +0000
Subject: [patch 1/1] ia64: export copy_page() to modules
Message-Id: <200711130929.lAD9Tmmh003824@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

With the unionfs patch applied I get

ERROR: "copy_page" [fs/unionfs/unionfs.ko] undefined!

the other architectures (some, at least) export copy_page() so I guess ia64
should also do so.

To do this we need to move the copy_page() functions out of lib.a and into
built-in.a, and create a silly little C file to add the EXPORT_SYMBOL().

Maybe there are better ways...

Cc: Sam Ravnborg <sam@ravnborg.org>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/lib/Makefile           |    6 +++---
 arch/ia64/lib/copy_page-export.c |    4 ++++
 2 files changed, 7 insertions(+), 3 deletions(-)

diff -puN /dev/null arch/ia64/lib/copy_page-export.c
--- /dev/null
+++ a/arch/ia64/lib/copy_page-export.c
@@ -0,0 +1,4 @@
+#include <asm/page.h>
+#include <linux/module.h>
+
+EXPORT_SYMBOL(copy_page);
diff -puN arch/ia64/lib/Makefile~ia64-export-copy_page-to-modules arch/ia64/lib/Makefile
--- a/arch/ia64/lib/Makefile~ia64-export-copy_page-to-modules
+++ a/arch/ia64/lib/Makefile
@@ -2,7 +2,7 @@
 # Makefile for ia64-specific library routines..
 #
 
-obj-y := io.o
+obj-y := io.o copy_page-export.o
 
 lib-y := __divsi3.o __udivsi3.o __modsi3.o __umodsi3.o			\
 	__divdi3.o __udivdi3.o __moddi3.o __umoddi3.o			\
@@ -11,8 +11,8 @@ lib-y := __divsi3.o __udivsi3.o __modsi3
 	flush.o ip_fast_csum.o do_csum.o				\
 	memset.o strlen.o xor.o
 
-lib-$(CONFIG_ITANIUM)	+= copy_page.o copy_user.o memcpy.o
-lib-$(CONFIG_MCKINLEY)	+= copy_page_mck.o memcpy_mck.o
+obj-$(CONFIG_ITANIUM)	+= copy_page.o copy_user.o memcpy.o
+obj-$(CONFIG_MCKINLEY)	+= copy_page_mck.o memcpy_mck.o
 lib-$(CONFIG_PERFMON)	+= carta_random.o
 
 AFLAGS___divdi3.o	_
