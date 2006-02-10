From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 10 Feb 2006 23:25:02 +0000
Subject: RE: some new unaligned access while booting ia64 (HP rx2620)
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05AD5D10@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602021946.k12Jk446028921@agluck-lia64.sc.intel.com>
In-Reply-To: <200602021946.k12Jk446028921@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Moore, Robert" <robert.moore@intel.com>, Thomas Renninger <trenn@suse.de>, "Brown, Len" <len.brown@intel.com>
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

A 16MB log_buf was enough.

Here is the initial trace up until the unaligned access messages:

Linux version 2.6.16-rc2-zx1-smp (aegl@linux-t10) (gcc version 3.4.3
20050227 (Red Hat 3.4.3-22.1)) #7 SMP Fri Feb 10 15:17:06 PST 2006
EFI v1.10 by HP: SALsystab=0x3fefa000 ACPI 2.0=0x3fd5e000
SMBIOS=0x3fefc000 HCDP=0x3fd5c000
PCDP: v0 at 0x3fd5c000
Explicit "console="; ignoring PCDP
warning: skipping physical page 0
Initial ramdisk at: 0xe00000407ee5b000 (1303589 bytes)
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
Kernel command line: BOOT_IMAGE=scsi0:EFI\redhat\l-zx1-smp.gz
console=ttyS0 root=LABEL=/ ro
PID hash table entries: 4096 (order: 12, 131072 bytes)
Console: colour dummy device 80x25
Dentry cache hash table entries: 262144 (order: 7, 2097152 bytes)
Inode-cache hash table entries: 131072 (order: 6, 1048576 bytes)
Memory: 2041632k/2086064k available (8308k code, 43248k reserved, 3585k
data, 272k init)
McKinley Errata 9 workaround not needed; disabling it
Mount-cache hash table entries: 1024
 tbxface-0109 [02] load_tables           : ACPI Tables successfully
