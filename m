From: Martin Hicks <mort@wildopensource.com>
Date: Mon, 26 May 2003 17:39:26 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] 2.5 - Change mmu_gathers into per-cpu data
Message-Id: <marc-linux-ia64-105590723706034@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706018@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706018@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 23, 2003 at 01:59:18PM -0700, David Mosberger wrote:
> >>>>> On Fri, 23 May 2003 13:52:46 -0400, Martin Hicks <mort@wildopensource.com> said:
> 
>   Martin> Here is a patch to move the mmu_gathers struct into the
>   Martin> per-cpu data region.
> 
>   Martin> The patch is against the linux-ia64-2.5 tree.
> 
> Argh, your patch is MIME-encoded, so blanks show up as  , which
> means I can't just save the mail to a file and then apply the patch.
> Either do not MIME-encode the mail or send the patch as a separate
> MIME attachement.

Sorry.

Here it is again.
mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1100  -> 1.1101 
#	include/asm-ia64/tlb.h	1.13    -> 1.14   
#	 arch/ia64/mm/init.c	1.36    -> 1.37   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/05/22	mort@green.i.bork.org	1.1101
# per-cpu-mmu_gathers.diff
# --------------------------------------------
#
diff -Nru a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
--- a/arch/ia64/mm/init.c	Fri May 23 13:48:36 2003
+++ b/arch/ia64/mm/init.c	Fri May 23 13:48:36 2003
@@ -29,7 +29,7 @@
 #include <asm/uaccess.h>
 #include <asm/tlb.h>
 
-struct mmu_gather mmu_gathers[NR_CPUS];
+DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
 
 /* References to section boundaries: */
 extern char _stext, _etext, _edata, __init_begin, __init_end;
diff -Nru a/include/asm-ia64/tlb.h b/include/asm-ia64/tlb.h
--- a/include/asm-ia64/tlb.h	Fri May 23 13:48:36 2003
+++ b/include/asm-ia64/tlb.h	Fri May 23 13:48:36 2003
@@ -63,7 +63,7 @@
 };
 
 /* Users of the generic TLB shootdown code must declare this storage space. */
-extern struct mmu_gather	mmu_gathers[NR_CPUS];
+DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
 
 /*
  * Flush the TLB for address range START to END and, if not in fast mode, release the
@@ -125,7 +125,7 @@
 static inline struct mmu_gather *
 tlb_gather_mmu (struct mm_struct *mm, unsigned int full_mm_flush)
 {
-	struct mmu_gather *tlb = &mmu_gathers[smp_processor_id()];
+	struct mmu_gather *tlb = &per_cpu(mmu_gathers, smp_processor_id());
 
 	tlb->mm = mm;
 	/*

