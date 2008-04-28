From: "stephane eranian" <eranian@googlemail.com>
Date: Mon, 28 Apr 2008 22:11:09 +0000
Subject: ia64_sync_krbs() may sleep with interrupts disabled
Message-Id: <7c86c4470804281511n6dc69999t6ffd366bd29e7b29@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello,

Here is another problem I ran into on 2.6.25

Although perfmon does rely on do_notify_resume_user(), it does not
fiddle with TIF_RESTORE_RSE. What it may cause however, is more
frequent calls to do_notify_resume_user() because perfmon does
piggyback its own flag (TIF_PERFMON_WORK) onto TIF_NOTIFY_RESUME.

In any case, executing the function triggers an assertion about sleeping wi=
th
interrupts disabled. Here is the call stack I am getting:

BUG: sleeping function called from invalid context at kernel/rwsem.c:21
in_atomic():0, irqs_disabled():1

Call Trace:
 [<a000000100012d60>] show_stack+0x40/0xa0
                                sp=E0000003ea02f840 bsp=E0000003ea028f10
 [<a000000100012df0>] dump_stack+0x30/0x60
                                sp=E0000003ea02fa10 bsp=E0000003ea028ef8
 [<a000000100064de0>] __might_sleep+0x1c0/0x1e0
                                sp=E0000003ea02fa10 bsp=E0000003ea028ed0
 [<a00000010050d1c0>] down_read+0x20/0x60
                                sp=E0000003ea02fa10 bsp=E0000003ea028eb0
 [<a0000001001093a0>] access_process_vm+0x60/0x2c0
                                sp=E0000003ea02fa10 bsp=E0000003ea028e20
 [<a0000001000148b0>] ia64_sync_kernel_rbs+0x30/0x100
                                sp=E0000003ea02fa20 bsp=E0000003ea028de0
 [<a000000100014fc0>] do_sync_rbs+0xc0/0x100
                                sp=E0000003ea02fa30 bsp=E0000003ea028db0
 [<a00000010000a8b0>] unw_init_running+0x70/0xa0
                                sp=E0000003ea02fa40 bsp=E0000003ea028d88
 [<a000000100018760>] ia64_sync_krbs+0x80/0xa0
                                sp=E0000003ea02fe20 bsp=E0000003ea028d70
 [<a000000100013800>] do_notify_resume_user+0x140/0x1a0
                                sp=E0000003ea02fe20 bsp=E0000003ea028d40
 [<a00000010000a740>] notify_resume_user+0x40/0x60
                                sp=E0000003ea02fe20 bsp=E0000003ea028cf0
 [<a00000010000a670>] skip_rbs_switch+0xe0/0x110
                                sp=E0000003ea02fe30 bsp=E0000003ea028cf0
 [<a000000000010720>] ia64_ivt+0xffffffff00010720/0x400
                                sp=E0000003ea030000 bsp=E0000003ea028cf0


Any ideas?
