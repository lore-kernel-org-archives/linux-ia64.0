From: Grant Grundler <iod00d@hp.com>
Date: Tue, 22 Jun 2004 06:15:05 +0000
Subject: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <20040622061505.GA23075@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
just a bug report.

I tried building a 2.6.7 kernel using my "standard" .config
that worked for 2.6.6. The only source code changes were
to include openib.org infiniband driver in the tree as modules.

Last output was:
	Console: colour VGA+ 80x25

THe next line for 2.6.6 kernel would be:
	Memory: 6225280k/6263872k available (6560k code, 38224k reserved, 3069k data, 208k init)


After 2 minutes I still couldn't ping the box and reset it.
I should have "INIT" the box to see where it hung but wasn't thinking.

I wonder if this might be related to KALLSYMS bugs recently discussed.
Trying with CONFIG_KALLSYMS and CONFIG_KALLSYMS_ALL off next.

hth,
grant

EFI Boot Manager ver 1.10 [14.61]  Firmware ver 2.21 [4334]

Please select a boot option

    Debian GNU/Linux                                                
    EFI Shell [Built-in]                                            
    Boot Option Maintenance Menu                                    
    System Configuration Menu                                       


    Use ^ and v to change option(s). Use Enter to select an option
Loading.: Debian GNU/Linux                                          
Starting: Debian GNU/Linux
ELILO

ELILO boot: 
Linux266 Linux267   Linux265   Linux2424   (or a kernel file name: [[dev_name:/]path/]kernel_image cmdline options)

ELILO boot: Linux267
Uncompressing Linux... done
Linux version 2.6.7 (grundler@gsyprf3.external.hp.com) (gcc version 3.3.4 (Debian)) #1 SMP Mon Jun 21 22:36:17 PDT 2004
EFI v1.10 by HP: SALsystab=0x3fb38000 ACPI 2.0=0x3fb2e000 SMBIOS=0x3fb3a000 HCDP=0x3fb2c000
ACPI: RSDP (v002     HP                                    ) @ 0x000000003fb2e000
ACPI: XSDT (v001     HP   zx6000 0x00000000 HP 0x00000000) @ 0x000000003fb2e02c
ACPI: FADT (v003     HP   zx6000 0x00000000 HP 0x00000000) @ 0x000000003fb369e0
ACPI: SPCR (v001     HP   zx6000 0x00000000 HP 0x00000000) @ 0x000000003fb36b18
ACPI: DBGP (v001     HP   zx6000 0x00000000 HP 0x00000000) @ 0x000000003fb36b68
ACPI: MADT (v001     HP   zx6000 0x00000000 HP 0x00000000) @ 0x000000003fb36c28
ACPI: SPMI (v004     HP   zx6000 0x00000000 HP 0x00000000) @ 0x0003fb36ba0
ACPI: CPEP (v001     HP   zx6000 0x00000000 HP 0x00000000) @ 0x000000003fb36bf0
ACPI: SSDT (v001     HP   zx6000 0x006 INTL 0x02012044) @ 0x000000003fb33870
ACPI: SSDT (v001     HP   zx6000 0x00000006 INTL 0x02012044) @ 0x000000003fb33a50
ACPIT (v001     HP   zx6000 0x00000006 INTL 0x02012044) @ 0x000000003fb33da0
ACPI: SSDT (v001     HP   zx6000 0x00000006 INTL 0x020) @ 0x000000003fb347c0
ACPI: SSDT (v001     HP   zx6000 0x00000006 INTL 0x02012044) @ 0x000000003fb351e0
ACPI: SSDT (v001     zx6000 0x00000006 INTL 0x02012044) @ 0x000000003fb35c00
ACPI: SSDT (v001     HP   zx6000 0x00000006 INTL 0x02012044) @ 0x00000036620
ACPI: SSDT (v001     HP   zx6000 0x00000006 INTL 0x02012044) @ 0x000000003fb36800
ACPI: SSDT (v001     HP   zx6000 0x000 INTL 0x02012044) @ 0x000000003fb368f0
ACPI: DSDT (v001     HP   zx6000 0x00000007 INTL 0x02012044) @ 0x0000000000000000
efi.top: ignoring 4KB of memory at 0x0 due to granule hole at 0x0
efi.trim_top: ignoring 636KB of memory at 0x1000 due to granule ho 0x0
efi.trim_bottom: ignoring 15360KB of memory at 0x100000 due to granule hole at 0x0
SAL 3.1: HP version 2.21
SAL Platformures: None
SAL: AP wakeup using external interrupt vector 0xff
ACPI: Local APIC address 0xc0000000fee00000
ACPI: LAPIC_ADDR_Oddress[00000000fee00000])
ACPI: LSAPIC (acpi_id[0x00] lsapic_id[0x00] lsapic_eid[0x00] enabled)
CPU 0 (0x0000) enabled (BSP)
: LSAPIC (acpi_id[0x01] lsapic_id[0x01] lsapic_eid[0x00] enabled)
CPU 1 (0x0100) enabled
ACPI: IOSAPIC (id[0x0] global_irq_bas0] address[00000000fed20800])
ACPI: IOSAPIC (id[0x1] global_irq_base[0x1b] address[00000000fed22800])
ACPI: IOSAPIC (id[0x2] g_irq_base[0x26] address[00000000fed24800])
ACPI: IOSAPIC (id[0x3] global_irq_base[0x31] address[00000000fed26800])
ACPI: IOSAPd[0x4] global_irq_base[0x3c] address[00000000fed28800])
ACPI: IOSAPIC (id[0x6] global_irq_base[0x47] address[00000000fed2c800])PI: IOSAPIC (id[0x7] global_irq_base[0x52] address[00000000fed2e800])
GSI 0x24(low,level) -> CPU 0x0000 vector 48
2 CPUs avail 2 CPUs total
GSI 0x52(low,level) -> CPU 0x0000 vector 49
MCA related initialization done
On node 0 totalpages: 391492
  DMA: 391492 pages, LIFO batch:4
  Normal zone: 0 pages, LIFO batch:1
  HighMem zone: 0 pages, LIFO batch:1
Virtual mem_map start0xa0007fffc7200000
Built 1 zonelists
Kernel command line: BOOT_IMAGE=scsi0:/EFI/debian/boot/vmlinuz-2.6.7 root=/dev/sdb3 consoyS0 ro
PID hash table entries: 4096 (order 12: 65536 bytes)
CPU 0: base freq 0.000MHz, ITC ratio/2, ITC freq00.000MHz+ppm
Console: colour VGA+ 80x25
<End Of Output>
