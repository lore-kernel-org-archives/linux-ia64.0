From: Masanari Iida <standby24x7@gmail.com>
Date: Sat, 15 Jul 2017 12:58:45 +0000
Subject: [PATCH] ia64: Remove an extra parenthesis in time.c
Message-Id: <20170715125845.24521-1-standby24x7@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: fweisbec@gmail.com, mingo@kernel.org, tony.luck@intel.com, fenghua.yu@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Masanari Iida <standby24x7@gmail.com>

This patch removes an extra parenthesis.
It was found by cppcheck.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 arch/ia64/kernel/time.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index aa7be020a904..c954523d00fe 100644
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
2.14.0.rc0

