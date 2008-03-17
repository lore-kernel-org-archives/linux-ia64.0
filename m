From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 17 Mar 2008 23:43:12 +0000
Subject: Re: [2.6.25-rc5-mm1][regression] ia64: hackbench doesn't finish >12 hour
Message-Id: <20080318083917.FF0C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080317204810.7B4F.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1FE6DD409037234FAB833C420AA843ECD410F3@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843ECD410F3@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Luck, Tony" <tony.luck@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-ia64@vger.kernel.org, "Yu, Fenghua" <fenghua.yu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

Hi Tony-san,

Thank you for quick responce.

> > 2.6.25-rc5:     works well
> > 2.6.25-rc5-mm1: doesn't finish >12 hour
>=20
> How long does hackbench take to complete on 2.6.25-rc5?
> Does -mm1 hang completely?  Or is it making slow progress?

2.6.25-rc5: about 200sec
-mm1: super heavy soft lockup happend.
      I cut & paste console message to tail of this mail.


> > Could you please revert that patch from ia64?
>=20
> I'll revert it while I investigate the cause of this
> problem and try to find a way to avoid this problem.
>=20
> > I dislike its strong regression.
>=20
> Me too!

Thank you very much!


----------------------------------------------------------
2.6.25-rc5-mm1 spinlock lockup

Starting Avahi daemon... [  OK  ]
Starting HAL daemon: [  OK  ]
Starting smartd: [  OK  ]

Red Hat Enterprise Linux Server release 5.1 (Tikanga)
Kernel 2.6.25-rc5-mm1 on an ia64

PQ-muneda login: BUG: spinlock lockup on CPU#1, hackbench/12693, e0000040c4=
5b1950

Call Trace:
 [<a000000100015f20>] show_stack+0x80/0xa0
                                sp=E0000160369ff950 bsp=E0000160369f1560
 [<a000000100015f70>] dump_stack+0x30/0x60
                                sp=E0000160369ffb20 bsp=E0000160369f1548
 [<a000000100462960>] _raw_spin_lock+0x2e0/0x300
                                sp=E0000160369ffb20 bsp=E0000160369f14f0
 [<a0000001008290e0>] _spin_lock+0x20/0x40
                                sp=E0000160369ffb20 bsp=E0000160369f14d0
 [<a00000010014b2e0>] page_lock_anon_vma+0x80/0xa0
                                sp=E0000160369ffb20 bsp=E0000160369f14a8
 [<a00000010014da60>] page_referenced+0x180/0x340
                                sp=E0000160369ffb20 bsp=E0000160369f1460
 [<a00000010012bd00>] shrink_active_list+0x9e0/0xe80
                                sp=E0000160369ffb30 bsp=E0000160369f13b8
 [<a00000010012e460>] shrink_zone+0x220/0x260
                                sp=E0000160369ffbf0 bsp=E0000160369f1368
 [<a0000001001300f0>] try_to_free_pages+0x590/0x900
                                sp=E0000160369ffbf0 bsp=E0000160369f1290
 [<a000000100120500>] __alloc_pages_internal+0x4a0/0x860
                                sp=E0000160369ffc30 bsp=E0000160369f11d8
 [<a000000100120950>] __alloc_pages+0x30/0x60
                                sp=E0000160369ffc40 bsp=E0000160369f11a8
BUG: spinlock lockup on CPU#3, hackbench/12705, a04000000013abd0

Call Trace:
 [<a000000100015f20>] show_stack+0x80/0xa0
                                sp=E00001603727f940 bsp=E000016037271588
 [<a000000100015f70>] dump_stack+0x30/0x60
                                sp=E00001603727fb10 bsp=E000016037271570
 [<a000000100462960>] _raw_spin_lock+0x2e0/0x300
                                sp=E00001603727fb10 bsp=E000016037271518
 [<a0000001008290e0>] _spin_lock+0x20/0x40
                                sp=E00001603727fb10 bsp=E0000160372714f8
 [<a00000010014b470>] page_check_address+0x170/0x200
                                sp=E00001603727fb10 bsp=E0000160372714b8
 [<a00000010014b680>] page_referenced_one+0xa0/0x2c0
                                sp=E00001603727fb10 bsp=E000016037271478
 [<a00000010014db10>] page_referenced+0x230/0x340
                                sp=E00001603727fb20 bsp=E000016037271430
 [<a00000010012bd00>] shrink_active_list+0x9e0/0xe80
                                sp=E00001603727fb30 bsp=E000016037271388
 [<a00000010012e460>] shrink_zone+0x220/0x260
                                sp=E00001603727fbf0 bsp=E000016037271338
 [<a0000001001300f0>] try_to_free_pages+0x590/0x900
                                sp=E00001603727fbf0 bsp=E000016037271260
 [<a000000100120500>] __alloc_pages_internal+0x4a0/0x860
                                sp=E00001603727fc30 bsp=E0000160372711a8
 [<a000000100120950>] __alloc_pages+0x30/0x60
                                sp=E00001603727fc40 bsp=E000016037271178
 [<a0000001001714e0>] kmem_getpages+0x120/0x2a0
                                sp=E00001603727fc40 bsp=E000016037271130
 [<a000000100172480>] fallback_alloc+0x320/0x440
                                sp=E00001603727fc40 bsp=E0000160372710a8
 [<a0000001001726b0>] ____cache_alloc_node+0x110/0x300
                                sp=E00001603727fc40 bsp=E000016037271028
 [<a000000100171770>] kmem_cache_alloc_node+0x110/0x3c0
                                sp=E00001603727fc40 bsp=E000016037270fe0
 [<a0000001006ea210>] __alloc_skb+0x70/0x280
                                sp=E00001603727fc40 bsp=E000016037270f98
 [<a0000001006df480>] sock_alloc_send_skb+0x400/0x560
                                sp=E00001603727fc40 bsp=E000016037270f28
 [<a0000001007e7930>] unix_stream_sendmsg+0x3b0/0x780
                                sp=E00001603727fc70 bsp=E000016037270e68
 [<a0000001006d7e80>] sock_aio_write+0x260/0x2a0
                                sp=E00001603727fca0 bsp=E000016037270e28
 [<a0000001001817b0>] do_sync_write+0x170/0x260
                                sp=E00001603727fd20 bsp=E000016037270dd0
 [<a000000100182f70>] vfs_write+0x310/0x320
                                sp=E00001603727fe20 bsp=E000016037270d80
 [<a000000100183ad0>] sys_write+0x70/0xe0
                                sp=E00001603727fe20 bsp=E000016037270d08
 [<a00000010000aa40>] ia64_ret_from_syscall+0x0/0x20
                                sp=E00001603727fe30 bsp=E000016037270d08
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=E000016037280000 bsp=E000016037270d08
 [<a0000001001714e0>] kmem_getpages+0x120/0x2a0
                                sp=E0000160369ffc40 bsp=E0000160369f1160
 [<a000000100172480>] fallback_alloc+0x320/0x440
                                sp=E0000160369ffc40 bsp=E0000160369f10d8
 [<a0000001001726b0>] ____cache_alloc_node+0x110/0x300
                                sp=E0000160369ffc40 bsp=E0000160369f1058
 [<a000000100171770>] kmem_cache_alloc_node+0x110/0x3c0
                                sp=E0000160369ffc40 bsp=E0000160369f1018
 [<a000000100171a80>] __kmalloc_node+0x60/0xa0
                                sp=E0000160369ffc40 bsp=E0000160369f0fe0
 [<a0000001006ea250>] __alloc_skb+0xb0/0x280
                                sp=E0000160369ffc40 bsp=E0000160369f0f98
 [<a0000001006df480>] sock_alloc_send_skb+0x400/0x560
                                sp=E0000160369ffc40 bsp=E0000160369f0f28
 [<a0000001007e7930>] unix_stream_sendmsg+0x3b0/0x780
                                sp=E0000160369ffc70 bsp=E0000160369f0e68
 [<a0000001006d7e80>] sock_aio_write+0x260/0x2a0
                                sp=E0000160369ffca0 bsp=E0000160369f0e28
 [<a0000001001817b0>] do_sync_write+0x170/0x260
                                sp=E0000160369ffd20 bsp=E0000160369f0dd0
 [<a000000100182f70>] vfs_write+0x310/0x320
                                sp=E0000160369ffe20 bsp=E0000160369f0d80
 [<a000000100183ad0>] sys_write+0x70/0xe0
                                sp=E0000160369ffe20 bsp=E0000160369f0d08
 [<a00000010000aa40>] ia64_ret_from_syscall+0x0/0x20
                                sp=E0000160369ffe30 bsp=E0000160369f0d08
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=E000016036a00000 bsp=E0000160369f0d08
BUG: soft lockup - CPU#0 stuck for 61s! [hackbench:10060]
Modules linked in: sunrpc binfmt_misc dm_multipath fan sg thermal processor=
 button container e100 eepro100 mii dm_snapshot dm_zero dm_mirror dm_log dm=
_mod lpfc mptspi mptscsih mptbase ehci_hcd ohci_hcd uhci_hcd usbcore

Pid: 10060, CPU 0, comm:            hackbench
psr : 00001010085a6010 ifs : 8000000000000590 ip  : [<a0000001004628b0>]   =
 Not tainted (2.6.25-rc5-mm1)
