From: Linas Vepstas <linas@austin.ibm.com>
Date: Tue, 01 Mar 2005 19:17:54 +0000
Subject: Re: [PATCH/RFC] I/O-check interface for driver's error handling
Message-Id: <20050301191754.GD1220@austin.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <422428EC.3090905@jp.fujitsu.com> <42249A44.4020507@pobox.com>
In-Reply-To: <42249A44.4020507@pobox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jgarzik@pobox.com>
Cc: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Luck, Tony" <tony.luck@intel.com>

On Tue, Mar 01, 2005 at 11:37:24AM -0500, Jeff Garzik was heard to remark:
> 
> A new API handles none of this.

Seto is propsing an API that solves a different problem than what
you are thinking about.

In my case, the hardware (pci controller) will shut down a pci
slot(s) in the case of a pci error (parity or otherwise).  
There's nothing that the software can do except to reset
the pci controller (and the cards underneath it).

Seto's API solves 1/2 the problem for me: it allows errors
to be detected.  The other 1/2 (to be discussed) is how
to coordinate all the affected device drivers while the
pci controller is being reset.


--linas
