From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Wed, 18 May 2022 22:49:50 +0000
Subject: [PATCH 00/16] ptrace: cleanups and calling do_cldstop with only siglock
Message-Id: <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220421150248.667412396@infradead.org>
        <20220421150654.817117821@infradead.org>
        <87czhap9dy.fsf@email.froward.int.ebiederm.org>
        <878rrrh32q.fsf_-_@email.froward.int.ebiederm.org>
        <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
        <87k0b0apne.fsf_-_@email.froward.int.ebiederm.org>
        <87a6bv6dl6.fsf_-_@email.froward.int.ebiederm.org>
In-Reply-To: <87a6bv6dl6.fsf_-_@email.froward.int.ebiederm.org> (Eric
        W. Biederman's message of "Thu, 05 May 2022 13:25:57 -0500")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: rjw@rjwysocki.net, oleg@redhat.com, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>, linux-ia64@vger.kernel.org, Robert O'Callahan <roc@pernos.co>, Kyle Huey <khuey@pernos.co>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Jason Wessel <jason.wessel@windriver.com>, Daniel Thompson <daniel.thompson@linaro.org>, Douglas Anderson <dianders@chromium.org>, Douglas Miller <dougmill@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>


For ptrace_stop to work on PREEMT_RT no spinlocks can be taken once
ptrace_freeze_traced has completed successfully.  Which fundamentally
means the lock dance of dropping siglock and grabbing tasklist_lock does
not work on PREEMPT_RT.  So I have worked through what is necessary so
that tasklist_lock does not need to be grabbed in ptrace_stop after
siglock is dropped.

I have explored several alternate ways of getting there and along the
way I found a lot of small bug fixes/cleanups that don't necessarily
contribute to the final result but that or worthwhile on their own.  So
I have included those changes in this set of changes just so they don't
get lost.

In addition I had a conversation with Thomas Gleixner recently that
emphasized for me the need to reduce the hold times of tasklist_lock,
and that made me realize that in principle it is possible.
https://lkml.kernel.org/r/87mtfmhap2.fsf@email.froward.int.ebiederm.org

Which is a long way of saying that not taking tasklist_lock in
ptrace_stop is good not just for PREMPT_RT but also for improving the
scalability of the kernel in general.

After this set of changes only cgroup_enter_frozen should remain a
stumbling block for PREEMPT_RT in the ptrace_stop path.

Eric W. Biederman (16):
      signal/alpha: Remove unused definition of TASK_REAL_PARENT
      signal/ia64: Remove unused definition of IA64_TASK_REAL_PARENT_OFFSET
      kdb: Use real_parent when displaying a list of processes
      powerpc/xmon:  Use real_parent when displaying a list of processes
      ptrace: Remove dead code from __ptrace_detach
      ptrace: Remove unnecessary locking in ptrace_(get|set)siginfo
      signal: Wake up the designated parent
      ptrace: Only populate last_siginfo from ptrace
      ptrace: In ptrace_setsiginfo deal with invalid si_signo
      ptrace: In ptrace_signal look at what the debugger did with siginfo
      ptrace: Use si_sino as the signal number to resume with
      ptrace: Stop protecting ptrace_set_signr with tasklist_lock
      ptrace: Document why ptrace_setoptions does not need a lock
      signal: Protect parent child relationships by childs siglock
      ptrace: Use siglock instead of tasklist_lock in ptrace_check_attach
      signal: Always call do_notify_parent_cldstop with siglock held

 arch/alpha/kernel/asm-offsets.c |   1 -
 arch/ia64/kernel/asm-offsets.c  |   1 -
 arch/powerpc/xmon/xmon.c        |   2 +-
 kernel/debug/kdb/kdb_main.c     |   2 +-
 kernel/exit.c                   |  23 +++-
 kernel/fork.c                   |  12 +-
 kernel/ptrace.c                 | 132 ++++++++----------
 kernel/signal.c                 | 296 ++++++++++++++++++++++++++--------------
 8 files changed, 279 insertions(+), 190 deletions(-)

Eric
