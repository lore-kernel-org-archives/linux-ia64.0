From: Robin Holt <holt@sgi.com>
Date: Tue, 24 Jun 2008 14:39:23 +0000
Subject: FW: [BISECT] Boot failure on ia64.
Message-Id: <20080624143922.GK10123@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Oops, missed sending this to the ia64 mailing list.

Robin

----- Forwarded message from Robin Holt <holt@sgi.com> -----

Date: Tue, 24 Jun 2008 07:30:14 -0500
From: Robin Holt <holt@sgi.com>
To: tony.luck@intel.com, Alex Chiang <achiang@hp.com>
Cc: linux-kernel@vger.kernel.org
Subject: [BISECT] Boot failure on ia64.

I bisected to this commit 3463a93def55c309f3c0d0a8aaf216be3be42d64

3463a93def55c309f3c0d0a8aaf216be3be42d64 is first bad commit
commit 3463a93def55c309f3c0d0a8aaf216be3be42d64
Author: Alex Chiang <achiang@hp.com>
Date:   Wed Jun 11 17:29:27 2008 -0600

    [IA64] Update check_sal_cache_flush to use platform_send_ipi()
...

This fails to boot on any sn2 ia64 with the sn2_defconfig.

Here is the output from that boot.

fs0:\efi\SuSE> elilo net0:holt/v1 root=/dev/sda7 console=ttySG0
ELILO
Uncompressing Linux... done
Linux version 2.6.26-rc5-00223-g3463a93 (holt@attica) (gcc version 4.1.2 20070115 (prerelease) (SUSE Linux)) #14 SMP Tue Jun 24 07:27:34 CDT 2008
EFI v1.10 by INTEL: SALsystab=0x6002c25f10 ACPI 2.0=0x6002c26000
console [sn_sal0] enabled
ACPI: RSDP 6002C26000, 0024 (r2    SGI)
ACPI: XSDT 6002C297F0, 0044 (r1    SGI  XSDTSN2    10001           7C)
ACPI: APIC 6002C26870, 032C (r1    SGI  APICSN2    10001            1)
ACPI: SRAT 6002C26BB0, 06B0 (r1    SGI  SRATSN2    10001            1)
ACPI: SLIT 6002C27270, 012C (r1    SGI  SLITSN2    10001            1)
ACPI: FACP 6002C27400, 00F4 (r3    SGI  FACPSN2    30001            1)
ACPI: DSDT 6002C2AAF0, 0024 (r2    SGI  DSDTSN2    20001          AAC)
ACPI: FACS 6002C273B0, 0040
Number of logical nodes in system = 16
Number of memory chunks in system = 16
SAL 3.2: SGI SN2 version 1.50
SAL Platform features: ITC_Drift
SAL: AP wakeup using external interrupt vector 0x12
Unable to handle kernel NULL pointer dereference (address 00000000000044b8)
swapper[0]: Oops 8813272891392 [1]
Modules linked in:

Pid: 0, CPU 0, comm:              swapper
psr : 00001010084a2010 ifs : 8000000000000491 ip  : [<a000000100087020>]    Not tainted (2.6.26-rc5-00223-g3463a93)
ip is at sn2_send_IPI+0x80/0x240
unat: 0000000000000000 pfs : 0000000000000491 rsc : 0000000000000003
rnat: 000000000000afc8 bsps: 000000000001003e pr  : 65691ba55aa68599
ldrs: 0000000000000000 ccv : 0000000000ff03ff fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000100942870 b6  : 00000000ff5423b0 b7  : e000000001fffc00
f6  : 1003e0000000000000000 f7  : 1003e0000000000000001
f8  : 1003e0000000000000000 f9  : 1003e0000000000000000
f10 : 100068fffffffff700000 f11 : 1003e0000000000000090
r1  : a000000100e8bd10 r2  : 00000000000044b8 r3  : 0000000000000000
r8  : 0000000000000000 r9  : 0000000000000000 r10 : ffffffffffff6298
r11 : 0000000000000000 r12 : a000000100adfc30 r13 : a000000100ad0000
r14 : 0000000000000000 r15 : e000006003106298 r16 : e000006003110000
r17 : a000000100d0dce8 r18 : a000000100d0dce8 r19 : a000000100d0dce8
r20 : 0000000000000000 r21 : ffffffffffff0420 r22 : 0000000000000800
r23 : 0000000000000007 r24 : e0000060030b0000 r25 : 000000000004ffff
r26 : a00000010097c460 r27 : e0000060030b0010 r28 : e0000060030b0000
r29 : e0000060030b0020 r30 : 0000000000000000 r31 : 00000000000007ff
Unable to handle kernel NULL pointer dereference (address 0000000000000000)
swapper[0]: Oops 8813272891392 [2]
Modules linked in:

Pid: 0, CPU 0, comm:              swapper
psr : 0000101008022018 ifs : 800000000000038c ip  : [<a000000100175b30>]    Not tainted (2.6.26-rc5-00223-g3463a93)
ip is at kmem_cache_alloc+0x70/0x180
unat: 0000000000000000 pfs : 0000000000000610 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 65691ba55aa69aa5
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000100040bc0 b6  : a000000100040e00 b7  : a00000010000b730
f6  : 1003e45b3373c16c02344 f7  : 1003e9e3779b97f4a7c16
f8  : 1003e0a00000010001426 f9  : 10006c7fffffffd73ea5c
f10 : 100068fffffffff700000 f11 : 1003e0000000000000090
r1  : a000000100e8bd10 r2  : a000000100bae950 r3  : a000000100bac860
r8  : 0000000000000000 r9  : 0000000000000000 r10 : a000000100ad0c54
r11 : 0000000000000000 r12 : a000000100adf100 r13 : a000000100ad0000
r14 : 0000000000000014 r15 : a000000100adf190 r16 : a000000100adf198
r17 : a000000100ca1480 r18 : a000000100adf17c r19 : a000000100adf170
r20 : 0000000000000000 r21 : 0000000000000000 r22 : a000000100adf170
r23 : a000000100adf174 r24 : 000000000000000c r25 : a000000100adf180
r26 : a000000100adf174 r27 : 0000000000000000 r28 : 0000000000000000
r29 : a000000100adf178 r30 : 000000007fffffff r31 : 000000000000000c

--
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/

----- End forwarded message -----
