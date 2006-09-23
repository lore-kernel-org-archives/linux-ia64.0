From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 23 Sep 2006 01:18:56 +0000
Subject: Re: IA64 without ZONE_DMA?
Message-Id: <20060923101856.8ecabed3.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0609221622170.10232@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609221622170.10232@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 22 Sep 2006 16:30:20 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> There is code in Andrews tree that allows getting rid of ZONE_DMA. I know 
> that SGI machines do not use ZONE_DMA. I looked through the arch code and 
> I do not see ZONE_DMA or GFP_DMA uses that I cannot account for. However, 
> I am not familiar with the code for other IA64 platforms.
> 
> This patch will make IA64 have a single zone in each node. As a result
> loops are unrolled, various VM macros can be optimized further and the 
> memory load balancing code between different zones in one node is no 
> longer necessary. Note that having no ZONE_DMA means that GFP_DMA will be 
> ignored. If you know of any devices depending on ZONE_DMA (memory returned 
> must be below 4GB) then we first need to deal with those possibly by 
> modifying dma_alloc_coherent functions to obtain memory in a different 
> way than via GFP_DMA.
> 
> We are currently working on a new page allocator function
> 
> alloc_pages_range()
>
looks atractive :) But how to use it ? the devices(codes) can know their
necessary and available address range on any platform ?


-Kame