ip is at _raw_spin_lock+0x230/0x300
unat: 0000000000000000 pfs : 0000000000000590 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : a45856a555966995
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000100462890 b6  : a00000010012b2a0 b7  : a00000010000f190
f6  : 1003efffffffffffffc03 f7  : 1003e0000000000000b13
f8  : 1003e0000000000000023 f9  : 1003ea3d70a3d70a3d70b
f10 : 1003e0000000000000051 f11 : 1003efffffffffffff481
r1  : a000000100f80990 r2  : 0000000000000000 r3  : 0000000000000004
r8  : e0000040beab0c64 r9  : e0000040cee50000 r10 : ffffffffdead4ead
r11 : 00000000dead4ead r12 : e0000040beabfb10 r13 : e0000040beab0000
r14 : 0000000000000001 r15 : 0000000000000000 r16 : a040000058126354
r17 : 000000002f7c4000 r18 : 000000000bc6c000 r19 : 0000000000614000
r20 : 000000000c280000 r21 : a000000100d98da8 r22 : a000000100d98da8
r23 : 0000000000000001 r24 : 0000000000000001 r25 : 0000000000000001
r26 : 5fc0000000000000 r27 : a040000058246e30 r28 : 0000000000000000
r29 : e0000040beab0c64 r30 : 0000000000000000 r31 : a04000005824a1d8

Call Trace:
 [<a000000100015f20>] show_stack+0x80/0xa0
                                sp=E0000040beabf770 bsp=E0000040beab1838
 [<a000000100016820>] show_regs+0x880/0x8c0
                                sp=E0000040beabf940 bsp=E0000040beab17d8
 [<a000000100101b60>] softlockup_tick+0x2e0/0x360
                                sp=E0000040beabf940 bsp=E0000040beab1788
 [<a0000001000ba320>] run_local_timers+0x40/0x60
                                sp=E0000040beabf940 bsp=E0000040beab1770
 [<a0000001000ba420>] update_process_times+0x40/0xc0
                                sp=E0000040beabf940 bsp=E0000040beab1740
 [<a00000010003b150>] timer_interrupt+0x1b0/0x4a0
                                sp=E0000040beabf940 bsp=E0000040beab16e0
 [<a000000100102420>] handle_IRQ_event+0x80/0x120
                                sp=E0000040beabf940 bsp=E0000040beab16a8
 [<a000000100102600>] __do_IRQ+0x140/0x420
                                sp=E0000040beabf940 bsp=E0000040beab1648
 [<a000000100012df0>] ia64_handle_irq+0x3f0/0x420
                                sp=E0000040beabf940 bsp=E0000040beab15c8
 [<a00000010000abe0>] ia64_leave_kernel+0x0/0x270
                                sp=E0000040beabf940 bsp=E0000040beab15c8
 [<a0000001004628b0>] _raw_spin_lock+0x230/0x300
                                sp=E0000040beabfb10 bsp=E0000040beab1548
 [<a0000001008290e0>] _spin_lock+0x20/0x40
                                sp=E0000040beabfb10 bsp=E0000040beab1528
 [<a00000010014b470>] page_check_address+0x170/0x200
                                sp=E0000040beabfb10 bsp=E0000040beab14e8
 [<a00000010014b680>] page_referenced_one+0xa0/0x2c0
                                sp=E0000040beabfb10 bsp=E0000040beab14a8
 [<a00000010014db10>] page_referenced+0x230/0x340
                                sp=E0000040beabfb20 bsp=E0000040beab1460
 [<a00000010012bd00>] shrink_active_list+0x9e0/0xe80
                                sp=E0000040beabfb30 bsp=E0000040beab13b8
 [<a00000010012e460>] shrink_zone+0x220/0x260
                                sp=E0000040beabfbf0 bsp=E0000040beab1368
 [<a0000001001300f0>] try_to_free_pages+0x590/0x900
                                sp=E0000040beabfbf0 bsp=E0000040beab1290
 [<a000000100120500>] __alloc_pages_internal+0x4a0/0x860
                                sp=E0000040beabfc30 bsp=E0000040beab11d8
 [<a000000100120950>] __alloc_pages+0x30/0x60
                                sp=E0000040beabfc40 bsp=E0000040beab11a8
 [<a0000001001714e0>] kmem_getpages+0x120/0x2a0
                                sp=E0000040beabfc40 bsp=E0000040beab1160
 [<a000000100172480>] fallback_alloc+0x320/0x440
                                sp=E0000040beabfc40 bsp=E0000040beab10d8
 [<a0000001001726b0>] ____cache_alloc_node+0x110/0x300
                                sp=E0000040beabfc40 bsp=E0000040beab1058
 [<a000000100171770>] kmem_cache_alloc_node+0x110/0x3c0
                                sp=E0000040beabfc40 bsp=E0000040beab1018
 [<a000000100171a80>] __kmalloc_node+0x60/0xa0
                                sp=E0000040beabfc40 bsp=E0000040beab0fe0
 [<a0000001006ea250>] __alloc_skb+0xb0/0x280
                                sp=E0000040beabfc40 bsp=E0000040beab0f98
 [<a0000001006df480>] sock_alloc_send_skb+0x400/0x560
                                sp=E0000040beabfc40 bsp=E0000040beab0f28
 [<a0000001007e7930>] unix_stream_sendmsg+0x3b0/0x780
                                sp=E0000040beabfc70 bsp=E0000040beab0e68
 [<a0000001006d7e80>] sock_aio_write+0x260/0x2a0
                                sp=E0000040beabfca0 bsp=E0000040beab0e28
 [<a0000001001817b0>] do_sync_write+0x170/0x260
                                sp=E0000040beabfd20 bsp=E0000040beab0dd0
 [<a000000100182f70>] vfs_write+0x310/0x320
                                sp=E0000040beabfe20 bsp=E0000040beab0d80
 [<a000000100183ad0>] sys_write+0x70/0xe0
                                sp=E0000040beabfe20 bsp=E0000040beab0d08
 [<a00000010000aa40>] ia64_ret_from_syscall+0x0/0x20
                                sp=E0000040beabfe30 bsp=E0000040beab0d08
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=E0000040beac0000 bsp=E0000040beab0d08
BUG: soft lockup - CPU#7 stuck for 61s! [hackbench:10576]
Modules linked in: sunrpc binfmt_misc dm_multipath fan sg thermal processor=
 button container e100 eepro100 mii dm_snapshot dm_zero dm_mirror dm_log dm=
_mod lpfc mptspi mptscsih mptbase ehci_hcd ohci_hcd uhci_hcd usbcore

Pid: 10576, CPU 7, comm:            hackbench
psr : 00001010085a6010 ifs : 8000000000000590 ip  : [<a0000001004628b0>]   =
 Not tainted (2.6.25-rc5-mm1)
ip is at _raw_spin_lock+0x230/0x300
unat: 0000000000000000 pfs : 0000000000000590 rsc : 0000000000000003
rnat: a45456a565965a55 bsps: a00000010014b680 pr  : a45456a565966995
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000100462890 b6  : a000000100088f20 b7  : a0000001000995a0
f6  : 1000f87ff800000000000 f7  : 1003e0000000000010fff
f8  : 1003e0000000000000023 f9  : 1003ea3d70a3d70a3d70b
f10 : 1003e0000000000000051 f11 : 1003efffffffffffff481
r1  : a000000100f80990 r2  : 0000000000000000 r3  : 0000000000000000
r8  : e000000045b20c64 r9  : e0000040beab0000 r10 : ffffffffdead4ead
r11 : 00000000dead4ead r12 : e000000045b2fb20 r13 : e000000045b20000
r14 : 0000000000000001 r15 : 0000000000000007 r16 : e0000040c45b48fc
r17 : 000000002f7c4000 r18 : 000000000bc6c000 r19 : 0000000000614000
r20 : 000000000c280000 r21 : a000000100d98da8 r22 : a000000100d98da8
r23 : 0000000000000001 r24 : 0000000000000001 r25 : 0000000000000001
r26 : e000000045b2fb50 r27 : a040000058271bb0 r28 : e000000045b2fb48
r29 : 0000000000007bfe r30 : a000000100d764b0 r31 : a040000058271b58

