From: Michael Di Domenico <mdidomenico4@gmail.com>
Date: Thu, 14 May 2009 14:25:58 +0000
Subject: soft lockups
Message-Id: <e75d22a90905140725s45cfa1c2n4487247c10051ba9@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I have a user application that seems to be soft locking the linux
kernel, in this case 2.6.18

Can anyone narrow down whether this is a bug in the linux kernel (and
perhaps if so, whether is was fixed in a later version) or not?

Or what this user application might have done to create this issue?

thanks
- Michael




BUG: soft lockup detected on CPU#33!

Call Trace:
 [<a000000100013b20>] show_stack+0x40/0xa0
                        sp=E00000ff000b73d0 bsp=E00000ff000b1818
 [<a000000100013bb0>] dump_stack+0x30/0x60
                        sp=E00000ff000b75a0 bsp=E00000ff000b1800
 [<a0000001000e5fe0>] softlockup_tick+0x240/0x280
                        sp=E00000ff000b75a0 bsp=E00000ff000b17b8
 [<a000000100092df0>] run_local_timers+0x30/0x60
                        sp=E00000ff000b75b0 bsp=E00000ff000b17a0
 [<a000000100092ea0>] update_process_times+0x80/0x100
                        sp=E00000ff000b75b0 bsp=E00000ff000b1770
 [<a000000100037220>] timer_interrupt+0x180/0x360
                        sp=E00000ff000b75b0 bsp=E00000ff000b1730
 [<a0000001000e6650>] handle_IRQ_event+0x90/0x120
                        sp=E00000ff000b75b0 bsp=E00000ff000b16f0
 [<a0000001000e6810>] __do_IRQ+0x130/0x420
                        sp=E00000ff000b75b0 bsp=E00000ff000b16a8
 [<a000000100011630>] ia64_handle_irq+0xf0/0x1a0
                        sp=E00000ff000b75b0 bsp=E00000ff000b1678
 [<a00000010000c020>] __ia64_leave_kernel+0x0/0x280
                        sp=E00000ff000b75b0 bsp=E00000ff000b1678
 [<a000000100626b90>] _spin_unlock_irqrestore+0x30/0x60
                        sp=E00000ff000b7780 bsp=E00000ff000b1660
 [<a0000001000989d0>] force_sig_info+0x130/0x160
                        sp=E00000ff000b7780 bsp=E00000ff000b1620
 [<a00000010003c620>] ia64_handle_unaligned+0x2d00/0x2d20
                        sp=E00000ff000b7780 bsp=E00000ff000b1580
 [<a00000010000c630>] ia64_prepare_handle_unaligned+0x30/0x60
                        sp=E00000ff000b7970 bsp=E00000ff000b1580
 [<a00000010000c020>] __ia64_leave_kernel+0x0/0x280
                        sp=E00000ff000b7b80 bsp=E00000ff000b1580
 [<a0000001000b9150>] exit_robust_list+0x250/0x2e0
                        sp=E00000ff000b7d50 bsp=E00000ff000b1518
 [<a000000100081690>] do_exit+0x510/0x14a0
                        sp=E00000ff000b7d60 bsp=E00000ff000b14c0
 [<a000000100082770>] do_group_exit+0x150/0x160
                        sp=E00000ff000b7d80 bsp=E00000ff000b1488
 [<a000000100099a00>] get_signal_to_deliver+0x740/0x7c0
                        sp=E00000ff000b7d80 bsp=E00000ff000b1438
 [<a0000001000341d0>] ia64_do_signal+0x90/0xde0
                        sp=E00000ff000b7d80 bsp=E00000ff000b1350
 [<a0000001000139a0>] do_notify_resume_user+0x100/0x160
                        sp=E00000ff000b7e20 bsp=E00000ff000b1320
 [<a00000010000c500>] notify_resume_user+0x40/0x60
                        sp=E00000ff000b7e20 bsp=E00000ff000b12d0
 [<a00000010000c430>] skip_rbs_switch+0xe0/0x110
                        sp=E00000ff000b7e30 bsp=E00000ff000b12d0

BUG: soft lockup detected on CPU#72!

