From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 30 Jan 2006 23:58:36 +0000
Subject: Re: [PATCH] ia64: avoid broken SAL_CACHE_FLUSH implementations
Message-Id: <20060130235836.GA5750@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601301511.57109.bjorn.helgaas@hp.com>
In-Reply-To: <200601301511.57109.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jan 30, 2006 at 04:51:57PM -0700, Bjorn Helgaas wrote:
> On Monday 30 January 2006 16:36, Luck, Tony wrote:
> > > If SAL_CACHE_FLUSH drops interrupts, complain about it and fall back to
> > > using PAL_CACHE_FLUSH instead.
> > 
> > But PAL_CACHE_FLUSH may not do all that SAL_CACHE_FLUSH does (e.g. if
> > the system has caches outside of the scope of PAL).  So there is an
> > assumption here that only systems where SAL_CACHE_FLUSH is equivalent
> > to PAL_CACHE_FLUSH have this bug in their SAL.
> 
> Right.  I verified with our firmware guys that in the case of the
> rx5670, SAL doesn't do anything extra.  So we should be safe there.
> 
> But you're right that in general, SAL may do something extra.
> 
> I'm hoping that the rx5670 is the only shipping box with this problem,
> and the error check should point out the problem so firmware for
> future boxes can be fixed.
> 
> I thought about also checking for "HP" or "rx5670" somewhere, but
> wasn't sure whether the extra effort of grubbing through DMI or
> something to find that would be worthwhile.
> 
> > Keith just confirmed that SGI doesn't have this SAL bug, but should I
> > be worried about other large ia64 boxes?
> 
> I expect that if other boxes have this problem, they should be seeing
> issues, now that we actually *use* SAL_CACHE_FLUSH for the migration
> cost measurements.  The dropped interrupt should cause pretty obvious
> problems.
> 
> (Did you mean to post this to the list?  If you meant to but forgot,
> you can quote my response.)

Doh!  Yes, I meant for this one to go to the list.  Perhaps the
printk(KERN_ERR "SAL: ...); will be enough of a warning in the
future to anyone unfortunate enough to have a SAL with this bug
and PAL_CACHE_FLUSH != SAL_CACHE_FLUSH.

-Tony
