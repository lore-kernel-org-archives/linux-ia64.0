From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 02 Mar 2005 22:46:12 +0000
Subject: Re: [PATCH/RFC] I/O-check interface for driver's error handling
Message-Id: <1109803572.5679.113.camel@gaston>
List-Id: <linux-ia64.vger.kernel.org>
References: <422428EC.3090905@jp.fujitsu.com>
	 <Pine.LNX.4.58.0503010844470.25732@ppc970.osdl.org>
	 <20050301165904.GN28741@parcelfarce.linux.theplanet.co.uk>
	 <200503010910.29460.jbarnes@engr.sgi.com>
	 <20050301183333.GB1220@austin.ibm.com> <1109716047.5679.51.camel@gaston>
	 <20050302200216.GM1220@austin.ibm.com>
In-Reply-To: <20050302200216.GM1220@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linas Vepstas <linas@austin.ibm.com>
Cc: Jesse Barnes <jbarnes@engr.sgi.com>, linux-pci@atrey.karlin.mff.cuni.cz, Matthew Wilcox <matthew@wil.cx>, Linus Torvalds <torvalds@osdl.org>, Jeff Garzik <jgarzik@pobox.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>

On Wed, 2005-03-02 at 14:02 -0600, Linas Vepstas wrote:
> On Wed, Mar 02, 2005 at 09:27:27AM +1100, Benjamin Herrenschmidt was heard to remark:

> That's a style issue.  Propose an API, I'll code it.   We can have
> the master recovery thread be a state machine, and so every device
> driver gets notified of state changes:
> 
> typedef enum pci_bus_state {
>      DEVICE_IO_FROZEN=1,
>      DEVICE_IO_THAWED,
>      DEVICE_PERM_FAILURE,
> };
> 
> struct pci_driver {
>    .... 
>    void (*io_state_change) (struct pci_dev *dev, pci_bus_state);
> };
> 
> would that work?

Too much ppc64-centric.

Also, we want to use the re-enable IOs facility of EEH to give the
driver a chance to extract diagnostic infos from the HW.

Ben.


