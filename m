From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 10 Aug 2005 16:23:41 +0000
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 2.
Message-Id: <1123691021.11313.2.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050809194115.C370.Y-GOTO@jp.fujitsu.com>
	 <20050809211501.GB6235@w-mikek2.ibm.com>
	 <1123643188.7069.8.camel@localhost>
In-Reply-To: <1123643188.7069.8.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Kravetz <kravetz@us.ibm.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "Martin J. Bligh" <mbligh@mbligh.org>, ia64 list <linux-ia64@vger.kernel.org>, "Luck, Tony" <tony.luck@intel.com>

On Tue, 2005-08-09 at 20:06 -0700, Dave Hansen wrote: 
> On Tue, 2005-08-09 at 14:15 -0700, Mike Kravetz wrote:
> > On Tue, Aug 09, 2005 at 08:11:20PM +0900, Yasunori Goto wrote:
> > > I modified the patch which guarantees allocation of DMA area
> > > at alloc_bootmem_low().
> > 
> > I was going to replace more instances of __pa(MAX_DMA_ADDRESS) with
> > max_dma_physaddr().  However, when grepping for MAX_DMA_ADDRESS I
> > noticed instances of virt_to_phys(MAX_DMA_ADDRESS) as well.  Can
> > someone tell me what the differences are between __pa() and virt_to_phys().

One more thing is the obvious: __pa() is always a macro, and
virt_to_phys() is sometimes a function.  __pa() can, therefore, be used
in assembly.

-- Dave

