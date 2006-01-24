From: Brent Casavant <bcasavan@sgi.com>
Date: Tue, 24 Jan 2006 22:41:35 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060124163651.O90635@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 24 Jan 2006, Chen, Kenneth W wrote:

> Brent Casavant wrote on Tuesday, January 24, 2006 2:12 PM
> > > On the other hand, it may not be too bad because on kernel exit, flags
> > > field in thread_info is accessed for TIF_* and if kernel exit path is
> > > taken back-to-back with context switch, the net effect maybe small.
> > 
> > Actually, IA64_HAS_EXTRA_STATE() reads the TIF_* flags, and is called
> > in __switch_to(), which is in very close proximity to checking last_cpu.
> 
> Where??
> 
> IA64_HAS_EXTRA_STATE() uses task->thread.flags, not task->thread_info->flags.
> These two flags are in two different places.

Bhaa! You are right of course. My mistake.

Still, other than moving last_cpu to neighbor cpu (or getting them
moved to the thread_struct, as you inquired of Ingo), I'm not sure
what can be done to further mitigate the cacheline impact.

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
