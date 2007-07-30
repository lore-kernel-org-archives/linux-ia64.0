From: Russ Anderson <rja@sgi.com>
Date: Mon, 30 Jul 2007 23:31:49 +0000
Subject: SN2 hanging in udevsettle (was: Re: Linus' tree broken?)
Message-Id: <200707302331.l6UNVnLA138913606@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson wrote:
> 
> More specificly, it hangs in /sbin/udevsettle .

Using git bisect to narrow it down, it looks like
commit 2008220879af095d00ca27eb168a55c8595fbc0b may
be causing the hang in udevsettle on SN2. 

A tree synced up with "cg-seek 7b4c965a0b74748269d05185a394c9dc121dd558" boots.
With "cg-seek 2008220879af095d00ca27eb168a55c8595fbc0b" udevsettle hangs.

I'll dig further into this tomorrow.

--------------------------------------------------------------------
commit 2008220879af095d00ca27eb168a55c8595fbc0b
Author: Linus Torvalds <torvalds@woody.linux-foundation.org>
Date:   Fri Jul 20 13:28:54 2007 -0700

    Revert "sys_time() speedup"

    This basically reverts commit 4e44f3497d41db4c3b9051c61410dee8ae4fb49c,
    while waiting for it to be re-done more completely.  There are cases of
    people mixing "time()" with higher-resolution time sources, and we need
    to take the nanosecond offsets into account.

    Ingo has a patch that does that, but it's still under some discussion.
    In the meantime, just revert back to the old simple situation of just
    doing the whole exact timesource calculations.

    But rather than using do_gettimeofday(), use the internal nanosecond
    resolution getnstimeofday(), which at least avoids one unnecessary
    conversion (since we really don't care about whether the fractional
    seconds are nanoseconds or microseconds - we'll just throw them away).

    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>



-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
