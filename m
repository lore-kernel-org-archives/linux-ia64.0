From: Valentin Ilie <valentin.ilie@gmail.com>
Date: Fri, 05 Jan 2018 23:12:59 +0000
Subject: [PATCH] ia64: Fix syntax error introduced by e2339a4caa5e
Message-Id: <1515193979-24873-1-git-send-email-valentin.ilie@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: fenghua.yu@intel.com, mingo@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, valentin.ilie@gmail.com

Remove extra parentheses.

Signed-off-by: Valentin Ilie <valentin.ilie@gmail.com>
---
 arch/ia64/kernel/time.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index c6ecb97..9025699 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -88,7 +88,7 @@ void vtime_flush(struct task_struct *tsk)
 	}
 
 	if (ti->softirq_time) {
-		delta = cycle_to_nsec(ti->softirq_time));
+		delta = cycle_to_nsec(ti->softirq_time);
 		account_system_index_time(tsk, delta, CPUTIME_SOFTIRQ);
 	}
 
-- 
2.7.4

