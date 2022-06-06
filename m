From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon, 06 Jun 2022 22:10:02 +0000
Subject: Re: [PATCH 07/16] signal: Wake up the designated parent
Message-Id: <87a6ap30lh.fsf@email.froward.int.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
        <20220518225355.784371-7-ebiederm@xmission.com>
        <20220524132553.GD14347@redhat.com>
        <20220524162808.GF14347@redhat.com> <20220525142845.GA2687@redhat.com>
In-Reply-To: <20220525142845.GA2687@redhat.com> (Oleg Nesterov's message of
        "Wed, 25 May 2022 16:28:46 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, Robert OCallahan <roc@pernos.co>, Kyle Huey <khuey@pernos.co>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Jason Wessel <jason.wessel@windriver.com>, Daniel Thompson <daniel.thompson@linaro.org>, Douglas Anderson <dianders@chromium.org>, Douglas Miller <dougmill@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

Oleg Nesterov <oleg@redhat.com> writes:

> On 05/24, Oleg Nesterov wrote:
>>
>> On 05/24, Oleg Nesterov wrote:
>> >
>> > I fail to understand this patch...
>> >
>> > On 05/18, Eric W. Biederman wrote:
>> > >
>> > > Today if a process is ptraced only the ptracer will ever be woken up in
>> > > wait
>> >
>> > and why is this wrong?
>> >
>> > > Fixes: 75b95953a569 ("job control: Add @for_ptrace to do_notify_parent_cldstop()")
>> >
>> > how does this change fix 75b95953a569?
>>
>> OK, I guess you mean the 2nd do_notify_parent_cldstop() in ptrace_stop(),
>> the problematic case is current->ptrace = T. Right?
>>
>> I dislike this patch anyway, but let me think more about it.
>
> OK, now that I understand the problem, the patch doesn't look bad to me,
> although I'd ask to make the changelog more clear.

I will see what I can do.

> After this change __wake_up_parent() can't accept any "parent" from
> p->parent thread group, but all callers look fine except
> ptrace_detach().

Having looked at it a little more I think the change was too
restrictive.  For the !ptrace_reparented case there are possibly
two threads of the parent process that wait_consider_task will
allow to wait even with __WNOTHREAD specified.  It is desirable
to wake them both up.

Which if I have had enough sleep reduces this patch to just:

diff --git a/kernel/exit.c b/kernel/exit.c
index f072959fcab7..c8156366b722 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -1431,8 +1431,10 @@ static int child_wait_callback(wait_queue_entry_t *wait, unsigned mode,
        if (!eligible_pid(wo, p))
                return 0;
 
-       if ((wo->wo_flags & __WNOTHREAD) && wait->private != p->parent)
-               return 0;
+       if ((wo->wo_flags & __WNOTHREAD) &&
+           (wait->private != p->parent) &&
+           (wait->private != p->real_parent))
+                       return 0;
 
        return default_wake_function(wait, mode, sync, key);
 }


I think that solves the issue without missing wake-ups without adding
any more.

For the same set of reasons it looks like the __wake_up_parent in
__ptrace_detach is just simply dead code.  I don't think there is a case
where when !ptrace_reparented the thread that is the real_parent can
sleep in do_wait when the thread that was calling ptrace could not.

That needs a very close look to confirm. 

Eric
