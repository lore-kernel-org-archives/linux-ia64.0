From: Nick Piggin <npiggin@suse.de>
Date: Fri, 24 Aug 2007 03:12:57 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <20070824031257.GD6989@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822045714.GD26374@wotan.suse.de>
	<alpine.LFD.0.999.0708221049560.30176@woody.linux-foundation.org>
	<1187854035.5972.4.camel@localhost.localdomain>
	<200708230956.17049.jesse.barnes@intel.com>
In-Reply-To: <200708230956.17049.jesse.barnes@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jesse.barnes@intel.com>
Cc: linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linuxppc-dev@ozlabs.org

On Thu, Aug 23, 2007 at 09:56:16AM -0700, Jesse Barnes wrote:
> On Thursday, August 23, 2007 12:27 am Benjamin Herrenschmidt wrote:
> > > Of course, the normal memory barrier would usually be a
> > > "spin_unlock()" or something like that, not a "wmb()". In fact, I
> > > don't think the powerpc implementation (as an example of this) will
> > > actually synchronize with anything *but* a spin_unlock().
> >
> > We are even more sneaky in the sense that we set a per-cpu flag on
> > any MMIO write and do the sync automatically in spin_unlock() :-)
> 
> Yeah, that's a reasonable thing to do, and in fact I think there's code 
> to do something similar when a task is switched out (this keeps user 
> level drivers from having do mmiowb() type things).

It might be worth doing that and removing mmiowb completely. Or, if
that's too expensive, I'd like to see an API that is more explicitly
for keeping IOs inside critical sections.


> FWIW, I think I had an earlier version of the patch that used the name 
> pioflush() or something similar, the only confusing thing about that 
> name is that the primitive doesn't actually force I/Os down to the 
> device level, just to the closest bridge.

Yeah, that's what I found when trying to think of a name ;) It is
like an intermediate-level flush for the platform code, but from the
POV of the driver writer, it is nothing of the sort ;)
 
