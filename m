From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 10 Sep 2004 15:05:53 +0000
Subject: Re: [PATCH] 2.6.9-rc1 Ia64 build broken due to HPET
Message-Id: <Pine.LNX.4.58.0409100803300.7422@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040910041200.GN5668@cse.unsw.EDU.AU>
In-Reply-To: <20040910041200.GN5668@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Could you try the patch that was already posted to linux-ia64? Please make
sure you run a glibc build for 2.6.x and then send me the output of the
short test program following the patch to verify that this really works.

Index: linux-2.6.9-rc1/drivers/char/hpet.c
=================================--- linux-2.6.9-rc1.orig/drivers/char/hpet.c	2004-09-07 18:37:00.000000000 -0700
+++ linux-2.6.9-rc1/drivers/char/hpet.c	2004-09-08 16:17:57.000000000 -0700
@@ -664,8 +664,7 @@

 static struct time_interpolator hpet_interpolator = {
 	.source = TIME_SOURCE_MMIO64,
-	.shift = 10,
-	.addr = MC
+	.shift = 10
 };

 #endif
@@ -953,11 +952,10 @@
 			struct hpet *hpet;

 			hpet = hpets->hp_hpet;
-			hpet_cycles_per_sec = hpet_time_div(hpets->hp_period);
-			hpet_interpolator.frequency = hpet_cycles_per_sec;
-			hpet_interpolator.drift = hpet_cycles_per_sec *
+			hpet_interpolator.addr = &hpets->hp_hpet->hpet_mc;
+			hpet_interpolator.frequency = hpet_time_div(hpets->hp_period);
+			hpet_interpolator.drift = hpet_interpolator.frequency *
 			    HPET_DRIFT / 1000000;
-			hpet_nsecs_per_cycle = 1000000000 / hpet_cycles_per_sec;
 			register_time_interpolator(&hpet_interpolator);
 		}
 #endif

== END OF patch


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

On Fri, 10 Sep 2004, Darren Williams wrote:

> The ia64 build broke overnight due to this patch
> http://marc.theaimsgroup.com/?l=linux-ia64&m9211170801213&w=2
> any ia64 arch that includes CONFIG_HPET will fail
> on the build, this effect generic_defconfig also.
>
>
>   CC      drivers/char/hpet.o
> drivers/char/hpet.c:669: error: `MC' undeclared here (not in a function)
> drivers/char/hpet.c:669: error: initializer element is not constant
> drivers/char/hpet.c:669: error: (near initialization for `hpet_interpolator.addr')
> drivers/char/hpet.c: In function `hpet_init':
> drivers/char/hpet.c:956: error: `hpet_cycles_per_sec' undeclared (first use in this function)
> drivers/char/hpet.c:956: error: (Each undeclared identifier is reported only once
> drivers/char/hpet.c:956: error: for each function it appears in.)
> drivers/char/hpet.c:960: error: `hpet_nsecs_per_cycle' undeclared (first use in this function)
> make[2]: *** [drivers/char/hpet.o] Error 1
>
> The included patch will need to be scrutinised due
> to the fact I had no idea what to assign to:
> hpet_interpolator.addr
> signed-off-by Darren Williams <dswATgelato.unsw.edu.au>
>
> # ChangeSet
> #   2004/09/10 13:11:25+10:00 dsw@vanilla.gelato
> #   Define hpet_cycles_per_sec for hpet clock calculation and assign
> #   nsec_per_cyc directly to hpet_interpolator.nsec_per_cyc
> #
> #   The assignment of .addr = hpet_control is more than likely bogus
> #   time_interpolator.addr requires an address of a counter or function
> #
> # drivers/char/hpet.c
> #   2004/09/10 13:11:18+10:00 dsw@vanilla.gelato +4 -3
> #   Define hpet_cycles_per_sec for hpet clock calculation and assign
> #   nsec_per_cyc directly to hpet_interpolator.nsec_per_cyc
> #
> #   The assignment of .addr = hpet_control is more than likely bogus
> #   time_interpolator.addr requires an address of a counter or function
> #
> diff -Nru a/drivers/char/hpet.c b/drivers/char/hpet.c
> --- a/drivers/char/hpet.c	2004-09-10 13:36:48 +10:00
> +++ b/drivers/char/hpet.c	2004-09-10 13:36:48 +10:00
> @@ -665,7 +665,7 @@
>  static struct time_interpolator hpet_interpolator = {
>  	.source = TIME_SOURCE_MMIO64,
>  	.shift = 10,
> -	.addr = MC
> +	.addr = hpet_control
>  };
>
>  #endif
> @@ -951,13 +951,14 @@
>  #ifdef	CONFIG_TIME_INTERPOLATION
>  		{
>  			struct hpet *hpet;
> -
> +			long hpet_cycles_per_sec;
> +
>  			hpet = hpets->hp_hpet;
>  			hpet_cycles_per_sec = hpet_time_div(hpets->hp_period);
>  			hpet_interpolator.frequency = hpet_cycles_per_sec;
>  			hpet_interpolator.drift = hpet_cycles_per_sec *
>  			    HPET_DRIFT / 1000000;
> -			hpet_nsecs_per_cycle = 1000000000 / hpet_cycles_per_sec;
> +			hpet_interpolator.nsec_per_cyc = 1000000000 / hpet_cycles_per_sec;
>  			register_time_interpolator(&hpet_interpolator);
>  		}
>  #endif
>
>
> --------------------------------------------------
> Darren Williams <dsw AT gelato.unsw.edu.au>
> Gelato@UNSW <www.gelato.unsw.edu.au>
> --------------------------------------------------
>
