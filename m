From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 09 Apr 2003 17:53:20 +0000
Subject: Re: [Linux-ia64] [patch] 2.4 timer_interrupt/gettimeoffset machvec
Message-Id: <marc-linux-ia64-105590723705450@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705438@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705438@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 8 Apr 2003 14:49:25 -0700, Jesse Barnes <jbarnes@sgi.com> said:

  >> The motivation for changing timer_interrupt() seems suspect to me.
  >> The timer interupt is generated PER CPU, so there is no drift issue at
  >> all (in fact, we intentionally _skew_ things at boot time to reduce
  >> the likelihood of getting all timer interrupts at the same time).

  Jesse> The problem is that we want high resolution gettimeofday, which means
  Jesse> that we need to know how long its been since wall time was updated
  Jesse> when gettimeoffset is called.  We do that right now by snapshoting the
  Jesse> RTC in timer_interrupt...

Clearly you need to establish the relationship between the external
clock and time-of-day somewhere, but I'm not so sure this should be
done in the arch-specific timer interrupt handler.  I suspect you
really want to do it where the time-of-day gets updated.  Also, I
think this should be treated much more as a driver issue rather than a
platform-issue (suppose someone plugged in an adapter card providing a
low-latency, atomic accurracy & high precision lock, you'd presumably
want to be able to use that card in favor of whatever other hardware
might be there.

	--david