Call Trace:
 [<a000000100015f20>] show_stack+0x80/0xa0
                                sp=E000000045b2f780 bsp=E000000045b217d8
 [<a000000100016820>] show_regs+0x880/0x8c0
                                sp=E000000045b2f950 bsp=E000000045b21780
 [<a000000100101b60>] softlockup_tick+0x2e0/0x360
                                sp=E000000045b2f950 bsp=E000000045b21730
 [<a0000001000ba320>] run_local_timers+0x40/0x60
                                sp=E000000045b2f950 bsp=E000000045b21718
 [<a0000001000ba420>] update_process_times+0x40/0xc0
                                sp=E000000045b2f950 bsp=E000000045b216e8
 [<a00000010003b150>] timer_interrupt+0x1b0/0x4a0
                                sp=E000000045b2f950 bsp=E000000045b21688
 [<a000000100102420>] handle_IRQ_event+0x80/0x120
                                sp=E000000045b2f950 bsp=E000000045b21650
 [<a000000100102600>] __do_IRQ+0x140/0x420
                                sp=E000000045b2f950 bsp=E000000045b215e8
 [<a000000100012df0>] ia64_handle_irq+0x3f0/0x420
                                sp=E000000045b2f950 bsp=E000000045b21570
 [<a00000010000abe0>] ia64_leave_kernel+0x0/0x270
                                sp=E000000045b2f950 bsp=E000000045b21570
 [<a0000001004628b0>] _raw_spin_lock+0x230/0x300
                                sp=E000000045b2fb20 bsp=E000000045b214f0
 [<a0000001008290e0>] _spin_lock+0x20/0x40
                                sp=E000000045b2fb20 bsp=E000000045b214d0
 [<a00000010014b2e0>] page_lock_anon_vma+0x80/0xa0
                                sp=E000000045b2fb20 bsp=E000000045b214a8
 [<a00000010014da60>] page_referenced+0x180/0x340
                                sp=E000000045b2fb20 bsp=E000000045b21460
 [<a00000010012bd00>] shrink_active_list+0x9e0/0xe80
                                sp=E000000045b2fb30 bsp=E000000045b213b8
 [<a00000010012e460>] shrink_zone+0x220/0x260
                                sp=E000000045b2fbf0 bsp=E000000045b21368
 [<a0000001001300f0>] try_to_free_pages+0x590/0x900
                                sp=E000000045b2fbf0 bsp=E000000045b21290
 [<a000000100120500>] __alloc_pages_internal+0x4a0/0x860
                                sp=E000000045b2fc30 bsp=E000000045b211d8
 [<a000000100120950>] __alloc_pages+0x30/0x60
                                sp=E000000045b2fc40 bsp=E000000045b211a8
 [<a0000001001714e0>] kmem_getpages+0x120/0x2a0
                                sp=E000000045b2fc40 bsp=E000000045b21160
 [<a000000100172480>] fallback_alloc+0x320/0x440
                                sp=E000000045b2fc40 bsp=E000000045b210d8
 [<a0000001001726b0>] ____cache_alloc_node+0x110/0x300
                                sp=E000000045b2fc40 bsp=E000000045b21058
 [<a000000100171770>] kmem_cache_alloc_node+0x110/0x3c0
                                sp=E000000045b2fc40 bsp=E000000045b21018
 [<a000000100171a80>] __kmalloc_node+0x60/0xa0
                                sp=E000000045b2fc40 bsp=E000000045b20fe0
 [<a0000001006ea250>] __alloc_skb+0xb0/0x280
                                sp=E000000045b2fc40 bsp=E000000045b20f98
 [<a0000001006df480>] sock_alloc_send_skb+0x400/0x560
                                sp=E000000045b2fc40 bsp=E000000045b20f28
 [<a0000001007e7930>] unix_stream_sendmsg+0x3b0/0x780
                                sp=E000000045b2fc70 bsp=E000000045b20e68
 [<a0000001006d7e80>] sock_aio_write+0x260/0x2a0
                                sp=E000000045b2fca0 bsp=E000000045b20e28
 [<a0000001001817b0>] do_sync_write+0x170/0x260
                                sp=E000000045b2fd20 bsp=E000000045b20dd0
 [<a000000100182f70>] vfs_write+0x310/0x320
                                sp=E000000045b2fe20 bsp=E000000045b20d80
 [<a000000100183ad0>] sys_write+0x70/0xe0
                                sp=E000000045b2fe20 bsp=E000000045b20d08
 [<a00000010000aa40>] ia64_ret_from_syscall+0x0/0x20
                                sp=E000000045b2fe30 bsp=E000000045b20d08
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=E000000045b30000 bsp=E000000045b20d08
BUG: soft lockup - CPU#5 stuck for 61s! [hackbench:12811]
Modules linked in: sunrpc binfmt_misc dm_multipath fan sg thermal processor=
 button container e100 eepro100 mii dm_snapshot dm_zero dm_mirror dm_log dm=
_mod lpfc mptspi mptscsih mptbase ehci_hcd ohci_hcd uhci_hcd usbcore

Pid: 12811, CPU 5, comm:            hackbench
psr : 00001010085a6010 ifs : 8000000000000005 ip  : [<a000000100008d30>]   =
 Not tainted (2.6.25-rc5-mm1)
ip is at ia64_delay_loop+0x30/0x40
unat: 0000000000000000 pfs : 0000000000000590 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : a45456a555966995
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000100462890 b6  : a00000010012b2a0 b7  : a00000010000f190
f6  : 1003efffffffffffffc03 f7  : 1003e0000000000000b13
f8  : 1003e0000000000000023 f9  : 1003ea3d70a3d70a3d70b
f10 : 1003e0000000000000051 f11 : 1003efffffffffffff481
r1  : a000000100f80990 r2  : 0000000000000000 r3  : 0000000000000003
r8  : e00001603bd10c64 r9  : e0000040cda10000 r10 : ffffffffdead4ead
r11 : 00000000dead4ead r12 : e00001603bd1fb20 r13 : e00001603bd10000
r14 : 0000000000000001 r15 : 0000000000000005 r16 : e0000040c45b48fc
r17 : 000000002f7c4000 r18 : 000000000bc6c000 r19 : 0000000000614000
r20 : 000000000c280000 r21 : a000000100d98da8 r22 : a000000100d98da8
r23 : 0000000000000001 r24 : 0000000000000001 r25 : 0000000000000001
r26 : e00001603bd1fb50 r27 : a040000058012d30 r28 : e00001603bd1fb48
r29 : 0000000000007bfe r30 : 0000000000000000 r31 : a04000005829e4d8

Call Trace:
 [<a000000100015f20>] show_stack+0x80/0xa0
                                sp=E00001603bd1f780 bsp=E00001603bd117d8
 [<a000000100016820>] show_regs+0x880/0x8c0
                                sp=E00001603bd1f950 bsp=E00001603bd11780
 [<a000000100101b60>] softlockup_tick+0x2e0/0x360
                                sp=E00001603bd1f950 bsp=E00001603bd11730
 [<a0000001000ba320>] run_local_timers+0x40/0x60
                                sp=E00001603bd1f950 bsp=E00001603bd11718
 [<a0000001000ba420>] update_process_times+0x40/0xc0
                                sp=E00001603bd1f950 bsp=E00001603bd116e8
 [<a00000010003b150>] timer_interrupt+0x1b0/0x4a0
                                sp=E00001603bd1f950 bsp=E00001603bd11688
 [<a000000100102420>] handle_IRQ_event+0x80/0x120
                                sp=E00001603bd1f950 bsp=E00001603bd11650
 [<a000000100102600>] __do_IRQ+0x140/0x420
                                sp=E00001603bd1f950 bsp=E00001603bd115e8
 [<a000000100012df0>] ia64_handle_irq+0x3f0/0x420
                                sp=E00001603bd1f950 bsp=E00001603bd11570
 [<a00000010000abe0>] ia64_leave_kernel+0x0/0x270
                                sp=E00001603bd1f950 bsp=E00001603bd11570
 [<a000000100008d30>] ia64_delay_loop+0x30/0x40
                                sp=E00001603bd1fb20 bsp=E00001603bd11548
 [<a000000100462890>] _raw_spin_lock+0x210/0x300
                                sp=E00001603bd1fb20 bsp=E00001603bd114f0
 [<a0000001008290e0>] _spin_lock+0x20/0x40
                                sp=E00001603bd1fb20 bsp=E00001603bd114d0
 [<a00000010014b2e0>] page_lock_anon_vma+0x80/0xa0
                                sp=E00001603bd1fb20 bsp=E00001603bd114a8
 [<a00000010014da60>] page_referenced+0x180/0x340
                                sp=E00001603bd1fb20 bsp=E00001603bd11460
 [<a00000010012bd00>] shrink_active_list+0x9e0/0xe80
                                sp=E00001603bd1fb30 bsp=E00001603bd113b8
 [<a00000010012e460>] shrink_zone+0x220/0x260
                                sp=E00001603bd1fbf0 bsp=E00001603bd11368
 [<a0000001001300f0>] try_to_free_pages+0x590/0x900
                                sp=E00001603bd1fbf0 bsp=E00001603bd11290
 [<a000000100120500>] __alloc_pages_internal+0x4a0/0x860
                                sp=E00001603bd1fc30 bsp=E00001603bd111d8
 [<a000000100120950>] __alloc_pages+0x30/0x60
                                sp=E00001603bd1fc40 bsp=E00001603bd111a8
 [<a0000001001714e0>] kmem_getpages+0x120/0x2a0
                                sp=E00001603bd1fc40 bsp=E00001603bd11160
 [<a000000100172480>] fallback_alloc+0x320/0x440
                                sp=E00001603bd1fc40 bsp=E00001603bd110d8
 [<a0000001001726b0>] ____cache_alloc_node+0x110/0x300
                                sp=E00001603bd1fc40 bsp=E00001603bd11058
 [<a000000100171770>] kmem_cache_alloc_node+0x110/0x3c0
                                sp=E00001603bd1fc40 bsp=E00001603bd11018
 [<a000000100171a80>] __kmalloc_node+0x60/0xa0
                                sp=E00001603bd1fc40 bsp=E00001603bd10fe0
 [<a0000001006ea250>] __alloc_skb+0xb0/0x280
                                sp=E00001603bd1fc40 bsp=E00001603bd10f98
 [<a0000001006df480>] sock_alloc_send_skb+0x400/0x560
                                sp=E00001603bd1fc40 bsp=E00001603bd10f28
 [<a0000001007e7930>] unix_stream_sendmsg+0x3b0/0x780
                                sp=E00001603bd1fc70 bsp=E00001603bd10e68
 [<a0000001006d7e80>] sock_aio_write+0x260/0x2a0
                                sp=E00001603bd1fca0 bsp=E00001603bd10e28
 [<a0000001001817b0>] do_sync_write+0x170/0x260
                                sp=E00001603bd1fd20 bsp=E00001603bd10dd0
 [<a000000100182f70>] vfs_write+0x310/0x320
                                sp=E00001603bd1fe20 bsp=E00001603bd10d80
 [<a000000100183ad0>] sys_write+0x70/0xe0
                                sp=E00001603bd1fe20 bsp=E00001603bd10d08
 [<a00000010000aa40>] ia64_ret_from_syscall+0x0/0x20
                                sp=E00001603bd1fe30 bsp=E00001603bd10d08
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=E00001603bd20000 bsp=E00001603bd10d08
BUG: soft lockup - CPU#4 stuck for 61s! [hackbench:9582]
Modules linked in: sunrpc binfmt_misc dm_multipath fan sg thermal processor=
 button container e100 eepro100 mii dm_snapshot dm_zero dm_mirror dm_log dm=
