From: Hugh Dickins <hugh@veritas.com>
Date: Thu, 23 Feb 2006 20:13:38 +0000
Subject: Re: IA64 non-contiguous memory space bugs
Message-Id: <Pine.LNX.4.61.0602231956560.12069@goblin.wat.veritas.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602220132.k1M1Vxg09552@unix-os.sc.intel.com>
 <200602220151.k1M1pqg09761@unix-os.sc.intel.com> <20060222022558.GE23574@localhost.localdomain>
 <Pine.LNX.4.61.0602221546040.9885@goblin.wat.veritas.com>
 <20060222234949.GB25108@localhost.localdomain>
In-Reply-To: <20060222234949.GB25108@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 23 Feb 2006, 'David Gibson' wrote:
> 
> Consider a HPAGE_SIZE hugepage VMA starting at 4GB, and a normal page
> VMA starting at (4GB-PAGE_SIZE).  This situation is possible on
> powerpc, and is_hugepage_only_range(4GB-PAGE_SIZE, HPAGE_SIZE) will
> (and must) return true.  Therefore the free_pgtables() logic will call
> hugetlb_free_pgd_range() across the normal page VMA.

Thanks for your patience, I eventually got it.  Although (amused to
observe my own incomprehension) I couldn't actually understand your
explanation at all, realized it myself overnight, read again what
you'd written, and then found that you had explained it very well.

Yes, I was wrong to use HPAGE_SIZE in that way in free_pgtables,
and it ought to go to the trouble of testing the real end-addr 
(if we keep using is_hugepage_only_range there at all).  Though
it's nothing urgent while your hugetlb_free_pgd_range happens to
be the same as your free_pgd_range, right?  Is that changing soon?

May I plead the extenuating circumstance, that the powerpc
is_hugepage_only_range means something quite different from the ia64?
The ia64 one means "within a hugepage-only range" but the powerpc one
means "overlaps a hugepage-only range"; I don't know which came first,
and is_hugepage_only_range isn't very descriptive of either (though
matches the ia64 case much better).

(That is, I think from the "touch" naming, and from your description,
that the powerpc one means "overlaps".  After a few minutes, I gave
up trying to decipher exactly what LOW_ESID_MASK and HTLB_AREA_MASK
end up doing, and take your superior knowledge on trust.)

While is_hugepage_only_range means different things to different
architectures, I guess it'd best be avoided in common code.  That use
in get_unmapped_area: powerpc gets it right, but ia64 gets it wrong?
But I didn't notice a change to that line (or the ia64 implementaton
thereof) in your original patch.

> I can see two ways of fixing this.  The quick, hacky fix is to use
> is_vm_hugetlb_page(), and work around the problems by having
> hugetlb_free_pgd_range() be identical to free_pgd_range() in most
> cases.

I don't see that as hacky.  I did point out that is_vm_hugetlb_page
will miss out on some coalescence, but that can't be a big deal for
what are already huge areas (the optimization was intended for many
tiny adjacent areas).

Hugh
