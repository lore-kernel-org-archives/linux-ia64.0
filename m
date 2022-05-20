From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Fri, 20 May 2022 07:33:46 +0000
Subject: Re: [PATCH 00/16] ptrace: cleanups and calling do_cldstop with only siglock
Message-Id: <YodEWlfo4kFd8+mt@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220421150248.667412396@infradead.org>
 <20220421150654.817117821@infradead.org>
 <87czhap9dy.fsf@email.froward.int.ebiederm.org>
 <878rrrh32q.fsf_-_@email.froward.int.ebiederm.org>
 <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
 <87k0b0apne.fsf_-_@email.froward.int.ebiederm.org>
 <87a6bv6dl6.fsf_-_@email.froward.int.ebiederm.org>
 <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
In-Reply-To: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, oleg@redhat.com, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>, linux-ia64@vger.kernel.org, Robert O'Callahan <roc@pernos.co>, Kyle Huey <khuey@pernos.co>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Jason Wessel <jason.wessel@windriver.com>, Daniel Thompson <daniel.thompson@linaro.org>, Douglas Anderson <dianders@chromium.org>, Douglas Miller <dougmill@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

On 2022-05-18 17:49:50 [-0500], Eric W. Biederman wrote:
> 
> For ptrace_stop to work on PREEMT_RT no spinlocks can be taken once
> ptrace_freeze_traced has completed successfully.  Which fundamentally
> means the lock dance of dropping siglock and grabbing tasklist_lock does
> not work on PREEMPT_RT.  So I have worked through what is necessary so
> that tasklist_lock does not need to be grabbed in ptrace_stop after
> siglock is dropped.
…
It took me a while to realise that this is a follow-up I somehow assumed
that you added a few patches on top. Might have been the yesterday's
heat. b4 also refused to download this series because the v4 in this
thread looked newer… Anyway. Both series applied:

| =============================
| WARNING: suspicious RCU usage
| 5.18.0-rc7+ #16 Not tainted
| -----------------------------
| include/linux/ptrace.h:120 suspicious rcu_dereference_check() usage!
|
| other info that might help us debug this:
|
| rcu_scheduler_active = 2, debug_locks = 1
| 2 locks held by ssdd/1734:
|  #0: ffff88800eaa6918 (&sighand->siglock){....}-{2:2}, at: lock_parents_siglocks+0xf0/0x3b0
|  #1: ffff88800eaa71d8 (&sighand->siglock/2){....}-{2:2}, at: lock_parents_siglocks+0x115/0x3b0
|
| stack backtrace:
| CPU: 2 PID: 1734 Comm: ssdd Not tainted 5.18.0-rc7+ #16
| Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS 1.16.0-debian-1.16.0-4 04/01/2014
| Call Trace:
|  <TASK>
|  dump_stack_lvl+0x45/0x5a
|  unlock_parents_siglocks+0xb6/0xc0
|  ptrace_stop+0xb9/0x390
|  get_signal+0x51c/0x8d0
|  arch_do_signal_or_restart+0x31/0x750
|  exit_to_user_mode_prepare+0x157/0x220
|  irqentry_exit_to_user_mode+0x5/0x50
|  asm_sysvec_apic_timer_interrupt+0x12/0x20

That is ptrace_parent() in unlock_parents_siglocks().

Sebastian
