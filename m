From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Wed, 18 May 2022 22:53:44 +0000
Subject: [PATCH 05/16] ptrace: Remove dead code from __ptrace_detach
Message-Id: <20220518225355.784371-5-ebiederm@xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
In-Reply-To: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, Robert OCallahan <roc@pernos.co>, Kyle Huey <khuey@pernos.co>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Jason Wessel <jason.wessel@windriver.com>, Daniel Thompson <daniel.thompson@linaro.org>, Douglas Anderson <dianders@chromium.org>, Douglas Miller <dougmill@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Eric W. Biederman" <ebiederm@xmission.com>

Ever since commit 28d838cc4dfe ("Fix ptrace self-attach rule") it has
been impossible to attach another thread in the same thread group.

Remove the code from __ptrace_detach that was trying to support
detaching from a thread in the same thread group.  The code is
dead and I can not make sense of what it is trying to do.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 kernel/ptrace.c | 24 +++---------------------
 1 file changed, 3 insertions(+), 21 deletions(-)

diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 328a34a99124..ca0e47691229 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -526,19 +526,6 @@ static int ptrace_traceme(void)
 	return ret;
 }
 
-/*
- * Called with irqs disabled, returns true if childs should reap themselves.
- */
-static int ignoring_children(struct sighand_struct *sigh)
-{
-	int ret;
-	spin_lock(&sigh->siglock);
-	ret = (sigh->action[SIGCHLD-1].sa.sa_handler = SIG_IGN) ||
-	      (sigh->action[SIGCHLD-1].sa.sa_flags & SA_NOCLDWAIT);
-	spin_unlock(&sigh->siglock);
-	return ret;
-}
-
 /*
  * Called with tasklist_lock held for writing.
  * Unlink a traced task, and clean it up if it was a traced zombie.
@@ -565,14 +552,9 @@ static bool __ptrace_detach(struct task_struct *tracer, struct task_struct *p)
 
 	dead = !thread_group_leader(p);
 
-	if (!dead && thread_group_empty(p)) {
-		if (!same_thread_group(p->real_parent, tracer))
-			dead = do_notify_parent(p, p->exit_signal);
-		else if (ignoring_children(tracer->sighand)) {
-			__wake_up_parent(p, tracer);
-			dead = true;
-		}
-	}
+	if (!dead && thread_group_empty(p))
+		dead = do_notify_parent(p, p->exit_signal);
+
 	/* Mark it as in the process of being reaped. */
 	if (dead)
 		p->exit_state = EXIT_DEAD;
-- 
2.35.3
