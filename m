From: Doug Anderson <dianders@chromium.org>
Date: Thu, 19 May 2022 20:52:22 +0000
Subject: Re: [PATCH 03/16] kdb: Use real_parent when displaying a list of processes
Message-Id: <CAD=FV=UFK7h0oHGJ23y37ShO+z4vt9ubGE9E4m=jMECgNAAHgA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org> <20220518225355.784371-3-ebiederm@xmission.com>
In-Reply-To: <20220518225355.784371-3-ebiederm@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@kernel.org>, Vincent Guittot <vincent.guittot@linaro.org>, Dietmar Eggemann <dietmar.eggemann@arm.com>, Steven Rostedt <rostedt@goodmis.org>, Mel Gorman <mgorman@suse.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Will Deacon <will@kernel.org>, Tejun Heo <tj@kernel.org>, Linux PM <linux-pm@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, Robert OCallahan <roc@pernos.co>, Kyle Huey <khuey@pernos.co>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Jason Wessel <jason.wessel@windriver.com>, Daniel Thompson <daniel.thompson@linaro.org>, Douglas Miller <dougmill@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

Hi,

On Wed, May 18, 2022 at 3:54 PM Eric W. Biederman <ebiederm@xmission.com> wrote:
>
> kdb has a bug that when using the ps command to display a list of
> processes, if a process is being debugged the debugger as the parent
> process.
>
> This is silly, and I expect it never comes up in ptractice.  As there
> is very little point in using gdb and kdb simultaneously.  Update the
> code to use real_parent so that it is clear kdb does not want to
> display a debugger as the parent of a process.

So I would tend to defer to Daniel, but I'm not convinced that the
behavior you describe for kdb today _is_ actually silly.

If I was in kdb and I was listing processes, I might actually want to
see that a process's parent was set to gdb. Presumably that would tell
me extra information that might be relevant to my debug session.

Personally, I'd rather add an extra piece of information into the list
showing the real parent if it's not the same as the parent. Then
you're not throwing away information.

-Doug
