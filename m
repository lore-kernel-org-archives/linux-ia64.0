From: Keith Owens <kaos@sgi.com>
Date: Tue, 09 Mar 2004 00:50:56 +0000
Subject: 2.6 unwind problem in kernel/sched.c
Message-Id: <3398.1078793456@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

2.6.4-rc2, gcc 3.2.3, binutils 2.14.90.0.4.

kernel/sched.c does schedule() -> context_switch() -> switch_to()
followed by finish_task_switch().  finish_task_switch() calls
finish_arch_switch() which enables interrupts.  If there is an
interrupt pending, that interrupt runs at schedule+0x1090 (ssm).

At this point we are running on the new stack but cr_iip points into
schedule() so the unwinder uses schedule's unwind data (b0, ar.pfs in
r60, r61).  r60 and r61 are loaded from bsp on the new stack, they are
completely wrong and the unwind is useless.

kdb bt with unw_debug_level 6.  In this case the incorrect values for
b0 and ar.pfs ended up pointing at skip_rbs_switch.  That caused a loop
between skip_rbs_switch and schedule+0x1010, eventually psp <- psp+0x10
ran off the top of the stack and unwind aborted after about 60 useless
unwind entries.


0xa000000100014030 ia64_handle_irq+0xb0
        args (0x0, 0xe000023010d5fc60, 0x0, 0xfd, 0xa00000010000df20)
        sp 0xe000023010d5fc50 bsp 0xe000023010d59080 cfm 0x0000000000000308
unwind.build_script: ip 0xa00000010000df20
unwind.desc_abi: interrupt frame
unwind.build_script: state record for func 0xa00000010000df20, t=0:
  ar.pfs <- [sp+0x60]           -1
  psp <- psp+0x1d0              -1
  rp <- [sp+0x58]               -1
  ar.unat <- [sp+0x68]          -1
  pr <- [sp+0x90]               -1
  ar.fpsr <- [sp+0xc0]          -1
0xa00000010000df20 ia64_leave_kernel
        args (0x0, 0xe000023010d5fc60)
        sp 0xe000023010d5fc50 bsp 0xe000023010d59080 cfm 0x0000000000000002
unwind.unw_unwind: interrupt_frame pt 0xe000023010d5fc60
unwind.build_script: ip 0xa0000001000bee70
unwind.build_script: state record for func 0xa0000001000bdde0, ty5:
  ar.pfs <- r61         0
  psp <- psp+0x10               1
  rp <- r60             5
0xa0000001000bee70 schedule+0x1090
        args (0x0, 0xe000023010d5fe40, 0x0, 0xfd, 0xa00000010000df20)
        sp 0xe000023010d5fe20 bsp 0xe000023010d58f68 cfm 0x8000000000000f22
unwind.build_script: ip 0xa00000010000e2c0
unwind.build_script: using default for rp at ip=0xa00000010000e2c0 where=3 val=0x0
unwind.build_script: state record for func 0xa00000010000e2c0, t=0:
  ar.pfs <- r38         0
  rp <- b0              -1
unwind.get_scratch_regs: sp 0xe000023010d5fe30 pt 0xe000023010d5fc60
0xa00000010000e2c0 skip_rbs_switch+0x80
        args (0x0, 0xe000023010d5fe40)
        sp 0xe000023010d5fe30 bsp 0xe000023010d58f68 cfm 0x0000000000000002
unwind.build_script: ip 0xa0000001000bedf0
unwind.build_script: state record for func 0xa0000001000bdde0, tw1:
  ar.pfs <- r61         0
  psp <- psp+0x10               1
  rp <- r60             5
0xa0000001000bedf0 schedule+0x1010
        args (0x0, 0xe000023010d5fe40)
        sp 0xe000023010d5fe30 bsp 0xe000023010d58f68 cfm 0x0000000000000002
unwind.build_script: ip 0xa00000010000e2c0
unwind.build_script: using default for rp at ip=0xa00000010000e2c0 where=3 val=0x0
unwind.build_script: state record for func 0xa00000010000e2c0, t=0:
  ar.pfs <- r38         0
  rp <- b0              -1
unwind.get_scratch_regs: sp 0xe000023010d5fe40 pt 0xe000023010d5fc60
0xa00000010000e2c0 skip_rbs_switch+0x80
        args (0x0, 0xe000023010d5fe40)


