From: Barclay Jameson <almightybeeij@gmail.com>
Date: Fri, 30 Aug 2013 03:13:27 +0000
Subject: Kernel oops
Message-Id: <CAMzumdY89wpc26ca7Tzg-GMqyMr6xODiniSzg+4gRyNKEVtszA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I have retried compiling the 3.4 Kernel this time in Squeeze. The
Kernel compiles fine and will boot up to 255 cores; however, after
that if fails out with the following Kernel oops when booting more
than 255 cores (Kernel is compiled with 512). Here is the boot log
with the option bootmem_debug=3D1. I have tried to shorten the boot log
and leave what I think are the important parts; however if anyone
needs the 35M boot log then I will gladly send as attachment.

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.4.49 (beeij@debian-hpc) (gcc version
4.4.5 (Debian 4.4.5-8) ) #16 SMP Thu Aug 29 14:41:59 CDT 2013
[    0.000000] EFI v1.10 by INTEL: SALsystab=3D0x1802c2d990 ACPI 2.0=3D0x18=
02c2da80
[    0.000000] booting generic kernel on platform sn2
[    0.000000] console [sn_sal0] enabled
[    0.000000] ACPI: RSDP 0000001802c2da80 00024 (v02    SGI)
[    0.000000] ACPI: XSDT 0000001802c38df0 00044 (v01    SGI  XSDTSN2
00010001    ? 00000094)
[    0.000000] ACPI: APIC 0000001802c2f5a0 0152C (v01    SGI  APICSN2
00010001    ? 00000001)
[    0.000000] ACPI: SRAT 0000001802c30ae0 02DB0 (v01    SGI  SRATSN2
00010001    ? 00000001)
[    0.000000] ACPI: SLIT 0000001802c338a0 0312C (v01    SGI  SLITSN2
00010001    ? 00000001)
[    0.000000] ACPI: FACP 0000001802c369e0 000F4 (v03    SGI  FACPSN2
00030001    ? 00000001)
[    0.000000] ACPI Warning: 32/64X length mismatch in Pm1aEventBlock:
32/0 (20120320/tbfadt-548)
[    0.000000] ACPI Warning: 32/64X length mismatch in
Pm1aControlBlock: 16/0 (20120320/tbfadt-548)
[    0.000000] ACPI Warning: 32/64X length mismatch in PmTimerBlock:
32/0 (20120320/tbfadt-548)
[    0.000000] ACPI Warning: 32/64X length mismatch in Gpe0Block: 64/0
(20120320/tbfadt-548)
[    0.000000] ACPI Warning: Invalid length for Pm1aEventBlock: 0,
using default 32 (20120320/tbfadt-629)
[    0.000000] ACPI Warning: Invalid length for Pm1aControlBlock: 0,
using default 16 (20120320/tbfadt-629)
[    0.000000] ACPI Warning: Invalid length for PmTimerBlock: 0, using
default 32 (20120320/tbfadt-629)
[    0.000000] ACPI: DSDT 0000001802c3af20 00024 (v02    SGI  DSDTSN2
00020001    ? 00002483)
[    0.000000] ACPI: FACS 0000001802c2e1e0 00040
[    0.000000] ACPI: Local APIC address c0000000fee00000
[    0.000000] 448 CPUs available, 448 CPUs total
[    0.000000] Number of logical nodes in system =3D 112
[    0.000000] Number of memory chunks in system =3D 112
[    0.000000] SMP: Allowing 448 CPUs, 0 hotplug CPUs

