From: Davidlohr Bueso <dave@stgolabs.net>
Date: Thu, 15 Jan 2015 07:50:00 +0000
Subject: ia64: use current->state helpers
Message-Id: <1421308200.17403.3.camel@stgolabs.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>

Call __set_current_state() instead of assigning the new state directly.
These interfaces also aid CONFIG_DEBUG_ATOMIC_SLEEP environments, keeping
track of who changed the state.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
Completely untested.

 arch/ia64/kernel/mca.c    | 2 +-
 arch/ia64/kernel/ptrace.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 8bfd36a..9797d01 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1821,7 +1821,7 @@ format_mca_init_stack(void *mca_data, unsigned long offset,
 	ti->task = p;
 	ti->cpu = cpu;
 	p->stack = ti;
-	p->state = TASK_UNINTERRUPTIBLE;
+	__set_task_state(p, TASK_UNINTERRUPTIBLE);
 	cpu_set(cpu, p->cpus_allowed);
 	INIT_LIST_HEAD(&p->tasks);
 	p->parent = p->real_parent = p->group_leader = p;
diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index 6f54d51..67bb42c 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -643,7 +643,7 @@ ptrace_attach_sync_user_rbs (struct task_struct *child)
 		    !test_and_set_tsk_thread_flag(child, TIF_RESTORE_RSE)) {
 			set_notify_resume(child);
 
-			child->state = TASK_TRACED;
+			__set_task_state(child, TASK_TRACED);
 			stopped = 1;
 		}
 		spin_unlock_irq(&child->sighand->siglock);
@@ -665,7 +665,7 @@ ptrace_attach_sync_user_rbs (struct task_struct *child)
 		spin_lock_irq(&child->sighand->siglock);
 		if (child->state = TASK_TRACED &&
 		    (child->signal->flags & SIGNAL_STOP_STOPPED)) {
-			child->state = TASK_STOPPED;
+			__set_task_state(child, TASK_STOPPED);
 		}
 		spin_unlock_irq(&child->sighand->siglock);
 	}
-- 
2.1.2



