From: Finn Arne Gangstad <Finn.Gangstad@fast.no>
Date: Mon, 24 Mar 2003 12:06:04 +0000
Subject: [Linux-ia64] Re: [PATCH] fix nanosleep() granularity bumps
Message-Id: <marc-linux-ia64-105590723705296@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 18, 2003 at 10:05:56AM +0100, Tim Schmielau wrote:
> On Mon, 17 Mar 2003, Tim Schmielau wrote:
> 
> > I've re-checked that the problem does not occur with the original "initial
> > jiffies" patch for 2.4.
> 
> Stupid me - 2.4 with the patch has the same problem, it just takes 10x as
> long to show up, a range that was not covered by the testcase.
> 
> 
> The actual problem is that I didn't fully understand the, well,
> 'elaborated' way of counting jiffies in the timer cascade:
> 
> When starting out with timer_jiffies=0, the timer cascade is
> (unneccessarily) triggered on the first timer interrupt, incrementing all
> the higher indices.
> When starting with any other initial jiffies value, we miss that and end
> up with all higher indices being off by one.

Suggest the attached patch as a fix instead - easier to understand I
think and works for every possible start value. This is what I made for
Andrea Arcangeli many years ago...

diff -ur linux-2.5.65/kernel/timer.c linux-2.5.65-new/kernel/timer.c
--- linux-2.5.65/kernel/timer.c	2003-03-17 22:44:41.000000000 +0100
+++ linux-2.5.65-new/kernel/timer.c	2003-03-24 12:57:31.000000000 +0100
@@ -1182,11 +1182,14 @@
 		INIT_LIST_HEAD(base->tv1.vec + j);
 
 	base->timer_jiffies = INITIAL_JIFFIES;
-	base->tv1.index = INITIAL_JIFFIES & TVR_MASK;
-	base->tv2.index = (INITIAL_JIFFIES >> TVR_BITS) & TVN_MASK;
-	base->tv3.index = (INITIAL_JIFFIES >> (TVR_BITS+TVN_BITS)) & TVN_MASK;
-	base->tv4.index = (INITIAL_JIFFIES >> (TVR_BITS+2*TVN_BITS)) & TVN_MASK;
-	base->tv5.index = (INITIAL_JIFFIES >> (TVR_BITS+3*TVN_BITS)) & TVN_MASK;
+	base->tv1.index = (1 + (INITIAL_JIFFIES - 1)) & TVR_MASK;
+	base->tv2.index = (1 + ((INITIAL_JIFFIES - 1) >> TVR_BITS)) & TVN_MASK;
+	base->tv3.index = (1 + ((INITIAL_JIFFIES - 1)
+				>> (TVR_BITS + TVN_BITS))) & TVN_MASK;
+	base->tv4.index = (1 + ((INITIAL_JIFFIES - 1)
+				>> (TVR_BITS + 2 * TVN_BITS))) & TVN_MASK;
+	base->tv5.index = (1 + ((INITIAL_JIFFIES - 1)
+				>> (TVR_BITS + 3 * TVN_BITS))) & TVN_MASK;
 }
 	
 static int __devinit timer_cpu_notify(struct notifier_block *self, 


- Finn Arne

