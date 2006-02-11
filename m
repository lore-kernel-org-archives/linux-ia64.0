From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 11 Feb 2006 00:39:55 +0000
Subject: RE: some new unaligned access while booting ia64 (HP rx2620)
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05AD5E4F@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602021946.k12Jk446028921@agluck-lia64.sc.intel.com>
In-Reply-To: <200602021946.k12Jk446028921@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Moore, Robert" <robert.moore@intel.com>, Thomas Renninger <trenn@suse.de>, "Brown, Len" <len.brown@intel.com>
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

> This only contains the output of stores to the ACPI "debug" object,
> not the full trace output. However, "_CRS 0" may help

So ignoring ACPI_DEBUG=3Dy for the moment, I put in a WARN_ON() in the
unaligned trap handler to get some stack traces when the unaligned
access happened.

Here's the boot log from that (note that there are perhaps more
unaligned
accesses than this, but the kernel rate limiting code kicks in at five
messages).

-Tony

Linux version 2.6.16-rc2-zx1-smp (aegl@linux-t10) (gcc version 3.4.3
20050227 (Red Hat 3.4.3-22.1)) #2 SMP Fri Feb 10 16:29:13 PST 2006
EFI v1.10 by HP: SALsystab=3D0x3fefa000 ACPI 2.0=3D0x3fd5e000
SMBIOS=3D0x3fefc000 HCDP=3D0x3fd5c000
PCDP: v0 at 0x3fd5c000
Explicit "console=3D"; ignoring PCDP
warning: skipping physical page 0
Initial ramdisk at: 0xe00000407ee5b000 (1303576 bytes)
SAL 3.1: HP version 3.15
SAL Platform features: None
SAL: AP wakeup using external interrupt vector 0xff
No logical to physical processor mapping available
ACPI: Local APIC address c0000000fee00000
GSI 36 (level, low) -> CPU 0 (0x0000) vector 48
2 CPUs available, 2 CPUs total
MCA related initialization done
Virtual mem_map starts at 0xa0007fffc7900000
Built 1 zonelists
Kernel command line: BOOT_IMAGE=3Dscsi0:EFI\redhat\l-zx1-smp.gz
console=3DttyS0 root=3DLABEL=3D/ ro
PID hash table entries: 4096 (order: 12, 131072 bytes)
Console: colour dummy device 80x25
Dentry cache hash table entries: 262144 (order: 7, 2097152 bytes)
Inode-cache hash table entries: 131072 (order: 6, 1048576 bytes)
Memory: 2058128k/2086064k available (8134k code, 26784k reserved, 3552k
data, 272k init)
McKinley Errata 9 workaround not needed; disabling it
Mount-cache hash table entries: 1024
Boot processor id 0x0/0x0
CPU 1: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 554
cycles)
Brought up 2 CPUs
Total of 2 processors activated (3891.20 BogoMIPS).
migration_cost064
checking if image is initramfs... it is
Freeing initrd memory: 1264kB freed
NET: Registered protocol family 16
ACPI: bus type pci registered
ACPI: Subsystem revision 20060127
ACPI: Interpreter enabled
ACPI: Using IOSAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
kernel unaligned access to 0xe000004040e72604, ip=3D0xa0000001003afb00
Badness in ia64_handle_unaligned at arch/ia64/kernel/unaligned.c:1349

