From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 02 Mar 2018 08:51:32 +0000
Subject: [PATCH 4.14 089/115] ia64, sched/cputime: Fix build error if CONFIG_VIRT_CPU_ACCOUNTING_NATIVE=y
Message-Id: <20180302084507.455791996@linuxfoundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180302084503.856536800@linuxfoundation.org>
In-Reply-To: <20180302084503.856536800@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Valentin Ilie <valentin.ilie@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, tony.luck@intel.com, Ingo Molnar <mingo@kernel.org>, Sasha Levin <alexander.levin@verizon.com>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

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
Signed-off-by: Sasha Levin <alexander.levin@verizon.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 arch/ia64/kernel/time.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -88,7 +88,7 @@ void vtime_flush(struct task_struct *tsk
 	}
 
 	if (ti->softirq_time) {
-		delta = cycle_to_nsec(ti->softirq_time));
+		delta = cycle_to_nsec(ti->softirq_time);
 		account_system_index_time(tsk, delta, CPUTIME_SOFTIRQ);
 	}
 


