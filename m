From: Andi Kleen <ak@suse.de>
Date: Tue, 13 Apr 2004 18:37:50 +0000
Subject: Re: [PATCH] PCI MSI Kconfig consolidation
Message-Id: <20040413203750.01fac421.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404131041.06275.bjorn.helgaas@hp.com>
In-Reply-To: <200404131041.06275.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tom.l.nguyen@intel.com

On Tue, 13 Apr 2004 10:41:06 -0600
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:

> This consolidates the PCI MSI configuration into drivers/pci/Kconfig,
> removing it from the i386, x86_64, and ia64 Kconfig.
> 
> It also changes the default for ia64 from "y" to "n".  The default on
> i386 is "n" already, and I'm not sure why ia64 should be different.

Looks good to me. Hopefully the indexed support on x86-64 can be fixed
soon, then even the !X86_64 will be unnecessary.

-Andi
