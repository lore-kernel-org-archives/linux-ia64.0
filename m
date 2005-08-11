From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 11 Aug 2005 21:42:07 +0000
Subject: Re: [PATCH] IDE: don't offer IDE_GENERIC on ia64
Message-Id: <200508111542.07851.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200508111424.43150.bjorn.helgaas@hp.com> <200508111445.41428.bjorn.helgaas@hp.com> <42FBBB6F.1030306@pobox.com>
In-Reply-To: <42FBBB6F.1030306@pobox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jgarzik@pobox.com>
Cc: B.Zolnierkiewicz@elka.pw.edu.pl, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On Thursday 11 August 2005 2:56 pm, Jeff Garzik wrote:
> Bjorn Helgaas wrote:
> > On Thursday 11 August 2005 2:36 pm, Jeff Garzik wrote:
> >>Bjorn Helgaas wrote:
> >>> config IDE_GENERIC
> >>> 	tristate "generic/default IDE chipset support"
> >>>+	depends on !IA64
> >>
> >>hmmmmmmmmm.  Are you POSITIVE that the legacy IDE ports are never enabled?
> >>
> >>In modern Intel chipsets, this still occurs with e.g. combined mode.
> > 
> > I don't know about combined mode.  If the legacy IDE ports are
> > enabled, shouldn't they be described via ACPI, and hence usable
> > via the ide_pnp - PNPACPI - ACPI path?
> 
> No idea...  that's more for platform IA64 people to answer :/

OK, well, I assert that failure to describe an IDE device that
uses legacy ports would be an ACPI defect.

Tony, others, does this change give you any heartburn?  On
the 460GX and 870 boxes I have, IDE is a PCI device.

(I have been told that the SGI ia64 simulator depends on
IDE_GENERIC.  But it really should make the IDE device
appear in PCI (or describe it via ACPI)).
