From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 09 Mar 2004 23:19:04 +0000
Subject: [PATCH] clean up some ACPI IRQ conversions
Message-Id: <200403091619.04333.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org
Cc: Andi Kleen <ak@suse.de>, "Nakajima, Jun" <jun.nakajima@intel.com>, "Brown, Len" <len.brown@intel.com>

Back in January, I posted a patch to clean up some ACPI IRQ
handling:

    http://www.gelato.unsw.edu.au/linux-ia64/0401/8019.html
    http://www.gelato.unsw.edu.au/linux-ia64/0401/8005.html

At the time, it conflicted with some pending MSI updates, so we
put it off until those went in.  Those are now in, so I'll post
my updated patches as responses to this note.

I originally proposed "acpi_interrupt_to_irq" as a better name for
"acpi_irq_to_vector", but I'm now proposing "acpi_global_irq_to_irq".
ia64 uses "gsi" rather than "global_irq", but "global_irq" seems to
be already established in include/linux/acpi.h, so I went that way.

If people think "acpi_global_irq_to_irq" is too clunky, I'd be glad
to change it, but it'd be nice to at least get these changes in as
a start.

I split it into six easy pieces:
    1: i386 and x86_64: whitespace and typo changes to sync mpparse.c
    2: x86_64: add acpi_irq_to_vector() to be same as i386
    3: i386, x86_64: rename "irq" to "global_irq" (local vars, arguments)
	(this also fixes a potential i386 bug; we used to do
	    irq = acpi_irq_to_vector(irq);
	    entry->irq = irq;
	    continue;
	where we convert "irq" from an ACPI global irq to a Linux IRQ,
	then go through the loop again.  So we could find another PRT
	entry where the global IRQ happens to match the Linux IRQ we
	previously found, and screw things up.)
    4: i386, x86_64, ia64, acpi: rename "acpi_irq_to_vector()" to "acpi_global_irq_to_irq()"
    5: acpi: fix double conversion in acpi_os_install_interrupt_handler()
	(this fixes the bug mentioned as the "fishy" part in
	http://www.gelato.unsw.edu.au/linux-ia64/0401/8005.html)
    6: acpi: rename acpi_irq variables for clarity

These changes (all together, not individually) have been built and
booted on ia64 and built for i386.

