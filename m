From: Jes Sorensen <jes@wildopensource.com>
Date: Wed, 26 Mar 2003 16:27:55 +0000
Subject: [Linux-ia64] [patch] 2.4 arch/ia64/kernel/smpboot.c
Message-Id: <marc-linux-ia64-105590723705320@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

A small patch for 2.4 that stops the kernel from trying to syncrhonize
ITC clocks between CPUs if we know that the ITC isn't synchronized
across the backplane.

The patch is relative to 2.4.21-pre5-bjorn, but I believe it should
apply directly to 2.5.x as well.

Cheers,
Jes

--- ../linux-2.4.20-021210/arch/ia64/kernel/smpboot.c	Tue Mar 11 11:23:49 2003
+++ arch/ia64/kernel/smpboot.c	Wed Mar 26 06:19:17 2003
@@ -334,12 +334,15 @@
 
 	smp_setup_percpu_timer();
 
-	/*
-	 * Synchronize the ITC with the BP
-	 */
-	Dprintk("Going to syncup ITC with BP.\n");
+	if (!(sal_platform_features & IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT)) {
+		/*
+		 * Synchronize the ITC with the BP
+		 */
+		Dprintk("Going to syncup ITC with BP.\n");
+
+		ia64_sync_itc(0);
+	}
 
-	ia64_sync_itc(0);
 	/*
 	 * Get our bogomips.
 	 */