Call Trace:
 [<a000000100013b20>] show_stack+0x40/0xa0
                        sp=E00000fbe5e3f3d0 bsp=E00000fbe5e39830
 [<a000000100013bb0>] dump_stack+0x30/0x60
                        sp=E00000fbe5e3f5a0 bsp=E00000fbe5e39818
 [<a0000001000e5fe0>] softlockup_tick+0x240/0x280
                        sp=E00000fbe5e3f5a0 bsp=E00000fbe5e397d0
 [<a000000100092df0>] run_local_timers+0x30/0x60
                        sp=E00000fbe5e3f5b0 bsp=E00000fbe5e397b8
 [<a000000100092ea0>] update_process_times+0x80/0x100
                        sp=E00000fbe5e3f5b0 bsp=E00000fbe5e39788
 [<a000000100037220>] timer_interrupt+0x180/0x360
                        sp=E00000fbe5e3f5b0 bsp=E00000fbe5e39748
 [<a0000001000e6650>] handle_IRQ_event+0x90/0x120
                        sp=E00000fbe5e3f5b0 bsp=E00000fbe5e39708
 [<a0000001000e6810>] __do_IRQ+0x130/0x420
                        sp=E00000fbe5e3f5b0 bsp=E00000fbe5e396c0
 [<a000000100011630>] ia64_handle_irq+0xf0/0x1a0
                        sp=E00000fbe5e3f5b0 bsp=E00000fbe5e39690
 [<a00000010000c020>] __ia64_leave_kernel+0x0/0x280
                        sp=E00000fbe5e3f5b0 bsp=E00000fbe5e39690
 [<a000000100009100>] ia64_spinlock_contention+0x20/0x60
                        sp=E00000fbe5e3f780 bsp=E00000fbe5e39690
 [<a000000100626a20>] _spin_lock_irqsave+0x60/0x80
                        sp=E00000fbe5e3f780 bsp=E00000fbe5e39688
 [<a0000001000988d0>] force_sig_info+0x30/0x160
                        sp=E00000fbe5e3f780 bsp=E00000fbe5e39648
 [<a00000010003c620>] ia64_handle_unaligned+0x2d00/0x2d20
                        sp=E00000fbe5e3f780 bsp=E00000fbe5e395a8
 [<a00000010000c630>] ia64_prepare_handle_unaligned+0x30/0x60
                        sp=E00000fbe5e3f970 bsp=E00000fbe5e395a8
 [<a00000010000c020>] __ia64_leave_kernel+0x0/0x280
                        sp=E00000fbe5e3fb80 bsp=E00000fbe5e395a8
 [<a0000001000b4ff0>] handle_futex_death+0x90/0x1a0
                        sp=E00000fbe5e3fd50 bsp=E00000fbe5e39568
 [<a0000001000b90f0>] exit_robust_list+0x1f0/0x2e0
                        sp=E00000fbe5e3fd50 bsp=E00000fbe5e39518
 [<a000000100081690>] do_exit+0x510/0x14a0
                        sp=E00000fbe5e3fd60 bsp=E00000fbe5e394c0
 [<a000000100082770>] do_group_exit+0x150/0x160
                        sp=E00000fbe5e3fd80 bsp=E00000fbe5e39488
 [<a000000100099a00>] get_signal_to_deliver+0x740/0x7c0
                        sp=E00000fbe5e3fd80 bsp=E00000fbe5e39438
 [<a0000001000341d0>] ia64_do_signal+0x90/0xde0
                        sp=E00000fbe5e3fd80 bsp=E00000fbe5e39350
 [<a0000001000139a0>] do_notify_resume_user+0x100/0x160
                        sp=E00000fbe5e3fe20 bsp=E00000fbe5e39320
 [<a00000010000c500>] notify_resume_user+0x40/0x60
                        sp=E00000fbe5e3fe20 bsp=E00000fbe5e392d0
 [<a00000010000c430>] skip_rbs_switch+0xe0/0x110
                        sp=E00000fbe5e3fe30 bsp=E00000fbe5e392d0

BUG: soft lockup detected on CPU#104!

Call Trace:
 [<a000000100013b20>] show_stack+0x40/0xa0
                        sp=E00000fc4b03f7d0 bsp=E00000fc4b039730
 [<a000000100013bb0>] dump_stack+0x30/0x60
                        sp=E00000fc4b03f9a0 bsp=E00000fc4b039718
 [<a0000001000e5fe0>] softlockup_tick+0x240/0x280
                        sp=E00000fc4b03f9a0 bsp=E00000fc4b0396d8
 [<a000000100092df0>] run_local_timers+0x30/0x60
                        sp=E00000fc4b03f9b0 bsp=E00000fc4b0396c0
 [<a000000100092ea0>] update_process_times+0x80/0x100
                        sp=E00000fc4b03f9b0 bsp=E00000fc4b039690
 [<a000000100037220>] timer_interrupt+0x180/0x360
                        sp=E00000fc4b03f9b0 bsp=E00000fc4b039650
 [<a0000001000e6650>] handle_IRQ_event+0x90/0x120
                        sp=E00000fc4b03f9b0 bsp=E00000fc4b039610
 [<a0000001000e6810>] __do_IRQ+0x130/0x420
                        sp=E00000fc4b03f9b0 bsp=E00000fc4b0395c0
 [<a000000100011630>] ia64_handle_irq+0xf0/0x1a0
                        sp=E00000fc4b03f9b0 bsp=E00000fc4b039590
 [<a00000010000c020>] __ia64_leave_kernel+0x0/0x280
                        sp=E00000fc4b03f9b0 bsp=E00000fc4b039590
 [<a000000100004ac0>] dispatch_unaligned_handler+0x2a0/0x400
                        sp=E00000fc4b03fb80 bsp=E00000fc4b039580
 [<a0000001000b90f0>] exit_robust_list+0x1f0/0x2e0
                        sp=E00000fc4b03fb80 bsp=E00000fc4b039530
