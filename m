From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 24 Feb 2006 03:05:23 +0000
Subject: RE: [patch] fix ia64 hugetlb_free_pgd_range
Message-Id: <200602240305.k1O35Ng06352@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20060224024431.GC28368@localhost.localdomain>
References: <200602240145.k1O1jEg05475@unix-os.sc.intel.com>
In-Reply-To: <200602240145.k1O1jEg05475@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: 'Hugh Dickins' <hugh@veritas.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

David Gibson wrote on Thursday, February 23, 2006 6:45 PM
> However... I suspect in fact that the transformations should be
> unconditional.

No, that won't be correct.


> The whole address scaling thing that ia64 does for
> hugepages is extremely confusing, but since floor and ceiling are just
> used for bounds checking on the inner functions, shouldn't they be
> transformed to the same scale as addr and end, even if that's not
> actually a true address (hugepage or otherwise).

Think of multiple page size support, the way we do it on ia64 is
effective have different PAGE_SHIFT for normal page and hugetlb
page.  Normal page has page shift of 14 bits (of 16K page size).
Hugetlb page has page shift of 28 bits (of 256MB page size).
For any address, regardless whether it is normal/hugetlb page,
they all have full 3 level (or 4 level page table).  So for hugetlb
address, pgd/pud/pmd/pte index are off by (28-14) bits compare
to normal page.  We just transform the address so all the generic
code can be applied.  It's sort of selling you a wood looking
vinyl car stick shift.

- Ken

