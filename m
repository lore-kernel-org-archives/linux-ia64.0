From: Brent Casavant <bcasavan@sgi.com>
Date: Fri, 20 Jan 2006 06:47:03 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060120003303.O81637@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
 <200601191818.43157.jbarnes@virtuousgeek.org>
In-Reply-To: <200601191818.43157.jbarnes@virtuousgeek.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, jes@sgi.com, tony.luck@intel.com

On Thu, 19 Jan 2006, Jesse Barnes wrote:

> Maybe you could just turn the above into mmiowb() calls instead?  That 
> would cover altix, origin, and ppc as well I think.  On other platforms 
> it would be a complete no-op.

As you obviously noted, the core of the code was lifted from mmiowb().
But no, an mmiowb() as such isn't correct.  At the time this code is
executing, it's on a CPU remote from the one which issued any PIO writes
to the device.  So in this case we need to poll the Shub register for
a remote node, but mmiowb() only polls for the Shub corresponding to
the current CPU.

My first incarnation of this patch (never publicly presented) did
implement a new mmiowb_remote(cpu) machvec instead, and this was
placed in the context-switch (in) path instead of the task migration
path.  However, since this behavior is only needed for the task
migration case, Jack Steiner pointed out that this was a more
appropriate way to implement it.  As migration is much less frequent
than context switching, this is a better-performing method to solve
the problem.

Thanks,
Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
