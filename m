From: "Nguyen, Tom L" <tom.l.nguyen@intel.com>
Date: Tue, 13 Apr 2004 19:16:10 +0000
Subject: RE: [PATCH] PCI MSI Kconfig consolidation
Message-Id: <C7AB9DA4D0B1F344BF2489FA165E502404058232@orsmsx404.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404131041.06275.bjorn.helgaas@hp.com>
In-Reply-To: <200404131041.06275.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>, linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, Andi Kleen <ak@suse.de>

On Tuesday, April 13, Bjorn Helgaas wrote:

> This consolidates the PCI MSI configuration into drivers/pci/Kconfig,
> removing it from the i386, x86_64, and ia64 Kconfig.
>
> It also changes the default for ia64 from "y" to "n".  The default on
> i386 is "n" already, and I'm not sure why ia64 should be different.

It looks good; however, it may create a confusion on ia64 because ia64 
is already vector-based indexing. 

Thanks,
Long
