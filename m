From: Christian Hinkelbein <hinkelbein@ti.uni-mannheim.de>
Date: Wed, 16 Jul 2003 12:02:15 +0000
Subject: 2.6.0-test1 and 2.5.75-ia64-030712 won't compile with
Message-Id: <marc-linux-ia64-105835694324047@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
i tried both 2.6.0-test1 and 2.5.75-ia64-030712
with CONFIG_IA64_GENERIC.
They won't compile:
>>>
>include/asm/hw_irq.h: In function `irq_descp':
>include/asm/hw_irq.h:130: warning: return from incompatible pointer type
>>>
>In file included from include/asm/sn/sn_cpuid.h:20,
>                 from include/asm/sn/sn_sal.h:17,
>                 from arch/ia64/sn/io/sgi_io_sim.c:13:
>include/asm/nodedata.h:27: `NR_NODES' undeclared here (not in a function)
>include/asm/nodedata.h:28: `NR_BANKS' undeclared here (not in a function)
>include/asm/nodedata.h:29: `NR_NODES' undeclared here (not in a function)
>include/asm/nodedata.h:30: `NR_BANKS' undeclared here (not in a function)
>>>
looks like the DISCONTIG/NUMA/DIG/GENERIC raised in 2.5.72 issues are still 
not cleaned up.

with CONFIG_IA64_DIG they compile (with warnings) but don't really run:
2.5.75-ia64-030712 complains about disability to aquire acpi irq, and 
therefore i do not have network:
>>>
>kernel: CPU 0: base freq3.273MHz, ITC ratio/2, ITC freqy9.641MHz+/--1ppm
>kernel: Unexpected irq vector 0x0 on CPU 0!
>kernel: Console: colour VGA+ 80x25
>>>
>kernel:  tbxface-0117 [03] acpi_load_tables      : ACPI Tables successfully acquired
>kernel: Parsing all Control Methods:.....................................
>kernel: Table [DSDT](id F005) - 283 Objects with 29 Devices 37 Methods 12 Regions
>kernel: Parsing all Control Methods:.
>kernel: Table [SSDT](id F003) - 1 Objects with 0 Devices 1 Methods 0 Regions
>kernel: ACPI Namespace successfully loaded at root a0000001006b4c48
>kernel: evxfevnt-0093 [04] acpi_enable           : Transition to ACPI mode successful
>kernel: evgpeblk-0748 [06] ev_create_gpe_block   : GPE 00 to 15 [_GPE] 2 regs at 0000000000000A0C on int 9
>kernel: evgpeblk-0748 [06] ev_create_gpe_block   : GPE 16 to 31 [_GPE] 2 regs at 0000000000000A16 on int 9
>kernel: ACPI: SCI (IRQ-1) allocation failed
>kernel:  evevent-0133: *** Error: Unable to install System Control Interrupt Handler, AE_NOT_ACQUIRED
>kernel: ACPI: Unable to start the ACPI Interpreter
>kernel: evxfevnt-0135 [06] acpi_disable          : Could not exit ACPI mode to legacy mode  evmisc-0563 [05] ev_terminate
>kernel:  utalloc-0986 [05] ut_dump_allocations   : No outstanding allocations.
>kernel: Trying to free free IRQ0
>kernel: ACPI: ACPI tables contain no PCI IRQ routing entries
>kernel: PCI: Invalid ACPI-PCI IRQ routing table
>>>
2.6.0-test1 crashes during loading too fast, so i can't tell the exact point
of failure (sorry, i don't have a serial console).

both kernel-compiles complain about:
>warning: your linker cannot handle cross-segment segment-relative relocations.
>         please upgrade to a newer version (it is safe to use this linker, but
>         the kernel will be bigger than strictly necessary).
where to get a suitable linker?

all errors occured after make mrproper;make menuconfig; make;

i use binutils 2.14 and gcc 3.2 on a dual i2000.

 christian
