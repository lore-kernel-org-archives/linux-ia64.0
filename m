From: Robin Holt <holt@sgi.com>
Date: Tue, 15 Feb 2005 12:02:13 +0000
Subject: Re: [PATCH] Convert pgtable cache to slab
Message-Id: <20050215120213.GA20607@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 14, 2005 at 11:18:21AM -0800, Luck, Tony wrote:
> >I have given this some more thought over the weekend and think I am
> >leaning more towards the quicklists.  Its main attraction to me seems
> >to be the simplicity of design.  The quicklists remain consistent with
> >what we are already familiar with.  To make pte, pmd, and pgd entries
> >equivalent, I think I am going to propose a single quicklist for all
> >the different types of entries with a single add/remove function.
> 
> What about the 4-level case?  With 64K pages you end up with a surplus
> of bits if you use a full page for all pgd/pud/pmd/pte levels.  Are
> you planning on just leaving unused space in the PGD so that everything
> is simple?  It might be more efficient to slim down the number of bits
> in the pte level?  Then the slab starts looking attractive again to
> handle the sub-page allocations.

For the 4-level case with 64k pages, what about just using 16k page
tables?  That leaves us with 60 bits of addressable space which is fairly
close to the full space.  It would make the tables consistently sized,
but I am not sure that is of much value.  As you point out, the slab
would make that completely unnecessary.

Jack Steiner is trying to determine how much more expensive the off-node
page tables are than on node.  Once we know that, we will know if a
per-cpu or per-node quicklist type arrangement is truely beneficial or
if a general use slab without node awareness will be adequate.

Thanks,
Robin
