From: Mark Maule <maule@sgi.com>
Date: Mon, 07 Feb 2005 15:49:14 +0000
Subject: Re: [PATCH 2.6.11-rc2 3/3] altix: tioca chip driver (agp)
Message-Id: <Pine.SGI.3.96.1050207094338.29754669E-100000@daisy-e236.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050204213213.16671.77171.95362@attica.americas.sgi.com>
In-Reply-To: <20050204213213.16671.77171.95362@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Mon, 7 Feb 2005, Christoph Hellwig wrote:

> Private headers after <asm/*> headers, please.  If tioca_provider.h needs
> xwidgetdev.h the latter should move to <asm/sn/>

ok.

> All the exports aren't nice because they expose internals.  In cases
> where AGP and PCI iommu code are similar interwinded (e.g. alpha and amd64)
> we made building the agpgart code builin mandatory which sounds like the
> way to go for altix aswell.

Will investigate this further.

> 
> > +	ca_base = (struct tioca *)tioca_common->ca_common.bs_base;
> 

Will remove unneeded casts and cleanup your style-related comments.

> >
> > +	if (!tioca_kern) {
> > +		return -1;
> > +	}
> 
> And you're leaking the previous allocation here.

yep.

> 
> list_for_each_entry() please

ok.

> 
> > +int
> > +tioca_init_provider(void)
> > +{
> > +	if (sn_sal_rev_major() < 4 || sn_sal_rev_minor() < 0x06) {
> > +		printk
> > +		    (KERN_ERR "%s:  SGI prom rev 4.06 or greater required "
> > +		     "for tioca support\n", __FUNCTION__);
> > +		return 0;
> > +	}
> 
> isn't that a little noisy for people who have systems without the hardware
> this driver actually supports?  Also the hex notation for the SAL minor
> is pure obsfucation.
> 

Agreed.  This check should move to tioca_bus_fixup().

Mark

