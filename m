From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 13 Aug 2003 15:37:50 +0000
Subject: Re: hugetlb compile problems (2.4 with gcc-3.4)
Message-Id: <marc-linux-ia64-106078984603174@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 12 August 2003 1:37 pm, Stephane Eranian wrote:
> I have run into some compilation problems on mm/hugetlb.c
> when using gcc3.4, it is more picky. It fails because
> in the latest 2.4 kernel there is the following:
> 
> static long    htlbzone_pages;
> 
> int set_hugetlb_mem_size(int count)
> {
> 	int j, lcount;
> 	struct page *page, *map;
> >>>	extern long htlbzone_pages;
> 	extern struct list_head htlbpage_freelist;
> 
> }

I applied the following patch for 2.4:

#### AUTHOR bjorn.helgaas@hp.com
#### COMMENT START
### Comments for ChangeSet
HUGETLB: remove bogus "extern" decls to satisfy gcc-3.4.
### Comments for arch/ia64/mm/hugetlbpage.c
HUGETLB: remove bogus "extern" decls to satisfy gcc-3.4.
#### COMMENT END

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1076  -> 1.1077 
#	arch/ia64/mm/hugetlbpage.c	1.2     -> 1.3    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/13	bjorn.helgaas@hp.com	1.1077
# HUGETLB: remove bogus "extern" decls to satisfy gcc-3.4.
# --------------------------------------------
#
diff -Nru a/arch/ia64/mm/hugetlbpage.c b/arch/ia64/mm/hugetlbpage.c
--- a/arch/ia64/mm/hugetlbpage.c	Wed Aug 13 10:41:45 2003
+++ b/arch/ia64/mm/hugetlbpage.c	Wed Aug 13 10:41:45 2003
@@ -12,12 +12,11 @@
 #include <linux/pagemap.h>
 #include <linux/smp_lock.h>
 #include <linux/slab.h>
-#include <linux/module.h>
+#include <linux/sysctl.h>
 #include <asm/mman.h>
 #include <asm/pgalloc.h>
 #include <asm/tlb.h>
 
-#include <linux/sysctl.h>
 
 #define TASK_HPAGE_BASE (REGION_HPAGE << REGION_SHIFT)
 
@@ -357,8 +356,6 @@
 {
 	int j, lcount;
 	struct page *page, *map;
-	extern long htlbzone_pages;
-	extern struct list_head htlbpage_freelist;
 
 	if (count < 0)
 		lcount = count;

