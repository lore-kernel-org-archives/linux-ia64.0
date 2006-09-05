From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 05 Sep 2006 08:53:19 +0000
Subject: [PATCH] CMC/CPE: Reverse the order of fetching log and checking poll
Message-Id: <44FD3AFF.7050005@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch reverses the order of fetching log from SAL and
checking poll threshold. This will fix following trivial issues:

- If SAL_GET_SATE_INFO is unbelievably slow (due to huge system
   or just its silly implementation) and if it takes more than
   1/5 sec, CMCI/CPEI will never switch to CMCP/CPEP.
- Assuming terrible flood of interrupt (continuous corrected
   errors let all CPUs enter to handler at once and bind them
   in it), CPUs will be serialized by IA64_LOG_LOCK(*).
   Now we check the poll threshold after the lock and log fetch,
   so we need to call SAL_GET_STATE_INFO (num_online_cpus() + 4)
   times in the worst case.
   if we can check the threshold before the lock, we can shut up
   interrupts quickly without waiting preceding log fetches, and
   the number of times will be reduced to (num_online_cpus()) in
   the same situation.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---
  arch/ia64/kernel/mca.c |   18 ++++++++++--------
  1 files changed, 10 insertions(+), 8 deletions(-)

Index: linux-2.6.17-rc6/arch/ia64/kernel/mca.c
=================================--- linux-2.6.17-rc6.orig/arch/ia64/kernel/mca.c
+++ linux-2.6.17-rc6/arch/ia64/kernel/mca.c
@@ -345,9 +345,6 @@
  	/* SAL spec states this should run w/ interrupts enabled */
  	local_irq_enable();

-	/* Get the CPE error record and log it */
-	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE);
-
  	spin_lock(&cpe_history_lock);
  	if (!cpe_poll_enabled && cpe_vector >= 0) {

@@ -376,7 +373,7 @@
  			mod_timer(&cpe_poll_timer, jiffies + MIN_CPE_POLL_INTERVAL);

  			/* lock already released, get out now */
-			return IRQ_HANDLED;
+			goto out;
  		} else {
  			cpe_history[index++] = now;
  			if (index = CPE_HISTORY_LENGTH)
@@ -384,6 +381,10 @@
  		}
  	}
  	spin_unlock(&cpe_history_lock);
+out:
+	/* Get the CPE error record and log it */
+	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE);
+
  	return IRQ_HANDLED;
  }

@@ -1107,9 +1108,6 @@
  	/* SAL spec states this should run w/ interrupts enabled */
  	local_irq_enable();

-	/* Get the CMC error record and log it */
-	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CMC);
-
  	spin_lock(&cmc_history_lock);
  	if (!cmc_polling_enabled) {
  		int i, count = 1; /* we know 1 happened now */
@@ -1142,7 +1140,7 @@
  			mod_timer(&cmc_poll_timer, jiffies + CMC_POLL_INTERVAL);

  			/* lock already released, get out now */
-			return IRQ_HANDLED;
+			goto out;
  		} else {
  			cmc_history[index++] = now;
  			if (index = CMC_HISTORY_LENGTH)
@@ -1150,6 +1148,10 @@
  		}
  	}
  	spin_unlock(&cmc_history_lock);
+out:
+	/* Get the CMC error record and log it */
+	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CMC);
+
  	return IRQ_HANDLED;
  }


