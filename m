From: Linas Vepstas <linas@austin.ibm.com>
Date: Tue, 01 Mar 2005 18:33:33 +0000
Subject: Re: [PATCH/RFC] I/O-check interface for driver's error handling
Message-Id: <20050301183333.GB1220@austin.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <422428EC.3090905@jp.fujitsu.com> <Pine.LNX.4.58.0503010844470.25732@ppc970.osdl.org> <20050301165904.GN28741@parcelfarce.linux.theplanet.co.uk> <200503010910.29460.jbarnes@engr.sgi.com>
In-Reply-To: <200503010910.29460.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: linux-pci@atrey.karlin.mff.cuni.cz, Matthew Wilcox <matthew@wil.cx>, Linus Torvalds <torvalds@osdl.org>, Jeff Garzik <jgarzik@pobox.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Luck, Tony" <tony.luck@intel.com>

On Tue, Mar 01, 2005 at 09:10:29AM -0800, Jesse Barnes was heard to remark:
> On Tuesday, March 1, 2005 8:59 am, Matthew Wilcox wrote:
> > The MCA handler has to go and figure out what the hell just happened
> > (was it a DIMM error, PCI bus error, etc).  

I assume "MCA" stands for machine check architecture .. except that 
is not how it currently works, at least not on the systems I work with.  

The PCI bridge chips on many IBM ppc64 pSereies boxes can detect 
PCI errors and handle them "cleanly", without causing machine checks;
so can some PCI-Express chips (Seto is the expert on PCI-Express,
I'm not).

On ppc64, after a PCI error, the pci slot is "isolated":  all i/o 
to and from the device is cut off (including dma).  I/O reads return
all 0xff's (which is what an empty pci/pcmcia slot returns).  

There are three low-level firmware api's:
-- ask if a slot is "isolated" (returns yes/no)
-- reset the pci card (assert the #RST pci signal)
-- un-isolate the pci slot 

The current ppc64 code doesn't use Seto's API, but it could, that
is the direction I'm moving towards.  

I don't know if PCI-Express "isolates" the slot; Seto, can you provide
an overview of what the PCI-Express spec says?

> > If we're lucky, we get all the information that allows us to figure
> > out which device it was (eg a destination address that matches a BAR),

Seto's API allows drivers to find out is thier PCI slot is isolated.
So it works for me.

> > then we could have a ->error method in the pci_driver that handles it.
> > If there's no ->error method, at leat call ->remove so one device only
> > takes itself down.

The tricky part is what to do with multi-function cards/slots
(e.g. a pci bus error on a bridge that has multiple devices under it).
In this case, multiple device drivers are affected.  Thus, no single
device driver can handle the recovery of the bridge chip.

The current proposal (and prototype) has a "master recovery thread"
to handle the coordinated reset of the pci controller.  This master
recovery thyread makes three calls in struct pci_driver:

   void (*frozen) (struct pci_dev *);  /* called when dev is first frozen */
   void (*thawed) (struct pci_dev *);  /* called after card is reset */
   void (*perm_failure) (struct pci_dev *);  /* called if card is dead */

The master recovery thread runs in the kernel.  Earlier suggestions said
"run it in user space, use pci hotplug, use udev, etc." However, if
you get a pci error on a scsi card, you can't shell script 
"umount /dev/sdX; rmmod scsi; clear_pci_error; insmod scsi; mount /dev/sdX"
beacuse you can't umount an open filesystem, and you can't really close
it (I fiddled with prototyping some of this, but its ugly and painful
and bizarre and outside my area of expertise :)

FWIW, the current prototype tries to do a pci hotplug if the above
routines aren't implemented in struct pci_driver.  It can recover 
from pci errors on ethernet cards, and I have one scsi driver that
successfully recovers with above API, and am working on adding recovery
to the symbios driver.

--linas
