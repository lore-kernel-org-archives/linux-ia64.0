From: Alex Williamson <alex_williamson@attbi.com>
Date: Thu, 24 Apr 2003 04:16:43 +0000
Subject: [Linux-ia64] [PATCH] fix timer interrupts getting lost
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------010207090005080105090004"
Message-Id: <marc-linux-ia64-105590723705596@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------010207090005080105090004
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


    This patch fixes the issue of some CPUs not showing timer interrupts
going off.  Seems during the process of sync'ing the itc, we jumped over
the next timer value.  This patch is against 2.5.67 + ia64.  I haven't
seen the problem on 2.4, but a quick looks seems like it's potentially
an issue there too.  Thanks,

	Alex

--
Alex Williamson                             HP Linux and Open Source Lab

--------------010207090005080105090004
Content-Type: text/plain;
 name="smp_timer_fix.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="smp_timer_fix.diff"

--- linux-2.5.67.clean/arch/ia64/kernel/smpboot.c	2003-04-22 13:58:09.000000000 -0600
+++ linux-2.5.67/arch/ia64/kernel/smpboot.c	2003-04-23 20:25:00.000000000 -0600
@@ -311,6 +311,15 @@
 		 */
 		Dprintk("Going to syncup ITC with BP.\n");
 		ia64_sync_itc(0);
+
+		/*
+		 * Make sure we didn't sync the itc ahead of the next
+		 * timer interrupt, if so, just reset it.
+		 */
+		if (time_after(ia64_get_itc(),local_cpu_data->itm_next)) {
+			Dprintk("oops, jumped a timer.\n");
+			ia64_cpu_local_tick();
+		}
 	}
 
 	/*

--------------010207090005080105090004--


