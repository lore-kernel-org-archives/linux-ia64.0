From: Robin Holt <holt@sgi.com>
Date: Fri, 11 Feb 2005 18:35:19 +0000
Subject: Re: [PATCH] Convert pgtable cache to slab
Message-Id: <20050211183519.GA4059@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 10, 2005 at 12:38:06PM -0800, Luck, Tony wrote:
> Can pgtable_cache_init() be "__init"?

I have that changed in my work area now.

> 
> Do you have some before/after numbers from lmbench fork overhead
> (I wouldn't expect much impact from this, but it would be nice to
> make sure).

I am running lmbench even as we speak.  Is there a way to run lmbench
and only get the fork overhead information?

I started with this patch because it goes part of the way to where I
need to be.  I am trying to get 4 level page table directories working
efficiently on SGI boxes.  I see this as three problems.

1) This patch to join quicklists together and simplify the cleanup
   of the list to cases where memory is really needed (slabs does this
   nicely).
2) Ensure the slabs are made node aware.  We have seen significant
   impact when the page tables are allocated off node.
3) Implement the pud_alloc pud_free stuff so 4-level directories
   work.

After looking at some of the performance numbers, I am beginning to
think #1 and #2 need to be done as one.  I assumed there would be no
significant impact from using the zeroed slab versus the quicklists and
that appears to be true.  I have not considered all the ramifications
like the default sizes of the slab, etc.  There does not appear to be
much performance difference on lmbench between the two.  For a page-fault
test, the fault rate with the zeroed slab appears to be slightly lower,
but that is as I would expect due to the added overhead of the slab.

Right now, neither the quicklists nor slabs are node local.  I think
that is a larger issue.  I will start a seperate discussion about node
locality soon.

Thanks,
Robin
