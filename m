From: Roland McGrath <roland@redhat.com>
Date: Sat, 29 Mar 2008 02:24:08 +0000
Subject: Re: [PATCH 2/4] set_restore_sigmask TIF_SIGPENDING
Message-Id: <20080329022408.0DD4726FA1D@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080329001230.D013726FA1D@magilla.localdomain>
	<20080329001341.7F93826FA1D@magilla.localdomain>
	<alpine.LFD.1.00.0803281746480.14670@woody.linux-foundation.org>
In-Reply-To: Linus Torvalds's message of  Friday, 28 March 2008 17:53:16 -0700 <alpine.LFD.1.00.0803281746480.14670@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

> Hmm. That probably means that TIF_RESTORE_SIGMASK shouldn't be a "TIF" 
> flag at all, but a "TS" ("thread status") flag.

Yes.  It only ever needs to be set or tested by the thread itself.
It's used in an entirely synchronous fashion and never from
interrupts or anything like that.  

I didn't tackle changing this at the same time because of the can of
worms you cited (and because of doing one thing at a time).

It could be a PF_* too, I suppose.  There aren't too many of those
bits free, but it would have the advantage of being a place for an
arch that doesn't store any TS_* bits anywhere.

Since acting on the flag is in arch signal code anyway, it makes some
sense to let the arch define how it gets that to happen.  I'll send
some follow-on patches that change the conditionals to use #ifdef
HAVE_SET_RESTORE_SIGMASK.  Then an arch can define that to provide
its own set_restore_sigmask() instead of TIF_RESTORE_SIGMASK, using a
TS_* flag or whatever it likes.  It will make for an easy slow
transition by each arch whenever it decides it cares about the cycles.

> I guess TIF_RESTORE_SIGMASK is never *so* performance-critical that we'd 
> care about the difference between a single cycle (approx) for a non-atomic 
> "or" into memory and an atomic bitop (~50 cycles or so). 

I doubt it is.  There is always about to be a whole lot more overhead
for taking siglock and all manner of synchronizing hooey, anyway.

OTOH, my patch here just added a second set_thread_flag there purely
for paranoia (it's probably never needed, but I'd have to be Oleg to
be sure ;-).  So even if 50 doesn't much matter, 51 sounds better
than 100.


Thanks,
Roland
