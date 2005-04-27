From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 27 Apr 2005 18:44:20 +0000
Subject: [PATCH] time interpolator: Fix settimeofday inaccuracy
Message-Id: <Pine.LNX.4.58.0504271142500.14542@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

settimeofday will set the time a little bit too early on systems using
time interpolation since it subtracts the current interpolator offset
from the time. This used to be necessary with the code in 2.6.9 and earlier
but the new code resets the time interpolator after setting the time.
Thus the time is set too early and gettimeofday will return a time slightly
before the time specified with settimeofday if invoked immeditely after
settimeofday.

The following patch removes the obsolete subtraction of the time interpolator
offset and makes settimeofday set the time accurately.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.11/kernel/time.c
=================================--- linux-2.6.11.orig/kernel/time.c	2005-03-01 23:37:50.000000000 -0800
+++ linux-2.6.11/kernel/time.c	2005-04-26 18:06:03.000000000 -0700
@@ -505,14 +505,6 @@

 	write_seqlock_irq(&xtime_lock);
 	{
-		/*
-		 * This is revolting. We need to set "xtime" correctly. However, the value
-		 * in this location is the value at the most recent update of wall time.
-		 * Discover what correction gettimeofday would have done, and then undo
-		 * it!
-		 */
-		nsec -= time_interpolator_get_offset();
-
 		wtm_sec  = wall_to_monotonic.tv_sec + (xtime.tv_sec - sec);
 		wtm_nsec = wall_to_monotonic.tv_nsec + (xtime.tv_nsec - nsec);

