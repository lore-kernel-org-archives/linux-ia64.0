From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 24 Feb 2006 01:14:03 +0000
Subject: RE: IA64 non-contiguous memory space bugs
Message-Id: <200602240114.k1O1E4g05231@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20060224001146.GC25101@localhost.localdomain>
References: <20060222001359.GA23574@localhost.localdomain>
In-Reply-To: <20060222001359.GA23574@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'David Gibson' <david@gibson.dropbear.id.au>, Hugh Dickins <hugh@veritas.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

David Gibson wrote on Thursday, February 23, 2006 4:12 PM
> It doesn't really mean different things - "touches a hugepage
> exclusive area" is the correct semantic, the ia64 implementation
> doesn't quite encode that, but is equivalent for valid address
> ranges.  (though I wonder if that's another bug associated with by
> task-region-max patch, without that patch invalid address ranges can
> slip through, so maybe it's possible on ia64 to create a normalpage VM
> with its start in the address space gap and its end in the hugepage
> region, ouch).

This is getting complicated that my little brain hurts.  There has been
so many iterations that the semantic is ambiguous.  If the semantic is
decided to be "overlap", then 

It will break arch/ia64/mm/hugetlbpage.c:hugetlb_free_pgd_range():

        if (is_hugepage_only_range(tlb->mm, floor, HPAGE_SIZE))
                floor = htlbpage_to_page(floor);
        if (is_hugepage_only_range(tlb->mm, ceiling, HPAGE_SIZE))
                ceiling = htlbpage_to_page(ceiling);

And it will break horribly bad because hugetlbpage_to_page does
"magic" address transformation.

- Ken

