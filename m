From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Thu, 05 May 2022 12:50:31 +0000
Subject: Re: [PATCH v3 09/11] ptrace: Don't change __state
Message-Id: <YnPIF9DvM9L0k+0U@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k0b0apne.fsf_-_@email.froward.int.ebiederm.org>
 <20220504224058.476193-9-ebiederm@xmission.com>
In-Reply-To: <20220504224058.476193-9-ebiederm@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org

On 2022-05-04 17:40:56 [-0500], Eric W. Biederman wrote:
> Stop playing with tsk->__state to remove TASK_WAKEKILL while a ptrace
> command is executing.
> 
> Instead remove TASK_WAKEKILL from the definition of TASK_TRACED, and
> implemention a new jobctl flag TASK_PTRACE_FROZEN.  This new flag is
implement ?

> set in jobctl_freeze_task and cleared when ptrace_stop is awoken or in
> jobctl_unfreeze_task (when ptrace_stop remains asleep).

Sebastian
