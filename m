From: Hirokazu Takahashi <taka@valinux.co.jp>
Date: Thu, 05 Aug 2004 16:35:22 +0000
Subject: Re: Hugetlb demanding paging for -mm tree
Message-Id: <20040806.013522.74731251.taka@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040805133637.GG14358@holomorphy.com>
	<200408051340.i75De0Y26517@unix-os.sc.intel.com>
In-Reply-To: <200408051340.i75De0Y26517@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kenneth.w.chen@intel.com
Cc: wli@holomorphy.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, rohit.seth@intel.com

Hello,

> > On Thu, Aug 05, 2004 at 06:29:02AM -0700, Chen, Kenneth W wrote:
> > > Dusted it off from 3 month ago.  This time re-diffed against 2.6.8-rc3-mm1.
> > > One big change compare to previous release is this patch should work for
> > > ALL arch that supports hugetlb page.  I have tested it on ia64 and x86.
> > > For x86, tested with no highmem config, 4G highmem config and PAE config.
> > > I have not tested it on sh, sparc64 and ppc64, but I have no reason to
> > > believe that this feature won't work on these arches.
> > > Patches are broken into two pieces.  But they should be applied together
> > > to have correct functionality for hugetlb demand paging.
> > > 00.demandpaging.patch - core hugetlb demand paging
> > > 01.overcommit.patch   - hugetlbfs strict overcommit accounting.
> > > Testing and comments are welcome.  Thanks.
> >
> > Could you resend as plaintext?
> 
> ---------------------
> 00.demandpaging.patch
> ---------------------

I noticed some problems in your patch.

  - unmap_hugepage_range() may over-decrease mm->rss, since
    some pte's may not assigned pages yet.

  - Some architectures may require to call update_mmu_cache() right after
    a pte is updated.

The following patch will fix them on IA32.
Patches against other architectures should be also needed.

Thanks,
Hirokazu Takahashi.


--- linux-2.6.8-rc3-mm1/arch/i386/mm/hugetlbpage.c.ORG	Thu Aug  5 20:56:59 2032
+++ linux-2.6.8-rc3-mm1/arch/i386/mm/hugetlbpage.c	Thu Aug  5 21:47:24 2032
@@ -234,7 +234,7 @@ void unmap_hugepage_range(struct vm_area
 			continue;
 		page = pte_page(pte);
 		put_page(page);
+		mm->rss -= (HPAGE_SIZE / PAGE_SIZE);
 	}
-	mm->rss -= (end - start) >> PAGE_SHIFT;
 	flush_tlb_range(vma, start, end);
 }
--- linux-2.6.8-rc3-mm1/mm/hugetlb.c.ORG	Thu Aug  5 20:57:13 2032
+++ linux-2.6.8-rc3-mm1/mm/hugetlb.c	Thu Aug  5 21:15:45 2032
@@ -276,9 +276,10 @@ retry:
 	}
 
 	spin_lock(&mm->page_table_lock);
-	if (pte_none(*pte))
+	if (pte_none(*pte)) {
 		set_huge_pte(mm, vma, page, pte, vma->vm_flags & VM_WRITE);
-	else
+		update_mmu_cache(vma, address, *pte);
+	} else
 		put_page(page);
 out:
 	spin_unlock(&mm->page_table_lock);
