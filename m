From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Fri, 10 Oct 2003 00:52:21 +0000
Subject: [PATCH] now < last_tick problem
MIME-Version: 1
Content-Type: multipart/mixed; boundary="qtZFehHsKgwS5rPz"
Message-Id: <marc-linux-ia64-106574725701696@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--qtZFehHsKgwS5rPz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,
                                                                                                                                                    
I started hitting this problem when using httperf, upon investigation
it seems to be easily triggered when you make gettimeofday() calls in
very close succession (just doing them in a tight loop easily
replicates the problem).
                                                                                                                                                    
I think the problem is that in itc_get_offset() there is a race
between getting the now value and calculating the last_tick from
itm_next; if we are interrupted between the two itm_next will be set
after now.
                                                                                                                                                    
Suggested patch attached; note the fsyscall implementation does not
appear to have this problem.
                                                                                                                                                    
-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au
--qtZFehHsKgwS5rPz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="time.c.diff"

===== arch/ia64/kernel/time.c 1.35 vs edited =====
--- 1.35/arch/ia64/kernel/time.c	Wed Oct  8 12:53:38 2003
+++ edited/arch/ia64/kernel/time.c	Fri Oct 10 09:49:37 2003
@@ -72,10 +72,16 @@
 itc_get_offset (void)
 {
 	unsigned long elapsed_cycles, lost = jiffies - wall_jiffies;
-	unsigned long now = ia64_get_itc(), last_tick;
+	unsigned long now, last_tick;
 
 	last_tick = (cpu_data(TIME_KEEPER_ID)->itm_next
 		     - (lost + 1)*cpu_data(TIME_KEEPER_ID)->itm_delta);
+	
+	/*
+	 * get now after last_tick to avoid race condition where
+	 * itm_next might be updated.
+	 */
+	now = ia64_get_itc();
 
 	if (unlikely((long) (now - last_tick) < 0)) {
 		printk(KERN_ERR "CPU %d: now < last_tick (now=0x%lx,last_tick=0x%lx)!\n",

--qtZFehHsKgwS5rPz--