_mod lpfc mptspi mptscsih mptbase ehci_hcd ohci_hcd uhci_hcd usbcore

Pid: 9582, CPU 4, comm:            hackbench
psr : 00001010085a6010 ifs : 8000000000000590 ip  : [<a0000001004628b0>]   =
 Not tainted (2.6.25-rc5-mm1)
ip is at _raw_spin_lock+0x230/0x300
unat: 0000000000000000 pfs : 0000000000000590 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : a45456a555966995
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000100462890 b6  : a00000010012b2a0 b7  : a00000010000f190
f6  : 1003efffffffffffffc03 f7  : 1003e0000000000000b13
f8  : 1003e0000000000000023 f9  : 1003ea3d70a3d70a3d70b
f10 : 1003e0000000000000051 f11 : 1003efffffffffffff497
r1  : a000000100f80990 r2  : 0000000000000000 r3  : 0000000000000002
r8  : e0000040fda10c64 r9  : e00001603e090000 r10 : ffffffffdead4ead
r11 : 00000000dead4ead r12 : e0000040fda1fb20 r13 : e0000040fda10000
r14 : 0000000000000001 r15 : 0000000000000004 r16 : e0000040c45b854c
r17 : 000000002f7c4000 r18 : 000000000bc6c000 r19 : 0000000000614000
r20 : 000000000c280000 r21 : a000000100d98da8 r22 : a000000100d98da8
r23 : 0000000000000001 r24 : 0000000000000001 r25 : 0000000000000001
r26 : e0000040fda1fb50 r27 : a0400000582853b0 r28 : e0000040fda1fb48
r29 : 0000000000007bfe r30 : 0000000000000000 r31 : a040000058285358

Call Trace:
 [<a000000100015f20>] show_stack+0x80/0xa0
                                sp=E0000040fda1f780 bsp=E0000040fda117a8
 [<a000000100016820>] show_regs+0x880/0x8c0
                                sp=E0000040fda1f950 bsp=E0000040fda11750
 [<a000000100101b60>] softlockup_tick+0x2e0/0x360
                                sp=E0000040fda1f950 bsp=E0000040fda11700
 [<a0000001000ba320>] run_local_timers+0x40/0x60
                                sp=E0000040fda1f950 bsp=E0000040fda116e8
 [<a0000001000ba420>] update_process_times+0x40/0xc0
                                sp=E0000040fda1f950 bsp=E0000040fda116b8
 [<a00000010003b150>] timer_interrupt+0x1b0/0x4a0
                                sp=E0000040fda1f950 bsp=E0000040fda11658
 [<a000000100102420>] handle_IRQ_event+0x80/0x120
                                sp=E0000040fda1f950 bsp=E0000040fda11620
 [<a000000100102600>] __do_IRQ+0x140/0x420
                                sp=E0000040fda1f950 bsp=E0000040fda115b8
 [<a000000100012df0>] ia64_handle_irq+0x3f0/0x420
                                sp=E0000040fda1f950 bsp=E0000040fda11540
 [<a00000010000abe0>] ia64_leave_kernel+0x0/0x270
                                sp=E0000040fda1f950 bsp=E0000040fda11540
 [<a0000001004628b0>] _raw_spin_lock+0x230/0x300
                                sp=E0000040fda1fb20 bsp=E0000040fda114c0
 [<a0000001008290e0>] _spin_lock+0x20/0x40
                                sp=E0000040fda1fb20 bsp=E0000040fda114a0
 [<a00000010014b2e0>] page_lock_anon_vma+0x80/0xa0
                                sp=E0000040fda1fb20 bsp=E0000040fda11478
 [<a00000010014da60>] page_referenced+0x180/0x340
                                sp=E0000040fda1fb20 bsp=E0000040fda11430
 [<a00000010012bd00>] shrink_active_list+0x9e0/0xe80
                                sp=E0000040fda1fb30 bsp=E0000040fda11388
 [<a00000010012e460>] shrink_zone+0x220/0x260
                                sp=E0000040fda1fbf0 bsp=E0000040fda11338
 [<a0000001001300f0>] try_to_free_pages+0x590/0x900
                                sp=E0000040fda1fbf0 bsp=E0000040fda11260
 [<a000000100120500>] __alloc_pages_internal+0x4a0/0x860
                                sp=E0000040fda1fc30 bsp=E0000040fda111a8
 [<a000000100120950>] __alloc_pages+0x30/0x60
                                sp=E0000040fda1fc40 bsp=E0000040fda11178
 [<a0000001001714e0>] kmem_getpages+0x120/0x2a0
                                sp=E0000040fda1fc40 bsp=E0000040fda11130
 [<a000000100172480>] fallback_alloc+0x320/0x440
                                sp=E0000040fda1fc40 bsp=E0000040fda110a8
 [<a0000001001726b0>] ____cache_alloc_node+0x110/0x300
                                sp=E0000040fda1fc40 bsp=E0000040fda11028
 [<a000000100171770>] kmem_cache_alloc_node+0x110/0x3c0
                                sp=E0000040fda1fc40 bsp=E0000040fda10fe0
 [<a0000001006ea210>] __alloc_skb+0x70/0x280
                                sp=E0000040fda1fc40 bsp=E0000040fda10f98
 [<a0000001006df480>] sock_alloc_send_skb+0x400/0x560
                                sp=E0000040fda1fc40 bsp=E0000040fda10f28
 [<a0000001007e7930>] unix_stream_sendmsg+0x3b0/0x780
                                sp=E0000040fda1fc70 bsp=E0000040fda10e68
 [<a0000001006d7e80>] sock_aio_write+0x260/0x2a0
                                sp=E0000040fda1fca0 bsp=E0000040fda10e28
 [<a0000001001817b0>] do_sync_write+0x170/0x260
                                sp=E0000040fda1fd20 bsp=E0000040fda10dd0
 [<a000000100182f70>] vfs_write+0x310/0x320
                                sp=E0000040fda1fe20 bsp=E0000040fda10d80
 [<a000000100183ad0>] sys_write+0x70/0xe0
                                sp=E0000040fda1fe20 bsp=E0000040fda10d08
 [<a00000010000aa40>] ia64_ret_from_syscall+0x0/0x20
                                sp=E0000040fda1fe30 bsp=E0000040fda10d08
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=E0000040fda20000 bsp=E0000040fda10d08
BUG: soft lockup - CPU#6 stuck for 61s! [hackbench:13609]
Modules linked in: sunrpc binfmt_misc dm_multipath fan sg thermal processor=
 button container e100 eepro100 mii dm_snapshot dm_zero dm_mirror dm_log dm=
_mod lpfc mptspi mptscsih mptbase ehci_hcd ohci_hcd uhci_hcd usbcore

Pid: 13609, CPU 6, comm:            hackbench
psr : 00001010085a6010 ifs : 8000000000000590 ip  : [<a0000001004628b0>]   =
 Not tainted (2.6.25-rc5-mm1)
ip is at _raw_spin_lock+0x230/0x300
unat: 0000000000000000 pfs : 0000000000000590 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : a45456a555966995
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000100462890 b6  : a00000010012b2a0 b7  : a0000001001ac880
f6  : 1003efffffffffffffc03 f7  : 1003e0000000000000b13
f8  : 1003e0000000000000023 f9  : 1003ea3d70a3d70a3d70b
f10 : 1003e0000000000000051 f11 : 1003efffffffffffff497
r1  : a000000100f80990 r2  : 0000000000000000 r3  : 0000000000000004
r8  : e00001601a310c64 r9  : e0000040cee50000 r10 : ffffffffdead4ead
r11 : 00000000dead4ead r12 : e00001601a31fb10 r13 : e00001601a310000
r14 : 0000000000000001 r15 : 0000000000000006 r16 : a040000058126354
r17 : 000000002f7c4000 r18 : 000000000bc6c000 r19 : 0000000000614000
r20 : 000000000c280000 r21 : a000000100d98da8 r22 : a000000100d98da8
r23 : 0000000000000001 r24 : 0000000000000001 r25 : 0000000000000001
r26 : 5fc0000000000000 r27 : a040000058246270 r28 : 0000000000000006
r29 : e00001601a310c64 r30 : 0000000000000000 r31 : a04000005824a8d8

