From: Russ Anderson <rja@sgi.com>
Date: Mon, 28 Apr 2008 20:36:09 +0000
Subject: Re: [PATCH 0/2] ia64: Migrate data off physical pages with correctable errors
Message-Id: <20080428203609.GB23847@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080428192252.GA14629@sgi.com> <20080428193323.GA14990@parisc-linux.org>
In-Reply-To: <20080428193323.GA14990@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>

On Mon, Apr 28, 2008 at 01:33:23PM -0600, Matthew Wilcox wrote:
> On Mon, Apr 28, 2008 at 02:22:52PM -0500, Russ Anderson wrote:
> > 	There is always an issue of how agressive the code should be on
> > 	migrating pages.  Should it migrate on the first correctable error,
> > 	or wait for some threshold?  Reasonable people may disagree on the
> > 	threshold and the "right" answer may be hardware specific.  The 
> > 	decision making is confined to the cpe_migrate.c code.  It is
> > 	currently set to migrate on the first correctable error.
> 
> I think the kernel code should do the migration ASAP.  But I think we
> should have a list of 'bad' pages.  We could then have a badram driver
> that userspace can talk to to find out which pages are bad, map those
> pages into a badram process, do various tests on them, and return the
> pages to the pool if they're determined to be 'good'.

Sure.  The bad page list is badpagelist (defined in mca.c).
 
> I could also see badramd having a list of pages found to be bad
> in previous boots and asking the badram driver to take them out of
> circulation early in boot before they've been allocated.

That would be one alternative.  That type functionality would be
useful.  FWIW, some of my testing was on a system with a DIMM with
solid single bits.  It is a row/column problem so several meg of
addresses are effected.  Each boot it would migrate several meg worth
of pages without any problem.  It works surprisingly good.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
