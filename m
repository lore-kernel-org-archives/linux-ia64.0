From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 01 Mar 2005 17:10:29 +0000
Subject: Re: [PATCH/RFC] I/O-check interface for driver's error handling
Message-Id: <200503010910.29460.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <422428EC.3090905@jp.fujitsu.com> <Pine.LNX.4.58.0503010844470.25732@ppc970.osdl.org> <20050301165904.GN28741@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20050301165904.GN28741@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@atrey.karlin.mff.cuni.cz
Cc: Matthew Wilcox <matthew@wil.cx>, Linus Torvalds <torvalds@osdl.org>, Jeff Garzik <jgarzik@pobox.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linas Vepstas <linas@austin.ibm.com>, "Luck, Tony" <tony.luck@intel.com>

On Tuesday, March 1, 2005 8:59 am, Matthew Wilcox wrote:
> The MCA handler has to go and figure out what the hell just happened
> (was it a DIMM error, PCI bus error, etc).  OK, fine, it finds that it
> was an error on PCI bus 73.  At this point, I think the architecture
> error handler needs to call into the PCI subsystem and say "Hey, there
> was an error, you deal with it".
>
> If we're lucky, we get all the information that allows us to figure
> out which device it was (eg a destination address that matches a BAR),
> then we could have a ->error method in the pci_driver that handles it.
> If there's no ->error method, at leat call ->remove so one device only
> takes itself down.
>
> Does this make sense?

This was my thought too last time we had this discussion.  A completely 
asynchronous call is probably needed in addition to Hidetoshi's proposed API, 
since as you point out, the driver may not be running when an error occurs 
(e.g. in the case of a DMA error or more general bus problem).  The async 
->error callback could do a total reset of the card, or something along those 
lines as Jeff suggests, while the inline ioerr_clear/ioerr_check API could 
potentially deal with errors as they happen (probably in the case of PIO 
related errors), when the additional context may allow us to be smarter about 
recovery.

Jesse
