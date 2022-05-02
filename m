From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Mon, 02 May 2022 10:08:49 +0000
Subject: Re: [PATCH v2 10/12] ptrace: Only return signr from ptrace_stop if it was provided
Message-Id: <Ym+tsRcP2TQLcpJF@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
 <20220429214837.386518-10-ebiederm@xmission.com>
In-Reply-To: <20220429214837.386518-10-ebiederm@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org

On 2022-04-29 16:48:35 [-0500], Eric W. Biederman wrote:
> In ptrace_stop a ptrace_unlink or SIGKILL can occur either after
> siglock is dropped or after tasklist_lock is dropped.  At either point
> the result can be that ptrace will continue and not stop at schedule.
> 
> This means that there are cases where the current logic fails to handle
> the fact that ptrace_stop did not actually stop, and can potentially
> cause ptrace_report_syscall to attempt to deliver a signal.
> 
> Instead of attempting to detect in ptrace_stop when it fails to
> stop update ptrace_resume and ptrace_detach to set a flag to indicate
      ,
> that the signal to continue with has be set.   Use that
                                       been
> new flag to decided how to set return signal.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Sebastian
