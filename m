From: William Lee Irwin III <wli@holomorphy.com>
Date: Thu, 19 Aug 2004 00:20:38 +0000
Subject: Re: page fault fastpath patch v2: fix race conditions, stats for 8,32     and    512 cpu SMP
Message-Id: <20040819002038.GW11200@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <2uexw-1Nn-1@gated-at.bofh.it> <2uCTq-2wa-55@gated-at.bofh.it> <pan.2004.08.18.23.50.13.562750@umich.edu> <20040819000151.GU11200@holomorphy.com> <Pine.GSO.4.58.0408182005080.9340@sapphire.engin.umich.edu>
In-Reply-To: <Pine.GSO.4.58.0408182005080.9340@sapphire.engin.umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rajesh Venkatasubramanian <vrajesh@umich.edu>
Cc: Hugh Dickins <hugh@veritas.com>, "David S. Miller" <davem@redhat.com>, raybry@sgi.com, ak@muc.de, benh@kernel.crashing.org, manfred@colorfullife.com, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 18 Aug 2004, William Lee Irwin III wrote:
>> exit_mmap() has removed the vma from ->i_mmap and ->mmap prior to
>> unmapping the pages, so this should be safe unless that operation
>> can be caught while it's in progress.

On Wed, Aug 18, 2004 at 08:07:24PM -0400, Rajesh Venkatasubramanian wrote:
> No. Unfortunately exit_mmap() removes vmas from ->i_mmap after removing
> page table pages. Maybe we can reverse this, though.

Something like this?


Index: mm1-2.6.8.1/mm/mmap.c
=================================--- mm1-2.6.8.1.orig/mm/mmap.c	2004-08-16 23:47:16.000000000 -0700
+++ mm1-2.6.8.1/mm/mmap.c	2004-08-18 17:18:26.513559632 -0700
@@ -1810,6 +1810,14 @@
 	mm->map_count -= unmap_vmas(&tlb, mm, mm->mmap, 0,
 					~0UL, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
+	/*
+	 * Walk the list again, actually closing and freeing it.
+	 */
+	while (vma) {
+		struct vm_area_struct *next = vma->vm_next;
+		remove_vm_struct(vma);
+		vma = next;
+	}
 	BUG_ON(mm->map_count);	/* This is just debugging */
 	clear_page_tables(tlb, FIRST_USER_PGD_NR, USER_PTRS_PER_PGD);
 	tlb_finish_mmu(tlb, 0, MM_VM_SIZE(mm));
@@ -1822,16 +1830,6 @@
 	mm->locked_vm = 0;
 
 	spin_unlock(&mm->page_table_lock);
-
-	/*
-	 * Walk the list again, actually closing and freeing it
-	 * without holding any MM locks.
-	 */
-	while (vma) {
-		struct vm_area_struct *next = vma->vm_next;
-		remove_vm_struct(vma);
-		vma = next;
-	}
 }
 
 /* Insert vm structure into process list sorted by address
