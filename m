From: Meelis Roos <mroos@linux.ee>
Date: Tue, 21 Oct 2014 06:59:51 +0000
Subject: Re: kernel BUG at kernel/sched/core.c:2702!
Message-Id: <alpine.LRH.2.11.1410210956090.28680@adalberg.ut.ee>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.LRH.2.11.1410171401110.25429@adalberg.ut.ee> <alpine.LRH.2.11.1410191515150.32417@adalberg.ut.ee>
In-Reply-To: <alpine.LRH.2.11.1410191515150.32417@adalberg.ut.ee>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

> > I am seeing this BUG on 3 different sparc64 machines with yesterdays=20
> > git. sparc64-specific known problems were just fixed before,=20
> > 3.17.0-07551-g052db7e + slab alignment fix patch + sparc64 SIGBUS fix=20
> > patch is working stable for me, whereas 3.17.0-09670-g0429fbc + SIGBUS =

> > patch fails on 3 machines (all I tried). Will try bisecting later if I =

> > get time.
>=20
> Dave Miller identified it as a sparc64-specific problem with=20
> CONFIG_SCHED_STACK_END_CHECK in another thread and his fix is working=20
> for me.

The fix commit was=20
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=
=E2653143d7d79a49f1a961aeae1d82612838b12c=20
for sparc64 (for background).

Now I hit the same problem on ia64 (rx2620) with 3.18-rc1 and=20
CONFIG_SCHED_STACK_END_CHECK enabled:

[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x01000000-0x3e873fff]
[    0.000000]   node   0: [mem 0x3eb90000-0x3ee77fff]
[    0.000000]   node   0: [mem 0x3fc00000-0x3fe27fff]
[    0.000000]   node   0: [mem 0x100000000-0x5ffffbfff]
[    0.000000]   node   0: [mem 0x4040000000-0x40feffbfff]
[    0.000000]   node   0: [mem 0x40ff000000-0x40ffc2ffff]
[    0.000000]   node   0: [mem 0x40ffc9c000-0x40ffe03fff]
[    0.000000]   node   0: [mem 0x40ffe80000-0x40fffe3fff]
[    0.000000] Initmem setup node 0 [mem 0x01000000-0x40fffe3fff]
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Tota=
l pages: 1565221
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=3Dscsi0:/EFI/gentoo/boot/vml=
inuz root=3D/dev/sda3  ro
[    0.000000] PID hash table entries: 4096 (order: 1, 32768 bytes)
[    0.000000] Sorting __ex_table...
[    0.000000] Memory: 25028864K/25129440K available (8621K kernel code, 52=
8K rwdata, 932K rodata, 656K init, 286K bss, 100576K reserved)
[    0.000000] SLUB: HWalign=128, Order=3D0-3, MinObjects=3D0, CPUs=3D2, No=
des=3D8
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  RCU restricting CPUs from NR_CPUS=3D4 to nr_cpu_ids=3D2.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=
=3D2
[    0.000000] NR_IRQS:384
[    0.000000] ACPI: Local APIC address c0000000fee00000
[    0.000000] GSI 36 (level, low) -> CPU 0 (0x0000) vector 48
[    0.000000] Console: colour VGA+ 80x25
[    0.008000] Calibrating delay loop... 2390.01 BogoMIPS (lpjG80032)
[    0.016088] pid_max: default: 32768 minimum: 301
[    0.016225] ACPI: Core revision 20140828
[    0.020263] ACPI: All ACPI Tables successfully acquired
[    0.021734] Dentry cache hash table entries: 4194304 (order: 11, 3355443=
2 bytes)
[    0.050128] Inode-cache hash table entries: 2097152 (order: 10, 16777216=
 bytes)
[    0.062884] Mount-cache hash table entries: 65536 (order: 5, 524288 byte=
s)
[    0.063092] Mountpoint-cache hash table entries: 65536 (order: 5, 524288=
 bytes)
[    0.064677] kernel BUG at kernel/sched/core.c:2702!
[    0.064811] swapper/0[0]: bugcheck! 0 [1]
[    0.068000] Modules linked in:
[    0.068000]=20
[    0.068000] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.18.0-rc1 #13
[    0.068000] task: a000000100b40000 ti: a000000100b40cb0 task.ti: a000000=
100b40cb0
[    0.068000] psr : 00001010084a6010 ifs : 80000000000015ae ip  : [<a00000=
01008624e0>]    Not tainted (3.18.0-rc1)
[    0.068000] ip is at __schedule+0x1100/0x1520
[    0.068000] unat: 0000000000000000 pfs : 00000000000015ae rsc : 00000000=
00000003
[    0.068000] rnat: e000000001200880 bsps: a000000100b40000 pr  : 80000000=
ff509669
[    0.068000] ldrs: 0000000000000000 ccv : 0000000003dad2c2 fpsr: 0009804c=
8a70433f
[    0.068000] csd : 0000000000000000 ssd : 0000000000000000
[    0.068000] b0  : a0000001008624e0 b6  : a000000100a50350 b7  : a0000001=
0049ff00
[    0.068000] f6  : 000000000000000000000 f7  : 1003e0044b82fa09b5a53
[    0.068000] f8  : 1003e0000000000000084 f9  : 1003e00000000007b5ccd
[    0.068000] f10 : 1003e20c49ba5e353f7cf f11 : 1003e00000000000fca57
[    0.068000] r1  : a000000100dab340 r2  : a000000100b934d8 r3  : a0000001=
00b934e0
[    0.068000] r8  : 0000000000000027 r9  : 00000000000004d8 r10 : 00000000=
0000fffe
[    0.068000] r11 : 00000000000004d6 r12 : a000000100b47e20 r13 : a0000001=
00b40000
[    0.068000] r14 : a000000100babbc0 r15 : a000000100b934e0 r16 : 00000000=
0000026b
[    0.068000] r17 : 0000000000007fff r18 : a000000100b83ca8 r19 : 00000000=
0000000f
[    0.068000] r20 : 000000000000000f r21 : 0000000000000004 r22 : 00000000=
00000004
[    0.068000] r23 : 0000000000000000 r24 : a000000100a10588 r25 : 00000000=
00000000
[    0.068000] r26 : 0000000000000000 r27 : a000000100b69a28 r28 : a0000001=
00b83b30
[    0.068000] r29 : 0000000000000005 r30 : c0000000f4050000 r31 : a0000001=
00b83b30
[    0.068000]=20
[    0.068000] Call Trace:
[    0.068000]  [<a000000100013090>] show_stack+0x90/0xc0
[    0.068000]                                 sp=A000000100b47a00 bsp=A000=
000100b41198
[    0.068000] Disabling lock debugging due to kernel taint
[    0.184005] Kernel panic - not syncing: Attempted to kill the idle task!

--=20
Meelis Roos (mroos@linux.ee)
