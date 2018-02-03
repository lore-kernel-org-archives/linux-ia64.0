From: Sasha Levin <Alexander.Levin@microsoft.com>
Date: Sat, 03 Feb 2018 18:01:27 +0000
Subject: [PATCH AUTOSEL for 4.14 092/110] ia64, sched/cputime: Fix build error if CONFIG_VIRT_CPU_ACCOUNTING_
Message-Id: <20180203180015.29073-92-alexander.levin@microsoft.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180203180015.29073-1-alexander.levin@microsoft.com>
In-Reply-To: <20180203180015.29073-1-alexander.levin@microsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>
Cc: Valentin Ilie <valentin.ilie@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, "fenghua.yu@intel.com" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, Ingo Molnar <mingo@kernel.org>, Sasha Levin <Alexander.Levin@microsoft.com>

From: Valentin Ilie <valentin.ilie@gmail.com>

[ Upstream commit 7729bebc619307a0233c86f8585a4bf3eadc7ce4 ]

Remove the extra parenthesis.

This bug was introduced by:

  e2339a4caa5e: ("ia64: Convert vtime to use nsec units directly")

Signed-off-by: Valentin Ilie <valentin.ilie@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org
Cc: tony.luck@intel.com
Link: http://lkml.kernel.org/r/1515193979-24873-1-git-send-email-valentin.ilie@gmail.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
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
2.11.0
