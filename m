From: john stultz <johnstul@us.ibm.com>
Date: Wed, 18 Feb 2004 20:29:22 +0000
Subject: [PATCH] linux-2.6.3_time-interpolator-fix_A0
Message-Id: <1077136162.985.105.camel@cog.beaverton.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2004-02-17 at 22:58, David Mosberger wrote: 
> >>>>> On Tue, 17 Feb 2004 22:42:54 -0800, john stultz <johnstul@us.ibm.com> said:
>   John> Am I just missing something here?
> 
> I don't think so.  Good bug hunting.  Some time ago SGI reported some
> jumpiness but I never got a definite answer whether the problem had
> been solved.
> 
> You may want to run this by someone who actually understands the code
> in timer.c but I'm pretty sure you're right.

Sounds good, here is the patch then. 

Any further feed back would be appreciated. 

thanks
-john


	In developing the ia64-cyclone patch, which implements a cyclone based
time interpolator, I found the following bug which could cause time
inconsistencies. 

In update_wall_time_one_tick(), which is called each timer interrupt, we
call time_interpolator_update(delta_nsec) where delta_nsec is
approximately NSEC_PER_SEC/HZ. This directly correlates with the changes
to xtime which occurs in update_wall_time_one_tick().

However in update_wall_time(), on a second overflow, we again call
time_interpolator_update(NSEC_PER_SEC). However while the components of
xtime are being changed, the overall value of xtime does not (nsec is
decremented NSEC_PER_SEC and sec is incremented).  Thus this call to
time_interpolator_update is incorrect.

This patch removes the incorrect call to time_interpolator_update and
was found to resolve the time inconsistencies I had seen while
developing the ia64-cyclone patch. 

Please consider for inclusion into your tree.


diff -Nru a/kernel/timer.c b/kernel/timer.c
--- a/kernel/timer.c	Wed Feb 18 12:04:03 2004
+++ b/kernel/timer.c	Wed Feb 18 12:04:03 2004
@@ -677,7 +677,6 @@
 	if (xtime.tv_nsec >= 1000000000) {
 	    xtime.tv_nsec -= 1000000000;
 	    xtime.tv_sec++;
-	    time_interpolator_update(NSEC_PER_SEC);
 	    second_overflow();
 	}
 }