Call Trace:
 [<a000000100015f20>] show_stack+0x80/0xa0
                                sp=E00001601a31f770 bsp=E00001601a311838
 [<a000000100016820>] show_regs+0x880/0x8c0
                                sp=E00001601a31f940 bsp=E00001601a3117d8
 [<a000000100101b60>] softlockup_tick+0x2e0/0x360
                                sp=E00001601a31f940 bsp=E00001601a311788
 [<a0000001000ba320>] run_local_timers+0x40/0x60
                                sp=E00001601a31f940 bsp=E00001601a311770
 [<a0000001000ba420>] update_process_times+0x40/0xc0
                                sp=E00001601a31f940 bsp=E00001601a311740
 [<a00000010003b150>] timer_interrupt+0x1b0/0x4a0
                                sp=E00001601a31f940 bsp=E00001601a3116e0
 [<a000000100102420>] handle_IRQ_event+0x80/0x120
                                sp=E00001601a31f940 bsp=E00001601a3116a8
 [<a000000100102600>] __do_IRQ+0x140/0x420
                                sp=E00001601a31f940 bsp=E00001601a311648
 [<a000000100012df0>] ia64_handle_irq+0x3f0/0x420
                                sp=E00001601a31f940 bsp=E00001601a3115c8
 [<a00000010000abe0>] ia64_leave_kernel+0x0/0x270
                                sp=E00001601a31f940 bsp=E00001601a3115c8
 [<a0000001004628b0>] _raw_spin_lock+0x230/0x300
                                sp=E00001601a31fb10 bsp=E00001601a311548
 [<a0000001008290e0>] _spin_lock+0x20/0x40
                                sp=E00001601a31fb10 bsp=E00001601a311528
 [<a00000010014b470>] page_check_address+0x170/0x200
                                sp=E00001601a31fb10 bsp=E00001601a3114e8
 [<a00000010014b680>] page_referenced_one+0xa0/0x2c0
                                sp=E00001601a31fb10 bsp=E00001601a3114a8
 [<a00000010014db10>] page_referenced+0x230/0x340
                                sp=E00001601a31fb20 bsp=E00001601a311460
 [<a00000010012bd00>] shrink_active_list+0x9e0/0xe80
                                sp=E00001601a31fb30 bsp=E00001601a3113b8
 [<a00000010012e460>] shrink_zone+0x220/0x260
                                sp=E00001601a31fbf0 bsp=E00001601a311368
 [<a0000001001300f0>] try_to_free_pages+0x590/0x900
                                sp=E00001601a31fbf0 bsp=E00001601a311290
 [<a000000100120500>] __alloc_pages_internal+0x4a0/0x860
                                sp=E00001601a31fc30 bsp=E00001601a3111d8
 [<a000000100120950>] __alloc_pages+0x30/0x60
                                sp=E00001601a31fc40 bsp=E00001601a3111a8
 [<a0000001001714e0>] kmem_getpages+0x120/0x2a0
                                sp=E00001601a31fc40 bsp=E00001601a311160
 [<a000000100172480>] fallback_alloc+0x320/0x440
                                sp=E00001601a31fc40 bsp=E00001601a3110d8
 [<a0000001001726b0>] ____cache_alloc_node+0x110/0x300
                                sp=E00001601a31fc40 bsp=E00001601a311058
 [<a000000100171770>] kmem_cache_alloc_node+0x110/0x3c0
                                sp=E00001601a31fc40 bsp=E00001601a311018
 [<a000000100171a80>] __kmalloc_node+0x60/0xa0
                                sp=E00001601a31fc40 bsp=E00001601a310fe0
 [<a0000001006ea250>] __alloc_skb+0xb0/0x280
                                sp=E00001601a31fc40 bsp=E00001601a310f98
 [<a0000001006df480>] sock_alloc_send_skb+0x400/0x560
                                sp=E00001601a31fc40 bsp=E00001601a310f28
 [<a0000001007e7930>] unix_stream_sendmsg+0x3b0/0x780
                                sp=E00001601a31fc70 bsp=E00001601a310e68
 [<a0000001006d7e80>] sock_aio_write+0x260/0x2a0
                                sp=E00001601a31fca0 bsp=E00001601a310e28
 [<a0000001001817b0>] do_sync_write+0x170/0x260
                                sp=E00001601a31fd20 bsp=E00001601a310dd0
 [<a000000100182f70>] vfs_write+0x310/0x320
                                sp=E00001601a31fe20 bsp=E00001601a310d80
 [<a000000100183ad0>] sys_write+0x70/0xe0
                                sp=E00001601a31fe20 bsp=E00001601a310d08
 [<a00000010000aa40>] ia64_ret_from_syscall+0x0/0x20
                                sp=E00001601a31fe30 bsp=E00001601a310d08
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=E00001601a320000 bsp=E00001601a310d08
BUG: soft lockup - CPU#2 stuck for 61s! [hackbench:11407]
Modules linked in: sunrpc binfmt_misc dm_multipath fan sg thermal processor=
 button container e100 eepro100 mii dm_snapshot dm_zero dm_mirror dm_log dm=
_mod lpfc mptspi mptscsih mptbase ehci_hcd ohci_hcd uhci_hcd usbcore

Pid: 11407, CPU 2, comm:            hackbench
psr : 00001010085a6010 ifs : 8000000000000590 ip  : [<a0000001004628b0>]   =
 Not tainted (2.6.25-rc5-mm1)
ip is at _raw_spin_lock+0x230/0x300
unat: 0000000000000000 pfs : 0000000000000590 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : a45856a555966999
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000100462890 b6  : a00000010012b2a0 b7  : a00000010000f190
f6  : 1003efffffffffffffc03 f7  : 1003e0000000000000b13
f8  : 1003e0000000000000023 f9  : 1003ea3d70a3d70a3d70b
f10 : 1003e0000000000000051 f11 : 1003efffffffffffff497
r1  : a000000100f80990 r2  : 0000000000000000 r3  : 0000000000000002
r8  : 0000000000000000 r9  : a000000100d9b9d8 r10 : a000000100d81e28
r11 : 00000000dead4ead r12 : e00000003241fb20 r13 : e000000032410000
r14 : 0000000000000001 r15 : 0000000000000000 r16 : e000000032410c64
r17 : 000000002f7c4000 r18 : 000000000bc6c000 r19 : 0000000000614000
r20 : 000000000c280000 r21 : a000000100d98da8 r22 : a000000100d98da8
r23 : 0000000000000001 r24 : 0000000000000001 r25 : 0000000000000001
r26 : e00000003241fb50 r27 : a0400000582a3730 r28 : e00000003241fb48
r29 : 0000000000007bfe r30 : 0000000000000000 r31 : a0400000582a4ed8

Call Trace:
 [<a000000100015f20>] show_stack+0x80/0xa0
                                sp=E00000003241f780 bsp=E0000000324117a8
 [<a000000100016820>] show_regs+0x880/0x8c0
                                sp=E00000003241f950 bsp=E000000032411750
 [<a000000100101b60>] softlockup_tick+0x2e0/0x360
                                sp=E00000003241f950 bsp=E000000032411700
 [<a0000001000ba320>] run_local_timers+0x40/0x60
                                sp=E00000003241f950 bsp=E0000000324116e8
 [<a0000001000ba420>] update_process_times+0x40/0xc0
                                sp=E00000003241f950 bsp=E0000000324116b8
 [<a00000010003b150>] timer_interrupt+0x1b0/0x4a0
                                sp=E00000003241f950 bsp=E000000032411658
 [<a000000100102420>] handle_IRQ_event+0x80/0x120
                                sp=E00000003241f950 bsp=E000000032411620
 [<a000000100102600>] __do_IRQ+0x140/0x420
                                sp=E00000003241f950 bsp=E0000000324115b8
 [<a000000100012df0>] ia64_handle_irq+0x3f0/0x420
                                sp=E00000003241f950 bsp=E000000032411540
 [<a00000010000abe0>] ia64_leave_kernel+0x0/0x270
                                sp=E00000003241f950 bsp=E000000032411540
 [<a0000001004628b0>] _raw_spin_lock+0x230/0x300
                                sp=E00000003241fb20 bsp=E0000000324114c0
 [<a0000001008290e0>] _spin_lock+0x20/0x40
                                sp=E00000003241fb20 bsp=E0000000324114a0
 [<a00000010014b2e0>] page_lock_anon_vma+0x80/0xa0
                                sp=E00000003241fb20 bsp=E000000032411478
 [<a00000010014da60>] page_referenced+0x180/0x340
                                sp=E00000003241fb20 bsp=E000000032411430
 [<a00000010012bd00>] shrink_active_list+0x9e0/0xe80
                                sp=E00000003241fb30 bsp=E000000032411388
 [<a00000010012e460>] shrink_zone+0x220/0x260
                                sp=E00000003241fbf0 bsp=E000000032411338
 [<a0000001001300f0>] try_to_free_pages+0x590/0x900
                                sp=E00000003241fbf0 bsp=E000000032411260
 [<a000000100120500>] __alloc_pages_internal+0x4a0/0x860
                                sp=E00000003241fc30 bsp=E0000000324111a8
 [<a000000100120950>] __alloc_pages+0x30/0x60
                                sp=E00000003241fc40 bsp=E000000032411178
 [<a0000001001714e0>] kmem_getpages+0x120/0x2a0
                                sp=E00000003241fc40 bsp=E000000032411130
 [<a000000100172480>] fallback_alloc+0x320/0x440
                                sp=E00000003241fc40 bsp=E0000000324110a8
 [<a0000001001726b0>] ____cache_alloc_node+0x110/0x300
                                sp=E00000003241fc40 bsp=E000000032411028
 [<a000000100171770>] kmem_cache_alloc_node+0x110/0x3c0
                                sp=E00000003241fc40 bsp=E000000032410fe0
 [<a0000001006ea210>] __alloc_skb+0x70/0x280
                                sp=E00000003241fc40 bsp=E000000032410f98
 [<a0000001006df480>] sock_alloc_send_skb+0x400/0x560
                                sp=E00000003241fc40 bsp=E000000032410f28
 [<a0000001007e7930>] unix_stream_sendmsg+0x3b0/0x780
                                sp=E00000003241fc70 bsp=E000000032410e68
 [<a0000001006d7e80>] sock_aio_write+0x260/0x2a0
                                sp=E00000003241fca0 bsp=E000000032410e28
 [<a0000001001817b0>] do_sync_write+0x170/0x260
                                sp=E00000003241fd20 bsp=E000000032410dd0
 [<a000000100182f70>] vfs_write+0x310/0x320
                                sp=E00000003241fe20 bsp=E000000032410d80
 [<a000000100183ad0>] sys_write+0x70/0xe0
                                sp=E00000003241fe20 bsp=E000000032410d08
 [<a00000010000aa40>] ia64_ret_from_syscall+0x0/0x20
                                sp=E00000003241fe30 bsp=E000000032410d08
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=E000000032420000 bsp=E000000032410d08
BUG: soft lockup - CPU#3 stuck for 61s! [hackbench:12705]
Modules linked in: sunrpc binfmt_misc dm_multipath fan sg thermal processor=
 button container e100 eepro100 mii dm_snapshot dm_zero dm_mirror dm_log dm=
