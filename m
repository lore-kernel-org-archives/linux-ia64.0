From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 11 Jul 2003 18:30:31 +0000
Subject: RE: 2.5.75 out
Message-Id: <marc-linux-ia64-105795124111262@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105788013113852@msgid-missing>
In-Reply-To: <marc-linux-ia64-105788013113852@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luming,

Do you know what the status is in getting the ia64 ACPI changes folded
into 2.5.xx?

Thanks,

	--david

>>>>> On Fri, 11 Jul 2003 10:58:15 -0700, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> Ditto for tiger-4 machine.  Doesn't boot because interrupts are
  Ken> all messed up.

  Ken> - Ken

  Ken> -----Original Message----- From: Peter Chubb
  Ken> [mailto:peter@chubb.wattle.id.au] Sent: Thursday, July 10, 2003
  Ken> 7:54 PM To: davidm@hpl.hp.com Cc: linux-ia64@vger.kernel.org
  Ken> Subject: RE: 2.5.75 out

  DavidM> There is good and bad news: the bad news is that 2.5.75
  DavidM> doesn't work out-of-the-box on ia64.  The good news it
  DavidM> _does_ compile.
  Ken> The
  DavidM> thing that keeps it from working are a few (late) per-CPU
  Ken> related
  DavidM> changes.

  Ken> There still appears to be an ACPI issue.

  Ken> On bootup for a single processor I2000 (so the per-cpu problem
  Ken> doesn't arise), the interrupt routing isn't set up properly, so
  Ken> nothing that needs an interrupt work properly.

  >> From the log:
  Ken> ...  ACPI Namespace successfully loaded at root
  Ken> a00000010067b8b0 evxfevnt-0093 [04] acpi_enable : Transition to
  Ken> ACPI mode successful evgpeblk-0748 [06] ev_create_gpe_block :
  Ken> GPE 00 to 15 [_GPE] 2 regs at 0000000000000A0C on int 9
  Ken> evgpeblk-0748 [06] ev_create_gpe_block : GPE 16 to 31 [_GPE] 2
  Ken> regs at 0000000000000A16 on int 9 ACPI: SCI (IRQ-1) allocation
  Ken> failed evevent-0133: *** Error: Unable to install System
  Ken> Control Interrupt Handler, AE_NOT_ACQUIRED ACPI: Unable to
  Ken> start the ACPI Interpreter evxfevnt-0135 [06] acpi_disable :
  Ken> Could not exit ACPI mode to legacy mode evmisc-0563 [05]
  Ken> ev_terminate : acpi_disable failed utalloc-0986 [05]
  Ken> ut_dump_allocations : No outstanding allocations.  Trying to
  Ken> free free IRQ0 SCSI subsystem initialized
  Ken> drivers/usb/core/usb.c: registered new driver usbfs
  Ken> drivers/usb/core/usb.c: registered new driver hub ACPI: ACPI
  Ken> tables contain no PCI IRQ routing entries PCI: Invalid ACPI-PCI
  Ken> IRQ routing table ...  - To unsubscribe from this list: send
  Ken> the line "unsubscribe linux-ia64" in the body of a message to
  Ken> majordomo@vger.kernel.org More majordomo info at
  Ken> http://vger.kernel.org/majordomo-info.html
