From: Hirokazu Takahashi <taka@valinux.co.jp>
Date: Tue, 16 Mar 2004 02:32:09 +0000
Subject: Re: Hugetlbpages in very large memory machines.......
Message-Id: <20040316.113209.63031370.taka@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040313.135638.78732994.taka@valinux.co.jp>
	<JP20040316093003.3103921@pst.fujitsu.com>
	<20040316015401.GF9931@wotan.suse.de>
In-Reply-To: <20040316015401.GF9931@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ak@suse.de
Cc: n-yoshida@pst.fujitsu.com, raybry@sgi.com, linux-kernel@vger.kernel.org, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org

Hello,

> > +   pte = huge_pte_alloc(mm, address);
> > +   set_huge_pte(mm, vma, page, pte, vma->vm_flags & VM_WRITE);
> 
> This looks broken. Another CPU could have raced to the same fault
> and already added an PTE here. You have to handle that.
> 
> (my i386 version originally had the same problem)

Yes, you are true.
In the fault handler, we should use find_lock_page() instead of
find_get_page() to find a hugepage associated with the fault address.
After that pte_none(*pte) should be called again to check whether 
some races has happened.

> > +/*      update_mmu_cache(vma, address, *pte); */
> 
> I have not studied low level IA64 VM in detail, but don't you need
> some kind of TLB flush here?
> 
> -Andi


Thank you,
Hirokazu Takahashi.
