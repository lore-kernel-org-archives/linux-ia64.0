From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 29 Jul 2004 14:29:16 +0000
Subject: Re: Timer updates revision 6 (+jitter control/tuning/unification to
Message-Id: <Pine.LNX.4.58.0407290707270.31674@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407271921090.21106@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407271921090.21106@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 28 Jul 2004, David Mosberger wrote:

> >>>>> On Tue, 27 Jul 2004 19:23:09 -0700 (PDT), Christoph Lameter <clameter@sgi.com> said:
>
>   Christoph> A. 4 way Intel IA64 SMP system (kmart)
>   Christoph> ITC offsets:
>   Christoph> kmart:/usr/src/noship-tests # dmesg|grep synchr
>   Christoph> CPU 1: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 417 cycles)
>
>   Christoph> kmart:/usr/src # noship-tests/dmt
>   Christoph> gettimeofday cycles: 3428 215 215 215 215 215 215 215 215 215
>
> Is this a Merced-box?  It looks to me that way.  If so, that wouldn't
> be a good target for tuning the ITC-based code (it's not worth tuning
> around Merced idiosyncrasies, IMO).  On Madison, your gettimeofday()
> runs in 143 cycles for me.

The system is an Intel SDV (4 CPUs at 900 Mhz) and AFAIK it has McKinley
CPUs. Says the following on bootup:

Leaving McKinley Errata 9 workaround enabled.

> clock_gettime() is strange though: even with your patch applied, it
> still takes 421 cycles (compared to 466 cycles).  It appears that it's
> falling back on the slow path for some reason.  Unfortunately, I don't
> have time to investigate more right now.  What do you get with the
> attached test-program?

The test program is the same as the first part of the DMT thing (DMT David Mosberger Test). Results are included in the original post.

>
> Some other comments:
>
> The lfetch here:
>
> 	lfetch [r20]		// Needs lots of data from time_interpolator
> 	ld8 r21 = [r20]		// first quad with control information
>
> doesn't make much sense to me.  The following ld8 will have the same
> (actually, a stronger) effect as the lfetch.

Strangely I lost one cycle if the lfetch is omitted. But I will try this
again.

>
> This:
>
> 	mov pr = r21,0x3f00	// Set up predicates for timer operations
>
> is clever but I'm not sure it's an appropriate optimization for
> generic (non-ia64-specific) code and I suspect it will be a
> maintenance headache.  The additional compares needed in the absence
> of this solution should cost at most one cycle, no?

Putting 6 cmps/tbits in one cycle would do it yes. But I still would like
to have a bitmap to set options on how to handle the counters. This could
also be useful to implement future features.  Its an IA64 specific thing
that these flags begin at bit 8. Shift those to start at bit 0?

> I think the "is new ITC count greater than previous one is
> wrong".  Instead of:
>
> (p8)	mov r2 = ar.itc		// CPU_TIMER. 36 clocks latency!!!

> 	ld8 r26 = [r22]		// time_interpolator->last_counter

This is meant to be

(p13) ld8 r25 = [r23]         // time interpolator->last_cycle

right?

> (p13)	cmp.gt.unc p6,p7 = r25,r2	// check if it is less than last. p6,p7 cleared
>
> shouldn't it do something along the lines of:
>
> (p8)	mov r2 = ar.itc		// CPU_TIMER. 36 clocks latency!!!
> (p13)	ld8 r25 = [r23]		// time interpolator->last_cycle
> (p13)	sub rTMP = r25,r2
> (p13)	cmp.gt.unc p6,p7 = rTMP,r0 // check if it is less than last. p6,p7 cleared
>
> so ITC-wrap-around is handled correctly?

The current dejitter code has a problem for other reasons because it
sets r2 after r2 has already been used to calculate the time difference.

However the two above code samples have the same effect if I understand
correctly what you wanted to say. The cmp is doing a signed subtract for testing.

> This one:
>
> 	cmp.lt p6, p0 = CLOCK_MONOTONIC, r32
>
> should be cmp4.lt, since clockid_t appears to be an "int" on ia64, no?
>
> 	--david

I thought arguments are sign extended so either would work. If that is not
the case though then we might have found the reason that the function
falls back to the C code on your box.
