From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 01 Apr 2008 17:09:42 +0000
Subject: Re: + revert-gregkh-pci-pci-x86-use-generic-pci_enable_resources.patch added to -mm tree
Message-Id: <200804011109.43046.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200803282348.m2SNmleP016847@imap1.linux-foundation.org> <200804010957.16459.bjorn.helgaas@hp.com> <20080401100050.009cec7b.akpm@linux-foundation.org>
In-Reply-To: <20080401100050.009cec7b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: davem@davemloft.net, greg@kroah.com, m.kozlowski@tuxland.pl, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Ivan Kokshaysky <ink@jurassic.park.msu.ru>

On Tuesday 01 April 2008 11:00:50 am Andrew Morton wrote:
> On Tue, 1 Apr 2008 09:57:15 -0600 Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
> 
> > On Friday 28 March 2008 05:48:47 pm akpm@linux-foundation.org wrote:
> > > 
> > > The patch titled
> > >      revert gregkh-pci-pci-x86-use-generic-pci_enable_resources
> > > has been added to the -mm tree.  Its filename is
> > >      revert-gregkh-pci-pci-x86-use-generic-pci_enable_resources.patch
> > 
> > OK, I'm not sure where we are with this.  Ben listed arches where
> > the generic pci_enable_resources() should be safe: x86, alpha, and
> > powerpc.  I think we should also include ia64, since I work on that.
> > 
> > If there's no objection to those arches, how should we move forward?
> > Since Andrew put in "revert gregkh-pci" patches rather than just
> > dropping things, I assume the original patches are in Greg KH's tree.
> > 
> > Can we just drop the "revert gregkh" patches for x86, alpha, powerpc,
> > and ia64?
> 
> So powerpc is OK but ppc might not be?

I suppose Ben is the expert on that, and he did say he thought both
powerpc and ppc would be OK.  I think we just care less about ppc
because powerpc is the new converged one.

Bjorn
