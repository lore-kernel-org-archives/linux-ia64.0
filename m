From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 13 Apr 2004 20:08:17 +0000
Subject: Re: [PATCH] PCI MSI Kconfig consolidation
Message-Id: <200404131408.17248.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <C7AB9DA4D0B1F344BF2489FA165E502404058232@orsmsx404.jf.intel.com>
In-Reply-To: <C7AB9DA4D0B1F344BF2489FA165E502404058232@orsmsx404.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Nguyen, Tom L" <tom.l.nguyen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Andi Kleen <ak@suse.de>

On Tuesday 13 April 2004 1:16 pm, Nguyen, Tom L wrote:
> On Tuesday, April 13, Bjorn Helgaas wrote:
> 
> > This consolidates the PCI MSI configuration into drivers/pci/Kconfig,
> > removing it from the i386, x86_64, and ia64 Kconfig.
> >
> > It also changes the default for ia64 from "y" to "n".  The default on
> > i386 is "n" already, and I'm not sure why ia64 should be different.
> 
> It looks good; however, it may create a confusion on ia64 because ia64 
> is already vector-based indexing. 

No.  This is one reason why I think the MSI configuration symbol
should be CONFIG_PCI_MSI, not CONFIG_PCI_USE_VECTOR.

The fact that external interrupts in the ia64 architecture include a
number, and that we happen to call that number a "vector", has
nothing to do with PCI MSI.

In fact, I think there's a whole lot more architecture-specific
knowledge that has leaked across into drivers/pci/msi.[ch].  For
example, the MSI capability basically defines just a message address
register and a message data register.  It does not define anything
about the interpretation of either address or data.  So all the stuff
in struct msg_data and struct msg_address (vector, delivery_mode,
level, trigger, dest_id, dest_mode, redirection_hint) looks to me
like Intel-specific knowledge that should be encapsulated in the
arch code.