_mod lpfc mptspi mptscsih mptbase ehci_hcd ohci_hcd uhci_hcd usbcore

Pid: 12705, CPU 3, comm:            hackbench
psr : 00001010085a6010 ifs : 8000000000000590 ip  : [<a0000001004628a0>]   =
 Not tainted (2.6.25-rc5-mm1)
ip is at _raw_spin_lock+0x220/0x300
unat: 0000000000000000 pfs : 0000000000000590 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : a45866a555966a99
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000100462890 b6  : a0000001004573c0 b7  : a00000010000b1f0
f6  : 000000000000000000000 f7  : 1003e9e3779b97f4a7c16
f8  : 1003e0a00000000001072 f9  : 1003effffffffffffffe9
f10 : 1003e000000000000002d f11 : 1003e8208208208208209
r1  : a000000100f80990 r2  : 0000000000000000 r3  : e00001603727f940
r8  : ffffffffffffffff r9  : a000000100d98bd0 r10 : 0000000000000001
r11 : a000000100d98bf8 r12 : e00001603727fb10 r13 : e000016037270000
r14 : 0000000000000001 r15 : 9fffffffffffffff r16 : e00001603727f588
r17 : 00000000dead4ead r18 : 0000000000004000 r19 : a000000100d98bc8
r20 : 000000000000000a r21 : 0000000000000000 r22 : a000000100d9b2b0
r23 : 0000000000000001 r24 : 0000000000000001 r25 : 0000000000000001
r26 : 00000000000fffff r27 : 0000000000007c3b r28 : 0000000000000003
r29 : e000016037270c64 r30 : ffffffffffffffdb r31 : 0000000000000022

Call Trace:
 [<a000000100015f20>] show_stack+0x80/0xa0
                                sp=E00001603727f770 bsp=E000016037271808
 [<a000000100016820>] show_regs+0x880/0x8c0
                                sp=E00001603727f940 bsp=E0000160372717a8
 [<a000000100101b60>] softlockup_tick+0x2e0/0x360
                                sp=E00001603727f940 bsp=E000016037271758
 [<a0000001000ba320>] run_local_timers+0x40/0x60
                                sp=E00001603727f940 bsp=E000016037271740
 [<a0000001000ba420>] update_process_times+0x40/0xc0
                                sp=E00001603727f940 bsp=E000016037271710
 [<a00000010003b150>] timer_interrupt+0x1b0/0x4a0
                                sp=E00001603727f940 bsp=E0000160372716b0
 [<a000000100102420>] handle_IRQ_event+0x80/0x120
                                sp=E00001603727f940 bsp=E000016037271678
 [<a000000100102600>] __do_IRQ+0x140/0x420
                                sp=E00001603727f940 bsp=E000016037271618
 [<a000000100012df0>] ia64_handle_irq+0x3f0/0x420
                                sp=E00001603727f940 bsp=E000016037271598
 [<a00000010000abe0>] ia64_leave_kernel+0x0/0x270
                                sp=E00001603727f940 bsp=E000016037271598
 [<a0000001004628a0>] _raw_spin_lock+0x220/0x300
                                sp=E00001603727fb10 bsp=E000016037271518
 [<a0000001008290e0>] _spin_lock+0x20/0x40
                                sp=E00001603727fb10 bsp=E0000160372714f8
 [<a00000010014b470>] page_check_address+0x170/0x200
                                sp=E00001603727fb10 bsp=E0000160372714b8
 [<a00000010014b680>] page_referenced_one+0xa0/0x2c0
                                sp=E00001603727fb10 bsp=E000016037271478
 [<a00000010014db10>] page_referenced+0x230/0x340
                                sp=E00001603727fb20 bsp=E000016037271430
 [<a00000010012bd00>] shrink_active_list+0x9e0/0xe80
                                sp=E00001603727fb30 bsp=E000016037271388
 [<a00000010012e460>] shrink_zone+0x220/0x260
                                sp=E00001603727fbf0 bsp=E000016037271338
 [<a0000001001300f0>] try_to_free_pages+0x590/0x900
                                sp=E00001603727fbf0 bsp=E000016037271260
 [<a000000100120500>] __alloc_pages_internal+0x4a0/0x860
                                sp=E00001603727fc30 bsp=E0000160372711a8
 [<a000000100120950>] __alloc_pages+0x30/0x60
                                sp=E00001603727fc40 bsp=E000016037271178
 [<a0000001001714e0>] kmem_getpages+0x120/0x2a0
                                sp=E00001603727fc40 bsp=E000016037271130
 [<a000000100172480>] fallback_alloc+0x320/0x440
                                sp=E00001603727fc40 bsp=E0000160372710a8
 [<a0000001001726b0>] ____cache_alloc_node+0x110/0x300
                                sp=E00001603727fc40 bsp=E000016037271028
 [<a000000100171770>] kmem_cache_alloc_node+0x110/0x3c0
                                sp=E00001603727fc40 bsp=E000016037270fe0
 [<a0000001006ea210>] __alloc_skb+0x70/0x280
                                sp=E00001603727fc40 bsp=E000016037270f98
 [<a0000001006df480>] sock_alloc_send_skb+0x400/0x560
                                sp=E00001603727fc40 bsp=E000016037270f28
 [<a0000001007e7930>] unix_stream_sendmsg+0x3b0/0x780
                                sp=E00001603727fc70 bsp=E000016037270e68
 [<a0000001006d7e80>] sock_aio_write+0x260/0x2a0
                                sp=E00001603727fca0 bsp=E000016037270e28
 [<a0000001001817b0>] do_sync_write+0x170/0x260
                                sp=E00001603727fd20 bsp=E000016037270dd0
 [<a000000100182f70>] vfs_write+0x310/0x320
                                sp=E00001603727fe20 bsp=E000016037270d80
 [<a000000100183ad0>] sys_write+0x70/0xe0
                                sp=E00001603727fe20 bsp=E000016037270d08
 [<a00000010000aa40>] ia64_ret_from_syscall+0x0/0x20
                                sp=E00001603727fe30 bsp=E000016037270d08
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=E000016037280000 bsp=E000016037270d08
BUG: spinlock lockup on CPU#4, hackbench/9582, e0000040c45b8548

