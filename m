From: Khalid Aziz <khalid@fc.hp.com>
Date: Wed, 24 Sep 2003 18:58:01 +0000
Subject: Re: [PATCH] do_gettimeofday() fails to compensate for lost ticks
Message-Id: <marc-linux-ia64-106442994204018@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106442430128845@msgid-missing>
In-Reply-To: <marc-linux-ia64-106442430128845@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Khalid Aziz wrote:
> David Mosberger wrote:
> > Not sure off-hand and I haven't looked at the 2.4 code-base in a
> > while, but aren't we double-compensating in do_settimeofday()?  There,
> > we have:
> > 
> >                 tv->tv_usec -= gettimeoffset();
> >                 tv->tv_usec -= (jiffies - wall_jiffies) * (1000000 / HZ);
> > 
> > Perhaps the second line just needs to go?
> > 
> >         --david
> 
> I bet you are right. I will try taking that line out.

That was it. The same test that failed in less than 30 seconds, now has
been running for more than 10 minutes without failure. Thanks, David.

Here is a new patch.

--
Khalid


================--- linux-2.4.22/arch/ia64/kernel/time.c	Mon Aug 25 05:44:39 2003
+++ linux-2.4.22-clock_fix/arch/ia64/kernel/time.c	Wed Sep 24 12:38:20 2003
@@ -93,7 +93,6 @@
 		 * it!
 		 */
 		tv->tv_usec -= gettimeoffset();
-		tv->tv_usec -= (jiffies - wall_jiffies) * (1000000 / HZ);
 
 		while (tv->tv_usec < 0) {
 			tv->tv_usec += 1000000;
