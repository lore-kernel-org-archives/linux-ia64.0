From: Keith Owens <kaos@sgi.com>
Date: Wed, 17 Aug 2005 05:37:11 +0000
Subject: [Review 0/7] New MCA/INIT handlers
Message-Id: <7530.1124257031@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patches in the following mails are a signifcant rewrite of the
MCA/INIT handlers.  At this stage they are for review, not for
inclusion in the ia64 tree.

Some background might be useful.  The current MCA/INIT handlers have
several shortcomings :-

(1) Only one MCA stack, so we cannot handle concurrent MCA on multiple
    cpus.

(2) Only one INIT stack, for the monarch.  Slave INIT events never get
    into the C code, which gives no data for the slave processes.

(3) The lack of slave INIT processing also means that some MCA events
    that could normally be recovered may turn into fatal events.  If
    one or more cpus are spinning disabled when an MCA occurs then SAL
    will eventually hit the disabled cpus with a slave INIT event.
    Even if the MCA is recoverable (e.g. DBE in user space), the cpus
    that were hit by INIT are now dead, which makes MCA recovery
    pointless.

(4) A monarch INIT event assumes that it can use the existing stack.
    If the INIT was delivered while the cpu was in physical mode then
    the OS monarch handler gets a recursive error.  Ditto if the kernel
    stack has overflowed.

(5) MCA and INIT stacks are completely non-standard.  You cannot get a
    backtrace nor debug the MCA/INIT handlers.  We even have a special
    entry point in the unwind code just for MCA/INIT.  Only the kernel
    knows about that unwind routine, external code such as libunwind
    does not.

(6) The current code relies on getting data from the MCA/INIT record.
    If we hang trying to retrieve that record then we get no useful
    data.  A side effect of using the MCA/INIT record is that we may
    read a record from an earlier event, it may not have been cleared
    when a second event occurs.

(7) Some horrible assembler code in minstate.h, to handle both the
    normal stacks and the non-standard MCA/INIT stacks.

(8) Only one copy of the SAL to OS state, which prevents multiple cpus
    from returning to SAL.

My MCA/INIT rewrite addresses these problems by :-

(1) Using per cpu MCA stacks.

(2) Using per cpu INIT stacks.

(3) Using a common code path for both monarch and slave INIT events,
    passing in a flag to indicate if the event is monarch or slave.

(4) Neither MCA nor INIT will use any part of the current stack until
    they have verified that it is safe to do so.

(5) MCA/INIT stacks look like normal process stacks.  I can even get a
    backtrace through the MCA/INIT handlers :).  This removes the need
    for the special unwind routine.

(6) All data is obtained from PAL/SAL data areas.  There is no need to
    call SAL to get the record, and the problem of stale data goes
    away.

(7) minstate.h is now all virtual mode code.

(8) Each cpu gets its own copy of the SAL to OS state.


The original plan was to treat an MCA/INIT as an interrupt that
switched stacks, even if a cpu was already using a kernel stack.
However that caused problems with the notion of "current", mainly
because the task structure is stored in the stack area.  Separating the
task structure from the rest of the stack was vetoed on performance
grounds, it would require extra TLB entries.  This plan would also have
required changes to unwinders, both in the kernel and in external
packages such as lcrash.

Plan B involves switching to the MCA/INIT stacks, making them look like
normal processes with no dependency on data in other stacks.  The
process that was running at the time of MCA/INIT is converted to look
like a sleeping task, complete with its state at the time of interrupt.
The MCA/INIT stack has a pointer to the interrupted task; in addition
the pid of the interrupted task is placed in the 'comm' field of the
MCA/INIT process for humans to read.  This approach does not require
extra TLBs and it works with the existing unwind code.  The only
downside is that it requires two small hooks in the scheduler code to
adjust the scheduler's notion of "this process is on this cpu".

The following 7 patches contain :-

1) Scheduler hooks to change which process is deemed to be on a cpu.

2) Add an extra thread_info flag to indicate the special MCA/INIT
   stacks.  Mainly for debuggers.

3) The bulk of the change.  Use per cpu MCA/INIT stacks.  Change the
   SAL to OS state (sos) to be per process.  Do all the assembler work
   on the MCA/INIT stacks, leaving the original stack alone.  Pass per
   cpu state data to the C handlers for MCA and INIT, which also means
   changing the mca_drv interfaces slightly.  Lots of verification on
   whether the original stack is usable before converting it to a
   sleeping process.

4) Remove the physical mode path from minstate.h.

5) Align the stack for the initial task to be the same alignment as all
   other process stacks.  Otherwise the validation code needs special
   cases for the intial task, it is currently only page aligned.

6) Delete the special case unwind code that was only used by the old
   MCA/INIT handler.

7) Turn off PAL halt.  For some reason, INIT that is delivered while
   the cpu is in PAL halt gets corrupt registers on return from the
   INIT handler.  I am still investigating this, for now skip the PAL
   halt.

Patches are against 2.6.12-rc4, but they should fit rc6.


TODO:

Although we could theoretically handle concurrent MCA with these
patches, MCA is still single threaded by ia64_mca_serialize.  It is not
clear what our model should be for handling concurrent MCA on multiple
cpus, some discussion is required first.

Not all state is preserved over MCA/INIT and the return to the previous
task.  In particular the interrupt registers are not preserved.  No big
deal, it is just a matter of verifying the save/restore state of every
register.  This should be fixed in the next iteration.

Now that MCA/INIT is recoverable, we will have to address the SCSI
timeouts that occur if interrupts are disabled for long periods.  MCA
can disable interrupts for up to 20 seconds while it does the
rendezvous.  On resume, the timer code tries to bring jiffies in sync
with itc, time runs too fast and we get spurious timeouts.  There is no
point in recovering from MCA if the disk dies as a side effect of the
lost interrupts.