[=3D=3D=3D=3D=3D=3D=3D=3D=3DSNIP=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D]
[    0.000000] On node 63 totalpages: 504832
[    0.000000] free_area_init_node: node 63, pgdat e0000fd8040c1f80,
node_mem_map a0007ff57d62a000
[    0.000000]   DMA zone: 2650 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 502182 pages, LIFO batch:7
[    0.000000] bootmem::alloc_bootmem_core nidc size=18 [1 pages]
align=80 goal@00000000000 limit=3D0
[    0.000000] bootmem::__reserve nidc start?601318 end?601319 flags=3D1
[    0.000000] bootmem::alloc_bootmem_core nidc size=18000 [6 pages]
align=80 goal@00000000000 limit=3D0
[    0.000000] bootmem::__reserve nidc start?601319 end?60131f flags=3D1
[    0.000000] Could not find start_pfn for node 64
[    0.000000] On node 64 totalpages: 0
[    0.000000] free_area_init_node: node 64, pgdat e000101804102000,
node_mem_map a0007ff5b562a000
[    0.000000] Could not find start_pfn for node 65
[    0.000000] On node 65 totalpages: 0
[    0.000000] free_area_init_node: node 65, pgdat e000105804142080,
node_mem_map a0007ff5ed62a000
[    0.000000] Could not find start_pfn for node 66
[    0.000000] On node 66 totalpages: 0
[=3D=3D=3D=3D=3D=3D=3D=3D=3DSNIP=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D]

 [    0.000000] BUG: Bad page state in process swapper  pfn:40601318
[    0.000000] page:a0007ff5b5642d40 count:0 mapcount:1 mapping:
   (null) index:0x0
[    0.000000] page flags: 0x0()
[    0.000000] Modules linked in:
[    0.000000] Unable to handle kernel NULL pointer dereference
(address 0000000000000018)
[    0.000000] swapper[0]: Oops 11003706212352 [1]
[    0.000000] Modules linked in:
[    0.000000]
[    0.000000] Pid: 0, CPU 0, comm:              swapper
[    0.000000] psr : 00001210084a2018 ifs : 800000000000cc18 ip  :
[<a0000001003ea1b1>]    Not tainted (3.4.49)
[    0.000000] ip is at __copy_user+0x891/0x950
[    0.000000] unat: 0000000000000000 pfs : 0000000000000792 rsc :
0000000000000003
[    0.000000] rnat: 0000000000000000 bsps: 0000000000000000 pr  :
0bad0bad0baa55a9
[    0.000000] ldrs: 0000000000000000 ccv : 0000000000000000 fpsr:
0009804c8a70433f
[    0.000000] csd : 0000000000000000 ssd : 0000000000000000
[    0.000000] b0  : a000000100043430 b6  : a000000100043660 b7  :
a00000010000c3b0
[    0.000000] f6  : 000000000000000000000 f7  : 1003e9e3779b97f4a7c16
[    0.000000] f8  : 1003e0a00000010001577 f9  : 10006c7fffffffd73ea5c
[    0.000000] f10 : 1003e0000000000000000 f11 : 1003e0044b82fa09b5a53
[    0.000000] r1  : a000000100dfa9e0 r2  : a000000100ac75f0 r3  :
a000000100ac75f8
[    0.000000] r8  : 0000000000000298 r9  : 0000000000000013 r10 :
0000000000000000
[    0.000000] r11 : 0bad0bad0baa11e9 r12 : a000000100ac7550 r13 :
a000000100ac0000
[    0.000000] r14 : a000000100e44080 r15 : a000000100e44030 r16 :
0000000000000298
[    0.000000] r17 : 0000000000000010 r18 : 0000000000000018 r19 :
a000000100ac7850
[    0.000000] r20 : 0000000000000290 r21 : a000000100ac75b4 r22 :
a000000100c12f20
[    0.000000] r23 : a000000100ac75b0 r24 : 0000000000000000 r25 :
a000000100e44030
[    0.000000] r26 : a0000001007ea718 r27 : 0000000000018869 r28 :
a000000100ac4000
[    0.000000] r29 : 0000000000000014 r30 : 0000000000000000 r31 :
0000000000000792

It looks like after Node 64 which would be cores 256 and up, it can
not find start_pfn and
it shows 0 total pages. The instruction pointer is at
[__copy_user+0x891/0x950].  In the meantime I
have compiled the 2.6.35 Kernel with support for 1024 CPUs that works
as a hold over. Anyone have any ideas as to why it is failing out at
this point?

Thanks,

Beeij
