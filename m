From: Brent Casavant <bcasavan@sgi.com>
Date: Tue, 24 Jan 2006 22:04:35 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060124155434.Q90635@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 24 Jan 2006, Ingo Molnar wrote:

> btw., note that if such PIO writes happen frequently on a system, you 
> _really_ want this to be executed as late as possible - to give those 
> writes a chance to drain while this CPU is doing other useful work. In 
> that sense, doing the draining in the migration decision code is pretty 
> much the worst place to do it, because that's the _soonest_ point we 
> know that the task will migrate. That might still be milliseconds away 
> from actually hitting the CPU. Even if it was migrated to a totally idle 
> CPU, there's microseconds of codepath between the migration decision, 
> and the actual point in time where the switch_to() executes.

Right.  Which is of course one of the reasons my original patch sucked.
Since we're now running all the new code at the time of context switch
(and the potentially slow part only when we're *sure* we've switched CPUs),
it should now be about as good as it can get.

> a further detail: in that sense i'd rather suggest to move the condition 
> to after the __switch_to() call. You can drain anytime, as long as it's 
> done before userspace can issue new PIO writes. So you could as well do 
> it in the new context.

Done.  The new context is the right place for this to execute anyway
(not that it matters functionally).

Patch following in a few minutes.

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
