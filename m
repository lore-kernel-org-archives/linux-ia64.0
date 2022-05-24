From: Oleg Nesterov <oleg@redhat.com>
Date: Tue, 24 May 2022 11:42:51 +0000
Subject: Re: [PATCH 05/16] ptrace: Remove dead code from __ptrace_detach
Message-Id: <20220524114250.GB14347@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
 <20220518225355.784371-5-ebiederm@xmission.com>
In-Reply-To: <20220518225355.784371-5-ebiederm@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, Robert OCallahan <roc@pernos.co>, Kyle Huey <khuey@pernos.co>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Jason Wessel <jason.wessel@windriver.com>, Daniel Thompson <daniel.thompson@linaro.org>, Douglas Anderson <dianders@chromium.org>, Douglas Miller <dougmill@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

Sorry for delay.

On 05/18, Eric W. Biederman wrote:
>
> Ever since commit 28d838cc4dfe ("Fix ptrace self-attach rule") it has
> been impossible to attach another thread in the same thread group.
>
> Remove the code from __ptrace_detach that was trying to support
> detaching from a thread in the same thread group.

may be I am totally confused, but I think you misunderstood this code
and thus this patch is very wrong.

The same_thread_group() check does NOT try to check if debugger and
tracee is in the same thread group, this is indeed impossible.

We need this check to know if the tracee was ptrace_reparented() before
__ptrace_unlink() or not.


> -static int ignoring_children(struct sighand_struct *sigh)
> -{
> -	int ret;
> -	spin_lock(&sigh->siglock);
> -	ret = (sigh->action[SIGCHLD-1].sa.sa_handler = SIG_IGN) ||
> -	      (sigh->action[SIGCHLD-1].sa.sa_flags & SA_NOCLDWAIT);
> -	spin_unlock(&sigh->siglock);
> -	return ret;
> -}

...

> @@ -565,14 +552,9 @@ static bool __ptrace_detach(struct task_struct *tracer, struct task_struct *p)
>
>  	dead = !thread_group_leader(p);
>
> -	if (!dead && thread_group_empty(p)) {
> -		if (!same_thread_group(p->real_parent, tracer))
> -			dead = do_notify_parent(p, p->exit_signal);
> -		else if (ignoring_children(tracer->sighand)) {
> -			__wake_up_parent(p, tracer);
> -			dead = true;
> -		}
> -	}

So the code above does:

	- if !same_thread_group(p->real_parent, tracer), then the tracee was
	  ptrace_reparented(), and now we need to notify its natural parent
	  to let it know it has a zombie child.

	- otherwise, the tracee is our natural child, and it is actually dead.
	  however, since we are going to reap this task, we need to wake up our
	  sub-threads possibly sleeping on ->wait_chldexit wait_queue_head_t.

See?

> +	if (!dead && thread_group_empty(p))
> +		dead = do_notify_parent(p, p->exit_signal);

No, this looks wrong. Or I missed something?

Oleg.
