From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 08 Sep 2004 20:52:36 +0000
Subject: Re: Timer patch V8
Message-Id: <Pine.LNX.4.58.0409081345200.26350@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408092115500.22817@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0408092115500.22817@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Umm... I thought MC was constant and the address of the counter. I see it
used in lines 93 and following.

This may fix the MC issue:

Index: linux-2.6.9-rc1/drivers/char/hpet.c
=================================--- linux-2.6.9-rc1.orig/drivers/char/hpet.c    2004-09-07 18:37:00.000000000 -0700
+++ linux-2.6.9-rc1/drivers/char/hpet.c 2004-09-08 13:52:18.000000000 -0700
@@ -664,8 +664,7 @@

 static struct time_interpolator hpet_interpolator = {
        .source = TIME_SOURCE_MMIO64,
-       .shift = 10,
-       .addr = MC
+       .shift = 10;
 };

 #endif
@@ -954,6 +953,7 @@

                        hpet = hpets->hp_hpet;
                        hpet_cycles_per_sec = hpet_time_div(hpets->hp_period);
+                       hpet_interpolator.addr = MC;
                        hpet_interpolator.frequency = hpet_cycles_per_sec;
                        hpet_interpolator.drift = hpet_cycles_per_sec *
                            HPET_DRIFT / 1000000;


On Wed, 8 Sep 2004, Alex Williamson wrote:

>
>    I see this made it upstream.  Unfortunately w/ CONFIG_HPET=y, I now
> get this:
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
> I assume hpet_cycles_per_sec and hpet_nsecs_per_cycle just need to be
> declared again, but I couldn't figure out what MC is supposed to be.
>
> 	Alex
>
> --
> Alex Williamson                             HP Linux & Open Source Lab
>
