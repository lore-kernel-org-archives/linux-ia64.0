From: Mark Maule <maule@sgi.com>
Date: Tue, 11 Oct 2005 20:00:24 +0000
Subject: Re: [PATCH] set altix preferred console
Message-Id: <20051011200024.GF31265@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050930200422.GD13855@sgi.com>
In-Reply-To: <20050930200422.GD13855@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Oct 04, 2005 at 01:07:14PM -0600, Bjorn Helgaas wrote:
> > Our prom currently does not build up ACPI tables describing PCI (or any
> > IO)
> > devices.  We are working toward that goal, but it is still
> > work in progress and will be some time yet before this is done.
> >
> > It is because of this shortcoming that we have to rely on the PCDP table
> > to provide the io addresses needed for VGA console.
> >
> > Outside of PCDP, our earliest opportunity to get information about VGA
> > devices is through the call sequence initiated with
> > subsys_initcall(sn_pci_init), which would seem way too late for early boot
> > messages.
> 
> It's the same for us.  We don't find out about our built-in serial
> ports until the 8250 driver initializes, which is pretty late.  So
> we have "8250_early" that uses information from the PCDP to talk
> to the serial port before the normal 8250 driver discovers it.
> The important thing is that the PCDP doesn't influence the naming
> of the device (and there isn't really a "name" for VGA devices,
> AFAIK).
> 
> > Out of curiousity, what are the mmio_tra/ioport_tra fields in the PCDP PCI
> > interface structure intended for if not for this purpose?
> 
> You *can* use the _tra fields in the PCDP -- that's what they're
> there for.  But the PCDP should be *optional*, and I think it's
> not for your current setup.
> 
> If we don't build pcdp.o on an HP box, the console still works
> just fine; it just doesn't work until the 8250 driver discovers
> the port, which is fairly late.
> 
> So I think all you need to do is add some SN-specific code
> somewhere that discovers the VGA device.  It sounds like the
> only way to do that right now is to get the information from
> the PCDP, so I guess that's what you need to do.  But having
> this duplicated in the SN code means that you won't need the
> change to pcdp.c.
> 

Finally getting back to this ...

So we will dup some of the PCDP scan code in sn/kernel/setup.c for the time
being.  Does anyone have a problem with moving drivers/firmware/pcdp.h under
include/asm-ia64 so that I don't also have to dup the structure definitions?

thanks
Mark
