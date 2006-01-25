From: Brent Casavant <bcasavan@sgi.com>
Date: Wed, 25 Jan 2006 19:15:49 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060125131008.I16092@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 25 Jan 2006, Chen, Kenneth W wrote:

> I suppose, I don't have strong opinion where it is being called.
> Adding to ia64_load_extra(), you might need #ifdef CONFIG_SMP, of
> course you can just sneak in a plain version unless people yell at
> you for slowing their UP performance (I won't yell at you for UP).

Hmm. I just thought of a good reason.  Adding it to IA64_HAS_EXTRA_STATE
will cause ia64_{load,save}_extra to be invoked with every single
context switch on SN2, which I don't think we want to do.  Better to
leave it a separate test.  We may want to revisit that in the future
if/when IA64_THREAD_MIGRATION indicates something finer-grained than
"Is/isn't SN2", but for now it's the better solution.

> > __switch_task() (actually, after ia64_switch_to()) I would receive
> > kernel panics during boot (the migration threads would die from an
> > invalid access, swapper shortly thereafter, and finally a "soft
> lockup"
> > on swapper).  Was I perhaps missing something?
> 
> I can't immediately see why it won't work on sn2.  It works for me
> on a Intel tiger ia64 machine.

OK, I'll dig deeper into it.  I suspect ia64_switch_to() is changing
something important underneath us (e.g. a value saved on the stack,
which would tend to change when we switch stacks).

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
