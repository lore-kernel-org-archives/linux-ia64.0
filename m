From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 17 Oct 2003 18:37:20 +0000
Subject: Re: [PATCH] fix topology initialization
Message-Id: <marc-linux-ia64-106641601200638@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106641334730082@msgid-missing>
In-Reply-To: <marc-linux-ia64-106641334730082@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 17, 2003 at 11:27:07AM -0700, Jesse Barnes wrote:
> On Fri, Oct 17, 2003 at 07:05:11PM +0100, Christoph Hellwig wrote:
> > On Fri, Oct 17, 2003 at 10:48:34AM -0700, Jesse Barnes wrote:
> > > Now that NUMA kernels are working we can properly initialze the topology
> > > information so that /sys/devices/system/node* & friends aren't empty.
> > 
> > So with a proper topology API we can start to kill off the topology-related
> > hwgfs mess?
> 
> I think this will provide some of the info that hwgfs provides, but not
> all.  We still need a way to map PCI busses to nodes (or cpumasks,
> whatever makes sense)

We should have this in the topology API already in a generic fashion.  Do you
need it in userland aswell?

> and a way to map nodes & busses to physical, rack mounted bricks.

Well, that's a SN-specific thing.  But it could be implemented similar to the
current toplogy API.  What do you actually need this for?
