From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 22 Sep 2005 16:41:15 +0000
Subject: [PATCH] ia64 printk_clock()
Message-Id: <200509221641.j8MGfFKF031443@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Linus just took a patch from Andrew that allows architectures to
override the clock used for time-stamping kernel printk().  Ia64
needs to override for two reasons:

1) default printk_clock() uses sched_clock() which accesses per-cpu
   variables ... this means the kernel crashes on an early printk
   before the per-cpu mapping is set up.

2) sched_clock() is based on ar.itc which some systems do not keep
   synchronized, so printk() timestamps jump about as different cpus
   print messages.

Here is a trivial printk_clock() based on jiffies, so we get much less
resolution in exchange for correctness.  I'd be happy to see a better
version that does interpolation (but remember that you can't take
locks or access per-cpu variables).

-Tony

Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -253,3 +253,9 @@ time_init (void)
 	 */
 	set_normalized_timespec(&wall_to_monotonic, -xtime.tv_sec, -xtime.tv_nsec);
 }
+
+unsigned long long printk_clock(void)
+{
+	return (unsigned long long)(jiffies_64 - INITIAL_JIFFIES)*(1000000000/HZ);
+}
+
