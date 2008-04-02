From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 02 Apr 2008 14:43:01 +0000
Subject: Re: + revert-gregkh-pci-pci-x86-use-generic-pci_enable_resources.patch added to -mm tree
Message-Id: <200804020843.02402.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200803282348.m2SNmleP016847@imap1.linux-foundation.org> <1207082276.10388.224.camel@pasglop> <20080402051554.GA21714@kroah.com>
In-Reply-To: <20080402051554.GA21714@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <greg@kroah.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, davem@davemloft.net, m.kozlowski@tuxland.pl, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Kyle McMartin <kyle@mcmartin.ca>

On Tuesday 01 April 2008 11:15:54 pm Greg KH wrote:
> On Wed, Apr 02, 2008 at 07:37:56AM +1100, Benjamin Herrenschmidt wrote:
> > 
> > On Tue, 2008-04-01 at 09:57 -0600, Bjorn Helgaas wrote:
> > > 
> > > Can we just drop the "revert gregkh" patches for x86, alpha, powerpc,
> > > and ia64?
> > 
> > Considering that the generic is equivalent to what I have today on
> > powerpc, I'm fine with it.
> 
> Ok, so what ones should I keep in my tree?
> 
> Bjorn, any help?

I think we should keep x86, alpha, powerpc, ppc, and ia64.

Kyle previously acked it for parisc, so maybe he can speak
up about whether to keep it there.

Bjorn
