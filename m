From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 02 Mar 2005 23:40:09 +0000
Subject: Re: [PATCH/RFC] I/O-check interface for driver's error handling
Message-Id: <200503021540.10222.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <422428EC.3090905@jp.fujitsu.com> <1109803303.5611.108.camel@gaston> <20050302233003.GO1220@austin.ibm.com>
In-Reply-To: <20050302233003.GO1220@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@atrey.karlin.mff.cuni.cz
Cc: Linas Vepstas <linas@austin.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@osdl.org>, Jeff Garzik <jgarzik@pobox.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>

On Wednesday, March 2, 2005 3:30 pm, Linas Vepstas wrote:
> Put it another way: a device driver author should have the opportunity
> to poll the pci bus status if they so desire.  Polling for bus status
> on ppc64 is real easy.  Given what Jesse Barnes was saying, it sounded
> like a simple (optional, the dev driver doesn't have to use it) poll
> is not enough, because some errors might be transactional.

Yeah, I'm not arguing against your call, it could be useful for polling for 
errors or for use in an error handling callback.  What I was trying to say 
earlier (maybe I wasn't very clear) was that the idea of creating 
transactions for certain types of I/O (even if those transactions are 
artificial and purely in software) can be useful since it creates boundaries 
and context, making it easier to figure out what went wrong, hopefully making 
it easier to fix things and carry on.

IOW, using Seto-san's iochk_clear/iochk_read interface makes certain types of 
errors much easier to deal with since you *know* where an error occurred and 
can presumably deal with it right away.  The problem comes in for things that 
aren't well encapsulated, like DMA, for which error polling or some sort of 
callback is needed (and even with polling you'll need to poll in an error 
handling thread as you mentioned since the driver may start DMA, return, and 
the error can happen later when we're not actually in driver code).  So I 
think we mostly agree on what things need to be done, you and benh just have 
to fight it out over the details. :)

Jesse
