From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 27 Apr 2004 14:38:35 +0000
Subject: Re: [PATCH] bug w/ shared interrupts
Message-Id: <200404270838.36226.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1082989740.15656.20.camel@localhost>
In-Reply-To: <1082989740.15656.20.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 26 April 2004 3:12 pm, David Mosberger wrote:
> I do think that iosapic_enable_intr() is
> misnamed now that it actually leaves the interrupt _masked_.  What
> it's really doing now is that it asserts that the I/O SAPIC routine is
> programmed to a correct/working value.  It would be good to fix that
> when changing the corresponding code in drivers/acpi/pci_irq.c.  IIRC,
> Bjorn already has patches which touch on that file.  If so, could you
> do a rename at the same time, Bjorn?

Sure, I'll take a look at that.  I think the only interface between
acpi/pci_irq.c and the architecture code will be acpi_register_gsi(),
though, so renaming iosapic_enable_intr() should be independent
of those changes.

Bjorn
