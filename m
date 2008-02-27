From: Russ Anderson <rja@sgi.com>
Date: Wed, 27 Feb 2008 00:23:36 +0000
Subject: Re: Tiger oops in ia64_sal_physical_id_info (was [RFC] regression:113134fcbca83619be4c68d0ca66db6093
Message-Id: <20080227002336.GB23088@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200802251027.15107.bjorn.helgaas@hp.com>
In-Reply-To: <200802251027.15107.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 26, 2008 at 04:50:48PM -0700, Alex Chiang wrote:
> From: Alex Chiang <achiang@hp.com>
> Subject: [PATCH] ia64: ia64_sal_physical_id_info work around broken SAL
> 
> Unimplemented SAL calls should return -1, but on at least one
> platform (Tiger with SAL v3.1), attempting to call SAL_PHYSICAL_ID_INFO
> (which was defined in SAL v3.2 and later) results in an oops and
> a hang.
> 
> Signed-off-by: Alex Chiang <achiang@hp.com>
> ---
> diff --git a/include/asm-ia64/sal.h b/include/asm-ia64/sal.h
> index 2251118..f4904db 100644
> --- a/include/asm-ia64/sal.h
> +++ b/include/asm-ia64/sal.h
> @@ -807,6 +807,10 @@ static inline s64
>  ia64_sal_physical_id_info(u16 *splid)
>  {
>         struct ia64_sal_retval isrv;
> +
> +       if (sal_revision < SAL_VERSION_CODE(3,2))
> +               return -1;
> +
>         SAL_CALL(isrv, SAL_PHYSICAL_ID_INFO, 0, 0, 0, 0, 0, 0, 0);
>         if (splid)
>                 *splid = isrv.v0;


That causes ia64_sal_physical_id_info() to fail on my Altix.  :-(


------------------------------------------------------------------
Shell> fs1:efi\suse\elilo net0:rja/vmlinux.rja.2624 root=/dev/sda8 console=ttySG0 kdb=on
ELILO
001c01 DEBUG: extInt.c line 501 ; PS [EINT4] interrupts enabled
001c01 DEBUG: extInt.c line 490 ; PS [EINT4] interrupts disabled
Uncompressing Linux... done
Initializing cgroup subsys cpuset
Linux version 2.6.24 (rja@attica) (gcc version 4.1.2 20070115 (prerelease) (SUSE Linux)) #39 SMP Tue Feb 26 18:08:59 CST 2008
EFI v1.10 by INTEL: SALsystab=0x6002c25290 ACPI 2.0=0x6002c25b10
console [sn_sal0] enabled
ACPI: RSDP 6002C25B10, 0024 (r2    SGI)
ACPI: XSDT 6002C29270, 0044 (r1    SGI  XSDTSN2    10001           5C)
ACPI: APIC 6002C25BB0, 00D4 (r1    SGI  APICSN2    10001            1)
ACPI: SRAT 6002C25CA0, 0200 (r1    SGI  SRATSN2    10001            1)
ACPI: SLIT 6002C25EB0, 0050 (r1    SGI  SLITSN2    10001            1)
ACPI: FACP 6002C25F20, 00F4 (r3    SGI  FACPSN2    30001            1)
ACPI: DSDT 6002C28D90, 0024 (r2    SGI  DSDTSN2    20001          4C4)
ACPI: FACS 6002C25380, 0040
Number of logical nodes in system = 6
Number of memory chunks in system = 6
SAL 2.9: SGI SN2 version 1.30
SAL Platform features: ITC_Drift
SAL: AP wakeup using external interrupt vector 0x12
ia64_sal_pltid failed with -1
ACPI: Local APIC address c0000000fee00000
register_intr: No IOSAPIC for GSI 52
14 CPUs available, 14 CPUs total
MCA related initialization done
ACPI: RSDP 6002C25B10, 0024 (r2    SGI)
ACPI: XSDT 6002C29270, 005C (r1    SGI  XSDTSN2    10001           5C)
ACPI: APIC 6002C25BB0, 00D4 (r1    SGI  APICSN2    10001            1)
ACPI: SRAT 6002C25CA0, 0200 (r1    SGI  SRATSN2    10001            1)
ACPI: SLIT 6002C25EB0, 0050 (r1    SGI  SLITSN2    10001            1)
ACPI: FACP 6002C25F20, 00F4 (r3    SGI  FACPSN2    30001            1)
ACPI: DSDT 6002C28D90, 04C4 (r2    SGI  DSDTSN2    20101          4C4)
ACPI: FACS 6002C25380, 0040
ACPI: SSDT 6002C27FF0, 0095 (r2    SGI  SSDTSN2    20101           95)
ACPI: SSDT 6002C28100, 00F5 (r2    SGI  SSDTSN2    20101           F5)
ACPI: SSDT 6002C28450, 024B (r2    SGI  SSDTSN2    20101          24B)
SGI SAL version 1.30
Virtual mem_map starts at 0xa07ffffed2c80000
Zone PFN ranges:
  Normal    6292224 -> 90241024
Movable zone start PFN for each node
early_node_map[11] active PFN ranges
    0:  6292224 ->  6323200
    0:  6815744 ->  6847488
    0:  7340032 ->  7371776
    1: 23069440 -> 23132160
    2: 39846656 -> 39972863
    3: 56623872 -> 56686592
    4: 73401088 -> 73432064
    5: 90178304 -> 90240639
    5: 90240896 -> 90240981
    5: 90240986 -> 90240993
    5: 90241000 -> 90241006
Built 6 zonelists in Node order, mobility grouping on.  Total pages: 438306
Policy zone: Normal
Kernel command line: BOOT_IMAGE=net0:rja/vmlinux.rja.2624  ro root=/dev/sda8 console=ttySG0 kdb=on
PID hash table entries: 4096 (order: 12, 32768 bytes)
Console: colour dummy device 80x25
console [ttySG0] enabled
Memory: 27886912k/28111104k available (8301k code, 242368k reserved, 5967k data, 1792k init)
SLUB: Genslabs, HWalign8, Order=0-2, MinObjects=8, CPUs, Nodes24
Dentry cache hash table entries: 4194304 (order: 9, 33554432 bytes)
Inode-cache hash table entries: 2097152 (order: 8, 16777216 bytes)
Mount-cache hash table entries: 4096
ACPI: Core revision 20070126
Boot processor id 0x0/0x0
ia64_sal_pltid failed with -1
ia64_sal_pltid failed with -1
ia64_sal_pltid failed with -1
ia64_sal_pltid failed with -1
ia64_sal_pltid failed with -1
ia64_sal_pltid failed with -1
ia64_sal_pltid failed with -1
ia64_sal_pltid failed with -1
ia64_sal_pltid failed with -1
ia64_sal_pltid failed with -1
ia64_sal_pltid failed with -1
ia64_sal_pltid failed with -1
ia64_sal_pltid failed with -1
Brought up 14 CPUs
Total of 14 processors activated (44793.85 BogoMIPS).
------------------------------------------------------------------------------


saturn1-10:~ # cat /proc/cpuinfo
processor  : 0
vendor     : GenuineIntel
arch       : IA-64
family     : 32
model      : 1
model name : Dual-Core Intel(R) Itanium(R) Processor 9150M
revision   : 0
archrev    : 0
features   : branchlong, 16-byte atomic ops
cpu number : 0
cpu regs   : 4
cpu MHz    : 1669.503
itc MHz    : 416.875000
BogoMIPS   : 3325.95
siblings   : 1

processor  : 1
vendor     : GenuineIntel
arch       : IA-64
family     : 32
model      : 1
model name : Dual-Core Intel(R) Itanium(R) Processor 9150M
revision   : 0
archrev    : 0
features   : branchlong, 16-byte atomic ops
cpu number : 0
cpu regs   : 4
cpu MHz    : 1669.503
itc MHz    : 416.875000
BogoMIPS   : 3325.95
siblings   : 1
------------------------------------------------------------------------------


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
