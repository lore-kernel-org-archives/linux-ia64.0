From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 02 May 2008 09:27:44 +0000
Subject: [BUG?][2.6.25-mm1] sleeping during IRQ disabled
Message-Id: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi

On ia64 2.6.25-mm1, below message is displayed at stress test running.
Is it bug or not?


---------------------------------------------
BUG: sleeping function called from invalid context at kernel/rwsem.c:21
in_atomic():0, irqs_disabled():1

Call Trace:
 [<a000000100015d00>] show_stack+0x80/0xa0
                                sp=E00001608577f840 bsp=E000016085771038
 [<a000000100015d50>] dump_stack+0x30/0x60
                                sp=E00001608577fa10 bsp=E000016085771020
 [<a000000100092e80>] __might_sleep+0x1e0/0x2e0
                                sp=E00001608577fa10 bsp=E000016085770ff0
 [<a000000100791f00>] down_read+0x20/0x60
                                sp=E00001608577fa10 bsp=E000016085770fd0
 [<a00000010015cd50>] access_process_vm+0x70/0x3a0
                                sp=E00001608577fa10 bsp=E000016085770f28
 [<a000000100030f60>] ia64_sync_kernel_rbs+0x40/0x100
                                sp=E00001608577fa20 bsp=E000016085770ef0
 [<a00000010002f640>] do_sync_rbs+0xc0/0x100
                                sp=E00001608577fa30 bsp=E000016085770ec0
 [<a00000010000b250>] unw_init_running+0x70/0xa0
                                sp=E00001608577fa40 bsp=E000016085770e98
 [<a000000100033ee0>] ia64_sync_krbs+0x80/0xa0
                                sp=E00001608577fe20 bsp=E000016085770e80
 [<a0000001000168a0>] do_notify_resume_user+0x1c0/0x1e0
                                sp=E00001608577fe20 bsp=E000016085770e50
 [<a00000010000b0e0>] notify_resume_user+0x40/0x60
                                sp=E00001608577fe20 bsp=E000016085770e00
 [<a00000010000b010>] skip_rbs_switch+0xe0/0x110
                                sp=E00001608577fe30 bsp=E000016085770e00
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=E000016085780000 bsp=E000016085770e0

