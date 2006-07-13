From: Jay Lan <jlan@sgi.com>
Date: Thu, 13 Jul 2006 17:58:17 +0000
Subject: [BUG] running strace utility can cause system to hang at sys_ptrace
Message-Id: <44B689B9.3090902@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We ran into a system hang problem at sys_ptrace.

The system may hang if a user attempts to "strace" a pthreaded
application that is making frequent calls to pthread_create &
pthread_exit.
The hang is caused by a task sleeping (yield()) while holding the
tasklist_lock.

Note that the problem appears to exist ONLY on IA64. IA64 has an
ARCH-specific implementation of sys_ptrace().

The failing path is:

          sys_ptrace
            read_lock(&tasklist_lock);
               find_thread_for_addr(child, addr);
                 thread_matches(p, addr)
                   ptrace_check_attach(thread, 0)
                     wait_task_inactive(child);
                       yield();

Failures always show 1 task sleeping with the backtrace listed
above, plus tasks on all cpus spinning waiting to write_lock the
tasklist lock.

Sleeping
   Stack traceback for pid 31069
   0xe00000343b800000    31069    0    3   R  0xe00000343b8003a0 strace
   0xa000000100981c60 schedule+0x2460
   0xa00000010007d4d0 sys_sched_yield+0x110
   0xa000000100982120 yield+0x40
   0xa000000100082f10 wait_task_inactive+0x170
   0xa0000001000a2570 ptrace_check_attach+0x1d0
   0xa00000010002e9b0 sys_ptrace+0x1f0
   0xa00000010000c900 ia64_ret_from_syscall

CPU 0
   0xe00000343b5f0000     4973    0    3   C  0xe00000343b5f03a0  thdcrex
   0xa00000010000caa0 ia64_leave_kernel
   0xa00000010053d0a0 _raw_write_lock+0x120
   0xa0000001009854d0 _write_lock_irq+0x30
   0xa000000100093a00 do_exit+0xae0
   0xa000000100094560 sys_exit+0x20
   0xa00000010000c900 ia64_ret_from_syscall

CPU 1
   0xe000003038880000     4972    0    1   R  0xe0000030388803a0  thdcrex
   0xa00000010000caa0 ia64_leave_kernel
   0xa00000010053d0a0 _raw_write_lock+0x120
   0xa0000001009854d0 _write_lock_irq+0x30
   0xa0000001000880e0 copy_process+0x1f80
   0xa000000100088e30 do_fork+0x150
   0xa00000010000c160 sys_clone2+0x60
   0xa00000010000c900 ia64_ret_from_syscall


Regards,
  - jay
