From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 11 Dec 2003 00:34:21 +0000
Subject: Re: Latest 2.4 IA64 Baseline (Bjorn) + Latest ACPI testing report
Message-Id: <marc-linux-ia64-107110287920699@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106863619315583@msgid-missing>
In-Reply-To: <marc-linux-ia64-106863619315583@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 10 December 2003 3:29 am, Yu, Luming wrote:

> >> 2.PCI: no interrupt route for 00:00:03 pin B
> 
> >You say this is a known issue for 2.6, but I can't find any details
> >or discussion about it.  It looks to me like a firmware problem.
> >The function at 00:00:03.3 (2.6 nicely tells us which function)
> >claims it's using INTB, but ACPI isn't telling us which GSI that
> >corresponds to.  Can you ask your BIOS guys about this?
> 
> There is only 1 PRT entry in DSDT for bus 0, slot 3,  but it is for pin D  not for pin B . And the error message reflect that fact. 
> This error is for device 00:03.3 --SMBus. I don't know how to test that device.
> Actually 2.6 will call acpi_pci_irq_derive try to derive IRQ from parent bridge, if nothing found from PRT List, But 2.4 will not do that.

But your testing report from 2.6 shows the same message.  Did you
get any response from your BIOS guys?

> >> 3.alloc 0x0-0xcf7 from PCI IO for PCI Bus 00:00 failed   (Known issue)
> 
> >I poked at this again.  The reason this fails is because the
> >VGA console driver starts up very early and allocates ports
> >0x3c0-0x3df.  It would be nice if we could figure out a way
> >to allocate those ports later, after the PCI bridge has been
> >discovered, so we get the ioport resources correct, but I
> >don't know a reasonable way to do that.
> 
> Since VGA console driver faile to allocate that port range,  why it still can work?
> Does it mean 0x3c0-0x3df is inessential to  VGA console driver.

No, I think those ports are essential.  The driver just uses them,
even if the allocation fails.  I have a 2.6 patch that cleans this
up.  It doesn't change any functionality; it just gets rid of the
message and makes /proc/ioports more correct.  I'll submit it as
soon as it makes sense to put non-critical changes into 2.6.

Bjorn

