From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 17 Apr 2008 07:59:52 +0000
Subject: [PATCH 1/2] ia64: do notify DIE_MCA_MONARCH_PROCESS for each monarchs
Message-Id: <48070378.7090707@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There are 3 hooks in MCA handler, but this DIE_MCA_MONARCH_PROCESS
event does not notified other than for the first monarch.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
---
 arch/ia64/kernel/mca.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index e51bced..3ba091b 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1288,13 +1288,14 @@ ia64_mca_handler(struct pt_regs *regs, struct switch_stack *sw,
 		 * does not work.
 		 */
 		ia64_mca_wakeup_all();
-		if (notify_die(DIE_MCA_MONARCH_PROCESS, "MCA", regs, (long)&nd, 0, 0)
-				= NOTIFY_STOP)
-			ia64_mca_spin(__func__);
 	} else {
 		while (cpu_isset(cpu, mca_cpu))
 			cpu_relax();	/* spin until monarch wakes us */
-        }
+	}
+
+	if (notify_die(DIE_MCA_MONARCH_PROCESS, "MCA", regs, (long)&nd, 0, 0)
+			= NOTIFY_STOP)
+		ia64_mca_spin(__func__);

 	/* Get the MCA error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);
