From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 14 Oct 2003 23:05:49 +0000
Subject: Re: [PATCH_TAKE_2] now < last_tick problem
MIME-Version: 1
Content-Type: multipart/mixed; boundary="FCuugMFkClbJLl1L"
Message-Id: <marc-linux-ia64-106617300303532@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106575925709435@msgid-missing>
In-Reply-To: <marc-linux-ia64-106575925709435@msgid-missing>
To: linux-ia64@vger.kernel.org


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Oct 14, 2003 at 09:58:14AM -0700, David Mosberger wrote:
> Sounds fine to me.  Do you want to send me a complete patch

attached

thanks,
-i
--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="time.c.take3.diff"

===== arch/ia64/kernel/time.c 1.35 vs edited =====
--- 1.35/arch/ia64/kernel/time.c	Wed Oct  8 12:53:38 2003
+++ edited/arch/ia64/kernel/time.c	Wed Oct 15 08:54:31 2003
@@ -65,8 +65,12 @@
 }
 
 /*
- * Return the number of nano-seconds that elapsed since the last update to jiffy.  The
- * xtime_lock must be at least read-locked when calling this routine.
+ * Return the number of nano-seconds that elapsed since the last
+ * update to jiffy.  It is quite possible that the timer interrupt
+ * will interrupt this and result in a race for any of jiffies,
+ * wall_jiffies or itm_next.  Thus, the xtime_lock must be at least
+ * read synchronised when calling this routine (see do_gettimeofday()
+ * below for an example).
  */
 unsigned long
 itc_get_offset (void)
@@ -77,11 +81,6 @@
 	last_tick = (cpu_data(TIME_KEEPER_ID)->itm_next
 		     - (lost + 1)*cpu_data(TIME_KEEPER_ID)->itm_delta);
 
-	if (unlikely((long) (now - last_tick) < 0)) {
-		printk(KERN_ERR "CPU %d: now < last_tick (now=0x%lx,last_tick=0x%lx)!\n",
-		       smp_processor_id(), now, last_tick);
-		return last_nsec_offset;
-	}
 	elapsed_cycles = now - last_tick;
 	return (elapsed_cycles*local_cpu_data->nsec_per_cyc) >> IA64_NSEC_PER_CYC_SHIFT;
 }

--FCuugMFkClbJLl1L--
