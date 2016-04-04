From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 04 Apr 2016 09:21:43 +0000
Subject: Re: [PATCH 03/11] locking, rwsem: introduce basis for down_write_killable
Message-Id: <20160404092143.GX3448@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1459508695-14915-1-git-send-email-mhocko@kernel.org>
 <1459508695-14915-4-git-send-email-mhocko@kernel.org>
 <20160402044125.GC5329@linux-uzut.site>
 <20160404091659.GA13463@dhcp22.suse.cz>
In-Reply-To: <20160404091659.GA13463@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: Davidlohr Bueso <dave@stgolabs.net>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org

On Mon, Apr 04, 2016 at 11:17:00AM +0200, Michal Hocko wrote:
> > >@@ -486,21 +487,39 @@ struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
> > >
> > >		/* Block until there are no active lockers. */
> > >		do {
> > >+			if (signal_pending_state(state, current)) {
> > 
> >                           ^^ unlikely()?
> 
> The generated code is identical after I've added unlikely. I haven't
> tried more gcc versions (mine is 5.3.1) but is this worth it?

Both signal_pending() and __fatal_signal_pending() already have an
unlikely(), which is why adding it here is superfluous.
