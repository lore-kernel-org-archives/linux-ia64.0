From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 01 Mar 2005 22:27:27 +0000
Subject: Re: [PATCH/RFC] I/O-check interface for driver's error handling
Message-Id: <1109716047.5679.51.camel@gaston>
List-Id: <linux-ia64.vger.kernel.org>
References: <422428EC.3090905@jp.fujitsu.com>
	 <Pine.LNX.4.58.0503010844470.25732@ppc970.osdl.org>
	 <20050301165904.GN28741@parcelfarce.linux.theplanet.co.uk>
	 <200503010910.29460.jbarnes@engr.sgi.com>
	 <20050301183333.GB1220@austin.ibm.com>
In-Reply-To: <20050301183333.GB1220@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linas Vepstas <linas@austin.ibm.com>
Cc: Jesse Barnes <jbarnes@engr.sgi.com>, linux-pci@atrey.karlin.mff.cuni.cz, Matthew Wilcox <matthew@wil.cx>, Linus Torvalds <torvalds@osdl.org>, Jeff Garzik <jgarzik@pobox.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>

On Tue, 2005-03-01 at 12:33 -0600, Linas Vepstas wrote:

> The current proposal (and prototype) has a "master recovery thread"
> to handle the coordinated reset of the pci controller.  This master
> recovery thyread makes three calls in struct pci_driver:
> 
>    void (*frozen) (struct pci_dev *);  /* called when dev is first frozen */
>    void (*thawed) (struct pci_dev *);  /* called after card is reset */
>    void (*perm_failure) (struct pci_dev *);  /* called if card is dead */

See my other emails. I think only one callback is enough, and I think we
need more parameters.

> The master recovery thread runs in the kernel.  Earlier suggestions said
> "run it in user space, use pci hotplug, use udev, etc." However, if
> you get a pci error on a scsi card, you can't shell script 
> "umount /dev/sdX; rmmod scsi; clear_pci_error; insmod scsi; mount /dev/sdX"
> beacuse you can't umount an open filesystem, and you can't really close
> it (I fiddled with prototyping some of this, but its ugly and painful
> and bizarre and outside my area of expertise :)
> 
> FWIW, the current prototype tries to do a pci hotplug if the above
> routines aren't implemented in struct pci_driver.  It can recover 
> from pci errors on ethernet cards, and I have one scsi driver that
> successfully recovers with above API, and am working on adding recovery
> to the symbios driver.
> 
> --linas
-- 
Benjamin Herrenschmidt <benh@kernel.crashing.org>

