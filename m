From: Mike Rapoport <rppt@linux.ibm.com>
Date: Sat, 29 Aug 2020 13:04:29 +0000
Subject: Re: [ALTERNATE PATCH] memblock: fix min_low_pfn/max_low_pfn build errors
Message-Id: <20200829130429.GG167163@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200829000139.2513-1-rdunlap@infradead.org>
In-Reply-To: <20200829000139.2513-1-rdunlap@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-kernel@vger.kernel.org, kernel test robot <lkp@intel.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Simek <monstr@monstr.eu>, Michal Simek <michal.simek@xilinx.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Fri, Aug 28, 2020 at 05:01:39PM -0700, Randy Dunlap wrote:
> Export min_low_pfn & max_low_pfn in mm/memblock.c to fix build errors
> on arch/microblaze/ and arch/ia64/: (e.g.)

Please don't. This would give driver developers a wrong impression that
these variables can be used to query memory boundaries, but this is not
the case, at least not on all architectures.

I would prefer fixing it up locally for microblaze and ia64.

>   ERROR: "max_low_pfn" [drivers/rpmsg/virtio_rpmsg_bus.ko] undefined!
>   ERROR: "min_low_pfn" [drivers/rpmsg/virtio_rpmsg_bus.ko] undefined!
>   ERROR: "max_low_pfn" [drivers/mtd/spi-nor/spi-nor.ko] undefined!
>   ERROR: "min_low_pfn" [drivers/mtd/spi-nor/spi-nor.ko] undefined!
>   ERROR: "min_low_pfn" [drivers/mtd/nand/raw/nand.ko] undefined!
>   ERROR: "max_low_pfn" [drivers/mtd/nand/raw/nand.ko] undefined!
>   ERROR: "max_low_pfn" [drivers/rapidio/devices/rio_mport_cdev.ko] undefined!
>   ERROR: "min_low_pfn" [drivers/rapidio/devices/rio_mport_cdev.ko] undefined!
>   ERROR: "min_low_pfn" [drivers/hwtracing/intel_th/intel_th_msu.ko] undefined!
>   ERROR: "max_low_pfn" [drivers/hwtracing/intel_th/intel_th_msu.ko] undefined!
>   ERROR: "min_low_pfn" [drivers/crypto/cavium/nitrox/n5pf.ko] undefined!
>   ERROR: "max_low_pfn" [drivers/crypto/cavium/nitrox/n5pf.ko] undefined!
>   ERROR: "max_low_pfn" [drivers/md/dm-integrity.ko] undefined!
>   ERROR: "min_low_pfn" [drivers/md/dm-integrity.ko] undefined!
>   ERROR: "max_low_pfn" [crypto/tcrypt.ko] undefined!
>   ERROR: "min_low_pfn" [crypto/tcrypt.ko] undefined!
> 
> In both arches, these variables are referenced in
> arch/$ARCH/include/asm/page.h.
> 
> Mike had/has an alternate patch for Microblaze:
> https://lore.kernel.org/lkml/20200630111519.GA1951986@linux.ibm.com/
> 
> David suggested just exporting min_low_pfn & max_low_pfn in
> mm/memblock.c:
> https://lore.kernel.org/lkml/alpine.DEB.2.22.394.2006291911220.1118534@chino.kir.corp.google.com/
> 
> Reported-by: kernel test robot <lkp@intel.com>
> Suggested-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> Cc: linux-mm@kvack.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Cc: Michal Simek <monstr@monstr.eu>
> Cc: Michal Simek <michal.simek@xilinx.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: linux-ia64@vger.kernel.org
> ---
>  mm/memblock.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> --- linux-next-20200825.orig/mm/memblock.c
> +++ linux-next-20200825/mm/memblock.c
> @@ -99,6 +99,8 @@ EXPORT_SYMBOL(contig_page_data);
>  
>  unsigned long max_low_pfn;
>  unsigned long min_low_pfn;
> +EXPORT_SYMBOL(min_low_pfn);
> +EXPORT_SYMBOL(max_low_pfn);
>  unsigned long max_pfn;
>  unsigned long long max_possible_pfn;
>  

-- 
Sincerely yours,
Mike.
