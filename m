From: Oleg Nesterov <oleg@redhat.com>
Date: Tue, 24 May 2022 16:28:09 +0000
Subject: Re: [PATCH 07/16] signal: Wake up the designated parent
Message-Id: <20220524162808.GF14347@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
 <20220518225355.784371-7-ebiederm@xmission.com>
 <20220524132553.GD14347@redhat.com>
In-Reply-To: <20220524132553.GD14347@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, Robert OCallahan <roc@pernos.co>, Kyle Huey <khuey@pernos.co>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Jason Wessel <jason.wessel@windriver.com>, Daniel Thompson <daniel.thompson@linaro.org>, Douglas Anderson <dianders@chromium.org>, Douglas Miller <dougmill@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

On 05/24, Oleg Nesterov wrote:
>
> I fail to understand this patch...
>
> On 05/18, Eric W. Biederman wrote:
> >
> > Today if a process is ptraced only the ptracer will ever be woken up in
> > wait
>
> and why is this wrong?
>
> > Fixes: 75b95953a569 ("job control: Add @for_ptrace to do_notify_parent_cldstop()")
>
> how does this change fix 75b95953a569?

OK, I guess you mean the 2nd do_notify_parent_cldstop() in ptrace_stop(),
the problematic case is current->ptrace = T. Right?

I dislike this patch anyway, but let me think more about it.

Oleg.
