From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 10 Mar 2004 18:09:23 +0000
Subject: show_mem panic
Message-Id: <20040310180923.GA9032@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I just found that I can reproduce the show_mem panic with the discontig
version of show_mem.  Here's the backtrace:

Free swap:            0kB
Node ID: 0
Unable to handle kernel paging request at virtual address
a0007ff69f650000
swapper[1]: Oops 11012296146944 [1]

Pid: 1, CPU 0, comm:              swapper
psr : 0000121008022018 ifs : 800000000000068f ip  : [<a000000100054761>]
Not tainted
ip is at show_mem+0x161/0x320
unat: 0000000000000000 pfs : 000000000000068f rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 00000000000069a5
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000100054700 b6  : e0001030042713c0 b7  : e000000000fffc00
f6  : 10023f8d5875e00000000 f7  : 10008fa00000000000000
f8  : 1003e0000000007f672ec f9  : 10019fece5d8f5c0f735c
f10 : 0fffbccccccccc8c00000 f11 : 1003e0000000000000002
r1  : a00000010098cdc0 r2  : ffffffffffff01c8 r3  : 0000000000000000
r8  : 000000000000000b r9  : 0000000000000001 r10 : 0000000000000000
r11 : a00000010079eb98 r12 : e000103014997b40 r13 : e000103014990000
r14 : a0000001006c0d28 r15 : a0007ff69f650000 r16 : a0007ff69f650020
r17 : 0000000000000000 r18 : a0007ff69f650000 r19 : 000000000001f000
r20 : a0000001006c4698 r21 : e000103006855720 r22 : a00000010078d018
r23 : 0000000000000000 r24 : 000000000000000b r25 : a00000010079cf70
r26 : e000103014997a68 r27 : e000103014997a60 r28 : a00000010083f0c4
r29 : 000000000000fe2c r30 : 0000000000000000 r31 : a00000010079eb50

Call Trace:
 [<a000000100014ea0>] show_stack+0x80/0xa0
                                sp=E000103014997710 bsp=E0001030149913c8
 [<a000000100039730>] die+0x170/0x200
                                sp=E0001030149978e0 bsp=E000103014991390
 [<a0000001000532e0>] ia64_do_page_fault+0x340/0x940
                                sp=E0001030149978e0 bsp=E000103014991328
 [<a00000010000de20>] ia64_leave_kernel+0x0/0x260
                                sp=E000103014997970 bsp=E000103014991328
 [<a000000100054760>] show_mem+0x160/0x320
                                sp=E000103014997b40 bsp=E0001030149912b0
 [<a0000001003a79c0>] sysrq_handle_showmem+0x20/0x40
                                sp=E000103014997b40 bsp=E000103014991298
 [<a0000001003a7ef0>] __handle_sysrq_nolock+0x110/0x260
                                sp=E000103014997b40 bsp=E000103014991250
 [<a0000001003a7db0>] handle_sysrq+0x70/0xa0
                                sp=E000103014997b40 bsp=E000103014991220
 [<a0000001003a9030>] sn_receive_chars+0x330/0x3c0
                                sp=E000103014997b40 bsp=E000103014991198
 [<a0000001003a9ae0>] sn_sal_interrupt+0x220/0x2a0
                                sp=E000103014997b50 bsp=E000103014991150
 [<a000000100011600>] handle_IRQ_event+0xa0/0x120
                                sp=E000103014997c00 bsp=E000103014991108
 [<a000000100012040>] do_IRQ+0x2a0/0x3a0
                                sp=E000103014997c00 bsp=E0001030149910b8
 [<a000000100013e90>] ia64_handle_irq+0xb0/0x1a0
                                sp=E000103014997c00 bsp=E000103014991080
 [<a00000010000de20>] ia64_leave_kernel+0x0/0x260
                                sp=E000103014997c00 bsp=E000103014991080
 [<a0000001000c0700>] panic+0x2e0/0x320
                                sp=E000103014997dd0 bsp=E000103014990ff0
 [<a00000010061a050>] mount_block_root+0x150/0x220
                                sp=E000103014997e10 bsp=E000103014990f80
 [<a00000010061a270>] prepare_namespace+0x70/0x160
                                sp=E000103014997e30 bsp=E000103014990f60
 [<a000000100009320>] init+0xe0/0x2a0
                                sp=E000103014997e30 bsp=E000103014990f48
 [<a000000100016b50>] kernel_thread_helper+0xd0/0x100
                                sp=E000103014997e30 bsp=E000103014990f20
 [<a000000100009040>] ia64_invoke_kernel_thread_helper+0x20/0x40
                                sp=E000103014997e30 bsp=E000103014990f20
 [<e0001030042713c0>] 0xe0001030042713c0
                                sp=E000103014997e30 bsp=E000103014990f20
 [<a0000001000c05a0>] panic+0x180/0x320
                                sp=E000103014997e30 bsp=E000103014990f20
 <0>Kernel panic: Aiee, killing interrupt handler!
In interrupt handler - not syncing

It's in the inner loop looking at the pages in the first node's
node_mem_map.  I'm almost positive that this code worked in the past,
Andreas, when you reproduced this on a tiger machine was it with
CONFIG_VIRTUAL_MEM_MAP enabled?

Thanks,
Jesse
