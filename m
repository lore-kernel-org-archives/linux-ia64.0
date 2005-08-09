From: Mike Kravetz <kravetz@us.ibm.com>
Date: Tue, 09 Aug 2005 21:15:02 +0000
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 2.
Message-Id: <20050809211501.GB6235@w-mikek2.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050809194115.C370.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20050809194115.C370.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>

On Tue, Aug 09, 2005 at 08:11:20PM +0900, Yasunori Goto wrote:
> I modified the patch which guarantees allocation of DMA area
> at alloc_bootmem_low().

Thanks!

I was going to replace more instances of __pa(MAX_DMA_ADDRESS) with
max_dma_physaddr().  However, when grepping for MAX_DMA_ADDRESS I
noticed instances of virt_to_phys(MAX_DMA_ADDRESS) as well.  Can
someone tell me what the differences are between __pa() and virt_to_phys().
I noticed that on some archs they are the same, but are different on
others.

-- 
Mike
