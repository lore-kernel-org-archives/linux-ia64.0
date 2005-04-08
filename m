From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 08 Apr 2005 22:21:20 +0000
Subject: Beauties staggering timer interrupt
Message-Id: <200504082221.j38MLFg20356@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is more or less a teaser patch.  When we initialize local timer
tick on AP (application processor), we prefer to stagger them.  In a
perfect world, the staggering should be evenly spaced within a jiffy
for all the online cpu.  And that's what majority of the code in
ia64_cpu_local_tick() is trying to do.  However, when it initialize
itm_next, it didn't make any references to the AP's itm_next.  So we
end up with random staggering relative to AP's timer interrupt.

For platforms that has itc drift, this is not an issue since they going to
be out of sync anyway.  There is no point in trying to space them.  But on
box that has the itc synchronized, then current code is a bit suboptimal.
(this probably explains why it is easier to expose a scheduler idle load
balancing issue on ia64 compare to x86).

This patch will put the wonderful staggering calculation really in action.
Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- linux-2.6.11/arch/ia64/kernel/time.c.orig	2005-04-08 14:39:00.000000000 -0700
+++ linux-2.6.11/arch/ia64/kernel/time.c	2005-04-08 14:56:41.000000000 -0700
@@ -131,8 +131,9 @@ ia64_cpu_local_tick (void)
 	if (cpu) {
 		unsigned long hi = 1UL << ia64_fls(cpu);
 		shift = (2*(cpu - hi) + 1) * delta/hi/2;
-	}
-	local_cpu_data->itm_next = ia64_get_itc() + delta + shift;
+		local_cpu_data->itm_next = cpu_data(0)->itm_next + delta + shift;
+	} else
+		local_cpu_data->itm_next = ia64_get_itc() + delta;
 	ia64_set_itm(local_cpu_data->itm_next);
 }