acquired
Parsing all Control Methods:
Table [DSDT](id 000D) - 158 Objects with 11 Devices 106 Methods 0
Regions
Parsing all Control Methods:
Table [SSDT](id 0004) - 13 Objects with 1 Devices 9 Methods 0 Regions
Parsing all Control Methods:
Table [SSDT](id 0005) - 29 Objects with 3 Devices 23 Methods 0 Regions
Parsing all Control Methods:
Table [SSDT](id 0006) - 69 Objects with 9 Devices 41 Methods 0 Regions
Parsing all Control Methods:
Table [SSDT](id 0007) - 69 Objects with 9 Devices 41 Methods 0 Regions
Parsing all Control Methods:
Table [SSDT](id 0008) - 69 Objects with 9 Devices 41 Methods 0 Regions
Parsing all Control Methods:
Table [SSDT](id 0009) - 69 Objects with 9 Devices 41 Methods 0 Regions
Parsing all Control Methods:
Table [SSDT](id 000A) - 7 Objects with 0 Devices 5 Methods 0 Regions
Parsing all Control Methods:
Table [SSDT](id 000B) - 7 Objects with 0 Devices 5 Methods 0 Regions
ACPI Namespace successfully loaded at root a000000101bb41e0
evxfevnt-0079 [03] enable                : System is already in ACPI
mode
Boot processor id 0x0/0x0
CPU 1: synchronized ITC with CPU 0 (last diff -2 cycles, maxerr 554
cycles)
Brought up 2 CPUs
Total of 2 processors activated (3891.20 BogoMIPS).
migration_cost225
checking if image is initramfs... it is
Freeing initrd memory: 1264kB freed
NET: Registered protocol family 16
ACPI: bus type pci registered
ACPI: Subsystem revision 20060127
evgpeblk-0941 [06] ev_create_gpe_block   : GPE 00 to 0F [_GPE] 2 regs on
int 0x24
evgpeblk-0941 [06] ev_create_gpe_block   : GPE 10 to 1F [_GPE] 2 regs on
int 0x24
evgpeblk-1037 [05] ev_initialize_gpe_bloc: Found 0 Wake, Enabled 0
Runtime GPEs in this block
evgpeblk-1037 [05] ev_initialize_gpe_bloc: Found 0 Wake, Enabled 1
Runtime GPEs in this block
Completing Region/Field/Buffer/Package initialization:.
Initialized 0/0 Regions 0/0 Fields 0/0 Buffers 1/1 Packages (499 nodes)
Executing all Device _STA and_INI methods:..[ACPI Debug]  String: [0x04]
"_INI"
[ACPI Debug]  String: [0x1E] "Pointer And Rev are Not valid
"
[ACPI Debug]  String: [0x29] "Initializing the SCRAM data struct access"
[ACPI Debug]  String: [0x0E] "Executing GFIT"
[ACPI Debug]  String: [0x1D] "Init of scratch RAM complete!"
......................................................
56 Devices found - executed 0 _STA, 1 _INI methods
ACPI: Interpreter enabled
ACPI: Using IOSAPIC for interrupt routing
[ACPI Debug]  String: [0x0A] "CLIB.SBA 1"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x0B] "PARS.GPTR 2"
[ACPI Debug]  Integer: 0x00000002
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1A] "PARS.GPTR: Getting Sba Ptr"
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP1"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP2"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x0B] "Sba Ptr is "
[ACPI Debug]  Integer: 0x3FEF8070
[ACPI Debug]  String: [0x0A] "CLIB.BMC 2"
[ACPI Debug]  Integer: 0x00000002
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x0B] "PARS.GPTR 2"
[ACPI Debug]  Integer: 0x00000005
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1A] "PARS.GPTR: Getting BMC Ptr"
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP1"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x0B] "BMC Ptr is "
[ACPI Debug]  Integer: 0x3FEF8020
[ACPI Debug]  String: [0x0A] "CLIB.BMC 2"
[ACPI Debug]  Integer: 0x00000002
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x0B] "PARS.GPTR 2"
[ACPI Debug]  Integer: 0x00000005
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1A] "PARS.GPTR: Getting BMC Ptr"
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP1"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x0B] "BMC Ptr is "
[ACPI Debug]  Integer: 0x3FEF8020
[ACPI Debug]  String: [0x06] "_STA 0"
[ACPI Debug]  String: [0x0A] "CLIB.LBA 1"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x0B] "PARS.GPTR 2"
[ACPI Debug]  Integer: 0x00000003
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1A] "PARS.GPTR: Getting Lba Ptr"
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP1"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP2"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP3"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x0B] "Lba Ptr is "
[ACPI Debug]  Integer: 0x3FEF81E0
[ACPI Debug]  String: [0x06] "_HID 0"
[ACPI Debug]  String: [0x0A] "CLIB.LBA 1"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x0B] "PARS.GPTR 2"
[ACPI Debug]  Integer: 0x00000003
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1A] "PARS.GPTR: Getting Lba Ptr"
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP1"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP2"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP3"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x0B] "Lba Ptr is "
[ACPI Debug]  Integer: 0x3FEF81E0
[ACPI Debug]  String: [0x0A] "CLIB.LBA 1"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x0B] "PARS.GPTR 2"
[ACPI Debug]  Integer: 0x00000003
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1A] "PARS.GPTR: Getting Lba Ptr"
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP1"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP2"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP3"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x0B] "Lba Ptr is "
[ACPI Debug]  Integer: 0x3FEF81E0
[ACPI Debug]  String: [0x06] "_STA 0"
[ACPI Debug]  String: [0x0A] "CLIB.LBA 1"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x0B] "PARS.GPTR 2"
[ACPI Debug]  Integer: 0x00000003
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1A] "PARS.GPTR: Getting Lba Ptr"
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP1"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP2"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP3"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x0B] "Lba Ptr is "
[ACPI Debug]  Integer: 0x3FEF81E0
[ACPI Debug]  String: [0x06] "_BBN 0"
[ACPI Debug]  String: [0x0A] "CLIB.LBA 1"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x0B] "PARS.GPTR 2"
[ACPI Debug]  Integer: 0x00000003
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1A] "PARS.GPTR: Getting Lba Ptr"
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP1"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP2"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP3"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x0B] "Lba Ptr is "
[ACPI Debug]  Integer: 0x3FEF81E0
ACPI: PCI Root Bridge [PCI0] (0000:00)
[ACPI Debug]  String: [0x06] "_CRS 0"
[ACPI Debug]  String: [0x0A] "CLIB.LBA 1"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x0B] "PARS.GPTR 2"
[ACPI Debug]  Integer: 0x00000003
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1A] "PARS.GPTR: Getting Lba Ptr"
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP1"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP2"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP3"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x0B] "Lba Ptr is "
[ACPI Debug]  Integer: 0x3FEF81E0
[ACPI Debug]  String: [0x18] "Assert will not go fatal"
[ACPI Debug]  String: [0x0B] "PARS.GPTR 2"
[ACPI Debug]  Integer: 0x00000006
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x21] "PARS.GPTR: Getting SERIAL DEV Ptr"
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP1"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP2"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x12] "SERIAL DEV Ptr is "
[ACPI Debug]  Integer: 0x3FEF9980
[ACPI Debug]  String: [0x0B] "PARS.GPTR 2"
[ACPI Debug]  Integer: 0x00000006
[ACPI Debug]  Integer: 0x00010000
[ACPI Debug]  String: [0x21] "PARS.GPTR: Getting SERIAL DEV Ptr"
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP1"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x1F] "PARS.GUID: evaluating for COMP2"
[ACPI Debug]  Integer: 0x00000001
[ACPI Debug]  String: [0x12] "SERIAL DEV Ptr is "
[ACPI Debug]  Integer: 0x3FEF99A0
kernel unaligned access to 0xe000004040e7a434, ip=0xa0000001003c81a0
kernel unaligned access to 0xe000004040e7a46c, ip=0xa0000001003c81a0
kernel unaligned access to 0xe000004040e7a4bc, ip=0xa0000001003c81a0
kernel unaligned access to 0xe000004040e7a42c, ip=0xa0000001003c6ca1
kernel unaligned access to 0xe000004040e7a434, ip=0xa0000001003c6cb1
[ACPI Debug]  String: [0x06] "_CRS 0"
[ACPI Debug]  String: [0x0A] "CLIB.LBA 1"
[ACPI Debug]  Integer: 0x00000000
[ACPI Debug]  String: [0x0B] "PARS.GPTR 2"
