From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Mon, 02 May 2022 13:38:40 +0000
Subject: Re: [PATCH 0/12] ptrace: cleaning up ptrace_stop
Message-Id: <Ym/e4CrxwV3HlsJj@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220421150248.667412396@infradead.org>
 <20220421150654.817117821@infradead.org>
 <87czhap9dy.fsf@email.froward.int.ebiederm.org>
 <878rrrh32q.fsf_-_@email.froward.int.ebiederm.org>
 <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
In-Reply-To: <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, oleg@redhat.com, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>, linux-ia64@vger.kernel.org, tglx@linutronix.de

On 2022-04-29 16:46:59 [-0500], Eric W. Biederman wrote:
> 
> The states TASK_STOPPED and TASK_TRACE are special in they can not
> handle spurious wake-ups.  This plus actively depending upon and
> changing the value of tsk->__state causes problems for PREEMPT_RT and
> Peter's freezer rewrite.

PREEMPT_RT wise, I had to duct tape wait_task_inactive() and remove the
preempt-disable section in ptrace_stop() (like previously). This reduces
the amount of __state + saved_state checks and looks otherwise stable in
light testing.

Sebastian
