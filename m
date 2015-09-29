From: Al Stone <al.stone@linaro.org>
Date: Tue, 29 Sep 2015 23:45:41 +0000
Subject: [PATCH v5 0/5] Provide better MADT subtable sanity checks
Message-Id: <1443570346-15378-1-git-send-email-al.stone@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-pm@vger.kernel.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Al Stone <al.stone@linaro.org>

NB: this patch set is for use against the linux-pm bleeding edge branch.

Currently, the BAD_MADT_ENTRY macro is used to do a very simple sanity
check on the various subtables that are defined for the MADT.  The check
compares the size of the subtable data structure as defined by ACPICA to
the length entry in the subtable.  If they are not the same, the assumption
is that the subtable is incorrect.

Over time, the ACPI spec has allowed for MADT subtables where this can
never be true (the local SAPIC subtable, for example).  Or, more recently,
the spec has accumulated some minor flaws where there are three possible 
sizes for a subtable, all of which are valid, but only for specific versions
of the spec (the GICC subtable).  In both cases, BAD_MADT_ENTRY reports these
subtables as bad when they are not.  In order to retain some sanity check
on the MADT subtables, we now have to special case these subtables.  Of
necessity, these special cases have ended up in arch-dependent code (arm64)
or an arch has simply decided to forgo the check (ia64).

This patch set replaces the BAD_MADT_ENTRY macro with a function called
bad_madt_entry().  This function uses a data set of details about the
subtables to provide more sanity checking than before:

	-- is the subtable legal for the version given in the FADT?

	-- is the subtable legal for the revision of the MADT in use?

	-- is the subtable of the proper length (including checking
	   on the one variable length subtable that is currently ignored),
	   given the FADT version and the MADT revision?

Further, this patch set adds in the call to bad_madt_entry() from the 
acpi_table_parse_madt() function, allowing it to be used consistently
by all architectures, for all subtables, and removing the need for each
of the subtable traversal callback functions to use BAD_MADT_ENTRY.

In theory, as the ACPI specification changes, we would only have to add
additional information to the data set describing the MADT subtables in
order to continue providing sanity checks, even when new subtables are
added.

These patches have been tested on an APM Mustang (arm64) and are known to
work there.  They have also been cross-compiled for x86 and ia64 with no
known failures.

Changes for v5:
   -- 0-day found incorrect data in the table describing allowed MADT
      subtables; this only affected ACPI 1.0 firmware.  Corrected the
      data to meet the 1.0b spec.
   -- Rebase to bleeding-edge branch for Rafael Wysocki; this patch set
      now requires that a patch set from Marc Zyngier be applied first:
      https://lkml.org/lkml/2015/9/28/421
   -- Tested on AMD Seattle (linux-pm tree) also

Changes for v4:
   -- Remove extraneous white space change (Graeme Gregory)
   -- acpi_parse_entries() changes also needed a check to make sure that
      only MADT entries used bad_madt_entry() (Sudeep Holla)
   -- inadvertent use of 01day build noted that bad_madt_entry() can be
      static, so added it (Sudeep Holla, Fengguang Wu)

Changes for v3:
   -- Reviewed-and-tested-by from Sudeep Holla for arm64 parts
   -- Clearer language in error messages (Graeme Gregory, Timur Tabi)
   -- Double checked that inserting call to bad_madt_entry() into the
      function acpi_parse_entries() does not impact current behavior
      (Sudeep Holla)
   
Changes for v2:
   -- Acked-by on 2/5 from Marc Zyngier and Catalin Marinas for ARM
   -- Correct faulty end of loop test found by Timur Tabi


Al Stone (5):
  ACPI: add in a bad_madt_entry() function to eventually replace the
    macro
  ACPI / ARM64: remove usage of BAD_MADT_ENTRY/BAD_MADT_GICC_ENTRY
  ACPI / IA64: remove usage of BAD_MADT_ENTRY
  ACPI / X86: remove usage of BAD_MADT_ENTRY
  ACPI: remove definition of BAD_MADT_ENTRY macro

 arch/arm64/include/asm/acpi.h |   8 --
 arch/arm64/kernel/smp.c       |   2 -
 arch/ia64/kernel/acpi.c       |  20 ----
 arch/x86/kernel/acpi/boot.c   |  27 -----
 drivers/acpi/tables.c         | 247 +++++++++++++++++++++++++++++++++++++++++-
 drivers/irqchip/irq-gic.c     |   3 -
 include/linux/acpi.h          |   4 -
 7 files changed, 246 insertions(+), 65 deletions(-)

-- 
2.4.3

