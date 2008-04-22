From: Russ Anderson <rja@sgi.com>
Date: Tue, 22 Apr 2008 22:30:50 +0000
Subject: Boot breakage on Altix
Message-Id: <20080422223049.GA8765@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

The latest tree does not boot on Altix.
Looks like low bootmem is broken.
"low bootmem alloc of 128 bytes failed!"

The tree was pulled down using:
cg-clone git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git test

Built using arch/ia64/configs/sn2_defconfig (default settings).

I can look closer later tonight.

The output:
------------------------------------------------------------------------
Shell> fs2:efi\suse\elilo net0:rja/vmlinux.rja.2625 root=/dev/sda6 console=ttySG0 kdb=on
ELILO
Uncompressing Linux... done
Initializing cgroup subsys cpuset
Linux version 2.6.25 (rja@attica) (gcc version 4.1.2 20070115 (prerelease) (SUSE Linux)) #3 SMP Tue Apr 22 16:25:27 CDT 2008
EFI v1.10 by INTEL: SALsystab=0x46002c25010 ACPI 2.0=0x46002c25800
console [sn_sal0] enabled
ACPI: RSDP 46002C25800, 0024 (r2    SGI)
ACPI: XSDT 46002C29460, 0044 (r1    SGI  XSDTSN2    10001           5C)
ACPI: APIC 46002C258A0, 005C (r1    SGI  APICSN2    10001            1)
ACPI: SRAT 46002C25910, 00C0 (r1    SGI  SRATSN2    10001            1)
ACPI: SLIT 46002C259E0, 0030 (r1    SGI  SLITSN2    10001            1)
ACPI: FACP 46002C25A80, 00F4 (r3    SGI  FACPSN2    30001            1)
ACPI: DSDT 46002C28CB0, 0024 (r2    SGI  DSDTSN2    20001          6EA)
ACPI: FACS 46002C25A30, 0040
Number of logical nodes in system = 2
Number of memory chunks in system = 2
SAL 3.2: SGI SN2 version 1.42
SAL Platform features: ITC_Drift
SAL: AP wakeup using external interrupt vector 0x12
ACPI: Local APIC address c0000000fee00000
register_intr: No IOSAPIC for GSI 52
4 CPUs available, 4 CPUs total
MCA related initialization done
ACPI: RSDP 46002C25800, 0024 (r2    SGI)
ACPI: XSDT 46002C29460, 005C (r1    SGI  XSDTSN2    10001           5C)
ACPI: APIC 46002C258A0, 005C (r1    SGI  APICSN2    10001            1)
ACPI: SRAT 46002C25910, 00C0 (r1    SGI  SRATSN2    10001            1)
ACPI: SLIT 46002C259E0, 0030 (r1    SGI  SLITSN2    10001            1)
ACPI: FACP 46002C25A80, 00F4 (r3    SGI  FACPSN2    30001            1)
ACPI: DSDT 46002C28CB0, 06EA (r2    SGI  DSDTSN2    20101          6EA)
ACPI: FACS 46002C25A30, 0040
ACPI: SSDT 46002C27B50, 0095 (r2    SGI  SSDTSN2    20101           95)
ACPI: SSDT 46002C27C60, 0095 (r2    SGI  SSDTSN2    20101           95)
ACPI: SSDT 46002C293B0, 0095 (r2    SGI  SSDTSN2    20101           95)
SGI SAL version 1.42
Virtual mem_map starts at 0xa07ffffed2c80000
Zone PFN ranges:
  Normal   73401088 -> 90209280
Movable zone start PFN for each node
early_node_map[5] active PFN ranges
    0: 73401088 -> 73463807
    1: 90178304 -> 90208895
    1: 90209152 -> 90209237
    1: 90209242 -> 90209249
    1: 90209256 -> 90209262
low bootmem alloc of 128 bytes failed!
Kernel panic - not syncing: Out of low memory




An example of a good boot.
------------------------------------------------------------------------
Shell> fs2:efi\suse\elilo net0:rja/vmlinux.rja.2625 root=/dev/sda6 console=ttySG0 kdb=on
ELILO
Uncompressing Linux... done
Initializing cgroup subsys cpuset
Linux version 2.6.25-rc8 (rja@attica) (gcc version 4.1.2 20070115 (prerelease) (SUSE Linux)) #199 SMP Tue Apr 22 15:37:55 CDT 2008
EFI v1.10 by INTEL: SALsystab=0x46002c25010 ACPI 2.0=0x46002c25800
console [sn_sal0] enabled
ACPI: RSDP 46002C25800, 0024 (r2    SGI)
ACPI: XSDT 46002C29460, 0044 (r1    SGI  XSDTSN2    10001           5C)
ACPI: APIC 46002C258A0, 005C (r1    SGI  APICSN2    10001            1)
ACPI: SRAT 46002C25910, 00C0 (r1    SGI  SRATSN2    10001            1)
ACPI: SLIT 46002C259E0, 0030 (r1    SGI  SLITSN2    10001            1)
ACPI: FACP 46002C25A80, 00F4 (r3    SGI  FACPSN2    30001            1)
ACPI: DSDT 46002C28CB0, 0024 (r2    SGI  DSDTSN2    20001          6EA)
ACPI: FACS 46002C25A30, 0040
Number of logical nodes in system = 2
Number of memory chunks in system = 2
SAL 3.2: SGI SN2 version 1.42
SAL Platform features: ITC_Drift
SAL: AP wakeup using external interrupt vector 0x12
ACPI: Local APIC address c0000000fee00000
register_intr: No IOSAPIC for GSI 52
4 CPUs available, 4 CPUs total
MCA related initialization done
ACPI: RSDP 46002C25800, 0024 (r2    SGI)
ACPI: XSDT 46002C29460, 005C (r1    SGI  XSDTSN2    10001           5C)
ACPI: APIC 46002C258A0, 005C (r1    SGI  APICSN2    10001            1)
ACPI: SRAT 46002C25910, 00C0 (r1    SGI  SRATSN2    10001            1)
ACPI: SLIT 46002C259E0, 0030 (r1    SGI  SLITSN2    10001            1)
ACPI: FACP 46002C25A80, 00F4 (r3    SGI  FACPSN2    30001            1)
ACPI: DSDT 46002C28CB0, 06EA (r2    SGI  DSDTSN2    20101          6EA)
ACPI: FACS 46002C25A30, 0040
ACPI: SSDT 46002C27B50, 0095 (r2    SGI  SSDTSN2    20101           95)
ACPI: SSDT 46002C27C60, 0095 (r2    SGI  SSDTSN2    20101           95)
ACPI: SSDT 46002C293B0, 0095 (r2    SGI  SSDTSN2    20101           95)
SGI SAL version 1.42
Virtual mem_map starts at 0xa07ffffed2c80000
Zone PFN ranges:
  Normal   73401088 -> 90209280
Movable zone start PFN for each node
early_node_map[5] active PFN ranges
    0: 73401088 -> 73463807
    1: 90178304 -> 90208895
    1: 90209152 -> 90209237
    1: 90209242 -> 90209249
    1: 90209256 -> 90209262
Built 2 zonelists in Node order, mobility grouping on.  Total pages: 93329
Policy zone: Normal
------------------------------------------------------------------------
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
