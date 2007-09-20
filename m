From: Russ Anderson <rja@sgi.com>
Date: Thu, 20 Sep 2007 18:59:12 +0000
Subject: [patch] Remove needless delay in MCA rendezvous
Message-Id: <20070920185911.GA20978@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Remove needless delay in MCA rendezvous

While testing the MCA recovery code, noticed that some machines would have a 
five second delay rendezvousing cpus.  What was happening is that 
ia64_wait_for_slaves() would check to see if all the slave CPUs had 
rendezvoused.  If any had not, it would wait 1 millisecond then check again.
If any CPUs had still not rendezvoused, it would wait 5 seconds before
checking again. 

On some configs the rendezvous takes more than 1 millisecond, causing the code
to wait the full 5 seconds, even though the last CPU rendezvoused after only
a few milliseconds.

The fix is to check every 1 millisecond to see if all the cpus have 
rendezvoused.  After 5 seconds the code concludes the CPUs will never
rendezvous (same as before).

The MCA code is, by definition, not performance critical, but a needless
delay of 5 seconds is senseless.  The 5 seconds also adds up quickly
when running the error injection code in a loop.

This patch both simplifies the code and removes the needless delay.

Signed-off-by: Russ Anderson <rja@sgi.com>

---
 arch/ia64/kernel/mca.c |   41 +++++++++++++++++++----------------------
 1 file changed, 19 insertions(+), 22 deletions(-)

Index: test/arch/ia64/kernel/mca.c
=================================--- test.orig/arch/ia64/kernel/mca.c	2007-09-20 10:23:57.011455209 -0500
+++ test/arch/ia64/kernel/mca.c	2007-09-20 10:24:00.463872304 -0500
@@ -1136,30 +1136,27 @@ no_mod:
 static void
 ia64_wait_for_slaves(int monarch, const char *type)
 {
-	int c, wait = 0, missing = 0;
-	for_each_online_cpu(c) {
-		if (c = monarch)
-			continue;
-		if (ia64_mc_info.imi_rendez_checkin[c] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE) {
-			udelay(1000);		/* short wait first */
-			wait = 1;
-			break;
+	int c, i , wait;
+
+	/*
+	 * wait 5 seconds total for slaves (arbitrary)
+	 */
+	for (i = 0; i < 5000; i++) {
+		wait = 0;
+		for_each_online_cpu(c) {
+			if (c = monarch)
+				continue;
+			if (ia64_mc_info.imi_rendez_checkin[c]
+					= IA64_MCA_RENDEZ_CHECKIN_NOTDONE) {
+				udelay(1000);		/* short wait */
+				wait = 1;
+				break;
+			}
 		}
+		if (!wait)
+			goto all_in;
 	}
-	if (!wait)
-		goto all_in;
-	for_each_online_cpu(c) {
-		if (c = monarch)
-			continue;
-		if (ia64_mc_info.imi_rendez_checkin[c] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE) {
-			udelay(5*1000000);	/* wait 5 seconds for slaves (arbitrary) */
-			if (ia64_mc_info.imi_rendez_checkin[c] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE)
-				missing = 1;
-			break;
-		}
-	}
-	if (!missing)
-		goto all_in;
+
 	/*
 	 * Maybe slave(s) dead. Print buffered messages immediately.
 	 */
-- 
Russ Anderson  RAS group  SGI  rja@sgi.com
