From: john stultz <johnstul@us.ibm.com>
Date: Thu, 20 Nov 2003 21:58:34 +0000
Subject: Re: [PATCH] - sched_clock() broken for ia64 SN platform
Message-Id: <marc-linux-ia64-106936601610014@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106928980122896@msgid-missing>
In-Reply-To: <marc-linux-ia64-106928980122896@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2003-11-20 at 13:27, David Mosberger wrote:
> >>>>> On Thu, 20 Nov 2003 12:58:20 -0800, "John Hawkes" <hawkes@sgi.com> said:
> 
>   John> I doubt this double-count would ever be accepted by the wider
>   John> Linux Community, as it bloats mainline arch-independent code,
>   John> just to fix a problem with a handful of drifty platforms.
> 
> That's not an argument: the "bloat" can be trivially hidden for
> non-drifty architectures with an inline routine or macro.  I for one
> would be perfectly happy to pay an extra word in the ia64-version of
> task_struct if that would yield a generic and scalable solution to the
> problem.  The problem right now is that the generic kernel code is
> structured in a way that prevents this.

I too was confused why per-cpu start and stop times were not just used
for this high-res accounting. I'm not sure I can look into it now, but
I'd be interested to hear why we'd compare timestamps across cpus
(rather then just use time deltas calculated on a single cpu).

Oh, and that last thought, keep it around for when 2.7 opens ;)

-john

