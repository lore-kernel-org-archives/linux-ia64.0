From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 13 Sep 2004 22:22:42 +0000
Subject: Re: [PATCH] 2.6.9-rc1 Ia64 build broken due to HPET
Message-Id: <Pine.LNX.4.58.0409131519080.616@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040910041200.GN5668@cse.unsw.EDU.AU>
In-Reply-To: <20040910041200.GN5668@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 13 Sep 2004, Alex Williamson wrote:

> So, first and foremost, the ITC interpolator is broken for any ITC
> greater than 1GHz.  Secondary, the HPET interpolator comes in too late,
> and the code doesn't really seem to be able to support that.

Well. This means that the resolution is broken for any clock > 1GHZ.

The hpet interpolator is in a module? or is it compiled into the kernel?
register_time_interpolator allows a later registration of a time
interpolator. The question though is: Will it win against the one
already installed. It may win if you specify a smaller drift than the ITC
interpolator. Gotta look at that.

Could you try if the following patch fixes the precision problem:

Index: linux-2.6.9-rc1/kernel/timer.c
=================================--- linux-2.6.9-rc1.orig/kernel/timer.c 2004-09-13 08:14:46.000000000 -0700
+++ linux-2.6.9-rc1/kernel/timer.c      2004-09-13 15:20:36.000000000 -0700
@@ -1492,7 +1492,10 @@

 unsigned long time_interpolator_resolution(void)
 {
-       return NSEC_PER_SEC / time_interpolator->frequency;
+       if (time_interpolator->frequency < NSEC_PER_SEC)
+               return NSEC_PER_SEC / time_interpolator->frequency;
+       else
+               return 1;
 }

 #define GET_TI_NSECS(count,i) ((((count) - i->last_counter) *
i->nsec_per_cyc) >> i->shift)

