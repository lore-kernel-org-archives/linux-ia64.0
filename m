From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 14 Apr 2003 23:22:32 +0000
Subject: Re: [Linux-ia64] [patch] 2.4 timer_interrupt/gettimeoffset machvec
Message-Id: <marc-linux-ia64-105590723705501@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705438@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705438@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Apr 09, 2003 at 10:53:20AM -0700, David Mosberger wrote:
> Clearly you need to establish the relationship between the external
> clock and time-of-day somewhere, but I'm not so sure this should be
> done in the arch-specific timer interrupt handler.  I suspect you
> really want to do it where the time-of-day gets updated.  Also, I

I'd like for it to be there too.  Jes and I discussed this on irc and
I think he's going to take a stab at it.

> think this should be treated much more as a driver issue rather than a
> platform-issue (suppose someone plugged in an adapter card providing a
> low-latency, atomic accurracy & high precision lock, you'd presumably
> want to be able to use that card in favor of whatever other hardware
> might be there.

Agreed.  It would be nice to have that kind of flexibility.

Thanks,
Jesse

