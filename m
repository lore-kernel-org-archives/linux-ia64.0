From: Luming Yu <luming.yu@gmail.com>
Date: Wed, 09 Dec 2009 06:45:05 +0000
Subject: Re: [RFC PATCH] Add TRACE_IRQFLAGS_SUPPORT, LOCKDEP_SUPPORT then
Message-Id: <3877989d0912082245m3ee1ea14y3b3c8aca99e9f378@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0908272018va6ee8f7n7ab2838fdf1b26e6@mail.gmail.com>
	 <20090828062212.GB11552@elte.hu>
	 <3877989d0912032329u7c05a761wfdd5c7000b43218d@mail.gmail.com>
	 <4BDB13256095B24D9644F65379E604265C12@orsmsx505.amr.corp.intel.com>
	 <3877989d0912041919i458300d7ydce73cf77979dad3@mail.gmail.com>
	 <3877989d0912062156v7ba2a192y726f45b550ba50e@mail.gmail.com>
	 <12c511ca0912071335i1a805c2eudb6ecb8f726f6a80@mail.gmail.com>
	 <3877989d0912080425o4bf9e2beuf573e47930fd707f@mail.gmail.com>
In-Reply-To: <3877989d0912080425o4bf9e2beuf573e47930fd707f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Hellwig <hch@infradead.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "Yu, Fenghua" <fenghua.yu@intel.com>, Felix Blyakher <felixb@sgi.com>, "Li, Shaohua" <shaohua.li@intel.com>, Bob Picco <bob.picco@hp.com>

>
> But let me try more on other ia64 boxes that I can get access.
>
> Stay tuned.

I might have reproduced the problem on a HP ia64 system
with -32 kernel as the following info. But -31 kernel with
lockdep code enabled just works. ....debugging...

CPI: SSDT 000000003fdf66c8 000E0 (v01     HP   BL870c 00000006 INTL 20050309)
ACPI: SSDT 000000003fdf67b8 0013C (v01     HP   BL870c 00000006 INTL 20050309)
ACPI: SSDT 000000003fdf68f8 000E0 (v01     HP   BL870c 00000006 INTL 20050309)
ACPI: SSDT 000000003fdf69e8 0013C (v01     HP   BL870c 00000006 INTL 20050309)
ACPI: SSDT 000000003fdf6b28 000E0 (v01     HP   BL870c 00000006 INTL 20050309)
ACPI: SSDT 000000003fdf6c18 0013C (v01     HP   BL870c 00000006 INTL 20050309)
ACPI: SSDT 000000003fdf6d58 000E0 (v01     HP   BL870c 00000006 INTL 20050309)
ACPI: Local APIC address c0000000fee00000
SMP: Allowing 16 CPUs, 8 hotplug CPUs
Initial ramdisk at: 0xe0000100fe9d8000 (5607915 bytes)
SAL 3.20: HP version 3.11
SAL Platform features: None
SAL: AP wakeup using external interrupt vector 0xff
ACPI: Local APIC address c0000000fee00000
Unable to handle kernel paging request at virtual address a0000009019b0328
swapper[0]: Oops 8813272891392 [1]
Modules linked in:

Pid: 0, CPU 0, comm:              swapper
psr : 00001010084a2018 ifs : 8000000000000409 ip  :
[<a0000001000e8ff0>]    Not tainted (2.6.32)
ip is at save_trace+0xb0/0x1e0
unat: 0000000000000000 pfs : 0000000000000409 rsc : 0000000000000003
rnat: 000000001ad27480 bsps: 000000000001003e pr  : 656960155aa6a559
ldrs: 0000000000000000 ccv : 0000000001e600f3 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001000e8fc0 b6  : a000000100a6c440 b7  : e00000003f81f3a0
f6  : 000000000000000000000 f7  : 1003e0000000000000000
f8  : 1003e0000000000000000 f9  : 1003e0000000000000001
f10 : 10004c3ffffffff3c0000 f11 : 1003e0000000000000031
r1  : a00000010132c4b0 r2  : a000000100e07d60 r3  : 000000000000007c
r8  : a0000001018f2520 r9  : a0000009019b0328 r10 : 00000000ffffffff
r11 : a0000001019b0330 r12 : a000000100e07d60 r13 : a000000100e00000
r14 : a0000001018f2af0 r15 : 000000000003fffe r16 : ffffffffffffffff
r17 : 0000000000000001 r18 : 0000000000000000 r19 : 0000000000000000
r20 : a0000001019b0330 r21 : a000000101130a00 r22 : a0000001018f2c58
r23 : 0000000000000003 r24 : 0000000000040000 r25 : 0000000000040000
r26 : 0000000000000000 r27 : a0000001018f2b20 r28 : 0000000000001000
r29 : 0000000000000000 r30 : a000000100e00e00 r31 : a000000100e00dd8
Unable to handle kernel NULL pointer dereference (address 0000000000000000)
swapper[0]: Oops 8813272891392 [2]
Modules linked in:

Pid: 0, CPU 0, comm:              swapper
psr : 0000101008022018 ifs : 800000000000048e ip  :
[<a0000001001e1a60>]    Not tainted (2.6.32)
ip is at kmem_cache_alloc+0xe0/0x3c0
unat: 0000000000000000 pfs : 000000000000048e rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 656960155aa65965
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001001e19f0 b6  : a000000100042420 b7  : a00000010000c9b0
f6  : 1003ea877512c4d0b873a f7  : 1003e9e3779b97f4a7c16
f8  : 1003e0a000000100015f7 f9  : 1003e0000000000000001
f10 : 10004c3ffffffff3c0000 f11 : 1003e0000000000000031
r1  : a00000010132c4b0 r2  : 0000000012000000 r3  : a000000100e00014
r8  : 0000000000000002 r9  : 00000000003fff2f r10 : a000000101151a60
r11 : a000000101151a60 r12 : a000000100e07230 r13 : a000000100e00000
r14 : 0000000000000000 r15 : 0000000000200000 r16 : 0000000000000000
r17 : 0000000000000000 r18 : a000000100e01984 r19 : a000000100e072ac
r20 : a000000100e072a4 r21 : 0000000000000000 r22 : a000000100e072a0
r23 : a000000100e072a4 r24 : 0000000000000001 r25 : 0000000000000000
r26 : a000000100e072a0 r27 : 0000000000000000 r28 : a000000100e072a8
r29 : 000000007fffffff r30 : a00000010110a030 r31 : 0000000000000002
