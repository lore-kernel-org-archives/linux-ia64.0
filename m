From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 25 Jan 2005 21:22:37 +0000
Subject: RE: Questionable code in pci_sal_read
Message-Id: <1106688157.6880.22.camel@eeyore>
List-Id: <linux-ia64.vger.kernel.org>
References: <jek6q1o7p2.fsf@sykes.suse.de>
In-Reply-To: <jek6q1o7p2.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2005-01-25 at 12:47 -0800, Luck, Tony wrote:
> >Ah, yes, that looks wrong.  Looks like the check for (seg > 255) came
> >from the original pci_sal_read().  The original pci_sal_ext_read() did
> >check for (seg > 65535).  My bad.
> >
> >Thanks for catching this.
> 
> 
> So you (and Matthew Wilcox) are advocating this change?
> 
> === arch/ia64/pci/pci.c 1.66 vs edited ==> --- 1.66/arch/ia64/pci/pci.c	2005-01-22 14:42:51 -08:00
> +++ edited/arch/ia64/pci/pci.c	2005-01-25 12:42:49 -08:00
> @@ -71,7 +71,7 @@
>  	u64 addr, mode, data = 0;
>  	int result = 0;
>  
> -	if ((seg > 255) || (bus > 255) || (devfn > 255) || (reg > 4095))
> +	if ((seg > 65535) || (bus > 255) || (devfn > 255) || (reg > 4095))
>  		return -EINVAL;
>  
>  	if ((seg | reg) <= 255) {
> 
> "seg", "bus", etc. are all "int" ... should we be extra paranoid
> and check for negative values (or change the definitions to unsigned),
> or is that over the top?

We should definitely change them to unsigned; it's a real problem
that has bitten us already.  In fact, I wonder if Andreas was
looking at this code as a result of the bug I opened yesterday ;-)

I'm testing a patch right now, and it includes the "seg > 65535"
change as well.