Call Trace:
 [<a000000100015f20>] show_stack+0x80/0xa0
                                sp=E0000040fda1f950 bsp=E0000040fda11530
 [<a000000100015f70>] dump_stack+0x30/0x60
                                sp=E0000040fda1fb20 bsp=E0000040fda11518
 [<a000000100462960>] _raw_spin_lock+0x2e0/0x300
                                sp=E0000040fda1fb20 bsp=E0000040fda114c0
 [<a0000001008290e0>] _spin_lock+0x20/0x40
                                sp=E0000040fda1fb20 bsp=E0000040fda114a0
 [<a00000010014b2e0>] page_lock_anon_vma+0x80/0xa0
                                sp=E0000040fda1fb20 bsp=E0000040fda11478
 [<a00000010014da60>] page_referenced+0x180/0x340
                                sp=E0000040fda1fb20 bsp=E0000040fda11430
 [<a00000010012bd00>] shrink_active_list+0x9e0/0xe80
                                sp=E0000040fda1fb30 bsp=E0000040fda11388
 [<a00000010012e460>] shrink_zone+0x220/0x260
                                sp=E0000040fda1fbf0 bsp=E0000040fda11338
 [<a0000001001300f0>] try_to_free_pages+0x590/0x900
                                sp=E0000040fda1fbf0 bsp=E0000040fda11260
 [<a000000100120500>] __alloc_pages_internal+0x4a0/0x860
                                sp=E0000040fda1fc30 bsp=E0000040fda111a8
 [<a000000100120950>] __alloc_pages+0x30/0x60
                                sp=E0000040fda1fc40 bsp=E0000040fda11178
 [<a0000001001714e0>] kmem_getpages+0x120/0x2a0
                                sp=E0000040fda1fc40 bsp=E0000040fda11130
 [<a000000100172480>] fallback_alloc+0x320/0x440
                                sp=E0000040fda1fc40 bsp=E0000040fda110a8
 [<a0000001001726b0>] ____cache_alloc_node+0x110/0x300
                                sp=E0000040fda1fc40 bsp=E0000040fda11028
 [<a000000100171770>] kmem_cache_alloc_node+0x110/0x3c0
                                sp=E0000040fda1fc40 bsp=E0000040fda10fe0
 [<a0000001006ea210>] __alloc_skb+0x70/0x280
                                sp=E0000040fda1fc40 bsp=E0000040fda10f98
 [<a0000001006df480>] sock_alloc_send_skb+0x400/0x560
                                sp=E0000040fda1fc40 bsp=E0000040fda10f28
 [<a0000001007e7930>] unix_stream_sendmsg+0x3b0/0x780
                                sp=E0000040fda1fc70 bsp=E0000040fda10e68
 [<a0000001006d7e80>] sock_aio_write+0x260/0x2a0
                                sp=E0000040fda1fca0 bsp=E0000040fda10e28
 [<a0000001001817b0>] do_sync_write+0x170/0x260
                                sp=E0000040fda1fd20 bsp=E0000040fda10dd0
 [<a000000100182f70>] vfs_write+0x310/0x320
                                sp=E0000040fda1fe20 bsp=E0000040fda10d80
 [<a000000100183ad0>] sys_write+0x70/0xe0
                                sp=E0000040fda1fe20 bsp=E0000040fda10d08
 [<a00000010000aa40>] ia64_ret_from_syscall+0x0/0x20
                                sp=E0000040fda1fe30 bsp=E0000040fda10d08
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=E0000040fda20000 bsp=E0000040fda10d08
BUG: spinlock lockup on CPU#6, hackbench/13609, a040000058126350

Call Trace:
 [<a000000100015f20>] show_stack+0x80/0xa0
                                sp=E00001601a31f940 bsp=E00001601a3115b8
 [<a000000100015f70>] dump_stack+0x30/0x60
                                sp=E00001601a31fb10 bsp=E00001601a3115a0
 [<a000000100462960>] _raw_spin_lock+0x2e0/0x300
                                sp=E00001601a31fb10 bsp=E00001601a311548
 [<a0000001008290e0>] _spin_lock+0x20/0x40
                                sp=E00001601a31fb10 bsp=E00001601a311528
 [<a00000010014b470>] page_check_address+0x170/0x200
                                sp=E00001601a31fb10 bsp=E00001601a3114e8
 [<a00000010014b680>] page_referenced_one+0xa0/0x2c0
                                sp=E00001601a31fb10 bsp=E00001601a3114a8
 [<a00000010014db10>] page_referenced+0x230/0x340
                                sp=E00001601a31fb20 bsp=E00001601a311460
 [<a00000010012bd00>] shrink_active_list+0x9e0/0xe80
                                sp=E00001601a31fb30 bsp=E00001601a3113b8
 [<a00000010012e460>] shrink_zone+0x220/0x260
                                sp=E00001601a31fbf0 bsp=E00001601a311368
BUG: soft lockup - CPU#1 stuck for 61s! [hackbench:12693]
Modules linked in: sunrpc binfmt_misc dm_multipath fan sg thermal processor=
 button container e100 eepro100 mii dm_snapshot dm_zero dm_mirror dm_log dm=
_mod lpfc mptspi mptscsih mptbase ehci_hcd ohci_hcd uhci_hcd usbcore001601a=
31fc30 bsp=E00001601a3111d8
 [<a000000100120950>] __alloc_pages+0x30/0x60
Pid: 12693, CPU 1, comm:            hackbench31fc40 bsp=E00001601a3111a8
psr : 00001410085a6010 ifs : 8000000000000005 ip  : [<a000000100008d02>]   =
 Not tainted (2.6.25-rc5-mm1)                  sp=E00001601a31fc40 bsp=E000=
01601a311160
ip is at ia64_delay_loop+0x2/0x40loc+0x320/0x440
unat: 0000000000000000 pfs : 0000000000000590 rsc : 000000000000000310d8
rnat: e0000160369f0c60 bsps: 0000000000000000 pr  : a45856a565966a95
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70433f1058
csd : 0000000000000000 ssd : 0000000000000000x110/0x3c0
b0  : a000000100462890 b6  : a0000001005db080 b7  : a000000100537b801018
f6  : 1003e00000016fe73fb4d f7  : 1003e0000000000000190
f8  : 1003e00000016fe73f9bd f9  : 1003e0000000000000001=E00001601a310fe0
f10 : 1003e5eca18d532710f16 f11 : 1003e000000000000000e
r1  : a000000100f80990 r2  : 0000000000000000 r3  : e0000160369ff9500f98
r8  : ffffffffffffffff r9  : a000000100d98bd0 r10 : 0000000000000001
r11 : a000000100d98bf8 r12 : e0000160369ffb20 r13 : e0000160369f00000f28
r14 : 0000000000000001 r15 : 9fffffffffffffff r16 : e0000160369ff598
r17 : 00000000dead4ead r18 : a000000100cf122c r19 : a000000100d98bc80e68
r20 : 0000000000008303 r21 : 00000000000fffff r22 : 0000000000100000
r23 : 0000000000000001 r24 : 0000000000000001 r25 : 00000000000000010e28
r26 : 0000000000000000 r27 : 0000000000000060 r28 : 0000000000000001
r29 : e0000160369f0c64 r30 : 0000000000008301 r31 : 00000000000083010dd0
 [<a000000100182f70>] vfs_write+0x310/0x320
Call Trace:                     sp=E00001601a31fe20 bsp=E00001601a310d80
 [<a000000100015f20>] show_stack+0x80/0xa0
                                sp=E0000160369ff780 bsp=E0000160369f17d8
 [<a000000100016820>] show_regs+0x880/0x8c0+0x0/0x20
                                sp=E0000160369ff950 bsp=E0000160369f1780
 [<a000000100101b60>] softlockup_tick+0x2e0/0x3600x0/0x20
                                sp=E0000160369ff950 bsp=E0000160369f1730
 [<a0000001000ba320>] run_local_timers+0x40/0x60
                                sp=E0000160369ff950 bsp=E0000160369f1718
 [<a0000001000ba420>] update_process_times+0x40/0xc0
                                sp=E0000160369ff950 bsp=E0000160369f16e8
 [<a00000010003b150>] timer_interrupt+0x1b0/0x4a0
                                sp=E0000160369ff950 bsp=E0000160369f1688
 [<a000000100102420>] handle_IRQ_event+0x80/0x120
                                sp=E0000160369ff950 bsp=E0000160369f1650
 [<a000000100102600>] __do_IRQ+0x140/0x420
                                sp=E0000160369ff950 bsp=E0000160369f15e8
 [<a000000100012df0>] ia64_handle_irq+0x3f0/0x420
                                sp=E0000160369ff950 bsp=E0000160369f1570
 [<a00000010000abe0>] ia64_leave_kernel+0x0/0x270
                                sp=E0000160369ff950 bsp=E0000160369f1570
 [<a000000100008d00>] ia64_delay_loop+0x0/0x40
                                sp=E0000160369ffb20 bsp=E0000160369f1548
 [<a000000100462890>] _raw_spin_lock+0x210/0x300
                                sp=E0000160369ffb20 bsp=E0000160369f14f0
 [<a0000001008290e0>] _spin_lock+0x20/0x40
                                sp=E0000160369ffb20 bsp=E0000160369f14d0
 [<a00000010014b2e0>] page_lock_anon_vma+0x80/0xa0
                                sp=E0000160369ffb20 bsp=E0000160369f14a8
 [<a00000010014da60>] page_referenced+0x180/0x340
                                sp=E0000160369ffb20 bsp=E0000160369f1460
 [<a00000010012bd00>] shrink_active_list+0x9e0/0xe80
                                sp=E0000160369ffb30 bsp=E0000160369f13b8
 [<a00000010012e460>] shrink_zone+0x220/0x260
                                sp=E0000160369ffbf0 bsp=E0000160369f1368
 [<a0000001001300f0>] try_to_free_pages+0x590/0x900
                                sp=E0000160369ffbf0 bsp=E0000160369f1290
 [<a000000100120500>] __alloc_pages_internal+0x4a0/0x860
                                sp=E0000160369ffc30 bsp=E0000160369f11d8
 [<a000000100120950>] __alloc_pages+0x30/0x60
                                sp=E0000160369ffc40 bsp=E0000160369f11a8
 [<a0000001001714e0>] kmem_getpages+0x120/0x2a0
                                sp=E0000160369ffc40 bsp=E0000160369f1160
 [<a000000100172480>] fallback_alloc+0x320/0x440
                                sp=E0000160369ffc40 bsp=E0000160369f10d8
 [<a0000001001726b0>] ____cache_alloc_node+0x110/0x300
                                sp=E0000160369ffc40 bsp=E0000160369f1058
 [<a000000100171770>] kmem_cache_alloc_node+0x110/0x3c0
                                sp=E0000160369ffc40 bsp=E0000160369f1018
 [<a000000100171a80>] __kmalloc_node+0x60/0xa0
                                sp=E0000160369ffc40 bsp=E0000160369f0fe0
 [<a0000001006ea250>] __alloc_skb+0xb0/0x280
                                sp=E0000160369ffc40 bsp=E0000160369f0f98
 [<a0000001006df480>] sock_alloc_send_skb+0x400/0x560
                                sp=E0000160369ffc40 bsp=E0000160369f0f28
 [<a0000001007e7930>] unix_stream_sendmsg+0x3b0/0x780
                                sp=E0000160369ffc70 bsp=E0000160369f0e68
 [<a0000001006d7e80>] sock_aio_write+0x260/0x2a0
                                sp=E0000160369ffca0 bsp=E0000160369f0e28
 [<a0000001001817b0>] do_sync_write+0x170/0x260
                                sp=E0000160369ffd20 bsp=E0000160369f0dd0
 [<a000000100182f70>] vfs_write+0x310/0x320
                                sp=E0000160369ffe20 bsp=E0000160369f0d80
 [<a000000100183ad0>] sys_write+0x70/0xe0
                                sp=E0000160369ffe20 bsp=E0000160369f0d08
 [<a00000010000aa40>] ia64_ret_from_syscall+0x0/0x20
                                sp=E0000160369ffe30 bsp=E0000160369f0d08
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=E000016036a00000 bsp=E0000160369f0d08
BUG: spinlock lockup on CPU#0, hackbench/10060, a040000058126350

