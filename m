From: Brent Casavant <bcasavan@sgi.com>
Date: Tue, 28 Aug 2007 21:21:04 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <20070828155714.Q5403@pkunk.americas.sgi.com>
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
Cc: Nick Piggin <npiggin@suse.de>, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linuxppc-dev@ozlabs.org

On Thu, 23 Aug 2007, Jesse Barnes wrote:

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

Yes there is, git commit e08e6c521355cd33e647b2f739885bc3050eead6.

On SN2 any user process performing memory-mapped IO directly to a
device needs something like mmiowb() to be performed at the node of
the CPU it last ran on when the task context switches onto a new CPU.

The current code performs this action for all inter-CPU context
switches, but we had discussed the possibility of targetting the
action only when the user process has actually mapped a device for
IO.  I believe it was decided that this level of complexity wasn't
warranted unless this simple solution was found to cause a problem.

That reminds me.  Are the people who are working on the user-level
driver effort including a capability similar to mmiowb()?  If we
had that capability we could eventually do away with the change
mentioned above.  But that would come after all user-level drivers
were coded to include the mmiowb()-like calls, and existing drivers
which provide mmap() capability directly to hardware go away.

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
