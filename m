From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 23 Oct 2006 21:31:05 +0000
Subject: ia64 acpi-cpufreq driver
Message-Id: <200610231531.05346.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Venkatesh Pallipadi <venkatesh.pallipadi@intel.com>
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

arch/ia64/kernel/cpufreq/acpi-cpufreq.c currently makes direct
calls to PAL_SET_PSTATE.

Section 8.4.4.1 (_PCT) of the 3.0 ACPI spec says:

  OSPM performs processor performance transitions by writing
  the performance state-specific control value to a Performance
  Control Register (PERF_CTRL).

According to one of our architecture guys, this means we really
ought to have an OpRegion driver that encapsulates the PAL_SET_PSTATE
call.

I guess _PCT would return an acpi_generic_address in the FFixedHW
address space, and we would use acpi_hw_low_level_read() and
acpi_hw_low_level_write() to do the accesses (those functions
would need to be extended to support additional OpRegions, or
maybe I'm looking in the wrong place).

This sort of makes sense to me, because it would mean this part
of acpi-cpufreq wouldn't need to be ia64-specific.  On x86, I
suppose _PCT would return a ACPI_ADR_SPACE_SYSTEM_IO address,
and acpi_processor_set_performance() could use acpi_hw_low_level_write()
instead of its own acpi_processor_write_port().

But I haven't seen anything resembling an ACPI FFH OpRegion
driver for Linux, or even a spec (e.g., a definition of what
the FFH address space contains) that would allow such a driver
to be written.

Any hints on what the future might hold in this area?

Bjorn
