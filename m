From: Bernhard Walle <bwalle@suse.de>
Date: Fri, 29 Aug 2008 16:03:02 +0000
Subject: kdump broken on Altix 350
Message-Id: <20080829180302.6e67c26e@halley.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Tony Luck <tony.luck@intel.com>, jlan@sgi.com
Cc: kexec@lists.infradead.org, linux-ia64@vger.kernel.org

Hi Tony,

your commit

    commit 10617bbe84628eb18ab5f723d3ba35005adde143
    Author: Tony Luck <tony.luck@intel.com>
    Date:   Tue Aug 12 10:34:20 2008 -0700

    [IA64] Ensure cpu0 can access per-cpu variables in early boot code

broke kdump on our Altix 350. I get following early crash in kdump
kernel:

------------------------------------- 8< ------------------------------

Pid: 1, CPU 0, comm:              swapper
psr : 00001010085a6010 ifs : 800000000000038a ip  :
[<a0000001004faaf0>]    Not tainted (2.6.27-rc2-default)
ip is at __rtnl_register+0x150/0x1a0
unat: 0000000000000000 pfs : 000000000000038b rsc : 0000000000000003
rnat: 0000000000000014 bsps: 000000000001003e pr  : 0000000000006581
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001004fab70 b6  : a0000001002a8de0 b7  : a000000100434340
f6  : 1003e0000000000000000 f7  : 1003e8888888888888889
f8  : 1003e0000000000000000 f9  : 1003e0000000000000001
f10 : 1003e0000000000000f00 f11 : 1003e00000000000000a0
r1  : a000000100c27bf0 r2  : a000000100a3db68 r3  : a000000100a32be0
r8  : 0000005200000051 r9  : a000000100a0ca40 r10 : 000000019873d109
r11 : fffffffe602b9dae r12 : e0000030192cfdf0 r13 : e0000030192c8000
r14 : 0000005200000071 r15 : 0000000000000000 r16 : 0000000000000000
r17 : a000000100a0be40 r18 : a000000100a3acb0 r19 : a000000100a3acb8
r20 : a000000100a32208 r21 : a000000100a321e8 r22 : 0000000000000000
r23 : e000003037449454 r24 : 0000000000000001 r25 : 0000000000000000
r26 : 0000000000000001 r27 : 00000010085a6010 r28 : e000003019298040
r29 : e000003019298030 r30 : 0000000000000000 r31 : a000000100a0ca38

Call Trace:
 [<a000000100016320>] show_stack+0x40/0xa0
                                sp=E0000030192cf9c0 bsp=E0000030192c90b0
 [<a000000100016c30>] show_regs+0x850/0x8a0
                                sp=E0000030192cfb90 bsp=E0000030192c9058
 [<a000000100039d90>] die+0x1b0/0x2c0
                                sp=E0000030192cfb90 bsp=E0000030192c9010
 [<a000000100609a00>] ia64_do_page_fault+0x9a0/0xb00
                                sp=E0000030192cfb90 bsp=E0000030192c8fb0
 [<a00000010000c720>] ia64_native_leave_kernel+0x0/0x270
                                sp=E0000030192cfc20 bsp=E0000030192c8fb0
 [<a0000001004faaf0>] __rtnl_register+0x150/0x1a0
                                sp=E0000030192cfdf0 bsp=E0000030192c8f60
 [<a0000001004fab70>] rtnl_register+0x30/0x80
                                sp=E0000030192cfdf0 bsp=E0000030192c8f28
 [<a000000100808a00>] rtnetlink_init+0x180/0x2a0
                                sp=E0000030192cfdf0 bsp=E0000030192c8f08
 [<a000000100809a40>] netlink_proto_init+0x380/0x3e0
                                sp=E0000030192cfdf0 bsp=E0000030192c8ec8
 [<a00000010000a960>] do_one_initcall+0xa0/0x2e0
                                sp=E0000030192cfdf0 bsp=E0000030192c8e88
 [<a0000001007c4700>] kernel_init+0x4c0/0x580
                                sp=E0000030192cfe30 bsp=E0000030192c8e68
 [<a000000100014870>] kernel_thread_helper+0xd0/0x100
                                sp=E0000030192cfe30 bsp=E0000030192c8e40
 [<a00000010000a4c0>] start_kernel_thread+0x20/0x40
                                sp=E0000030192cfe30 bsp=E0000030192c8e40
Kernel panic - not syncing: Attempted to kill init!

------------------------------------- >8 ------------------------------

Since the code is very IA64-specific and I don't have the time now to
read all data sheets, I need your help to resolve that issue. :)


Bernhard
--=20
Bernhard Walle, SUSE Linux Products GmbH, Architecture Development
