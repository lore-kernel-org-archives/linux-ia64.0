From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 13 Oct 2006 18:03:33 +0000
Subject: Re: [RFC] Variable Kernel Page size support
Message-Id: <Pine.LNX.4.64.0610131051070.25828@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0610121730050.22778@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0610121730050.22778@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 13 Oct 2006, Robin Holt wrote:

> How do you handle speculation issues this raises.  Right now, we can
> ensure that speculation only occurs on a granule boundary.  mspec converts
> granules to uncached.  With this patch, we would have to allocate a chunk,
> determine the size of page table backing that chunk, if it does not span
> the entire, free it and ask for a larger chunk.  Alternatively, we would
> need to allocate a series of granule size chunks until none were found,
> then double that size and repeat.

The memory mapped via a vkp is reserved for a certain purpose. 
There will be only cached accesses. No mspec data will be there. I do not 
understand how any of the above scenarios could occur.

If you are concerned about multiple TLBs referring to the same physical 
address: The same is true for the current vmemmap page sized 
implementation. Addresses mapped via region 7 may have both a 16MB direct 
mapping via region7 and a 16k page sized one via region 5.

> Have you shown a benefit from this work yet?  In my and IIRC Jack's
> experience, nearly every place in the kernel that I have seen operating
> on vmem_map and struct page * that is performance critical have adequate
> TLB pressure to cause TLB replacement for the vmem_map.  With your patch,
> how much extra work is the kernel going to need to do when replacing an
> entry which will essentially end up being used once?

The effort is to walk the page table for each TLB miss in region 7 for 
custom page sizes. This is going to be rare given a large enough page 
size. For example with a vmem_map size of 16Meg one will have a single TLB 
entry for the vmemmap section for each node. It will be exceedingly rare 
to have that replaced.

> If you want vmem_map to have variable page sizes, how about specifying the
> min and max at something crazy like base page size for ia64.  Then you
> could still make the code generic and get it into the mainline kernel
> and not affect ia64.

Sorry but i386 and x86_64 (and many other processors) do not support 
variable page sizes. They will only support 2 or 3 fixed page sizes. So 
this cannot be genericed at all. We already  have a simulation of variable 
page sizes with sparsemem. That requires lots of lookups for each 
elementary address conversion in the VM.

We are simply using the supported page sizes of IA64 here.
