From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Sat, 01 Sep 2007 07:34:53 +0000
Subject: [PATCH][ia64][kdump] Fix problems on INIT
Message-Id: <1188632093.3930.6.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64 <linux-ia64@vger.kernel.org>, "Luck, Tony" <tony.luck@intel.com>
Cc: kexec@lists.infradead.org

Hi,

Here are patches for kdump on ia64 to fix the follwing problems:

  - [PATCH 1/2] Fix kernel panic in kdump on INIT

    I encountered the kernel panic when I sent an INIT without
    configuring kdump kernel image. The cause of this problem seems
    that machine_kdump_on_init() uses printk() in INIT
    context. Replacing it with ia64_mca_printk() fixes this problem.
    The panic message is attached at the end of this mail.

  - [PATCH 2/2] Fix kernel hangup in kdump on INIT

    Even after fixing the kernel panic problem mentioned above, I
    encontered the kernel hangup problem when I sent an INIT without
    configuring kdump kernel image. The kdump_init_notifier() on
    monarch CPU stops its operation if the kdump kernel image is not
    configured. On the other hand, kdump_init_notifier() on
    non-monarch CPUs get into spin because they don't know the fact
    the monarch stops its operation. This is the cause of this
    problem.

Thanks,
Kenji Kaneshige


machine_kdump_on_init(): kdump not configured
Unable to handle kernel NULL pointer dereference (address 0000000000000020)
INIT swapper 1[0]: Oops 11012296146944 [1]
Modules linked in: sunrpc binfmt_misc dm_mirror dm_mod fan sg eepro100 cont=
ainer e100 mii button thermal processor usb_storage ehci_hcd ohci_hcd

Pid: 0, CPU 1, comm:       INIT swapper 1
psr : 0000121808022030 ifs : 8000000000000813 ip  : [<a00000010006a3a1>]   =
 Not tainted
ip is at try_to_wake_up+0x5c1/0x740
unat: 0000000000000000 pfs : 0000000000000813 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 000000000000a685
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a00000010006a350 b6  : a000000100071540 b7  : e00000007fd08010
f6  : 1003e0000005b41d7540b f7  : 1003e00000000000005dc
f8  : 1003e000000002aaaaaab f9  : 1003e0000005b41d77388
f10 : 1003e35a3e8b515f27bd8 f11 : 1003e000000000000000f
r1  : a000000100bf9e20 r2  : 0000000000000000 r3  : a0000001009faa70
r8  : 0000003ba3d925e4 r9  : 0000003b9e207e0a r10 : e0000000010368d0
r11 : 0000003b9e207e0a r12 : e00000000115fa80 r13 : e000000001150000
r14 : 0000000000000400 r15 : 0000000000000400 r16 : e0000000010368c0
r17 : e000000001036ff8 r18 : e0000000010368c0 r19 : e00000007da10000
r20 : 0000000000000000 r21 : e000000001150000 r22 : e000000001036910
r23 : 0000000000000000 r24 : 0000000000000020 r25 : 0000000000000000
r26 : e000000001150040 r27 : e000000001150000 r28 : e000000001036fd8
r29 : a000000100a1a350 r30 : 0000000000000000 r31 : e000000001036880

Call Trace:
 [<a000000100013c20>] show_stack+0x40/0xa0
                                sp=E00000000115f650 bsp=E000000001151148
 [<a0000001000148a0>] show_regs+0x840/0x880
                                sp=E00000000115f820 bsp=E0000000011510f0
 [<a000000100036e80>] die+0x1a0/0x2a0
                                sp=E00000000115f820 bsp=E0000000011510a8
 [<a000000100061610>] ia64_do_page_fault+0x8d0/0xa00
                                sp=E00000000115f820 bsp=E000000001151058
 [<a00000010000b240>] ia64_leave_kernel+0x0/0x270
                                sp=E00000000115f8b0 bsp=E000000001151058
 [<a00000010006a3a0>] try_to_wake_up+0x5c0/0x740
                                sp=E00000000115fa80 bsp=E000000001150fb8
 [<a00000010006a550>] default_wake_function+0x30/0x60
                                sp=E00000000115fa90 bsp=E000000001150f88
 [<a0000001000a9670>] autoremove_wake_function+0x30/0xa0
                                sp=E00000000115fa90 bsp=E000000001150f50
 [<a0000001000641a0>] __wake_up_common+0x60/0x120
                                sp=E00000000115fa90 bsp=E000000001150f00
 [<a000000100067fd0>] __wake_up+0x50/0x80
                                sp=E00000000115fa90 bsp=E000000001150ec0
 [<a0000001000784b0>] wake_up_klogd+0x70/0xa0
                                sp=E00000000115fa90 bsp=E000000001150ea8
 [<a000000100079940>] release_console_sem+0x4a0/0x4c0
                                sp=E00000000115fa90 bsp=E000000001150e60
 [<a000000100078e40>] vprintk+0x7c0/0x940
                                sp=E00000000115fa90 bsp=E000000001150dd8
 [<a000000100079050>] printk+0x90/0xc0
                                sp=E00000000115fb00 bsp=E000000001150d78
 [<a00000010005f380>] machine_kdump_on_init+0x40/0xc0
                                sp=E00000000115fb50 bsp=E000000001150d60
 [<a00000010005f650>] kdump_init_notifier+0x250/0x280
                                sp=E00000000115fb50 bsp=E000000001150d30
 [<a000000100097c10>] notifier_call_chain+0x50/0xe0
                                sp=E00000000115fb50 bsp=E000000001150ce8
 [<a000000100097ce0>] __atomic_notifier_call_chain+0x40/0x60
                                sp=E00000000115fb50 bsp=E000000001150ca8
 [<a000000100097d40>] atomic_notifier_call_chain+0x40/0x60
                                sp=E00000000115fb50 bsp=E000000001150c78
 [<a0000001000b2160>] notify_die+0x80/0xa0
                                sp=E00000000115fb50 bsp=E000000001150c30
 [<a000000100049220>] ia64_init_handler+0x800/0x900
                                sp=E00000000115fb70 bsp=E000000001150bd8
 [<a000000100049b40>] ia64_os_init_virtual_begin+0x40/0x140
                                sp=E00000000115fb80 bsp=E000000001150bd8


