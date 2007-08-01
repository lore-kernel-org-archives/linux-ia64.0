From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 01 Aug 2007 05:48:16 +0000
Subject: ACPI: Uninitialized spinlocks & Unable to dump stack
Message-Id: <Pine.LNX.4.64.0707312246390.14878@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

With todays git I get (sn2_defconfig w/ spinlock debuggin):

Uncompressing Linux... done
Linux version 2.6.23-rc1 (clameter@schroedinger) (gcc version 4.1.2=20
20061115 (prerelease) (Debian 4.1.1-21)) #3 SMP PREEMPT Tue Jul 31=20
22:42:03 PDT 2007
EFI v1.10 by INTEL: SALsystab=3D0x3002a09000 ACPI 2.0=3D0x3002a097f0
console [sn_sal0] enabled
ACPI: RSDP 3002A097F0, 0024 (r2    SGI)
ACPI: XSDT 3002A0E320, 0044 (r1    SGI  XSDTSN2    10001           5C)
ACPI: APIC 3002A09890, 008C (r1    SGI  APICSN2    10001            1)
ACPI: SRAT 3002A09930, 0150 (r1    SGI  SRATSN2    10001            1)
ACPI: SLIT 3002A09A90, 003C (r1    SGI  SLITSN2    10001            1)
ACPI: FACP 3002A09B30, 00F4 (r3    SGI  FACPSN2    30001            1)
ACPI: DSDT 3002A0D8A0, 0024 (r2    SGI  DSDTSN2    20001          9BA)
ACPI: FACS 3002A09AE0, 0040
Number of logical nodes in system =3D 4
Number of memory chunks in system =3D 4
SAL 2.9: SGI SN2 version 4.80
SAL Platform features: ITC_Drift
SAL: AP wakeup using external interrupt vector 0x12
No logical to physical processor mapping available
ACPI: Local APIC address c0000000fee00000
ACPI: Error parsing MADT - no IOSAPIC entries
register_intr: No IOSAPIC for GSI 52
BUG: spinlock bad magic on CPU#0, swapper/0
 lock: a000000100bf66d0, .magic: 00000000, .owner: <none>/-1, .owner_cpu:=20
0
unwind: cannot stack reg state!

Call Trace:
 [<a000000100013900>] show_stack+0x40/0xa0
                                sp=A000000100b67a80 bsp=A000000100b610b8
unwind: cannot stack reg state!
 [<a000000100013990>] dump_stack+0x30/0x60
                                sp=A000000100b67c50 bsp=A000000100b610a0
unwind: cannot stack reg state!
 [<a000000100433010>] spin_bug+0x110/0x180
                                sp=A000000100b67c50 bsp=A000000100b61068
unwind: cannot stack reg state!
 [<a0000001004330d0>] _raw_spin_unlock+0x50/0x120
                                sp=A000000100b67c50 bsp=A000000100b61038
unwind: cannot stack reg state!
 [<a0000001007eb560>] _spin_unlock+0x20/0xa0
                                sp=A000000100b67c50 bsp=A000000100b61018
unwind: cannot stack reg state!
 [<a00000010004ec40>] iosapic_register_intr+0xb40/0xba0
                                sp=A000000100b67c50 bsp=A000000100b60fa8
unwind: cannot stack reg state!
 [<a00000010000a5e0>] acpi_register_gsi+0xc0/0xe0



