From: Jesse Barnes <jbarnes@sgi.com>
Date: Tue, 08 Apr 2003 21:49:25 +0000
Subject: Re: [Linux-ia64] [patch] 2.4 timer_interrupt/gettimeoffset machvec
Message-Id: <marc-linux-ia64-105590723705440@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705438@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705438@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 08, 2003 at 02:41:52PM -0700, David Mosberger wrote:
> I suspect we're better off in the long term making gettimeoffset() a
> function pointer.  I can certainly imagine platforms where multiple
> interpolation sources are available and depending on parameters (e.g.,
> long-term stability or overhead), one might want to choose one or
> another.

I agree, since it'll probably refer to a platform specific RTC.

> The motivation for changing timer_interrupt() seems suspect to me.
> The timer interupt is generated PER CPU, so there is no drift issue at
> all (in fact, we intentionally _skew_ things at boot time to reduce
> the likelihood of getting all timer interrupts at the same time).

The problem is that we want high resolution gettimeofday, which means
that we need to know how long its been since wall time was updated
when gettimeoffset is called.  We do that right now by snapshoting the
RTC in timer_interrupt...

Jesse

