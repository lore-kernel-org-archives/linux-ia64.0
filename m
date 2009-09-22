From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 22 Sep 2009 21:10:25 +0000
Subject: RE: [PATCHSET percpu#for-next] percpu: convert ia64 to dynamic
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3E29CCADC@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253605214-23210-1-git-send-email-tj@kernel.org>
 <20090922081631.GD1475@elte.hu>
 <57C9024A16AD2D4C97DC78E552063EA3E29CCA8E@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA3E29CCA8E@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Luck, Tony" <tony.luck@intel.com>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>
Cc: Nick Piggin <npiggin@suse.de>, "Yu, Fenghua" <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> Ski must have missed something.  I just tried to boot this on a
> "tiger_defconfig" kernel[1] and it panic'd early in boot.  I'll need
> to re-connect my serial console to get the useful part of the
> panic message ... what's on the VGA console isn't very helpful :-(

Ok.  Here is the tail of the console log.  The instruction at the
faulting address is a "ld8 r3=3D[r14]" and r14 is indeed 0x0.

... nothing apparently odd leading up to here ...
ACPI: Core revision 20090521
Boot processor id 0x0/0xc618
Unable to handle kernel NULL pointer dereference (address 0000000000000000)
migration/0[3]: Oops 8813272891392 [1]
Modules linked in:

Pid: 3, CPU 0, comm:          migration/0
psr : 00001010085a2018 ifs : 800000000000050e ip  : [<a00000010006a470>]   =
 Not tainted (2.6.31-tiger-smp)
ip is at __wake_up_common+0xb0/0x120
unat: 0000000000000000 pfs : 000000000000030b rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 0000000000002941
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70433f
csd : 0930ffff00090000 ssd : 0930ffff00090000
b0  : a00000010006c1a0 b6  : a000000100080f20 b7  : a00000010000bc20
f6  : 1003e0000000000000000 f7  : 1003e0000000000000002
f8  : 1003e00000000a0722fad f9  : 1003e000000000cf5bbc7
f10 : 1003e081f5d33de276e7b f11 : 1003e0000000000000000
r1  : a000000100da9de0 r2  : 00000000fffedfeb r3  : e0000001c0210230
r8  : 00000010085a6018 r9  : 0000000000000001 r10 : ffffffffffff7100
r11 : ffffffffffff7100 r12 : e0000001c021fe00 r13 : e0000001c0210000
r14 : 0000000000000000 r15 : ffffffffffffffe8 r16 : a000000100bc4708
r17 : a000000100bcbe30 r18 : 0000000000000000 r19 : e0000001c0210be4
r20 : 0000000000000001 r21 : 0000000000000001 r22 : 0000000000000000
r23 : e0000001c0210038 r24 : e0000001c0210000 r25 : e000000180007090
r26 : a000000100076000 r27 : 00000010085a6018 r28 : 00000000ffffffff
r29 : e0000001c021001c r30 : 0000000000000000 r31 : ffffffffffff7120

Call Trace:
 [<a000000100015a30>] show_stack+0x50/0xa0
                                sp=E0000001c021f9d0 bsp=E0000001c0210f00
 [<a0000001000162a0>] show_regs+0x820/0x860
                                sp=E0000001c021fba0 bsp=E0000001c0210ea8
 [<a00000010003abc0>] die+0x1a0/0x2c0
                                sp=E0000001c021fba0 bsp=E0000001c0210e68
 [<a0000001000645d0>] ia64_do_page_fault+0x8b0/0x9e0
                                sp=E0000001c021fba0 bsp=E0000001c0210e18
 [<a00000010000c420>] ia64_native_leave_kernel+0x0/0x270
                                sp=E0000001c021fc30 bsp=E0000001c0210e18
 [<a00000010006a470>] __wake_up_common+0xb0/0x120
                                sp=E0000001c021fe00 bsp=E0000001c0210da0
 [<a00000010006c1a0>] complete+0x60/0xa0
                                sp=E0000001c021fe00 bsp=E0000001c0210d70
 [<a0000001000815a0>] migration_thread+0x680/0x700
                                sp=E0000001c021fe00 bsp=E0000001c0210ca0
 [<a0000001000b9630>] kthread+0x110/0x140
                                sp=E0000001c021fe00 bsp=E0000001c0210c68
 [<a000000100013cf0>] kernel_thread_helper+0x30/0x60
                                sp=E0000001c021fe30 bsp=E0000001c0210c40
 [<a00000010000a0c0>] start_kernel_thread+0x20/0x40
                                sp=E0000001c021fe30 bsp=E0000001c0210c40

