From: Martin Pool <mbp@samba.org>
Date: Tue, 05 Aug 2003 02:08:07 +0000
Subject: janitor patch for 2.4.20-ia64
Message-Id: <marc-linux-ia64-106004945631478@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This small patch relative to linux-2.4.20-ia64-021210.diff seems to be
necessary to match the declarations in include/linux/smp.h and
arch/ia64/kernel/smpboot.c to satisfy gcc 3.2.3:

--- include/linux/smp.h.~1~	2003-08-01 16:47:04.000000000 +1000
+++ include/linux/smp.h	2003-08-01 17:03:30.000000000 +1000
@@ -48,7 +48,7 @@ extern int smp_call_function (void (*fun
 /*
  * True once the per process idle is forked
  */
-extern int smp_threads_ready;
+extern volatile int smp_threads_ready;
 
 extern int smp_num_cpus;
 
-- 
Martin 