Call Trace:
 [<a000000100015f20>] show_stack+0x80/0xa0
                                sp=E0000040beabf940 bsp=E0000040beab15b8
 [<a000000100015f70>] dump_stack+0x30/0x60
                                sp=E0000040beabfb10 bsp=E0000040beab15a0
 [<a000000100462960>] _raw_spin_lock+0x2e0/0x300
                                sp=E0000040beabfb10 bsp=E0000040beab1548
 [<a0000001008290e0>] _spin_lock+0x20/0x40
                                sp=E0000040beabfb10 bsp=E0000040beab1528
 [<a00000010014b470>] page_check_address+0x170/0x200
                                sp=E0000040beabfb10 bsp=E0000040beab14e8
 [<a00000010014b680>] page_referenced_one+0xa0/0x2c0
                                sp=E0000040beabfb10 bsp=E0000040beab14a8
 [<a00000010014db10>] page_referenced+0x230/0x340
                                sp=E0000040beabfb20 bsp=E0000040beab1460
 [<a00000010012bd00>] shrink_active_list+0x9e0/0xe80
                                sp=E0000040beabfb30 bsp=E0000040beab13b8
 [<a00000010012e460>] shrink_zone+0x220/0x260
                                sp=E0000040beabfbf0 bsp=E0000040beab1368
 [<a0000001001300f0>] try_to_free_pages+0x590/0x900
                                sp=E0000040beabfbf0 bsp=E0000040beab1290
 [<a000000100120500>] __alloc_pages_internal+0x4a0/0x860
                                sp=E0000040beabfc30 bsp=E0000040beab11d8
 [<a000000100120950>] __alloc_pages+0x30/0x60
                                sp=E0000040beabfc40 bsp=E0000040beab11a8
 [<a0000001001714e0>] kmem_getpages+0x120/0x2a0
                                sp=E0000040beabfc40 bsp=E0000040beab1160
 [<a000000100172480>] fallback_alloc+0x320/0x440
                                sp=E0000040beabfc40 bsp=E0000040beab10d8
 [<a0000001001726b0>] ____cache_alloc_node+0x110/0x300
                                sp=E0000040beabfc40 bsp=E0000040beab1058
 [<a000000100171770>] kmem_cache_alloc_node+0x110/0x3c0
                                sp=E0000040beabfc40 bsp=E0000040beab1018
 [<a000000100171a80>] __kmalloc_node+0x60/0xa0
                                sp=E0000040beabfc40 bsp=E0000040beab0fe0
 [<a0000001006ea250>] __alloc_skb+0xb0/0x280
                                sp=E0000040beabfc40 bsp=E0000040beab0f98
 [<a0000001006df480>] sock_alloc_send_skb+0x400/0x560
                                sp=E0000040beabfc40 bsp=E0000040beab0f28
 [<a0000001007e7930>] unix_stream_sendmsg+0x3b0/0x780
                                sp=E0000040beabfc70 bsp=E0000040beab0e68
 [<a0000001006d7e80>] sock_aio_write+0x260/0x2a0
                                sp=E0000040beabfca0 bsp=E0000040beab0e28
 [<a0000001001817b0>] do_sync_write+0x170/0x260
                                sp=E0000040beabfd20 bsp=E0000040beab0dd0
 [<a000000100182f70>] vfs_write+0x310/0x320
                                sp=E0000040beabfe20 bsp=E0000040beab0d80
 [<a000000100183ad0>] sys_write+0x70/0xe0
                                sp=E0000040beabfe20 bsp=E0000040beab0d08
 [<a00000010000aa40>] ia64_ret_from_syscall+0x0/0x20
                                sp=E0000040beabfe30 bsp=E0000040beab0d08
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=E0000040beac0000 bsp=E0000040beab0d08
BUG: spinlock lockup on CPU#2, hackbench/11407, e0000040c45b8548

Call Trace:
 [<a000000100015f20>] show_stack+0x80/0xa0
                                sp=E00000003241f950 bsp=E000000032411530
 [<a000000100015f70>] dump_stack+0x30/0x60
                                sp=E00000003241fb20 bsp=E000000032411518
 [<a000000100462960>] _raw_spin_lock+0x2e0/0x300
                                sp=E00000003241fb20 bsp=E0000000324114c0
 [<a0000001008290e0>] _spin_lock+0x20/0x40
                                sp=E00000003241fb20 bsp=E0000000324114a0
 [<a00000010014b2e0>] page_lock_anon_vma+0x80/0xa0
                                sp=E00000003241fb20 bsp=E000000032411478
 [<a00000010014da60>] page_referenced+0x180/0x340
                                sp=E00000003241fb20 bsp=E000000032411430
 [<a00000010012bd00>] shrink_active_list+0x9e0/0xe80
                                sp=E00000003241fb30 bsp=E000000032411388
 [<a00000010012e460>] shrink_zone+0x220/0x260
                                sp=E00000003241fbf0 bsp=E000000032411338
 [<a0000001001300f0>] try_to_free_pages+0x590/0x900
                                sp=E00000003241fbf0 bsp=E000000032411260
 [<a000000100120500>] __alloc_pages_internal+0x4a0/0x860
                                sp=E00000003241fc30 bsp=E0000000324111a8
 [<a000000100120950>] __alloc_pages+0x30/0x60
                                sp=E00000003241fc40 bsp=E000000032411178
 [<a0000001001714e0>] kmem_getpages+0x120/0x2a0
                                sp=E00000003241fc40 bsp=E000000032411130
 [<a000000100172480>] fallback_alloc+0x320/0x440
                                sp=E00000003241fc40 bsp=E0000000324110a8
 [<a0000001001726b0>] ____cache_alloc_node+0x110/0x300
                                sp=E00000003241fc40 bsp=E000000032411028
 [<a000000100171770>] kmem_cache_alloc_node+0x110/0x3c0
                                sp=E00000003241fc40 bsp=E000000032410fe0
 [<a0000001006ea210>] __alloc_skb+0x70/0x280
                                sp=E00000003241fc40 bsp=E000000032410f98
 [<a0000001006df480>] sock_alloc_send_skb+0x400/0x560
                                sp=E00000003241fc40 bsp=E000000032410f28
 [<a0000001007e7930>] unix_stream_sendmsg+0x3b0/0x780
                                sp=E00000003241fc70 bsp=E000000032410e68
 [<a0000001006d7e80>] sock_aio_write+0x260/0x2a0
                                sp=E00000003241fca0 bsp=E000000032410e28
 [<a0000001001817b0>] do_sync_write+0x170/0x260
                                sp=E00000003241fd20 bsp=E000000032410dd0
 [<a000000100182f70>] vfs_write+0x310/0x320
                                sp=E00000003241fe20 bsp=E000000032410d80
 [<a000000100183ad0>] sys_write+0x70/0xe0
                                sp=E00000003241fe20 bsp=E000000032410d08
 [<a00000010000aa40>] ia64_ret_from_syscall+0x0/0x20
                                sp=E00000003241fe30 bsp=E000000032410d08
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=E000000032420000 bsp=E000000032410d08

