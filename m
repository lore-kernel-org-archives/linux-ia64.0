From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Mon, 13 Oct 2003 02:11:52 +0000
Subject: Re: [PATCH_TAKE_2] now < last_tick problem
MIME-Version: 1
Content-Type: multipart/mixed; boundary="KsGdsel6WgEHnImy"
Message-Id: <marc-linux-ia64-106601121623079@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106575925709435@msgid-missing>
In-Reply-To: <marc-linux-ia64-106575925709435@msgid-missing>
To: linux-ia64@vger.kernel.org


--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Oct 10, 2003 at 09:42:35AM -0700, David Mosberger wrote:
> I think the source of the probem is that we consider the value
> returned by get_offset() to be valid EVEN when read_seqretry() returns
> 1.  Because of that, we'll end up updating last_nsec_offset with a
> potentialy bad value.

Well, to my eyes the use of the xtime_lock in do_gettimeofday() looks
OK, but I guess what you are saying is that the message is moot --
xtime_lock protects everything itc_get_offset() needs, and
do_gettimeofday() has a read lock on xtime_lock and so reads the
offset again if something was updated underneath it.

-i


--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="time.c.nomsg.diff"

===== arch/ia64/kernel/time.c 1.35 vs edited =====
--- 1.35/arch/ia64/kernel/time.c	Wed Oct  8 12:53:38 2003
+++ edited/arch/ia64/kernel/time.c	Mon Oct 13 11:54:05 2003
@@ -65,8 +65,11 @@
 }
 
 /*
- * Return the number of nano-seconds that elapsed since the last update to jiffy.  The
- * xtime_lock must be at least read-locked when calling this routine.
+ * Return the number of nano-seconds that elapsed since the last
+ * update to jiffy.  It is quite possible that the timer interrupt
+ * will interrupt this and result in a race for any of jiffies,
+ * wall_jiffies or itm_next.  Thus, the xtime_lock must be at least
+ * read-locked when calling this routine.
  */
 unsigned long
 itc_get_offset (void)
@@ -77,11 +80,6 @@
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

--KsGdsel6WgEHnImy--
