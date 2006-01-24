From: Brent Casavant <bcasavan@sgi.com>
Date: Tue, 24 Jan 2006 06:41:23 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060124003047.O80998@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 24 Jan 2006, Keith Owens wrote:

> The problem with setting arch specific flags in mailine code is the
> need to use #ifdef or to define dummy funcions for all architectures.
> Apart from that, the idea works for me.  You can pinch the
> TIF_SIGDELAYED bit, which I just removed.

It's actually quite clean.  See prepare_arch_switch() and
finish_arch_switch() as an example of how I'd pattern the code.
Those are done by #ifdef, but very clearly isolated.

Hmm, I might be able to utilize prepare_arch_switch() -- I'll have
to take a closer look when I get back into the office Tuesday.  I
sure hope that would work, as it would avoid the need for changes to
kernel/sched.c.

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
