From: Keith Owens <kaos@sgi.com>
Date: Wed, 01 Dec 2004 03:36:50 +0000
Subject: [PATCH 2.6.10-rc2] Drop SALINFO_TIMER_DELAY to one minute
Message-Id: <10903.1101872210@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Experience with recoverable MCA events shows that a poll interval of 5
minutes for new MCA/INIT records is a bit too long.  Drop the poll
interval to one minute.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/kernel/salinfo.c
=================================--- linux.orig/arch/ia64/kernel/salinfo.c	Tue Oct 19 07:54:40 2004
+++ linux/arch/ia64/kernel/salinfo.c	Wed Dec  1 14:29:16 2004
@@ -230,8 +230,8 @@ salinfo_log_wakeup(int type, u8 *buffer,
 	}
 }
 
-/* Check for outstanding MCA/INIT records every 5 minutes (arbitrary) */
-#define SALINFO_TIMER_DELAY (5*60*HZ)
+/* Check for outstanding MCA/INIT records every minute (arbitrary) */
+#define SALINFO_TIMER_DELAY (60*HZ)
 static struct timer_list salinfo_timer;
 
 static void

