From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 02 Mar 2005 22:43:48 +0000
Subject: Re: [PATCH/RFC] I/O-check interface for driver's error handling
Message-Id: <1109803429.5611.111.camel@gaston>
List-Id: <linux-ia64.vger.kernel.org>
References: <422428EC.3090905@jp.fujitsu.com>
	 <Pine.LNX.4.58.0503010844470.25732@ppc970.osdl.org>
	 <20050302182205.GI1220@austin.ibm.com>
	 <200503021041.07090.jbarnes@engr.sgi.com>
In-Reply-To: <200503021041.07090.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: linux-pci@atrey.karlin.mff.cuni.cz, Linas Vepstas <linas@austin.ibm.com>, Linus Torvalds <torvalds@osdl.org>, Jeff Garzik <jgarzik@pobox.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>


> One issue with that is how to notify drivers that they need to make this call.  
> In may cases, DMA completion will be signalled by an interrupt, but if the 
> DMA failed, that interrupt may never happen, which means the call to 
> pci_unmap or the above function from the interrupt handler may never occur.
> 
> Some I/O errors are by nature asynchronous and unpredictable, so I think we 
> need a separate thread and callback interface to deal with errors where the 
> beginning of the transaction and the end of the transaction occur in 
> different contexts, in addition to the PIO transaction interface already 
> proposed.

Yup. As I wrote already. We need a new callback in pci_driver, that's
the cleanest way. It would take an "event" argument plus some still to
be defined flags to inform the driver about platform capabilities.

The driver based on the result code can then request a slot reset  if
the platform supports it, or just try to recover, or just giveup.

Another callback would come once the slot has been reset & reconfigure,
etc...

I'm going to write something down real soon now (after I had breakfast
hopefully :)

Ben.


