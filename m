From: Khalid Aziz <khalid@fc.hp.com>
Date: Wed, 24 Sep 2003 17:21:19 +0000
Subject: [PATCH] do_gettimeofday() fails to compensate for lost ticks
Message-Id: <marc-linux-ia64-106442430128845@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

do_gettimeofday() needs to account for lost ticks before returning
current time and it fails to do that. do_gettimeofday() on other 
architectures compensate for lost ticks correctly. Due to this bug, if
you repeatedly do clock_settime() immediately followed by clock_gettime() 
and compare the time returned by clock_gettime() to the time set by
clock_settime(), you will eventually see clock going backwards. I am
attaching a test program from POSIX testsuite at the end that exposes
this bug. Run this test in a continuous loop that stops when test fails.

Following patch should address this issue.

--
Khalid


===========
--- linux-2.4.22/arch/ia64/kernel/time.c	Mon Aug 25 05:44:39 2003
+++ linux-2.4.22-clock_fix/arch/ia64/kernel/time.c	Wed Sep 24 11:14:54 2003
@@ -132,6 +132,7 @@
 
 		sec = xtime.tv_sec;
 		usec += xtime.tv_usec;
+		usec += (jiffies - wall_jiffies) * (1000000 / HZ);
 	}
 	read_unlock_irqrestore(&xtime_lock, flags);
 


========= Test program =========
/*   
 * Copyright (c) 2002, Intel Corporation. All rights reserved.
 * Created by:  julie.n.fleischer REMOVE-THIS AT intel DOT com
 * This file is licensed under the GPL license.  For the full content
 * of this license, see the COPYING file at the top level of this 
 * source tree.

 * Test that clock_settime() sets clock_id to tp.
 *
 * The clock_id chosen for this test is CLOCK_REALTIME.
 * The date chosen is Nov 12, 2002 ~11:13am (date when test was first
 * written).
 */
#include <stdio.h>
#include <time.h>
/*#include "posixtest.h"
#include "helpers.h"*/

#define TESTTIME 1037128358
#define ACCEPTABLEDELTA 1
#define PTS_UNRESOLVED 2
#define PTS_PASS 0
#define PTS_FAIL 1

int getBeforeTime(struct timespec *tpget)
{
	if (clock_gettime(CLOCK_REALTIME, tpget) != 0) {
		perror("clock_gettime() did not return success\n");
		perror("clock may not be reset properly\n");
		return PTS_UNRESOLVED;
	}
	return PTS_PASS;
}

int setBackTime(struct timespec tpset)
{
	if (clock_settime(CLOCK_REALTIME, &tpset) != 0) {
		perror("clock_settime() did not return success\n");
		perror("clock may not be reset properly\n");
		return PTS_UNRESOLVED;
	}
	return PTS_PASS;
}

int main(int argc, char *argv[])
{
	struct timespec tpset, tpget, tpreset;
	int delta;

	getBeforeTime(&tpreset);

	tpset.tv_sec = TESTTIME;
	tpset.tv_nsec = 0;
	if (clock_settime(CLOCK_REALTIME, &tpset) = 0) {
		if (clock_gettime(CLOCK_REALTIME, &tpget) = -1) {
			perror("Error in clock_gettime()");
			return 2;
		}
		delta = tpget.tv_sec-tpset.tv_sec;
		if ( (delta <= ACCEPTABLEDELTA) && (delta >= 0) ) {
			printf("Test PASSED\n");
			setBackTime(tpreset);
			return 0;
		} else {
			printf("delta = %d, tpget=%d,%d, tpset=%d,%d\n", delta, tpget.tv_sec, tpget.tv_nsec, tpset.tv_sec, tpset.tv_nsec);
			printf("clock does not appear to be set\n");
			setBackTime(tpreset);
			return 1;
		}
	} else {
		printf("clock_settime() failed\n");
		return 2;
	}

	printf("This code should not be executed.\n");
	return 2;
}
