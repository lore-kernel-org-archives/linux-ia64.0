From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 13 Nov 2007 20:12:41 +0000
Subject: Re: [patch 1/1] ia64: export copy_page() to modules
Message-Id: <20071113121241.16a6ac15.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200711130929.lAD9Tmmh003824@imap1.linux-foundation.org>
In-Reply-To: <200711130929.lAD9Tmmh003824@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 13 Nov 2007 10:20:49 -0500 Kyle McMartin <kyle@mcmartin.ca> wrote:

> On Tue, Nov 13, 2007 at 01:22:51AM -0800, akpm@linux-foundation.org wrote:
> > To do this we need to move the copy_page() functions out of lib.a and into
> > built-in.a, and create a silly little C file to add the EXPORT_SYMBOL().
> > 
> 
> The usual thing to do for an export for an assembly file is to put it
> into $arch_ksyms.c
> 

Yes.  I was a bit worried what would happen if CONFIG_ITANIUM=n and
CONFIG_MCKINLEY=n, but I guess that isn't a valid combination.



diff -puN arch/ia64/kernel/ia64_ksyms.c~ia64-export-copy_page-to-modules-fix arch/ia64/kernel/ia64_ksyms.c
--- a/arch/ia64/kernel/ia64_ksyms.c~ia64-export-copy_page-to-modules-fix
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
diff -puN arch/ia64/lib/copy_page-export.c~ia64-export-copy_page-to-modules-fix /dev/null
--- a/arch/ia64/lib/copy_page-export.c
+++ /dev/null
@@ -1,4 +0,0 @@
-#include <asm/page.h>
-#include <linux/module.h>
-
-EXPORT_SYMBOL(copy_page);
_