Call Trace:
 [<a000000100010a10>] show_stack+0x50/0xa0
                                sp=E00000407ff375c0 bsp=E00000407ff31428
 [<a000000100010a90>] dump_stack+0x30/0x60
                                sp=E00000407ff37790 bsp=E00000407ff31410
 [<a0000001000376f0>] ia64_handle_unaligned+0x2d0/0x2780
                                sp=E00000407ff37790 bsp=E00000407ff31388
 [<a00000010000bd70>] ia64_prepare_handle_unaligned+0x30/0x60
                                sp=E00000407ff37940 bsp=E00000407ff31388
 [<a00000010000b760>] ia64_leave_kernel+0x0/0x280
                                sp=E00000407ff37b50 bsp=E00000407ff31388
 [<a0000001003afb00>] acpi_rs_get_resource_source+0x60/0x1e0
                                sp=E00000407ff37d20 bsp=E00000407ff31328
 [<a0000001003ad9b0>] acpi_rs_convert_aml_to_resource+0x4d0/0x760
                                sp=E00000407ff37d20 bsp=E00000407ff312c8
 [<a0000001003ad190>] acpi_rs_convert_aml_to_resources+0x90/0x1c0
                                sp=E00000407ff37d30 bsp=E00000407ff31290
 [<a0000001003ac980>] acpi_rs_create_resource_list+0xc0/0x100
                                sp=E00000407ff37d40 bsp=E00000407ff31260
 [<a0000001003aff20>] acpi_rs_get_method_data+0x80/0xc0
                                sp=E00000407ff37d50 bsp=E00000407ff31230
 [<a0000001003ae3b0>] acpi_walk_resources+0xd0/0x240
                                sp=E00000407ff37d60 bsp=E00000407ff311e0
 [<a0000001006d6bd0>] pci_acpi_scan_root+0xf0/0x380
                                sp=E00000407ff37d70 bsp=E00000407ff31188
 [<a0000001003c4be0>] acpi_pci_root_add+0x4e0/0x660
                                sp=E00000407ff37d90 bsp=E00000407ff31138
 [<a0000001003d35f0>] acpi_bus_driver_init+0x70/0xe0
                                sp=E00000407ff37db0 bsp=E00000407ff31110
 [<a0000001003d53a0>] acpi_add_single_object+0x1540/0x1640
                                sp=E00000407ff37db0 bsp=E00000407ff31088
 [<a0000001003d5b40>] acpi_bus_scan+0x280/0x400
                                sp=E00000407ff37e00 bsp=E00000407ff31048
 [<a00000010097baf0>] acpi_scan_init+0x1f0/0x260
                                sp=E00000407ff37e20 bsp=E00000407ff31020
 [<a000000100009710>] init+0x470/0x7e0
                                sp=E00000407ff37e30 bsp=E00000407ff30fe8
 [<a000000100012c70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000407ff37e30 bsp=E00000407ff30fc0
 [<a000000100009140>] start_kernel_thread+0x20/0x40
                                sp=E00000407ff37e30 bsp=E00000407ff30fc0
kernel unaligned access to 0xe000004040e7263c, ip=3D0xa0000001003afb00
Badness in ia64_handle_unaligned at arch/ia64/kernel/unaligned.c:1349

Call Trace:
 [<a000000100010a10>] show_stack+0x50/0xa0
                                sp=E00000407ff375c0 bsp=E00000407ff31428
 [<a000000100010a90>] dump_stack+0x30/0x60
                                sp=E00000407ff37790 bsp=E00000407ff31410
 [<a0000001000376f0>] ia64_handle_unaligned+0x2d0/0x2780
                                sp=E00000407ff37790 bsp=E00000407ff31388
 [<a00000010000bd70>] ia64_prepare_handle_unaligned+0x30/0x60
                                sp=E00000407ff37940 bsp=E00000407ff31388
 [<a00000010000b760>] ia64_leave_kernel+0x0/0x280
                                sp=E00000407ff37b50 bsp=E00000407ff31388
 [<a0000001003afb00>] acpi_rs_get_resource_source+0x60/0x1e0
                                sp=E00000407ff37d20 bsp=E00000407ff31328
 [<a0000001003ad9b0>] acpi_rs_convert_aml_to_resource+0x4d0/0x760
                                sp=E00000407ff37d20 bsp=E00000407ff312c8
 [<a0000001003ad190>] acpi_rs_convert_aml_to_resources+0x90/0x1c0
                                sp=E00000407ff37d30 bsp=E00000407ff31290
 [<a0000001003ac980>] acpi_rs_create_resource_list+0xc0/0x100
                                sp=E00000407ff37d40 bsp=E00000407ff31260
 [<a0000001003aff20>] acpi_rs_get_method_data+0x80/0xc0
                                sp=E00000407ff37d50 bsp=E00000407ff31230
 [<a0000001003ae3b0>] acpi_walk_resources+0xd0/0x240
                                sp=E00000407ff37d60 bsp=E00000407ff311e0
 [<a0000001006d6bd0>] pci_acpi_scan_root+0xf0/0x380
                                sp=E00000407ff37d70 bsp=E00000407ff31188
 [<a0000001003c4be0>] acpi_pci_root_add+0x4e0/0x660
                                sp=E00000407ff37d90 bsp=E00000407ff31138
 [<a0000001003d35f0>] acpi_bus_driver_init+0x70/0xe0
                                sp=E00000407ff37db0 bsp=E00000407ff31110
 [<a0000001003d53a0>] acpi_add_single_object+0x1540/0x1640
                                sp=E00000407ff37db0 bsp=E00000407ff31088
 [<a0000001003d5b40>] acpi_bus_scan+0x280/0x400
                                sp=E00000407ff37e00 bsp=E00000407ff31048
 [<a00000010097baf0>] acpi_scan_init+0x1f0/0x260
                                sp=E00000407ff37e20 bsp=E00000407ff31020
 [<a000000100009710>] init+0x470/0x7e0
                                sp=E00000407ff37e30 bsp=E00000407ff30fe8
 [<a000000100012c70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000407ff37e30 bsp=E00000407ff30fc0
 [<a000000100009140>] start_kernel_thread+0x20/0x40
                                sp=E00000407ff37e30 bsp=E00000407ff30fc0
kernel unaligned access to 0xe000004040e7268c, ip=3D0xa0000001003afb00
Badness in ia64_handle_unaligned at arch/ia64/kernel/unaligned.c:1349

Call Trace:
 [<a000000100010a10>] show_stack+0x50/0xa0
                                sp=E00000407ff375c0 bsp=E00000407ff31428
 [<a000000100010a90>] dump_stack+0x30/0x60
                                sp=E00000407ff37790 bsp=E00000407ff31410
 [<a0000001000376f0>] ia64_handle_unaligned+0x2d0/0x2780
                                sp=E00000407ff37790 bsp=E00000407ff31388
 [<a00000010000bd70>] ia64_prepare_handle_unaligned+0x30/0x60
                                sp=E00000407ff37940 bsp=E00000407ff31388
 [<a00000010000b760>] ia64_leave_kernel+0x0/0x280
                                sp=E00000407ff37b50 bsp=E00000407ff31388
 [<a0000001003afb00>] acpi_rs_get_resource_source+0x60/0x1e0
                                sp=E00000407ff37d20 bsp=E00000407ff31328
 [<a0000001003ad9b0>] acpi_rs_convert_aml_to_resource+0x4d0/0x760
                                sp=E00000407ff37d20 bsp=E00000407ff312c8
 [<a0000001003ad190>] acpi_rs_convert_aml_to_resources+0x90/0x1c0
                                sp=E00000407ff37d30 bsp=E00000407ff31290
 [<a0000001003ac980>] acpi_rs_create_resource_list+0xc0/0x100
                                sp=E00000407ff37d40 bsp=E00000407ff31260
 [<a0000001003aff20>] acpi_rs_get_method_data+0x80/0xc0
                                sp=E00000407ff37d50 bsp=E00000407ff31230
 [<a0000001003ae3b0>] acpi_walk_resources+0xd0/0x240
                                sp=E00000407ff37d60 bsp=E00000407ff311e0
 [<a0000001006d6bd0>] pci_acpi_scan_root+0xf0/0x380
                                sp=E00000407ff37d70 bsp=E00000407ff31188
 [<a0000001003c4be0>] acpi_pci_root_add+0x4e0/0x660
                                sp=E00000407ff37d90 bsp=E00000407ff31138
 [<a0000001003d35f0>] acpi_bus_driver_init+0x70/0xe0
                                sp=E00000407ff37db0 bsp=E00000407ff31110
 [<a0000001003d53a0>] acpi_add_single_object+0x1540/0x1640
                                sp=E00000407ff37db0 bsp=E00000407ff31088
 [<a0000001003d5b40>] acpi_bus_scan+0x280/0x400
                                sp=E00000407ff37e00 bsp=E00000407ff31048
 [<a00000010097baf0>] acpi_scan_init+0x1f0/0x260
                                sp=E00000407ff37e20 bsp=E00000407ff31020
 [<a000000100009710>] init+0x470/0x7e0
                                sp=E00000407ff37e30 bsp=E00000407ff30fe8
 [<a000000100012c70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000407ff37e30 bsp=E00000407ff30fc0
 [<a000000100009140>] start_kernel_thread+0x20/0x40
                                sp=E00000407ff37e30 bsp=E00000407ff30fc0
kernel unaligned access to 0xe000004040e725fc, ip=3D0xa0000001003ae901
Badness in ia64_handle_unaligned at arch/ia64/kernel/unaligned.c:1349

Call Trace:
 [<a000000100010a10>] show_stack+0x50/0xa0
                                sp=E00000407ff375b0 bsp=E00000407ff31358
 [<a000000100010a90>] dump_stack+0x30/0x60
                                sp=E00000407ff37780 bsp=E00000407ff31340
 [<a0000001000376f0>] ia64_handle_unaligned+0x2d0/0x2780
                                sp=E00000407ff37780 bsp=E00000407ff312c0
 [<a00000010000bd70>] ia64_prepare_handle_unaligned+0x30/0x60
                                sp=E00000407ff37930 bsp=E00000407ff312c0
 [<a00000010000b760>] ia64_leave_kernel+0x0/0x280
                                sp=E00000407ff37b40 bsp=E00000407ff312c0
 [<a0000001003ae900>] acpi_resource_to_address64+0x340/0x3e0
                                sp=E00000407ff37d10 bsp=E00000407ff31280
 [<a0000001006d63d0>] resource_to_window+0x30/0xc0
                                sp=E00000407ff37d10 bsp=E00000407ff31258
 [<a0000001006d6490>] count_window+0x30/0x80
                                sp=E00000407ff37d10 bsp=E00000407ff31230
 [<a0000001003ae460>] acpi_walk_resources+0x180/0x240
                                sp=E00000407ff37d60 bsp=E00000407ff311e0
 [<a0000001006d6bd0>] pci_acpi_scan_root+0xf0/0x380
                                sp=E00000407ff37d70 bsp=E00000407ff31188
 [<a0000001003c4be0>] acpi_pci_root_add+0x4e0/0x660
                                sp=E00000407ff37d90 bsp=E00000407ff31138
 [<a0000001003d35f0>] acpi_bus_driver_init+0x70/0xe0
                                sp=E00000407ff37db0 bsp=E00000407ff31110
 [<a0000001003d53a0>] acpi_add_single_object+0x1540/0x1640
                                sp=E00000407ff37db0 bsp=E00000407ff31088
 [<a0000001003d5b40>] acpi_bus_scan+0x280/0x400
                                sp=E00000407ff37e00 bsp=E00000407ff31048
 [<a00000010097baf0>] acpi_scan_init+0x1f0/0x260
                                sp=E00000407ff37e20 bsp=E00000407ff31020
 [<a000000100009710>] init+0x470/0x7e0
                                sp=E00000407ff37e30 bsp=E00000407ff30fe8
 [<a000000100012c70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000407ff37e30 bsp=E00000407ff30fc0
 [<a000000100009140>] start_kernel_thread+0x20/0x40
                                sp=E00000407ff37e30 bsp=E00000407ff30fc0
kernel unaligned access to 0xe000004040e72604, ip=3D0xa0000001003ae911
Badness in ia64_handle_unaligned at arch/ia64/kernel/unaligned.c:1349

Call Trace:
 [<a000000100010a10>] show_stack+0x50/0xa0
                                sp=E00000407ff375b0 bsp=E00000407ff31358
 [<a000000100010a90>] dump_stack+0x30/0x60
                                sp=E00000407ff37780 bsp=E00000407ff31340
 [<a0000001000376f0>] ia64_handle_unaligned+0x2d0/0x2780
                                sp=E00000407ff37780 bsp=E00000407ff312c0
 [<a00000010000bd70>] ia64_prepare_handle_unaligned+0x30/0x60
                                sp=E00000407ff37930 bsp=E00000407ff312c0
 [<a00000010000b760>] ia64_leave_kernel+0x0/0x280
                                sp=E00000407ff37b40 bsp=E00000407ff312c0
 [<a0000001003ae910>] acpi_resource_to_address64+0x350/0x3e0
                                sp=E00000407ff37d10 bsp=E00000407ff31280
 [<a0000001006d63d0>] resource_to_window+0x30/0xc0
                                sp=E00000407ff37d10 bsp=E00000407ff31258
 [<a0000001006d6490>] count_window+0x30/0x80
                                sp=E00000407ff37d10 bsp=E00000407ff31230
 [<a0000001003ae460>] acpi_walk_resources+0x180/0x240
                                sp=E00000407ff37d60 bsp=E00000407ff311e0
 [<a0000001006d6bd0>] pci_acpi_scan_root+0xf0/0x380
                                sp=E00000407ff37d70 bsp=E00000407ff31188
 [<a0000001003c4be0>] acpi_pci_root_add+0x4e0/0x660
                                sp=E00000407ff37d90 bsp=E00000407ff31138
 [<a0000001003d35f0>] acpi_bus_driver_init+0x70/0xe0
                                sp=E00000407ff37db0 bsp=E00000407ff31110
 [<a0000001003d53a0>] acpi_add_single_object+0x1540/0x1640
                                sp=E00000407ff37db0 bsp=E00000407ff31088
 [<a0000001003d5b40>] acpi_bus_scan+0x280/0x400
                                sp=E00000407ff37e00 bsp=E00000407ff31048
 [<a00000010097baf0>] acpi_scan_init+0x1f0/0x260
                                sp=E00000407ff37e20 bsp=E00000407ff31020
 [<a000000100009710>] init+0x470/0x7e0
                                sp=E00000407ff37e30 bsp=E00000407ff30fe8
 [<a000000100012c70>] kernel_thread_helper+0xd0/0x100
                                sp=E00000407ff37e30 bsp=E00000407ff30fc0
 [<a000000100009140>] start_kernel_thread+0x20/0x40
                                sp=E00000407ff37e30 bsp=E00000407ff30fc0
ACPI: PCI Root Bridge [PCI1] (0000:20)
ACPI: PCI Root Bridge [PCI2] (0000:40)
ACPI: PCI Root Bridge [PCI3] (0000:60)
ACPI: PCI Root Bridge [PCI4] (0000:80)
ACPI: PCI Root Bridge [PCI6] (0000:c0)
Linux Plug and Play Support v0.97 (c) Adam Belay
