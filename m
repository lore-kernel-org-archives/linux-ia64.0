From: Grant Grundler <iod00d@hp.com>
Date: Wed, 09 Apr 2003 18:43:15 +0000
Subject: Re: [Linux-ia64] [patch] 2.4 timer_interrupt/gettimeoffset machvec
Message-Id: <marc-linux-ia64-105590723705451@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705438@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705438@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Apr 09, 2003 at 10:53:20AM -0700, David Mosberger wrote:
> Also, I think this should be treated much more as a driver issue rather
> than a platform-issue

In general, I like the idea.  It's really three peices of HW
involved: the RTC, the interval timer, and high resolution support.

The RTC is/has a driver in most cases it seems.

The interval timer gets started very early (bogomips) by
arch code. A seperate driver could work here which "claims"
the (per CPU) interval timer, registers the timer interrupt
handler, and syncronizes the multiple timers. But someone would
need to unravel dependencies and fix the init sequence accordingly.
Sounds like a pretty ugly task.

(Occasionally I try to figure out a timer problem that shows up on some
SMP parisc-linux boxes and then give up in the morass of interactions.)

The high resolution support is typically based on a cycle counter
in the CPU - very arch specific. But that probably doesn't need
to change (much) or become a driver.

> (suppose someone plugged in an adapter card providing a
> low-latency, atomic accurracy & high precision lock, you'd presumably
> want to be able to use that card in favor of whatever other hardware
> might be there.

yup.

thanks,
grant

