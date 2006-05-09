From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 09 May 2006 22:08:36 +0000
Subject: RE: [PATCH 2/3] swiotlb: create __alloc_bootmem_low_nopanic and add support in SWIOTLB
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F06704163@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060504205929.GD14361@us.ibm.com>
In-Reply-To: <20060504205929.GD14361@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jon Mason <jdmason@us.ibm.com>
Cc: Muli Ben-Yehuda <muli@il.ibm.com>, linux-kernel@vger.kernel.org, ak@suse.de, linux-ia64@vger.kernel.org, mulix@mulix.org

> Ah, then I better describe it.  The patch makes it possible to recover
> from an insufficient amount of bootmem during swiotlb_init (instead of
> panicing).  For x86_64, I have it bailing out (via the returned int from
> swiotlb_init and using the non-iommu DMA routines from
> arch/x86_64/kernel/pci-nommu.c).  For ia64, its not that simple.
> There are no alternative DMA routines to switch to incase of an error.
> Also, There is no way to "bail-out" from its mem_init.  I could add a
> panic there, if that is more palatable.

Presumably if you have insufficient memory to allocate the swiotlb
buffers, then you actually don't need *any* swiotlb buffers at all
as all your memory is at low enough addresses to be directly accessed
by whatever devices you have (offer void on bizarre discontig systems
that put the only memory they have in an address range that can't be
used by the devices that need to access it ... but perhaps in that
case it would be better to buy a different computer :-)

But ignoring that ... a new "noop" routine that returns an int
does seem to be the right solution.  Looking at the others that
are already there, calling it machvec_noop_dma() isn't a bad fit
with the style of the other "_noop" functions that are already
there.

-Tony
