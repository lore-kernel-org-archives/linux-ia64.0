From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 14 Feb 2005 19:18:21 +0000
Subject: RE: [PATCH] Convert pgtable cache to slab
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02E64A63@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I have given this some more thought over the weekend and think I am
>leaning more towards the quicklists.  Its main attraction to me seems
>to be the simplicity of design.  The quicklists remain consistent with
>what we are already familiar with.  To make pte, pmd, and pgd entries
>equivalent, I think I am going to propose a single quicklist for all
>the different types of entries with a single add/remove function.

What about the 4-level case?  With 64K pages you end up with a surplus
of bits if you use a full page for all pgd/pud/pmd/pte levels.  Are
you planning on just leaving unused space in the PGD so that everything
is simple?  It might be more efficient to slim down the number of bits
in the pte level?  Then the slab starts looking attractive again to
handle the sub-page allocations.

-Tony
