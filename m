From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 25 Apr 2003 16:13:31 +0000
Subject: Re: [Linux-ia64] [PATCH] 1/4 multi-ioport space support for 2.5
Message-Id: <marc-linux-ia64-105590723705607@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705599@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705599@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 24 April 2003 7:05 pm, Jesse Barnes wrote:
> ...  If drivers are required to
> call request_legacy_region and pass in a pci_bus, they'll get back a
> new io_base that they need to make use of.  Isn't that similar to the
> way you create multiple legacy I/O port spaces?

No.  I think part of the confusion here is that "legacy" is being used
to describe several different things.  In the VGA IO thread, it refers
to devices that are not relocatable by the standard PCI BAR mechanism.
When I said "the ia64 64K 'legacy IO port space'", I meant the 64K
IO port space inherited from the i386 processor model.  Finally,
David refers to "legacy devices" on pp. 304-307, and I think what
he's referring to are simply "low-cost and ill-designed PCI devices
that place some control registers in I/O space only," but are still
relocatable via PCI BARs.

My patch has nothing to do with the non-relocatable variety of "legacy"
devices.  Rather, I want to enable the "ill-designed" (but relocatable)
devices that happen to live outside the i386 64K IO port space.  This
should be transparent to the driver.  No request_legacy_region() call
should be required.  It wouldn't even make sense, because we're not
talking about a non-relocatable device.

> I must be missing something.  I understand that you've effectively
> created legacy I/O port spaces for each pci controller

Nope.  Let's not use "legacy" in this context.  For ia64, there is
exactly ONE "legacy IO port space", and it means "IO ports 0-65535,
which can be directly accessed in i386 mode".  On HP boxes, these
are all routed to one controller.  What I'm adding is support for
additional (non-legacy) IO port spaces that are routed to the
other controllers.

> but I don't
> see how that helps you with a driver that does e.g. inb(0x3e8).

My patch doesn't affect that driver at all.  Such a driver can
only talk to devices in certain slots.  The patch you mentioned
is a way to relax the "certain slots" restriction and is orthogonal
to mine.

> What do you anticipate that your stuff will be used for?

It enables a PCI card that requires IO ports but happens to be
plugged into a slot that doesn't get part of the 0-64K IO port
space.

I'd be interested in learning a little about how SGI boxes route
IO port space.  I don't know whether anything in my patch would
be applicable to them.  I'm guessing the ACPI discovery part would
not be applicable, but it's conceivable that the rest might be.

Bjorn


