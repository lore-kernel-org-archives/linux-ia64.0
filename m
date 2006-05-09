From: Jon Mason <jdmason@us.ibm.com>
Date: Tue, 09 May 2006 21:26:03 +0000
Subject: Re: [PATCH 2/3] swiotlb: create __alloc_bootmem_low_nopanic and add support in SWIOTLB
Message-Id: <20060509212602.GD22385@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0670403C@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F0670403C@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Muli Ben-Yehuda <muli@il.ibm.com>, linux-kernel@vger.kernel.org, ak@suse.de, linux-ia64@vger.kernel.org, mulix@mulix.org

On Tue, May 09, 2006 at 02:04:08PM -0700, Luck, Tony wrote:
> > I "fixed" it with the hack below.  Please let me know if this is not
> > palatable for you.
> 
> Not really.  The only use of platform_dma_init() that I can see is in
> arch/ia64/mm/init.c:mem_init() ...
> 
> 	platform_dma_init();
> 
> so "void" looks to be the right return value.  Why did it get changed to
> be "int" (here's where I admit that I've only looked superficially at your
> patch).

Ah, then I better describe it.  The patch makes it possible to recover
from an insufficient amount of bootmem during swiotlb_init (instead of
panicing).  For x86_64, I have it bailing out (via the returned int from
swiotlb_init and using the non-iommu DMA routines from
arch/x86_64/kernel/pci-nommu.c).  For ia64, its not that simple.
There are no alternative DMA routines to switch to incase of an error.
Also, There is no way to "bail-out" from its mem_init.  I could add a
panic there, if that is more palatable.

Thanks,
Jon

> 
> -Tony
