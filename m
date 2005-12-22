From: Mark Maule <maule@sgi.com>
Date: Thu, 22 Dec 2005 20:06:11 +0000
Subject: Re: [PATCH 2/3] per-platform IA64_{FIRST,LAST}_DEVICE_VECTOR definitions
Message-Id: <20051222200611.GF17552@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051222171616.8240.37671.12506@lnx-maule.americas.sgi.com> <20051222171626.8240.40685.41154@lnx-maule.americas.sgi.com> <20051222200111.GB14332@kroah.com>
In-Reply-To: <20051222200111.GB14332@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <greg@kroah.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On Thu, Dec 22, 2005 at 12:01:11PM -0800, Greg KH wrote:
> On Thu, Dec 22, 2005 at 11:15:19AM -0600, Mark Maule wrote:
> > --- msi.orig/drivers/pci/msi.c	2005-12-21 16:10:32.838675711 -0600
> > +++ msi/drivers/pci/msi.c	2005-12-21 18:55:05.020985381 -0600
> > @@ -35,7 +35,7 @@
> >  
> >  #ifndef CONFIG_X86_IO_APIC
> >  int vector_irq[NR_VECTORS] = { [0 ... NR_VECTORS - 1] = -1};
> > -u8 irq_vector[NR_IRQ_VECTORS] = { FIRST_DEVICE_VECTOR , 0 };
> > +u8 irq_vector[NR_IRQ_VECTORS] = { [0 ... NR_IRQ_VECTORS - 1 ] = 0 };
> 
> As previously mentioned, you don't have to initilize this to 0.

Shoot, I thought I fixed that.  Sent out the wrong version .... 

> 
> >  #endif
> >  
> >  static struct msi_ops *msi_ops;
> > @@ -377,6 +377,11 @@
> >  		printk(KERN_WARNING "PCI: MSI cache init failed\n");
> >  		return status;
> >  	}
> > +
> > +#ifndef CONFIG_X86_IO_APIC
> > +	irq_vector[0] = FIRST_DEVICE_VECTOR;
> > +#endif
> 
> Why do this here, what's wrong with the original code above in the
> static declaration?  Or am I missing some logic change somewhere?

The problem is that on ia64, FIRST_DEVICE_VECTOR is now a global variable,
due to the fact that SN has a different notion of FIRST/LAST_DEVICE_VECTOR.
So it causes compilation problems in the declaration.

Mark
