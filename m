From: Erich Focht <focht@ess.nec.de>
Date: Mon, 01 Oct 2001 17:26:15 +0000
Subject: [Linux-ia64] deadlock in crashed multithreaded job
Message-Id: <marc-linux-ia64-105590698805280@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

During the testing of the FFTW library (www.fftw.org) in multithreaded
mode I am regularly getting strange lock-ups on Itanium LION (4CPU)
and NEC AzusA (16CPU) systems. Anyway, I don't think this is IA64
specific...

The symptoms: running the tests (make check) sometimes ends up with
hanging processes. Reading from some of the /proc/pid/* files also
lead to hangs (top & ps just don't return). The processes cannot be
killed either.

As far as I understand, the program crashes while one of the threads
(#1) tries to get a write lock on mm->mmap_sem. Another thread (#2)
starts dumping core and gets a read lock in the mean time (before
thread #1). The write lock request gets queued and a subsequent
read lock request by thread #2 happening somewhere in the call tree of
coredump (in access_process_vm) cannot be satisfied. The two threads
wait forever and attempts to access their mm structure end up in the
same deadlock.

The tracebacks obtained by kdb vary from case to case a bit but I
basically see:

#1 : schedule <- __down_write <- sys_mmap <- ia64_ret_from_syscall

#2: schedule <- __down_read <- access_process_vm <- ia64_sync_user_rbs
    <- do_copy_regs <- unw_init_running <- load_script <- do_coredump
    <- ia64_do_signal <- handle_signal_delivery <- ia64_leave_kernel

others... : either already gone or somewhere in do_exit or
    sys_rt_sigsuspend, unimportant anyway...


I'm not really curious to debug the FFTW or pthreads libraries but
don't think that user program should lead to such deadlocks in the
kernel. So maybe one can fix this problem in the kernel...

I guess the problem is the nesting of critical sections, in this case
a critical section is defined in fs/exec.c:do_coredump and in
kernel/ptrace.c:access_process_vm. Getting rid of this kind of nesting
is quite tedious, so maybe one should deal with the nested critical
sections. A solution would be: The read lock request (down_read)
should be immediately granted if the current thread already owns the
lock. So maybe each task should remember the locks it owns, maybe in a
list accessible through the task structure.

I'm curious about your oppinions. Maybe there is already a way to deal
with this kind of problem?

Best regards,
Erich

---
Erich Focht                                    <efocht@ess.nec.de>
NEC European Supercomputer Systems, European HPC Technology Center



