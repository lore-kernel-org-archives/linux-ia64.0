From: Robin Holt <holt@sgi.com>
Date: Tue, 15 Feb 2005 19:31:48 +0000
Subject: Re: [PATCH] Convert pgtable cache to slab
Message-Id: <20050215193148.GC24401@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 15, 2005 at 10:29:51AM -0800, Luck, Tony wrote:
> Robin> For the 4-level case with 64k pages, what about just using
> Robin> 16k page tables?  That leaves us with 60 bits of addressable
> Robin> space which is fairly close to the full space.
> 
> David> You're kidding, right?  If getting "fairly close" to 64 bits was good
> David> enough, there would be no point for 64KB pages.
> 
> User space will only end up with just over 63.5 bits since the kernel
> has grabbed regions 5, 6, 7 for itself.  Unless someone comes up with
> a 16EB+16EB patch analogous to the 4G+4G ia32 patch :-)
> 
> We also lose some space out of each region for the VHPT.
> 
> Region 4 is reserved for hugetlb pages.
> 
> Page 0 of region 0 is a NaT page.
> 
> So we fall short of a full, flat 64-bit address space for a variety
> of reasons.
> 
> Nonetheless, I agree with David that reducing available virtual
> space by a factor of 16 sounds like a poor idea.

We do not currently forsee a need to go beyond 4 levels of 16k page
tables with 16k pages.  If so, jumping to 4 levels of 16k page tables
with 64k pages gets our address space to 60 bits.

With short format page tables, spanning regions is not possible.  We do
not see that as an issue since a 60 bit virtual address space should
meet our customer needs for the longterm future.

Is there a strong objection to implementing 4 levels of 16k page tables
for now and then, if someone else sees a need, convert to using long
page table format and adjust page tables as needed at that point in time.

At this point in time, I think the consistent 16k allocations would be
better for page table reuse than having 1k allocations intermingled with
64k allocations.

Am I off target on this completely?  Have I missed something important?

Thanks,
Robin
