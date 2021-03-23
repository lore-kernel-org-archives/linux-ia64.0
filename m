From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Tue, 23 Mar 2021 14:49:08 +0000
Subject: Current Linux kernels working on rx2800 again
Message-Id: <202ad1c0-e9d7-0cdd-d037-5258dfe3e378@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi!

I have tried a current kernel built from Linus' tree today on one of the
BL860c blades we use as buildds in Debian and it turns out with just three
fixes applied [1-3], the kernel works just fine:

root@lenz:~# dmesg|head -n20
[    0.000000] Linux version 5.12.0-rc4-00007-g572c09e775f7 (root@lenz) (gcc (Debian 10.2.1-6+b1) 10.2.1 20210110, GNU ld (GNU Binutils for Debian) 2.35.2) #2 SMP Tue Mar 23 14:29:21 UTC 2021
[    0.000000] efi: EFI v2.30 by HP
[    0.000000] efi: SALsystab=0xffdbff918 ESI=0xffdbffe18 ACPI 2.0=0x391a8014 HCDP=0xfffff8f18 SMBIOS=0x3914a000 
[    0.000000] PCDP: v3 at 0xfffff8f18
[    0.000000] earlycon: uart8250 at I/O port 0x2320 (options '115200n8')
[    0.000000] printk: bootconsole [uart8250] enabled
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000391A8014 000024 (v02 HP    )
[    0.000000] ACPI: XSDT 0x00000000391A8580 000124 (v01 HP     BL860C-4 00000001      01000013)
[    0.000000] ACPI: FACP 0x00000000391A2000 0000F4 (v03 HP     BL860C-4 00000001 HP   00000001)
[    0.000000] ACPI BIOS Warning (bug): Invalid length for FADT/Pm1aEventBlock: 16, using default 32 (20210105/tbfadt-669)
[    0.000000] ACPI BIOS Warning (bug): Invalid length for FADT/Pm1aControlBlock: 32, using default 16 (20210105/tbfadt-669)
[    0.000000] ACPI: DSDT 0x0000000039188000 009FFD (v02 HP     BL860C-4 00000008 INTL 20061109)
[    0.000000] ACPI: FACS 0x00000000391A4000 000040
[    0.000000] ACPI: FACS 0x00000000391A4000 000040
[    0.000000] ACPI: APIC 0x00000000391A6000 0001CC (v01 HP     BL860C-4 00000001 HP   00000001)
[    0.000000] ACPI: SPCR 0x00000000391A0000 000050 (v01 HP     BL860C-4 00000001 HP   00000001)
[    0.000000] ACPI: SRAT 0x000000003919E000 000348 (v02 HP     BL860C-4 00000001 HP   00000001)
[    0.000000] ACPI: SLIT 0x000000003919C000 00003C (v01 HP     BL860C-4 00000001 HP   00000001)
[    0.000000] ACPI: CPEP 0x000000003919A000 000034 (v01 HP     BL860C-4 00000001 HP   00000001)
root@lenz:~#

The previously reported regression [4] has magically fixed itself.

Once the patches [1-3] have been merged - in one form or another - we just need to
fix the issue Ben Hutchings reported for zstd compression [5] and we can build and
use regular Debian distribution kernels on all ia64 machines again.

Adrian

> [1] https://marc.info/?l=linux-scsi&m1558808505479&w=2
> [2] https://marc.info/?l=linux-ia64&m1579831530508&w=2
> [3] https://marc.info/?l=linux-ia64&m1607290522459&w=2
> [4] https://marc.info/?l=linux-ia64&m6144480821712&w=2
> [5] https://marc.info/?l=linux-ia64&m0002668711603&w=2

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
