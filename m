From: Robin Holt <holt@sgi.com>
Date: Thu, 20 Mar 2008 01:40:42 +0000
Subject: Re: [Patch 0/3] Modify how per_cpu allocations are done. -V8
Message-Id: <20080320014041.GG18194@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080213175519.892353127@attica.americas.sgi.com>
In-Reply-To: <20080213175519.892353127@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 18, 2008 at 10:46:59AM -0700, Luck, Tony wrote:
> > Have you had a chance to test this revised patchset on your tiger box?
> 
> Yes.  The new patchset still builds cleanly for all my test configs, and
> this time it boots on my Tiger.
> 
> I'm still wondering about the direction you've taken though.  One
> of the goals of this patchset is to reduce boot-time memory
> allocation by making sure that we don't allocate per-cpu resources
> for cpus that will never exist.  But not all systems provide
> enough information to determine this reliably (and Linux doesn't
> get around to looking at that information until after we need to
> do these allocations) so you've added the "early_cpu_possible_map"
> which in some cases has to err on the safe side in how many cpus
> it thinks may ever exist ... and so we may allocate resources for
> some non-existant cpus.

I am not sure where to go with this.  I have done some more pondering
today and now I feel further from a solution.  The code now does limit
the scope of our overallocation.  In the case where the ACPI tables
have described the cpu's numa placement, we don't overallocate at all.
In all other cases, we overshoot by far fewer.  With a defconfig kernel
on a zx1, the allocation drops from 512 per_cpu areas to 32.  I agree it
is not an ideal solution, but I fail to see a better solution.  Is there a
different table I should be walking to discover the actual number of cpus?

> The existing MCA part of the code appears to be more conservative
> than the code that you are adding.  It allocates for cpu0 using
> bootmem_alloc, and then for other cpus on an as-needed basis using
> alloc_pages_node().  The current code is very ugly ... needing
> an "__init refok" function, and not dealing well with possible
> allocation failures.  A clean-up is definitely needed, but can't
> we still maintain the alloc-on-demand part (perhaps moving it
> from being run by the new cpu itself to some pre-bring-up-code
> that will be run by the cpu that is going to initiate bringing
> the cpu online ... which would make the error handling path
> easier).

I think I am going to give up on that patch entirely.  My swag at this at
least ensured there was no way the allocation could fail, but it does
not make any of the over-allocation issues better.  Unless you feel
there is merit here, I will drop that patch.

Thanks,
Robin
