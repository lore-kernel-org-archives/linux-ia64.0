From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 02 Mar 2005 18:41:06 +0000
Subject: Re: [PATCH/RFC] I/O-check interface for driver's error handling
Message-Id: <200503021041.07090.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <422428EC.3090905@jp.fujitsu.com> <Pine.LNX.4.58.0503010844470.25732@ppc970.osdl.org> <20050302182205.GI1220@austin.ibm.com>
In-Reply-To: <20050302182205.GI1220@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@atrey.karlin.mff.cuni.cz
Cc: Linas Vepstas <linas@austin.ibm.com>, Linus Torvalds <torvalds@osdl.org>, Jeff Garzik <jgarzik@pobox.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Luck, Tony" <tony.luck@intel.com>

On Wednesday, March 2, 2005 10:22 am, Linas Vepstas wrote:
> On Tue, Mar 01, 2005 at 08:49:45AM -0800, Linus Torvalds was heard to 
remark:
> > The new API is what _allows_ a driver to care. It doesn't handle DMA, but
> > I think that's because nobody knows how to handle it (ie it's probably
> > hw-dependent and all existign implementations would thus be
> > driver-specific anyway).
>
> ?
> We could add a call
>
> int pci_was_there_an_error_during_dma (struct pci_dev);
>
> right?  And it could return true/false, right?  I can certainly
> do that today with ppc64.  I just can't tell you which dma triggered
> the problem.

One issue with that is how to notify drivers that they need to make this call.  
In may cases, DMA completion will be signalled by an interrupt, but if the 
DMA failed, that interrupt may never happen, which means the call to 
pci_unmap or the above function from the interrupt handler may never occur.

Some I/O errors are by nature asynchronous and unpredictable, so I think we 
need a separate thread and callback interface to deal with errors where the 
beginning of the transaction and the end of the transaction occur in 
different contexts, in addition to the PIO transaction interface already 
proposed.

Jesse
