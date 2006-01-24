From: Brent Casavant <bcasavan@sgi.com>
Date: Tue, 24 Jan 2006 01:23:50 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060123185157.D74549@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 23 Jan 2006, Luck, Tony wrote:

> Thinking about this a bit more, wouldn't it be better to do this
> work in the rebalance code that is making the decision to move
> the process.  The earlier argument that this would sometimes
> waste time because the process might not actually move doesn't
> sound so strong ... we context switch frequently, we move processes
> rarely.  Doing some work that may be wasted in the rare path sounds
> better than always doing work in the common path.

That's my opinion too, and what the original patch implemented, but
met with a little resistance from Ingo (Ingo: sorry, I forgot to CC 
you on the new patch to linux-ia64, let me know if you want a copy).
I agree with him that it's not wonderful to hook into mainline
scheduler code to solve this, but the alternative is what I presented
here: check if old CPU = new CPU at each context switch-in, entirely
within IA64 code.

An even better solution might be to have a hook in the main scheduler
which sets a "task has migrated" flag in the IA64 thread_info.flags and
add that flag to the IA64_HAS_EXTRA_STATE() macro.  ia64_load_extra()
and a machvec can then do the heavy lifting.  This way the migration
code would never do anything more than flip a bit, and we'd only make
the function call and wait on the Shub register at switch-in time on
the new CPU.  A side-effect of this would be laying most of the
necessary groundwork for what Jack Steiner referred to regarding
a future platform.

Does that, at least on the surface, sound palatable to each of you?
(I'm obviously not asking for a commitment to accept it, just "the
idea doesn't make me wretch").

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
