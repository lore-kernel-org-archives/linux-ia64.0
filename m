From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Wed, 18 May 2022 22:53:46 +0000
Subject: [PATCH 07/16] signal: Wake up the designated parent
Message-Id: <20220518225355.784371-7-ebiederm@xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
In-Reply-To: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, Robert OCallahan <roc@pernos.co>, Kyle Huey <khuey@pernos.co>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Jason Wessel <jason.wessel@windriver.com>, Daniel Thompson <daniel.thompson@linaro.org>, Douglas Anderson <dianders@chromium.org>, Douglas Miller <dougmill@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Eric W. Biederman" <ebiederm@xmission.com>

Today if a process is ptraced only the ptracer will ever be woken up in
wait, if the parent is waiting with __WNOTHREAD.  Update the code
so that the real_parent can also be woken up with __WNOTHREAD even
when the code is ptraced.

Fixes: 75b95953a569 ("job control: Add @for_ptrace to do_notify_parent_cldstop()")
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 kernel/exit.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index f072959fcab7..0e26f73c49ac 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -1421,26 +1421,35 @@ static int ptrace_do_wait(struct wait_opts *wo, struct task_struct *tsk)
 	return 0;
 }
 
+struct child_wait_info {
+	struct task_struct *p;
+	struct task_struct *parent;
+};
+
 static int child_wait_callback(wait_queue_entry_t *wait, unsigned mode,
 				int sync, void *key)
 {
 	struct wait_opts *wo = container_of(wait, struct wait_opts,
 						child_wait);
-	struct task_struct *p = key;
+	struct child_wait_info *info = key;
 
-	if (!eligible_pid(wo, p))
+	if (!eligible_pid(wo, info->p))
 		return 0;
 
-	if ((wo->wo_flags & __WNOTHREAD) && wait->private != p->parent)
-		return 0;
+	if ((wo->wo_flags & __WNOTHREAD) && (wait->private != info->parent))
+			return 0;
 
 	return default_wake_function(wait, mode, sync, key);
 }
 
 void __wake_up_parent(struct task_struct *p, struct task_struct *parent)
 {
+	struct child_wait_info info = {
+		.p = p,
+		.parent = parent,
+	};
 	__wake_up_sync_key(&parent->signal->wait_chldexit,
-			   TASK_INTERRUPTIBLE, p);
+			   TASK_INTERRUPTIBLE, &info);
 }
 
 static bool is_effectively_child(struct wait_opts *wo, bool ptrace,
-- 
2.35.3
