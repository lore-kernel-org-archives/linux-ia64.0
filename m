From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 28 Jul 2004 20:22:44 +0000
Subject: Re: Timer updates revision 6 (+jitter control/tuning/unification to one
Message-Id: <16648.2836.705071.962751@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407271921090.21106@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407271921090.21106@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 27 Jul 2004 19:23:09 -0700 (PDT), Christoph Lameter <clameter@sgi.com> said:

  Christoph> A. 4 way Intel IA64 SMP system (kmart)
  Christoph> ITC offsets:
  Christoph> kmart:/usr/src/noship-tests # dmesg|grep synchr
  Christoph> CPU 1: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 417 cycles)

  Christoph> kmart:/usr/src # noship-tests/dmt
  Christoph> gettimeofday cycles: 3428 215 215 215 215 215 215 215 215 215

Is this a Merced-box?  It looks to me that way.  If so, that wouldn't
be a good target for tuning the ITC-based code (it's not worth tuning
around Merced idiosyncrasies, IMO).  On Madison, your gettimeofday()
runs in 143 cycles for me.

clock_gettime() is strange though: even with your patch applied, it
still takes 421 cycles (compared to 466 cycles).  It appears that it's
falling back on the slow path for some reason.  Unfortunately, I don't
have time to investigate more right now.  What do you get with the
attached test-program?

Some other comments:

The lfetch here:

	lfetch [r20]		// Needs lots of data from time_interpolator
	ld8 r21 = [r20]		// first quad with control information

doesn't make much sense to me.  The following ld8 will have the same
(actually, a stronger) effect as the lfetch.

This:

	mov pr = r21,0x3f00	// Set up predicates for timer operations

is clever but I'm not sure it's an appropriate optimization for
generic (non-ia64-specific) code and I suspect it will be a
maintenance headache.  The additional compares needed in the absence
of this solution should cost at most one cycle, no?

I think the "is new ITC count greater than previous one is
wrong".  Instead of:

(p8)	mov r2 = ar.itc		// CPU_TIMER. 36 clocks latency!!!
	ld8 r26 = [r22]		// time_interpolator->last_counter
(p13)	cmp.gt.unc p6,p7 = r25,r2	// check if it is less than last. p6,p7 cleared

shouldn't it do something along the lines of:

(p8)	mov r2 = ar.itc		// CPU_TIMER. 36 clocks latency!!!
(p13)	ld8 r25 = [r23]		// time interpolator->last_cycle
(p13)	sub rTMP = r25,r2
(p13)	cmp.gt.unc p6,p7 = rTMP,r0 // check if it is less than last. p6,p7 cleared

so ITC-wrap-around is handled correctly?

This one:

	cmp.lt p6, p0 = CLOCK_MONOTONIC, r32

should be cmp4.lt, since clockid_t appears to be an "int" on ia64, no?

	--david


---------------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <time.h>

static inline unsigned long
get_itc (void)
{
  unsigned long ret;

  __asm__ __volatile__ ("mov %0=ar.itc" : "=r"(ret) :: "memory");
  return ret;
}

int
main (int argc, char **argv, char **envp)
{
   unsigned long t[10], start;
   char buf[16384], *cp = buf;
   struct timespec ts;
   int i;

   for (i = 0; i < 10; ++i)
     {
       start = get_itc ();
       clock_gettime (CLOCK_REALTIME, &ts);
       t[i] = get_itc () - start;
     }
   cp += sprintf (cp, "clock_gettime(CLOCK_REALTIME) cycles:");
   for (i = 0; i < 10; ++i)
     cp += sprintf (cp, " %lu", t[i]);
   cp += sprintf (cp, "\n");
   write (1, buf, cp - buf);
  return 0;
}
