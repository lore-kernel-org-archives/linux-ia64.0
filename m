From: Oleg Nesterov <oleg@redhat.com>
Date: Tue, 24 May 2022 15:27:25 +0000
Subject: Re: [PATCH 08/16] ptrace: Only populate last_siginfo from ptrace
Message-Id: <20220524152725.GE14347@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
 <20220518225355.784371-8-ebiederm@xmission.com>
In-Reply-To: <20220518225355.784371-8-ebiederm@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, Robert OCallahan <roc@pernos.co>, Kyle Huey <khuey@pernos.co>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Jason Wessel <jason.wessel@windriver.com>, Daniel Thompson <daniel.thompson@linaro.org>, Douglas Anderson <dianders@chromium.org>, Douglas Miller <dougmill@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

On 05/18, Eric W. Biederman wrote:
>
> The code in ptrace_signal to populate siginfo if the signal number
> changed is buggy.  If the tracer contined the tracee using
> ptrace_detach it is guaranteed to use the real_parent (or possibly a
> new tracer) but definitely not the origional tracer to populate si_pid
> and si_uid.

I guess nobody cares. As the comment says

	 If the debugger wanted something
	 specific in the siginfo structure then it should
	 have updated *info via PTRACE_SETSIGINFO.

otherwise I don't think si_pid/si_uid have any value.

However the patch looks fine to me, just the word "buggy" looks a bit
too strong imo.

Oleg.
