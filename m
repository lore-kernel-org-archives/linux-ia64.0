From: Linas Vepstas <linas@austin.ibm.com>
Date: Wed, 02 Mar 2005 23:30:03 +0000
Subject: Re: [PATCH/RFC] I/O-check interface for driver's error handling
Message-Id: <20050302233003.GO1220@austin.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <422428EC.3090905@jp.fujitsu.com> <42249A44.4020507@pobox.com> <Pine.LNX.4.58.0503010844470.25732@ppc970.osdl.org> <20050302182205.GI1220@austin.ibm.com> <1109803303.5611.108.camel@gaston>
In-Reply-To: <1109803303.5611.108.camel@gaston>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Jeff Garzik <jgarzik@pobox.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>

On Thu, Mar 03, 2005 at 09:41:43AM +1100, Benjamin Herrenschmidt was heard to remark:
> On Wed, 2005-03-02 at 12:22 -0600, Linas Vepstas wrote:
> > On Tue, Mar 01, 2005 at 08:49:45AM -0800, Linus Torvalds was heard to remark:
> > > 
> > > The new API is what _allows_ a driver to care. It doesn't handle DMA, but
> > > I think that's because nobody knows how to handle it (ie it's probably
> > > hw-dependent and all existign implementations would thus be
> > > driver-specific anyway).
> > 
> > ?  
> > We could add a call 
> > 
> > int pci_was_there_an_error_during_dma (struct pci_dev);
> > 
> > right?  And it could return true/false, right?  I can certainly 
> > do that today with ppc64.  I just can't tell you which dma triggered
> > the problem.
> 
> That's ugly. I prefer asynchronous notification by far.

Well, we've got that, I think the goal was to figure out what the
PCI-Express folks think they need, and what the dev driver folks want.

Put it another way: a device driver author should have the opportunity
to poll the pci bus status if they so desire.  Polling for bus status
on ppc64 is real easy.  Given what Jesse Barnes was saying, it sounded
like a simple (optional, the dev driver doesn't have to use it) poll 
is not enough, because some errors might be transactional.


--linas
