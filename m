From: Keith Owens <kaos@sgi.com>
Date: Tue, 16 Apr 2002 23:56:28 +0000
Subject: [Linux-ia64] Re: unw_init_frame_info() and activation records
Message-Id: <marc-linux-ia64-105590701905465@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 16 Apr 2002 14:55:21 -0700, 
Piet/Pete Delaney <piet@sgi.com> wrote:
>The kdb code at least seems to support the NEW_UNWIND code by using 
>unw_init_frame_info().  You code mentions that it should be using activation 
>records and I was wondering what that's all about.

kdb for i386 uses an internal structure that holds the activation
information about each frame.  Some of the stack data is arch
independent, some is arch dependent, I would like to use a common
internal representation for kdb stack information across all
architectures so the common code is easier to maintain.

The activation record was my first attempt at abstracting stack info,
but it is too i386 specific.  One day I will do a better abstraction
method, for now kdb for each architecture handles its own stack
decoding.

>Perhaps you could take a few minutes and provide a few pointers on how
>to save time in adding unwind support.

For IA64, use the kernel unwind routines.  The main problem on ia64 was
to distinguish between functions that were running and functions that
were sleeping, they have different starting points for unwinding.
Detecting current is not enough, because you need to access current
tasks on other cpus.

Running tasks do not have a switch_stack structure, this structure is
required to prime the unwind code.  To ensure that all tasks have a
switch_stack, arch/ia64/kdb/kdbasupport.c::kdba_main_loop() is invoked
for each process that enters kdb, kdba_main_loop() calls
unw_init_running() to build switch_stack before continuing with the
rest of the kdb processing.

The primary kdb cpu tries to drive all the other cpus into kdb, which
will invoke kdba_main_loop() for the running process on each cpu and
set up a switch_stack.  This can fail if the other cpus are ignoring
interrupts.  Trying to backtrace a process in a disabled spin loop on
another cpu will not work with this method.

This is just one symptom of the larger problem that kdb cannot break
into disabled spin loops on ia64, even NMI is ignored.  IMNSHO the real
fix is to change the cli/sti code on ia64 so it does not mask NMI.
David Mosberger has rejected this for the standard kernel, but I intend
to add it as a debugging option for kdb on ia64.  I don't like changing
such low level routines, it makes a debugging kernel different from a
normal kernel.  But sometimes it is the only way to debug disabled spin
lock problems, so it will be an additional kdb option.


