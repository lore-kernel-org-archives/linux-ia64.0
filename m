From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 17 Oct 2003 20:33:23 +0000
Subject: Re: [PATCH] fix topology initialization
Message-Id: <marc-linux-ia64-106642289105919@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106641334730082@msgid-missing>
In-Reply-To: <marc-linux-ia64-106641334730082@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 17, 2003 at 07:37:20PM +0100, Christoph Hellwig wrote:
> > I think this will provide some of the info that hwgfs provides, but not
> > all.  We still need a way to map PCI busses to nodes (or cpumasks,
> > whatever makes sense)
> 
> We should have this in the topology API already in a generic fashion.  Do you
> need it in userland aswell?

Yeah, it might be useful for a userland irq balancer for example.

> > and a way to map nodes & busses to physical, rack mounted bricks.
> 
> Well, that's a SN-specific thing.  But it could be implemented similar to the
> current toplogy API.  What do you actually need this for?

Well, I'm not sure that it should be in the kernel at all.  Maybe it
could just be a SAL call or something with a thin driver wrapper for a
userspace program to use.  It's mainly useful for physically locating
things, e.g.  'the PCI slot on this brick on this rack is dead'.

Jesse
