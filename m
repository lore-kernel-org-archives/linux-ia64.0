From: Christoph Lameter <clameter@sgi.com>
Date: Sat, 11 Sep 2004 15:35:06 +0000
Subject: Re: [PATCH] 2.6.9-rc1 Ia64 build broken due to HPET
Message-Id: <Pine.LNX.4.58.0409110832410.15088@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040910041200.GN5668@cse.unsw.EDU.AU>
In-Reply-To: <20040910041200.GN5668@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 12 Sep 2004, Darren Williams wrote:

> Hi Christoph
> I have tested the patch and all compiles for zx1_defconfig+hpet, I see
> that it has been applied to main stream already, however I do not see
> any init messages in dmesg for hpet initialisation.
> At what point should I be seeing the init message?

The patch does not change the hpet driver per se. There is no init message
showing that the hpet driver is being used as the time interpolator.

Please run the small program that I sent to you and post the
output as I requested.

> > /*
> >  * Display Timers
> >  */
> >
> > #include <stdio.h>
> > #include <stdlib.h>
> > #include <time.h>
> >
> > void pr(int clock,const char *n)
> > {
> > 	struct timespec tv,res;
> >
> > 	clock_gettime(clock,&tv);
> > 	clock_getres(clock,&res);
> > 	printf("%25s=% 11d.%09d resolution=% 2d.%09d\n",n,tv.tv_sec,tv.tv_nsec,res.tv_sec,res.tv_nsec);
> > }
> >
> > int main(char argc, char *argv[])
> > {
> > 	struct timespec tv;
> >
> > 	gettimeofday((struct timeval *)&tv);
> > 	tv.tv_nsec = tv.tv_nsec*1000;
> > 	printf("          Gettimeofday() =% 11d.%09d\n",tv.tv_sec,tv.tv_nsec);
> > 	pr(CLOCK_REALTIME,"CLOCK_REALTIME");
> > 	pr(CLOCK_MONOTONIC,"CLOCK_MONOTONIC");
> > 	pr(CLOCK_PROCESS_CPUTIME_ID,"CLOCK_PROCESS_CPUTIME_ID");
> > 	pr(CLOCK_THREAD_CPUTIME_ID,"CLOCK_THREAD_CPUTIME_ID");
> > 	printf("\n");
> > }
