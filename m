From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 15 Dec 2005 15:51:09 +0000
Subject: Re: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <200512150851.10037.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 15 December 2005 7:33 am, Prarit Bhargava wrote:
> Bjorn Helgaas wrote:
> > You ought to just describe this hardware in the ACPI namespace
> > and use acpi_bus_register_driver() to bind the drivers.
> 
> ACPI support is in the process of being implemented.
> Currently, there is no ACPI DSDT table being created on
> SN systems.

You ought to be able to compile an SSDT into the kernel and
load it at boot-time, e.g., by extending acpi_os_table_override().
Or you might do something like arch/parisc/kernel/drivers.c.
Or maybe there's a way to use platform_devices.

The point is, I think it's a mistake to use ia64_platform_is()
to decide whether to bind a driver to a device.  I think it would
be much better to make it explicit that these are drivers, and
they only bind to specific devices.

I do recognize that this doesn't cover all the current uses of
ia64_platform_is(), but it covers a pretty big chunk of them.
