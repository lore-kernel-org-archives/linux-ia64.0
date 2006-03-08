From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 08 Mar 2006 21:56:52 +0000
Subject: Re: git pull on ia64 linux tree
Message-Id: <200603081456.53031.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 08 March 2006 13:47, Luck, Tony wrote:
> >On Wed, Mar 08, 2006 at 11:54:26AM -0800, Luck, Tony wrote:
> >> Bjorn Helgaas:
> >>       [IA64] don't report !sn2 or !summit hardware as an error
> >>       [IA64] SGI SN drivers: don't report !sn2 hardware as an error
> >
> >I  thought hch solved  this by  fixing  the initcall  code  to  not
> >treat -ENODEV as an error  worthy of  reporting?
> 
> That's what happens when I get far, far behind on LKML.  I've found
> traces of the threads ... though none by hch, and no clear agreement
> about whether 0 or -ENODEV is right.  Some of this code is linked
> into the ia64 generic kernel by default, so I'm leaning a little
> towards Bjorn's position that we shouldn't be returning an error.

There are a ton of drivers that just return the result of
pci_register_driver().  This is typically zero, even when
no devices are present.

There are also some drivers that return -ENODEV when no devices
are present.

Personally, I think the first style is best, and we should deal
with the problem of loading the right drivers a different way,
e.g., with udev.  But others disagree:

    http://lkml.org/lkml/2006/3/7/159
