From: Robin Holt <holt@sgi.com>
Date: Fri, 11 Feb 2005 19:33:51 +0000
Subject: Re: [PATCH] Convert pgtable cache to slab
Message-Id: <20050211193351.GB4059@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 11, 2005 at 10:51:12AM -0800, Luck, Tony wrote:
> >> Do you have some before/after numbers from lmbench fork overhead
> >> (I wouldn't expect much impact from this, but it would be nice to
> >> make sure).
> >
> >I am running lmbench even as we speak.  Is there a way to run lmbench
> >and only get the fork overhead information?
> 
> You can run the "lat_proc" binary with the "fork" argument.
> 
> >I started with this patch because it goes part of the way to where I
> >need to be.  I am trying to get 4 level page table directories working
> >efficiently on SGI boxes.  I see this as three problems.
> 
> Do you mean full four-level page tables, or just fixing the quirks
> in the current implementation that has an empty PUD level (and seems
> to have caused a slight drop in performance for reasons that are not
> yet completely understood)?

Full four-level.

> 
> >Right now, neither the quicklists nor slabs are node local.  I think
> >that is a larger issue.  I will start a seperate discussion about node
> >locality soon.
> 
> Making the slab node aware is probably the right thing to do, but
> making quicklists node aware is less invasive.

Does anybody have a preference?

I sort of like the quicklist because they are more clear.  I think the
node-aware slab cache may be quicker for some workloads..  On the SGI
kernel based upon 2.4, we collapsed the quicklists into a single list
and then just checked to see if the page being added to the list was for
this node.  It prevented some problems, but resulted in some of our MPI
loads keeping the quicklist completely full on most nodes and constantly
draining/allocating from a single node.  My preference leans towards the
slab cache, but I can be easily swayed.

Thanks,
Robin
