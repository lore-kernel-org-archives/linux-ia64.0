From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Date: Sun, 09 Aug 2009 15:39:55 +0000
Subject: [PATCH] IA64: includecheck fix: ia64, ia64_ksyms.c
Message-Id: <1249831675.2957.30.camel@ht.satnam>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


fix the following 'make includecheck' warning:

  arch/ia64/kernel/ia64_ksyms.c: asm/page.h is included more than once.

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
---
 arch/ia64/kernel/ia64_ksyms.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/ia64_ksyms.c b/arch/ia64/kernel/ia64_ksyms.c
index 2d31186..8ebccb5 100644
--- a/arch/ia64/kernel/ia64_ksyms.c
+++ b/arch/ia64/kernel/ia64_ksyms.c
@@ -21,6 +21,7 @@ EXPORT_SYMBOL(csum_ipv6_magic);
 
 #include <asm/page.h>
 EXPORT_SYMBOL(clear_page);
+EXPORT_SYMBOL(copy_page);
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 #include <linux/bootmem.h>
@@ -60,9 +61,6 @@ EXPORT_SYMBOL(__udivdi3);
 EXPORT_SYMBOL(__moddi3);
 EXPORT_SYMBOL(__umoddi3);
 
-#include <asm/page.h>
-EXPORT_SYMBOL(copy_page);
-
 #if defined(CONFIG_MD_RAID456) || defined(CONFIG_MD_RAID456_MODULE)
 extern void xor_ia64_2(void);
 extern void xor_ia64_3(void);
-- 
1.6.0.6


