From: Eric Piel <Eric.Piel@Bull.Net>
Date: Thu, 13 Mar 2003 16:53:43 +0000
Subject: [Linux-ia64] [PATCH] settimeofday() not synchronised with gettimeofday()
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------8445AFF66E41010C65CC1230"
Message-Id: <marc-linux-ia64-105590709806076@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------8445AFF66E41010C65CC1230
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hello,

On the last 2.5 kernels the time we get with gettimeofday() is different
from the time we set with settimeofday().
I've written a small test case which should demonstrate that bug. It
simply sets the time to the current time and then reads a second time
the time. The difference between the two values should be only the
length of the syscalls.

Basically on a 2.4.19 I get this kind of result:

# ./a.out
requested:      1047481209s 671081ns
new:            1047481209s 671083ns
diff is  0.000002000sec

Fine.
But on a 2.5.64 I have something like that:
# ./a.out 
requested:      1047572128s 2564ns
new:            1047572127s 0239ns
diff is -1.232526000sec

gettimeofday() gave a time BEFORE the time we set!
First, I've corrected an obvious problem due to the change of the
returned value of gettimeoffset() from usec to nsec in settimeofday().
David, I think you can apply it, at least :-)

However, now, it still gives negative difference:
# ./a.out 
requested:      1047572128s 2564ns
new:            1047572128s 1588ns
diff is -0.000976000sec

That's better but there is still something...
Can anyone reproduce this bug? Any idea about what may cause this
shifted results?

I don't understand what does the line in settimeofday():
	nsec -= (jiffies - wall_jiffies ) * (1000000000 / HZ);
Maybe there is some error there. Removing it gives positive difference
but too big to look correct!

Any suggestion would be welcomed.
Eric
--------------8445AFF66E41010C65CC1230
Content-Type: text/plain; charset=us-ascii;
 name="bad_settimeofday.c"
Content-Disposition: inline;
 filename="bad_settimeofday.c"
Content-Transfer-Encoding: 7bit

/* should detect a problem in settimeofday 
 * we set the time to the time we've just got
 * then we read the time, we should obtain a time just little bit after what we set
 * You need to be root to run this test
 */ 

#include <stdio.h>
#include <sys/time.h>
#include <signal.h>

#define USEC_PER_SEC	1000000
#define timerdiff(a,b) ((float)((a)->tv_sec - (b)->tv_sec) + \
                         (float)((a)->tv_usec - (b)->tv_usec)/USEC_PER_SEC)

main()
{
	struct timeval treq, tnew;
	float diff;

//	raise(SIGSTOP);
	/* do the test */
	gettimeofday(&treq, NULL);
	settimeofday(&treq, NULL);
	gettimeofday(&tnew, NULL);

	/* interpret the result */
	diff = timerdiff(&tnew, &treq);
	printf("requested:\t%lds %ldns\n"
               "new:\t\t%lds %ldns\n"	
               "diff is %12.9fsec\n",
		treq.tv_sec, treq.tv_usec,
		tnew.tv_sec, tnew.tv_usec,
		diff);



}

--------------8445AFF66E41010C65CC1230
Content-Type: text/plain; charset=us-ascii;
 name="settimeofday-ia64-2.5.64-030313.patch"
Content-Disposition: inline;
 filename="settimeofday-ia64-2.5.64-030313.patch"
Content-Transfer-Encoding: 7bit

--- ../../../../linux-2.5.64-ia64.orig/arch/ia64/kernel/time.c	2003-03-07 13:27:04.000000000 +0100
+++ ./time.c	2003-03-13 16:40:06.000000000 +0100
@@ -60,7 +60,7 @@
 }
 
 /*
- * Return the number of micro-seconds that elapsed since the last update to jiffy.  The
+ * Return the number of nano-seconds that elapsed since the last update to jiffy.  The
  * xtime_lock must be at least read-locked when calling this routine.
  */
 static inline unsigned long
@@ -86,6 +86,9 @@
 void
 do_settimeofday (struct timeval *tv)
 {
+	unsigned long sec = tv->tv_sec;
+	unsigned long nsec = tv->tv_usec * 1000;
+
 	write_seqlock_irq(&xtime_lock);
 	{
 		/*
@@ -94,16 +97,16 @@
 		 * Discover what correction gettimeofday would have done, and then undo
 		 * it!
 		 */
-		tv->tv_usec -= gettimeoffset();
-		tv->tv_usec -= (jiffies - wall_jiffies) * (1000000 / HZ);
+		nsec -= gettimeoffset();
+		nsec -= (jiffies - wall_jiffies ) * (1000000000 / HZ);
 
-		while (tv->tv_usec < 0) {
-			tv->tv_usec += 1000000;
-			tv->tv_sec--;
+		while (nsec < 0) {
+			nsec += 1000000000;
+			sec--;
 		}
 
-		xtime.tv_sec = tv->tv_sec;
-		xtime.tv_nsec = 1000 * tv->tv_usec;
+		xtime.tv_sec = sec;
+		xtime.tv_nsec = nsec;
 		time_adjust = 0;		/* stop active adjtime() */
 		time_status |= STA_UNSYNC;
 		time_maxerror = NTP_PHASE_LIMIT;

--------------8445AFF66E41010C65CC1230--


