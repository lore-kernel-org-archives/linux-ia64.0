From: Jack Steiner <steiner@sgi.com>
Date: Wed, 26 Nov 2003 19:02:30 +0000
Subject: Re: [PATCH] - kernel profiler & spinlock_contention
Message-Id: <marc-linux-ia64-106987356401440@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106986108616188@msgid-missing>
In-Reply-To: <marc-linux-ia64-106986108616188@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 26, 2003 at 09:31:02AM -0800, David Mosberger wrote:
> >>>>> On Wed, 26 Nov 2003 09:23:10 -0600, Jack Steiner <steiner@sgi.com> said:
> 
>   Jack> Profiling is more useful if addresses in spinlock_contention
>   Jack> were attributed to the caller of spinlock_contention.
> 
> Execuse the language, but I'm reading:
> 
> 	my tools suck so let's make the kernel suck!

I dont quite agree. The way it work right now, profiling on large
systems is useless. The single hotest spot in the kernel is
spinlock_contention & there is no clue why. The patch makes
the kernel work the way it did before spinning for locks was
moved out-of-line. I think that is a big improvement.

However, if your new tools allows me to determine the caller
of spinlock_contention (I'm guessing that it does), that is even better!!
If a prerelease version of the tools is available, I'll be happy
to try it on our system

> 
> Let's defer this discussion until next week, when I had a chance to
> release my profiling tool.  I think you'll then agree that it's much
> better to leave the code as is.  In fact, we should also have an
> out-of-line contention handler for the read/write locks.

Agree!


> 
> 	--david

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


