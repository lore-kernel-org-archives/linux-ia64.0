From: Keith Owens <kaos@sgi.com>
Date: Mon, 12 Sep 2005 04:39:33 +0000
Subject: Re: git pull on ia64 linux tree
Message-Id: <6727.1126499973@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 11 Sep 2005 20:37:07 -0700 (PDT),
Linus Torvalds <torvalds@osdl.org> wrote:
LT>I don't think ia64 people realize how _wrong_ it is to just switch ->curr
LT>around. It doesn't matter if you "set it back" when the MCA ends: it may
LT>look atomic wrt _that_ CPU, but you're doing things that are fundamentally
LT>illegal.
LT>
LT>For example, if one CPU starts messing around with cpu_curr() on that CPU,
LT>another CPU may be doing "task_rq_lock()" on a task that is currently
LT>running on that CPU.
LT>
LT>THAT CPU MUST NOT CHANGE THE "current process" WITHOUT GETTING THE
LT>RUNQUEUE LOCK! Other CPU's are looking at it, and the scheduler uses
LT>rq->curr to decide whether to wake stuff up or not etc.

Or does something that stops the scheduler running on other cpus, which
ia64 does.  You are probably unaware that MCA/INIT cause the _entire_
system to rendezvous.  All cpus are driven into MCA/INIT code, not just
the current cpu.  So the scheduler cannot run on any cpu during
MCA/INIT.

LT>In other words, anybody who changes rq->curr without getting the lock IS
LT>BUGGY.

MCA/INIT are completely asynchronous.  They can occur at any time, when
the OS is in any state.  Including when one of the cpus is already
holding the runqueue lock.  Trying to get any lock from MCA/INIT state
is asking for deadlock.

LT>Unless somebody can convince me otherwise (and quite frankly, I doubt you
LT>can) I'm going to remove at _least_ the function that writes ->curr
LT>(set_curr_task()) tomorrow.

Removing set_curr_task() means that we cannot get decent backtraces for
all tasks during MCA/INIT.  There is no point in having an architecture
that can recover from some hardware errors, if the backtraces are no
good.

Let's see if I can explain the strange ia64 MCA process.  All of this
is mandated by Intel's specification for ia64 SAL, error recovery and
and unwind, it is not as if we have a choice here.

* MCA occurs on one cpu, usually due to a double bit memory error.
  This is the monarch cpu.

* SAL sends an MCA rendezvous interrupt (which is a normal interrupt)
  to all the other cpus, the slaves.

* Slave cpus that receive the MCA interrupt call down into SAL, they
  end up spinning disabled while the MCA is being serviced.

* If any slave cpu was already spinning disabled when the MCA occurred
  then it cannot service the MCA interrupt.  SAL waits ~20 seconds then
  sends an unmaskable INIT event to the slave cpus that have not
  already rendezvoused.

* Because MCA/INIT can be delivered at any time, including when the cpu
  is down in PAL in physical mode, the registers at the time of the
  event are _completely_ undefined.  In particular the MCA/INIT
  handlers cannot rely on the thread pointer, PAL physical mode can
  (and does) modify TP.  It is allowed to do that as long as it resets
  TP on return.  However MCA/INIT events expose us to these PAL
  internal TP changes.  Hence curr_task().

* If an MCA/INIT event occurs while the kernel was running (not user
  space) and the kernel has called PAL then the MCA/INIT handler cannot
  assume that the kernel stack is in a fit state to be used.  Mainly
  because PAL may or may not maintain the stack pointer internally.
  Because the MCA/INIT handlers cannot trust the kernel stack, they
  have to use their own, per-cpu stacks.

* Once all slaves have rendezvoused and are spinning disabled, the
  monarch is entered.  The monarch now tries to diagnose the problem
  and decide if it can recover or not.

* Part of the monarch's job is to look at the state of all the other
  tasks.  The only way to do that on ia64 is to call the unwinder,
  as mandated by Intel.

* The starting point for the unwind depends on whether a task is
  running or not.  That is, whether it is on a cpu or is blocked.  The
  monarch has to determine whether or not a task is on a cpu before it
  knows how to start unwinding it.  The tasks that received an MCA or
  INIT event are no longer running, they have been converted to blocked
  tasks.  But (and its a big but), the cpus that received the MCA
  rendezvous interrupt are still running on their normal kernel stacks!

* To distinguish between these two cases, the monarch must know which
  tasks are on a cpu and which are not.  Hence each slave cpu that
  switches to an MCA/INIT stack, registers its new stack using
  set_curr_task(), so the monarch can tell that the _original_ task is
  no longer running on that cpu.  That gives us a decent chance of
  getting a valid backtrace of the _original_ task.

* MCA/INIT can be nested, to a depth of 2 on any cpu.  In the case of a
  nested error, we want diagnostics on the MCA/INIT handler that
  failed, not on the task that was originally running.  Again this
  requires set_curr_task() so the MCA/INIT handlers can register their
  own stack as running on that cpu.  Then a recursive error gets a
  trace of the failing handler's "task".

I agree that the scheduler hooks are layer violations.  Unfortunately
MCA/INIT start off as massive layer violations (can occur at _any_
time) and they build from there.

At least ia64 makes an attempt at recovering from hardware errors, but
it is a difficult problem because of the asynchronous nature of these
errors.  When processing an unmaskable interrupt we sometimes need
special code to cope with our inability to take any locks.

LT>Everything Keith says about MCA/INIT is true on x86 about NMI's. That has
LT>nothing to do with "currently runnable process". And it sure as hell
LT>doesn't mean that you'd _change_ the kernel notion of what the currently
LT>runnable process is.

Wrong.  x86 NMI typically gets delivered to one cpu, MCA/INIT gets sent
to all cpus.  x86 NMI cannot be nested, MCA/INIT can.  x86 has a
separate struct task which points to one of multiple kernel stacks,
ia64 has the struct task embedded in the single kernel stack[1].  x86
does not call the BIOS so the NMI handler does not have to worry about
any registers having changed, ia64 MCA/INIT can occur while the cpu is
in PAL in physical mode, with undefined registers and an undefined
kernel stack.  i386 backtrace is not very sensitive to whether a
process is running or not, ia64 unwind is very, very sensitive to
whether a process is running or not.

[1] My original design called for ia64 to separate its struct task and
    the kernel stacks.  Then the MCA/INIT data would be chained stacks
    like i386 interrupt stacks.  But that required radical surgery on
    the rest of ia64, plus extra hard wired TLB entries with its
    associated performance degradation.  David Mosberger vetoed that
    approach.  Which meant separate "tasks" for the MCA/INIT handlers.

