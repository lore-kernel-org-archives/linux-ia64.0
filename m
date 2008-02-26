From: Alex Chiang <achiang@hp.com>
Date: Tue, 26 Feb 2008 22:45:40 +0000
Subject: Re: Tiger oops in ia64_sal_physical_id_info (was [RFC]
Message-Id: <20080226224540.GC15862@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200802251027.15107.bjorn.helgaas@hp.com>
In-Reply-To: <200802251027.15107.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Li, Shaohua <shaohua.li@intel.com>:
> 
> I can't get the log with serial console, so I copied by hand,
> so maybe there are errors. There are a lot of other registers
> below, if you need know, I'll copy them too

I was able to reproduce this on my tiger:
 
PAL Version 5.37
SAL Version 3.00
FPSWA Version 1.18

memmap output:

Type       Start            End               # Pages   
BS_data    0000000000000000-0000000000000FFF  0000000000000001 0000000000000009
available  0000000000001000-0000000000006FFF  0000000000000006 0000000000000009
BS_data    0000000000007000-0000000000008FFF  0000000000000002 0000000000000009
available  0000000000009000-0000000000081FFF  0000000000000079 0000000000000009
RT_data    0000000000082000-0000000000083FFF  0000000000000002 8000000000000009
available  0000000000084000-0000000000084FFF  0000000000000001 0000000000000009
BS_data    0000000000085000-000000000009FFFF  000000000000001B 0000000000000009
RT_code    00000000000C0000-00000000000FFFFF  0000000000000040 8000000000000009
available  0000000000100000-000000000FF7FFFF  000000000000FE80 000000000000000B
BS_data    000000000FF80000-000000000FFFFFFF  0000000000000080 000000000000000B
available  0000000010000000-000000007D8FFFFF  000000000006D900 000000000000000B
BS_code    000000007D900000-000000007F97FFFF  0000000000002080 000000000000000B
available  000000007F980000-000000007F9FFFFF  0000000000000080 000000000000000B
RT_code    000000007FA00000-000000007FDFFFFF  0000000000000400 8000000000000009
PAL_code   000000007FE00000-000000007FE3FFFF  0000000000000040 8000000000000009
RT_code    000000007FE40000-000000007FE95FFF  0000000000000056 8000000000000009
available  000000007FE96000-000000007FF27FFF  0000000000000092 000000000000000B
BS_data    000000007FF28000-000000007FF2FFFF  0000000000000008 000000000000000B
RT_data    000000007FF30000-000000007FFFFFFF  00000000000000D0 8000000000000009
MemMapIO   00000000FE000000-00000000FEFFFFFF  0000000000001000 0000000000000001
RT_data    00000000FF000000-00000000FFFFFFFF  0000000000001000 8000000000000001

Uncompressing Linux... done
Linux version 2.6.25-rc3-00081-g7704a8b (achiang@blender) (gcc version 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)) #213 SMP Tue Feb 26 12:59:43 MST 2008
EFI v1.10 by INTEL: SALsystab=0x7fe4c8c0 ACPI=0x7ff84000 ACPI 2.0=0x7ff83000 MPS=0x7ff82000 SMBIOS=0xf0000
booting generic kernel on platform dig
Early serial console at I/O port 0x2f8 (options '115200')
console [uart0] enabled
ACPI: RSDP 7FF83000, 0024 (r2 INTEL )
ACPI: XSDT 7FF83090, 0034 (r1 INTEL  SR870BN4  1072002 MSFT    10013)
ACPI: FACP 7FF83138, 00F4 (r3 INTEL  SR870BN4  1072002 MSFT    10013)
ACPI: DSDT 7FF85000, 6D62 (r1  Intel SR870BN4        0 MSFT  100000D)
ACPI: FACS 7FF83318, 0040
ACPI: APIC 7FF83230, 00E6 (r1 INTEL  SR870BN4  1072002 MSFT    10013)
Entering add_active_range(0, 256, 32672) 0 entries of 51200 used
Entering add_active_range(0, 32746, 32755) 1 entries of 51200 used
Entering add_active_range(0, 65536, 147455) 2 entries of 51200 used
Entering add_active_range(0, 294912, 327649) 3 entries of 51200 used
Entering add_active_range(0, 327656, 327675) 4 entries of 51200 used
SAL 3.1: Intel Corp                       SR870BN4                         version 3.0
SAL Platform features: BusLock IRQ_Redirection
SAL: AP wakeup using external interrupt vector 0xf0
swapper[0]: IA-64 Illegal operation fault 0 [1]

Pid: 0, CPU 0, comm:              swapper
psr : 00001010084a2010 ifs : 8000000000000818 ip  : [<e00000017fe50f00>]    Not tainted (2.6.25-rc3-00081-g7704a8b)
ip is at 0xe00000017fe50f00
unat: 0000000000000000 pfs : 000000000000038f rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 80000000afb580ab
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70433f
csd : 0930ffff00090000 ssd : 0930ffff00090000
b0  : a000000100cd7800 b6  : e00000017fe50f00 b7  : e00000007fe08010
f6  : 000000000000000000000 f7  : 1003e0a7c5ac471b47843
f8  : 1003e00000000000027ff f9  : 10004c000000000000000
f10 : 10004cbffffffff340000 f11 : 1003e0000000000000033
r1  : e00000008008c4c0 r2  : e00000017fe50f00 r3  : e00000007fe50f40
r8  : 0000000000000000 r9  : 0000000000000000 r10 : 0000000000000000
r11 : 0000000000000000 r12 : a00000010120f8f0 r13 : a000000101200000
r14 : a00000010120fa18 r15 : a00000010120fa00 r16 : 0000000000000020
r17 : a00000010120f938 r18 : a00000010120f939 r19 : a00000010120fa80
r20 : a00000010120f904 r21 : 0000000000000001 r22 : a00000010120f906
r23 : a00000010120f902 r24 : 0000000000000000 r25 : 000000000000000f
r26 : 0000000000000000 r27 : 00000010084a2010 r28 : 0000000000000000
r29 : a000000101465ab0 r30 : e00000007fe48020 r31 : a000000101436af0
kernel unaligned access to 0xffffffffffffffff, ip=0xa0000001001440b0
kernel unaligned access to 0xffffffffffffffff, ip=0xa0000001001440c1
swapper[0]: error during unaligned kernel access
 -1 [2]

I looked through some SAL specs, and it turns out that
SAL_PHYSICAL_ID_INFO was introduced in v3.2, but this tiger
implements v3.1.

SAL *should* be returning -1 for unimplemented calls, but
something is going fantastically wrong here. Bjorn pointed out
that both r2 and b6 contain the IP. Maybe SAL isn't computing
branches correctly or something?

So what to do to work around a broken SAL? Seems like a chicken
and egg problem to me -- the only way to try and check if a call
is implemented or not is to call it, and calling it hangs the
machine... :(

Thoughts?

/ac

