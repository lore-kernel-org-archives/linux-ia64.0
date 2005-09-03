From: hawkes@sgi.com
Date: Sat, 03 Sep 2005 16:22:46 +0000
Subject: [PATCH 3/3] 2.6.13: cpuset + build_sched_domains() fix
Message-Id: <20050903162246.22567.3948.sendpatchset@tomahawk.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dinakar Guniguntala <dino@in.ibm.com>, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-ia64@vger.kernel.org, hawkes@sgi.com, Paul Jackson <pj@sgi.com>, linux-kernel@vger.kernel.org

Fix part 3:
Undo the #ifdef disabling hack that was put into 2.6.13 to disable
dynamic sched domains.

Signed-off-by: John Hawkes <hawkes@sgi.com>

Index: linux/kernel/cpuset.c
=================================--- linux.orig/kernel/cpuset.c	2005-08-28 16:41:01.000000000 -0700
+++ linux/kernel/cpuset.c	2005-09-02 08:45:24.000000000 -0700
@@ -628,13 +628,6 @@
  * lock_cpu_hotplug()/unlock_cpu_hotplug() pair.
  */
 
-/*
- * Hack to avoid 2.6.13 partial node dynamic sched domain bug.
- * Disable letting 'cpu_exclusive' cpusets define dynamic sched
- * domains, until the sched domain can handle partial nodes.
- * Remove this #if hackery when sched domains fixed.
- */
-#if 0
 static void update_cpu_domains(struct cpuset *cur)
 {
 	struct cpuset *c, *par = cur->parent;
@@ -675,11 +668,6 @@
 	partition_sched_domains(&pspan, &cspan);
 	unlock_cpu_hotplug();
 }
-#else
-static void update_cpu_domains(struct cpuset *cur)
-{
-}
-#endif
 
 static int update_cpumask(struct cpuset *cs, char *buf)
 {
