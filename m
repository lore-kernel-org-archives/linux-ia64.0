From: Oleg Nesterov <oleg@redhat.com>
Date: Tue, 07 Jun 2022 15:26:54 +0000
Subject: Re: [PATCH 07/16] signal: Wake up the designated parent
Message-Id: <20220607152627.GA10192@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
 <20220518225355.784371-7-ebiederm@xmission.com>
 <20220524132553.GD14347@redhat.com>
 <20220524162808.GF14347@redhat.com>
 <20220525142845.GA2687@redhat.com>
 <87a6ap30lh.fsf@email.froward.int.ebiederm.org>
In-Reply-To: <87a6ap30lh.fsf@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, Robert OCallahan <roc@pernos.co>, Kyle Huey <khuey@pernos.co>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Jason Wessel <jason.wessel@windriver.com>, Daniel Thompson <daniel.thompson@linaro.org>, Douglas Anderson <dianders@chromium.org>, Douglas Miller <dougmill@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

On 06/06, Eric W. Biederman wrote:
>
> Which if I have had enough sleep reduces this patch to just:
>
> diff --git a/kernel/exit.c b/kernel/exit.c
> index f072959fcab7..c8156366b722 100644
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -1431,8 +1431,10 @@ static int child_wait_callback(wait_queue_entry_t *wait, unsigned mode,
>         if (!eligible_pid(wo, p))
>                 return 0;
>
> -       if ((wo->wo_flags & __WNOTHREAD) && wait->private != p->parent)
> -               return 0;
> +       if ((wo->wo_flags & __WNOTHREAD) &&
> +           (wait->private != p->parent) &&
> +           (wait->private != p->real_parent))
> +                       return 0;
>
>         return default_wake_function(wait, mode, sync, key);
>  }
>
>
> I think that solves the issue without missing wake-ups without adding
> any more.

Agreed, and looks much simpler.

> For the same set of reasons it looks like the __wake_up_parent in
> __ptrace_detach is just simply dead code.  I don't think there is a case
> where when !ptrace_reparented the thread that is the real_parent can
> sleep in do_wait when the thread that was calling ptrace could not.

Yes... this doesn't really differ from the case when one thread reaps
a natural child and another thread sleep in do_wait().

> That needs a very close look to confirm.

Yes.

Oleg.
