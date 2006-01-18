From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 18 Jan 2006 15:53:46 +0000
Subject: Re: [PATCH 2.6.15] ia64: use i386 dmi_scan.c
Message-Id: <200601180853.46290.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060104221627.GA26064@lists.us.dell.com> <200601171717.03192.bjorn.helgaas@hp.com> <200601180332.19692.ak@suse.de>
In-Reply-To: <200601180332.19692.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Matt Domsch <Matt_Domsch@dell.com>, linux-ia64@vger.kernel.org, openipmi-developer@lists.sourceforge.net, akpm@osdl.org, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, linux-kernel@vger.kernel.org

On Tuesday 17 January 2006 19:32, Andi Kleen wrote:
> At least on x86-64/i386 the ioremap is actually cached unless a MTRR
> changes it, but it normally doesn't here. If one wants to force uncached
> access one has to use ioremap_uncached(). You're saying IA64 ioremap
> forces uncached access? That seems weird.

Right.  On ia64, ioremap() and ioremap_nocache() are the same.  You'd
have to ask David about the history behind this.

> > +	if (efi_enabled) {
> > +		if (efi_mem_attributes(base & EFI_MEMORY_WB)) {
> > +			iomem = 0;
> > +			buf = (u8 *) phys_to_virt(base);
> > +		} else if (efi_mem_attributes(base & EFI_MEMORY_UC))
> > +			buf = dmi_ioremap(base, len);
> > +		else
> > +			buf = NULL;
> 
> I would expect your ioremap to already do such a lookup. That is at least
> how MTRRs on i386/x86-64 work.  If it does not how about you fix
> ioremap()?

Yes, hiding this all inside ioremap() is probably a good idea.
It'll slow it down a lot, but I guess it's probably not used in
performance paths anyway.  Thanks for the advice.
