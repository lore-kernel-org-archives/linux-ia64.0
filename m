From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Fri, 10 Oct 2003 04:13:48 +0000
Subject: Re: [PATCH_TAKE_2] now < last_tick problem
MIME-Version: 1
Content-Type: multipart/mixed; boundary="47eKBCiAZYFK5l32"
Message-Id: <marc-linux-ia64-106575925709435@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--47eKBCiAZYFK5l32
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Oct 10, 2003 at 10:52:21AM +1000, Ian Wienand wrote:
> Suggested patch attached; note the fsyscall implementation does not
> appear to have this problem.

Sorry to reply to myself, but I noticed when using httperf I still got
one or two messages (literally, it was very much reduced); the first
patch misses the fact there is also a race between 'lost' being
calculated and the timer interrupt possibly catching jiffies up to
wall_jiffies.  I also added a comment as I get easily confused.

The attached patch lets me run httperf repeatedly with none of these
warnings, though there still might be a better way to do it.

-i



--47eKBCiAZYFK5l32
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="time.c.take2.diff"

===== arch/ia64/kernel/time.c 1.35 vs edited =====
--- 1.35/arch/ia64/kernel/time.c	Wed Oct  8 12:53:38 2003
+++ edited/arch/ia64/kernel/time.c	Fri Oct 10 14:08:15 2003
@@ -71,11 +71,32 @@
 unsigned long
 itc_get_offset (void)
 {
-	unsigned long elapsed_cycles, lost = jiffies - wall_jiffies;
-	unsigned long now = ia64_get_itc(), last_tick;
+	unsigned long elapsed_cycles;
+	unsigned long now, last_tick;
 
+	/* 
+	 * itm_next is the next timer tick
+	 * itm_delta is the time between timer ticks
+	 * wall_jiffies are timer ticks the timer interrupt hasn't 
+	 * added to jiffies yet.
+	 *
+	 *    itm_delta      itm_delta
+	 * |--------------|---------------|
+	 * jiffies        wall_jiffies    itm_next
+	 *
+	 * (wall_jiffies - jiffies)*itm_delta = ITC ticks between jiffies and wall_jiffies
+	 * itm_next - itm_delta = ITC at wall_jiffies
+	 * last_tick = ITC at wall_jiffies - ITC ticks between jiffies and wall_jiffies 
+	 * elapsed ITC ticks since jiffies updated = ITC now - last_tick
+	 */
 	last_tick = (cpu_data(TIME_KEEPER_ID)->itm_next
-		     - (lost + 1)*cpu_data(TIME_KEEPER_ID)->itm_delta);
+		     - (jiffies - wall_jiffies + 1)*cpu_data(TIME_KEEPER_ID)->itm_delta);
+	
+	/*
+	 * get now after last_tick to avoid race condition where
+	 * itm_next might be updated.
+	 */
+	now = ia64_get_itc();
 
 	if (unlikely((long) (now - last_tick) < 0)) {
 		printk(KERN_ERR "CPU %d: now < last_tick (now=0x%lx,last_tick=0x%lx)!\n",

--47eKBCiAZYFK5l32--
