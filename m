From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 09 Sep 2004 15:28:23 +0000
Subject: Re: Timer patch V8
Message-Id: <Pine.LNX.4.58.0409090825490.32479@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408092115500.22817@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0408092115500.22817@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 9 Sep 2004, Alex Williamson wrote:

> On Wed, 2004-09-08 at 16:23 -0700, Christoph Lameter wrote:
> > Sorry. I was too superficial when looking at this issue. The following
> > patch makes the hpet driver build again but I do not have a machine here
> > that would allow me to test this. Could you verify that this works and get
> > back to me?
> >
>
>    It builds and boots, so a definite improvement.  I'm not sure how to
> check if the hpet is being used though.  Thanks,

Could you run the following program and sent me the output? The precision
of the REALTIME clock should be the same as the HPET device.

/*
 * Display Timers
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void pr(int clock,const char *n)
{
        struct timespec tv,res;

        clock_gettime(clock,&tv);
        clock_getres(clock,&res);
        printf("%25s=% 11d.%09d resolution=% 2d.%09d\n",n,tv.tv_sec,tv.tv_nsec,res.tv_sec,res.tv_nsec);
}

int main(char argc, char *argv[])
{
        struct timespec tv;

        gettimeofday((struct timeval *)&tv);
        tv.tv_nsec = tv.tv_nsec*1000;
        printf("          Gettimeofday() =% 11d.%09d\n",tv.tv_sec,tv.tv_nsec);
        pr(CLOCK_REALTIME,"CLOCK_REALTIME");
        pr(CLOCK_MONOTONIC,"CLOCK_MONOTONIC");
        pr(CLOCK_PROCESS_CPUTIME_ID,"CLOCK_PROCESS_CPUTIME_ID");
        pr(CLOCK_THREAD_CPUTIME_ID,"CLOCK_THREAD_CPUTIME_ID");
        printf("\n");
}
