From: Jesse Barnes <jbarnes@sgi.com>
Date: Tue, 06 Apr 2004 16:15:48 +0000
Subject: Re: [RFC] readX_check() - Interface for PCI-X error recovery
Message-Id: <200404060915.48292.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <0HVQ0051BXG19H@fjmail506.fjmail.jp.fujitsu.com> <20040406115145.GA23258@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040406115145.GA23258@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@debian.org>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Linux IA64 Mailing List <linux-ia64@vger.kernel.org>, Hironobu Ishii <ishii.hironobu@jp.fujitsu.com>

> >     readX_check(dev,vaddr)
> > 	Read a register of the device mapped to vaddr, and check errors
> > 	if possible(This is depending on its architecture. In the case of
> > 	ia64, we can generate a MCA from an error by simple operation to
> > 	test the read data.)
> > 	If any error happen on the recoverable region, set the error flag.
>
> I really don't think we want another readX variant.  Do we then also
> add readX_check_relaxed()?  Can't we just pretend the MCA is asynchronous
> on ia64?  I'm sure we'd get better performance.

Hmm.. I wonder if we could get away with not having a new readX interface by 
registering each PCI resource either at driver init time or in arch code with 
the MCA hander.  Then we could just make the read routines use the variable 
that was just read to try to flush out the MCA (there may be better ways to 
do this).  E.g.

arch_pci_scan()
{
	...
	for_each_pci_resource(dev, res) {
		check_region(res);
	}
	...
}

...

unsigned char readb(unsigned long addr)
{
	unsigned char val = *(volatile unsigned char *)addr;
#ifdef CONFIG_PCI_CHECK
	/* try to flush out the MCA by doing something with val */
#endif
	return val;
}

...

Then presumably the MCA error handler would see that an MCA occurred in a 
region registered during PCI initialization and return an error for 
pci_read_errors(dev);

Jesse
