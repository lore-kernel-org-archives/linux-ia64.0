From: Horms <horms@verge.net.au>
Date: Wed, 07 Mar 2007 08:24:31 +0000
Subject: Re: [Fastboot] [PATCH] saved_max_pfn too small on a specific machine
Message-Id: <20070307082429.GA29770@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 06, 2007 at 07:07:32PM +0100, Bernhard Walle wrote:
> Hello,
> 
> I has a problem with the patch "Make saved_max_pfn point to max_pfn of
> entire system":
> 
> On a HP rx8640 system with following memory map, the saved_max_pfn was wrong,
> i.e. there was memory in /proc/iomem marked as "System RAM" but above
> saved_max_pfn. This patch fixes the problem.
> 
> If you have a better solution, please give me some hints. Thanks!

Hi Bernard,

this seems reasonable to me.

Acked-by: Simon Horman <horms@verge.net.au>

Magnus Damm suggested to me that if this change is going to be made,
then the whole chunk may as well be moved up to just after md is
validated. See below:

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

As only md is used to calculate saved_max_pfn it seems reasonable
to move setting saved_max_pfn to imediately after md is validated.
This shouldn't change the logic at all. And it seems to make what is 
going on a little clearer.

As suggested to me by Magnus Damm

Cc: Magnus Damm <magnus.damm@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/kernel/efi.c
=================================--- linux-2.6.orig/arch/ia64/kernel/efi.c	2007-03-07 16:57:00.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/efi.c	2007-03-07 17:00:02.000000000 +0900
@@ -971,6 +971,11 @@
 		if (!is_memory_available(md))
 			continue;
 
+#ifdef CONFIG_CRASH_DUMP
+		/* saved_max_pfn should ignore max_addr= command line arg */
+		if (saved_max_pfn < (efi_md_end(md) >> PAGE_SHIFT))
+			saved_max_pfn = (efi_md_end(md) >> PAGE_SHIFT);
+#endif
 		/*
 		 * Round ends inward to granule boundaries
 		 * Give trimmings to uncached allocator
@@ -1010,11 +1015,6 @@
 		} else
 			ae = efi_md_end(md);
 
-#ifdef CONFIG_CRASH_DUMP
-		/* saved_max_pfn should ignore max_addr= command line arg */
-		if (saved_max_pfn < (efi_md_end(md) >> PAGE_SHIFT))
-			saved_max_pfn = (efi_md_end(md) >> PAGE_SHIFT);
-#endif
 		/* keep within max_addr= and min_addr= command line arg */
 		as = max(as, min_addr);
 		ae = min(ae, max_addr);
