From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 12 Jul 2004 19:15:51 +0000
Subject: Re: Timer patches (nsec support + fastcalls for gettod/clock_gettime for all clocks)
Message-Id: <200407121215.51266.clameter@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407091545250.5720@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407091545250.5720@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Have been working on the asm portion in the last days and also saw some 
strange things that could explain your problems (a segfault caused by 
clock_gettime and problems with seqlock handling). Will post another version 
later.

Thanks for the evaluation.
On Monday 12 July 2004 10:45 am, Chen, Kenneth W wrote:
> Christoph Lameter wrote on Friday, July 09, 2004 3:58 PM
>
> > The following patch is the first edition that is complete in that it
> > provides all existing functionality (fastcalls) and enhances various
> > interfaces:
> >
> > 1. Restructure timer interpolators to extract common code and provide a
> > structure that can be used from assembly language.
> > 2. Remove cmpxchg that causes scalability problems (for all clocks
> > including ITC now)
> >
> > 3. Simplify gettimeofday
> >
> > 4. Provide new fastcall gettimeofday suitable for all types of clock
> > (including cyclone and SN2 RTC). More than factor 10 speed gain on
> > machines that did not use ITC clock before.
> >
> > 5. Provide fastcall path for clock_gettime(CLOCK_REALTIME). Also for all
> > clock times. More than a factor 20 gain on this one since it returns
> > nanoseconds resolution and thereby avoids the multiplications / division
> > and the syscall overhead.
> >
> > 6. nanosecond resolution for CLOCK_REALTIME and CLOCK_MONOTONIC. This
> > yield a 40ns resolution on SN2.
> >
> > Todo:
> > - Test with cyclone machines
> > - Test with machines that only have ITC based clocks.
> >
> > Testind and feedback appreciated.
>
> The C portion works pretty well on ITC based clock.  One java benchmark
> that uses gettimeofday heavily gained one percentage point.  The assembly
> portion of the fsys call need some more work though, mingetty from the
> boot init script falls flat upon booting this patch.
>
> - Ken
