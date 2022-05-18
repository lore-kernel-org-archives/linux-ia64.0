From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Wed, 18 May 2022 22:53:45 +0000
Subject: [PATCH 06/16] ptrace: Remove unnecessary locking in ptrace_(get|set)siginfo
Message-Id: <20220518225355.784371-6-ebiederm@xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
In-Reply-To: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, Robert OCallahan <roc@pernos.co>, Kyle Huey <khuey@pernos.co>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Jason Wessel <jason.wessel@windriver.com>, Daniel Thompson <daniel.thompson@linaro.org>, Douglas Anderson <dianders@chromium.org>, Douglas Miller <dougmill@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Eric W. Biederman" <ebiederm@xmission.com>

Since commit 9899d11f6544 ("ptrace: ensure arch_ptrace/ptrace_request
can never race with SIGKILL") it has been unnecessary for
ptrace_getsiginfo and ptrace_setsiginfo to use lock_task_sighand.

Having the code taking an unnecessary lock is confusing
as it suggests that other parts of the code need to take
the unnecessary lock as well.

So remove the unnecessary lock to make the code more
efficient, simpler, and less confusing.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 kernel/ptrace.c | 30 ++++++++----------------------
 1 file changed, 8 insertions(+), 22 deletions(-)

diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index ca0e47691229..15e93eafa6f0 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -677,34 +677,20 @@ static int ptrace_setoptions(struct task_struct *child, unsigned long data)
 
 static int ptrace_getsiginfo(struct task_struct *child, kernel_siginfo_t *info)
 {
-	unsigned long flags;
-	int error = -ESRCH;
+	if (unlikely(!child->last_siginfo))
+		return -EINVAL;
 
-	if (lock_task_sighand(child, &flags)) {
-		error = -EINVAL;
-		if (likely(child->last_siginfo != NULL)) {
-			copy_siginfo(info, child->last_siginfo);
-			error = 0;
-		}
-		unlock_task_sighand(child, &flags);
-	}
-	return error;
+	copy_siginfo(info, child->last_siginfo);
+	return 0;
 }
 
 static int ptrace_setsiginfo(struct task_struct *child, const kernel_siginfo_t *info)
 {
-	unsigned long flags;
-	int error = -ESRCH;
+	if (unlikely(!child->last_siginfo))
+		return -EINVAL;
 
-	if (lock_task_sighand(child, &flags)) {
-		error = -EINVAL;
-		if (likely(child->last_siginfo != NULL)) {
-			copy_siginfo(child->last_siginfo, info);
-			error = 0;
-		}
-		unlock_task_sighand(child, &flags);
-	}
-	return error;
+	copy_siginfo(child->last_siginfo, info);
+	return 0;
 }
 
 static int ptrace_peek_siginfo(struct task_struct *child,
-- 
2.35.3
