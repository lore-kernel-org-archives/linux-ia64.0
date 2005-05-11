From: Jack Steiner <steiner@sgi.com>
Date: Wed, 11 May 2005 16:19:16 +0000
Subject: Re: [RFC] pcibus_to_node implementation for ia64
Message-Id: <20050511161916.GB25431@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0505051707220.6114@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0505051707220.6114@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 11, 2005 at 08:58:26AM -0700, Jesse Barnes wrote:
> On Wednesday, May 11, 2005 8:49 am, you wrote:
> > On Wed, 11 May 2005, colin ngam wrote:
> > > >That's certainly another way to go--just make the function do a
> > > > search to find the closest node with memory (and/or CPUs) all by
> > > > itself.  The obvious disadvantage is that you'll incur that cost
> > > > on every function call unless you build a lookup table at boot
> > > > time or somesuch.
> >
> > This search is performed by alloc_pages using the zonelists.
> 
> Not right now it isn't.  In the snippet you posted you might get back a 
> special node id, one that corresponds to an I/O node, which doesn't 
> have a pgdat associated with it, and therefore won't work when passed 
> to alloc_pages_node (I think it'll panic).
> 
> > How do I get a node that I can pass to alloc_pages_node?
> 
> Fix the sn2 implementation of I/O nodes to make them more like regular 
> nodes.  Basically,
> 
>   o put them in the SLIT and SRAT tables
>   o make sure empty pgdats are created for memoryless nodes (in
>     discontig.c), ideally on the closest node containing memory.

You are correct. 

Most of the confusion here results from overloading the 
term "node". Our (SGI) usage of the term "node" for TIO nodes is 
inompatible with "node" as used in the rest of the kernel.

TIO "nodes" are unusual in the sense that they have no cpus or memory, but DO
have the properties of distance & "nearness" to ordinary nodes. For most
purposes, you can think of TIO nodes as ordinary nodes with cpus & memory 
removed - only IO remains. (Physically, this is not correct but it's close 
enough....).

TIO nodes _should_ be described in the SRAT & SLIT tables.

Currently, there are several problems with treating TIO nodes as ordinary
nodes & describing them in the SRTA/SLIT. AFAICT, ACPI2.0 does not support 
an SRAT description for this type of node. Only PROCESSOR & MEMORY SRAT 
entries exist. 

The second limitation is that ACPI 2.0 limits the size of the SLIT to
256x256. Our largest system currently supports 256 nodes with memory/cpus +
an additional 256 TIO nodes. We would need at least a 512x512 SLIT to describe
our largest system. In ACPI3.0, these limitations are removed (I think).

I think it is time to take a step back & figure out how to correctly
describe TIO nodes & make them fit within the ACPI & kernel structures.

(BTW, does anyone know when ACPI3.0 will be implemented for IA64 ???)



> 
> The first step isn't strictly necessary since you could fake it (you'd 
> probably have to pull some code from io_init.c out and make it usable 
> at early boot), but is probably preferable to putting together an ugly 
> hack.
> 
> Jesse
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


