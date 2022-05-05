From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Thu, 05 May 2022 18:26:41 +0000
Subject: [PATCH v4 08/12] ptrace: Document that wait_task_inactive can't fail
Message-Id: <20220505182645.497868-8-ebiederm@xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87a6bv6dl6.fsf_-_@email.froward.int.ebiederm.org>
In-Reply-To: <87a6bv6dl6.fsf_-_@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

After ptrace_freeze_traced succeeds it is known that the the tracee
has a __state value of __TASK_TRACED and that no __ptrace_unlink will
happen because the tracer is waiting for the tracee, and the tracee is
in ptrace_stop.

The function ptrace_freeze_traced can succeed at any point after
ptrace_stop has set TASK_TRACED and dropped siglock.  The read_lock on
tasklist_lock only excludes ptrace_attach.

This means that the !current->ptrace which executes under a read_lock
of tasklist_lock will never see a ptrace_freeze_trace as the tracer
must have gone away before the tasklist_lock was taken and
ptrace_attach can not occur until the read_lock is dropped.  As
ptrace_freeze_traced depends upon ptrace_attach running before it can
run that excludes ptrace_freeze_traced until __state is set to
TASK_RUNNING.  This means that task_is_traced will fail in
ptrace_freeze_attach and ptrace_freeze_attached will fail.

On the current->ptrace branch of ptrace_stop which will be reached any
time after ptrace_freeze_traced has succeed it is known that __state
is __TASK_TRACED and schedule() will be called with that state.

Use a WARN_ON_ONCE to document that wait_task_inactive(TASK_TRACED)
should never fail.  Remove the stale comment about may_ptrace_stop.

Strictly speaking this is not true because if PREEMPT_RT is enabled
wait_task_inactive can fail because __state can be changed.  I don't
see this as a problem as the ptrace code is currently broken on
PREMPT_RT, and this is one of the issues.  Failing and warning when
the assumptions of the code are broken is good.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 kernel/ptrace.c | 14 +++-----------
 1 file changed, 3 insertions(+), 11 deletions(-)

diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 7105821595bc..05953ac9f7bd 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -266,17 +266,9 @@ static int ptrace_check_attach(struct task_struct *child, bool ignore_state)
 	}
 	read_unlock(&tasklist_lock);
 
-	if (!ret && !ignore_state) {
-		if (!wait_task_inactive(child, __TASK_TRACED)) {
-			/*
-			 * This can only happen if may_ptrace_stop() fails and
-			 * ptrace_stop() changes ->state back to TASK_RUNNING,
-			 * so we should not worry about leaking __TASK_TRACED.
-			 */
-			WARN_ON(READ_ONCE(child->__state) = __TASK_TRACED);
-			ret = -ESRCH;
-		}
-	}
+	if (!ret && !ignore_state &&
+	    WARN_ON_ONCE(!wait_task_inactive(child, __TASK_TRACED)))
+		ret = -ESRCH;
 
 	return ret;
 }
-- 
2.35.3
