From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Wed, 18 May 2022 22:53:52 +0000
Subject: [PATCH 13/16] ptrace: Document why ptrace_setoptions does not need a lock
Message-Id: <20220518225355.784371-13-ebiederm@xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
In-Reply-To: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, Robert OCallahan <roc@pernos.co>, Kyle Huey <khuey@pernos.co>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Jason Wessel <jason.wessel@windriver.com>, Daniel Thompson <daniel.thompson@linaro.org>, Douglas Anderson <dianders@chromium.org>, Douglas Miller <dougmill@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Eric W. Biederman" <ebiederm@xmission.com>

The functions that change ->ptrace are: ptrace_attach, ptrace_traceme,
ptrace_init_task, __ptrace_unlink, ptrace_setoptions.

Except for ptrace_setoptions all of the places where ->ptrace is
modified hold tasklist_lock for write, and either the tracee or the
tracer is modifies ->ptrace.

When ptrace_setoptions is called the tracee has been frozen with
ptrace_freeze_traced, and most be explicitly unfrozen by the tracer
before it can do anything.  As ptrace_setoption is run in the tracer
there can be no contention by the simple fact that the tracee can't
run.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 kernel/ptrace.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index d0527b6e2b29..fbadd2f21f09 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -689,7 +689,10 @@ static int ptrace_setoptions(struct task_struct *child, unsigned long data)
 	if (ret)
 		return ret;
 
-	/* Avoid intermediate state when all opts are cleared */
+	/*
+	 * With a frozen tracee, only the tracer modifies ->ptrace.
+	 * Avoid intermediate state when all opts are cleared.
+	 */
 	flags = child->ptrace;
 	flags &= ~(PTRACE_O_MASK << PT_OPT_FLAG_SHIFT);
 	flags |= (data << PT_OPT_FLAG_SHIFT);
-- 
2.35.3
