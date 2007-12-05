From: akpm@linux-foundation.org
Date: Wed, 05 Dec 2007 22:32:15 +0000
Subject: [patch 3/3] ia64: export copy_page() to modules
Message-Id: <200712052232.lB5MWFeP028397@imap1.linux-foundation.org>
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
built-in.o and add the EXPORT_SYMBOL().

Cc: Sam Ravnborg <sam@ravnborg.org>
Cc: "Luck, Tony" <tony.luck@intel.com>
Cc: Kyle McMartin <kyle@mcmartin.ca>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/kernel/ia64_ksyms.c |    3 +++
 arch/ia64/lib/Makefile        |    4 ++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff -puN arch/ia64/kernel/ia64_ksyms.c~ia64-export-copy_page-to-modules arch/ia64/kernel/ia64_ksyms.c
--- a/arch/ia64/kernel/ia64_ksyms.c~ia64-export-copy_page-to-modules
+++ a/arch/ia64/kernel/ia64_ksyms.c
@@ -63,6 +63,9 @@ EXPORT_SYMBOL(__udivdi3);
 EXPORT_SYMBOL(__moddi3);
 EXPORT_SYMBOL(__umoddi3);
 
+#include <asm/page.h>
+EXPORT_SYMBOL(copy_page);
+
 #if defined(CONFIG_MD_RAID456) || defined(CONFIG_MD_RAID456_MODULE)
 extern void xor_ia64_2(void);
 extern void xor_ia64_3(void);
diff -puN arch/ia64/lib/Makefile~ia64-export-copy_page-to-modules arch/ia64/lib/Makefile
--- a/arch/ia64/lib/Makefile~ia64-export-copy_page-to-modules
+++ a/arch/ia64/lib/Makefile
@@ -11,8 +11,8 @@ lib-y := __divsi3.o __udivsi3.o __modsi3
 	flush.o ip_fast_csum.o do_csum.o				\
 	memset.o strlen.o xor.o
 
-lib-$(CONFIG_ITANIUM)	+= copy_page.o copy_user.o memcpy.o
-lib-$(CONFIG_MCKINLEY)	+= copy_page_mck.o memcpy_mck.o
+obj-$(CONFIG_ITANIUM)	+= copy_page.o copy_user.o memcpy.o
+obj-$(CONFIG_MCKINLEY)	+= copy_page_mck.o memcpy_mck.o
 lib-$(CONFIG_PERFMON)	+= carta_random.o
 
 AFLAGS___divdi3.o	_
