From: Jesse Barnes <jesse.barnes@intel.com>
Date: Wed, 11 May 2005 15:58:26 +0000
Subject: Re: [RFC] pcibus_to_node implementation for ia64
Message-Id: <200505110858.26342.jesse.barnes@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0505051707220.6114@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0505051707220.6114@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, May 11, 2005 8:49 am, you wrote:
> On Wed, 11 May 2005, colin ngam wrote:
> > >That's certainly another way to go--just make the function do a
> > > search to find the closest node with memory (and/or CPUs) all by
> > > itself.  The obvious disadvantage is that you'll incur that cost
> > > on every function call unless you build a lookup table at boot
> > > time or somesuch.
>
> This search is performed by alloc_pages using the zonelists.

Not right now it isn't.  In the snippet you posted you might get back a 
special node id, one that corresponds to an I/O node, which doesn't 
have a pgdat associated with it, and therefore won't work when passed 
to alloc_pages_node (I think it'll panic).

> How do I get a node that I can pass to alloc_pages_node?

Fix the sn2 implementation of I/O nodes to make them more like regular 
nodes.  Basically,

  o put them in the SLIT and SRAT tables
  o make sure empty pgdats are created for memoryless nodes (in
    discontig.c), ideally on the closest node containing memory.

The first step isn't strictly necessary since you could fake it (you'd 
probably have to pull some code from io_init.c out and make it usable 
at early boot), but is probably preferable to putting together an ugly 
hack.

Jesse
