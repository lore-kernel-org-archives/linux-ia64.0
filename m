From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 11 Jul 2003 17:58:15 +0000
Subject: RE: 2.5.75 out
Message-Id: <marc-linux-ia64-105794630805778@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105788013113852@msgid-missing>
In-Reply-To: <marc-linux-ia64-105788013113852@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ditto for tiger-4 machine.  Doesn't boot because interrupts are all
messed up.

- Ken

-----Original Message-----
From: Peter Chubb [mailto:peter@chubb.wattle.id.au] 
Sent: Thursday, July 10, 2003 7:54 PM
To: davidm@hpl.hp.com
Cc: linux-ia64@vger.kernel.org
Subject: RE: 2.5.75 out

DavidM> There is good and bad news: the bad news is that 2.5.75 doesn't
DavidM> work out-of-the-box on ia64.  The good news it _does_ compile.
The
DavidM> thing that keeps it from working are a few (late) per-CPU
related
DavidM> changes.  

There still appears to be an ACPI issue.

On bootup for a single processor I2000 (so the per-cpu problem doesn't
arise), the interrupt routing isn't set up properly, so nothing that
needs an interrupt work properly.

From the log:
...
ACPI Namespace successfully loaded at root a00000010067b8b0
evxfevnt-0093 [04] acpi_enable           : Transition to ACPI mode
successful
evgpeblk-0748 [06] ev_create_gpe_block   : GPE 00 to 15 [_GPE] 2 regs at
0000000000000A0C on int 9
evgpeblk-0748 [06] ev_create_gpe_block   : GPE 16 to 31 [_GPE] 2 regs at
0000000000000A16 on int 9
ACPI: SCI (IRQ-1) allocation failed
 evevent-0133: *** Error: Unable to install System Control Interrupt
Handler, AE_NOT_ACQUIRED
ACPI: Unable to start the ACPI Interpreter
evxfevnt-0135 [06] acpi_disable          : Could not exit ACPI mode to
legacy mode
 evmisc-0563 [05] ev_terminate          : acpi_disable failed
 utalloc-0986 [05] ut_dump_allocations   : No outstanding allocations.
Trying to free free IRQ0
SCSI subsystem initialized
drivers/usb/core/usb.c: registered new driver usbfs
drivers/usb/core/usb.c: registered new driver hub
ACPI: ACPI tables contain no PCI IRQ routing entries
PCI: Invalid ACPI-PCI IRQ routing table
...
