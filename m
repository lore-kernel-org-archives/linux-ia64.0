From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Wed, 18 May 2022 22:53:41 +0000
Subject: [PATCH 02/16] signal/ia64: Remove unused definition of IA64_TASK_REAL_PARENT_OFFSET
Message-Id: <20220518225355.784371-2-ebiederm@xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
In-Reply-To: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, Robert OCallahan <roc@pernos.co>, Kyle Huey <khuey@pernos.co>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Jason Wessel <jason.wessel@windriver.com>, Daniel Thompson <daniel.thompson@linaro.org>, Douglas Anderson <dianders@chromium.org>, Douglas Miller <dougmill@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Eric W. Biederman" <ebiederm@xmission.com>

Rather than update the unused definition of IA64_TASK_REAL_PARENT_OFFSENT
when I move tsk->real_parent into signal_struct remove it now.

Cc: linux-ia64@vger.kernel.org
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 arch/ia64/kernel/asm-offsets.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/ia64/kernel/asm-offsets.c b/arch/ia64/kernel/asm-offsets.c
index be3b90fef2e9..245c4333ea30 100644
--- a/arch/ia64/kernel/asm-offsets.c
+++ b/arch/ia64/kernel/asm-offsets.c
@@ -55,7 +55,6 @@ void foo(void)
 	DEFINE(IA64_PID_UPID_OFFSET, offsetof (struct pid, numbers[0]));
 	DEFINE(IA64_TASK_PENDING_OFFSET,offsetof (struct task_struct, pending));
 	DEFINE(IA64_TASK_PID_OFFSET, offsetof (struct task_struct, pid));
-	DEFINE(IA64_TASK_REAL_PARENT_OFFSET, offsetof (struct task_struct, real_parent));
 	DEFINE(IA64_TASK_SIGNAL_OFFSET,offsetof (struct task_struct, signal));
 	DEFINE(IA64_TASK_TGID_OFFSET, offsetof (struct task_struct, tgid));
 	DEFINE(IA64_TASK_THREAD_KSP_OFFSET, offsetof (struct task_struct, thread.ksp));
-- 
2.35.3
