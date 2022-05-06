From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Fri, 06 May 2022 06:55:24 +0000
Subject: Re: [PATCH v4 08/12] ptrace: Document that wait_task_inactive can't fail
Message-Id: <YnTGXGabf9UDoZyn@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <87a6bv6dl6.fsf_-_@email.froward.int.ebiederm.org>
 <20220505182645.497868-8-ebiederm@xmission.com>
In-Reply-To: <20220505182645.497868-8-ebiederm@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org

On 2022-05-05 13:26:41 [-0500], Eric W. Biederman wrote:
> After ptrace_freeze_traced succeeds it is known that the the tracee
                                                       the

> has a __state value of __TASK_TRACED and that no __ptrace_unlink will
> happen because the tracer is waiting for the tracee, and the tracee is
> in ptrace_stop.

Sebastian
