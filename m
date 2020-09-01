From: Mike Rapoport <rppt@linux.ibm.com>
Date: Tue, 01 Sep 2020 04:19:02 +0000
Subject: Re: [PATCH] ia64: fix min_low_pfn/max_low_pfn build errors
Message-Id: <20200901041902.GC424181@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200829000126.2463-1-rdunlap@infradead.org>
In-Reply-To: <20200829000126.2463-1-rdunlap@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, kernel test robot <lkp@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Tony,

I can take it via the memblock tree, would appreciate an Ack.

On Fri, Aug 28, 2020 at 05:01:26PM -0700, Randy Dunlap wrote:
> Fix min_low_pfn/max_low_pfn build errors for arch/ia64/: (e.g.)
> 
>  ERROR: "max_low_pfn" [drivers/rpmsg/virtio_rpmsg_bus.ko] undefined!
>  ERROR: "min_low_pfn" [drivers/rpmsg/virtio_rpmsg_bus.ko] undefined!
>  ERROR: "min_low_pfn" [drivers/hwtracing/intel_th/intel_th_msu.ko] undefined!
>  ERROR: "max_low_pfn" [drivers/hwtracing/intel_th/intel_th_msu.ko] undefined!
>  ERROR: "min_low_pfn" [drivers/crypto/cavium/nitrox/n5pf.ko] undefined!
>  ERROR: "max_low_pfn" [drivers/crypto/cavium/nitrox/n5pf.ko] undefined!
>  ERROR: "max_low_pfn" [drivers/md/dm-integrity.ko] undefined!
>  ERROR: "min_low_pfn" [drivers/md/dm-integrity.ko] undefined!
>  ERROR: "max_low_pfn" [crypto/tcrypt.ko] undefined!
>  ERROR: "min_low_pfn" [crypto/tcrypt.ko] undefined!
>  ERROR: "min_low_pfn" [security/keys/encrypted-keys/encrypted-keys.ko] undefined!
>  ERROR: "max_low_pfn" [security/keys/encrypted-keys/encrypted-keys.ko] undefined!
>  ERROR: "min_low_pfn" [arch/ia64/kernel/mca_recovery.ko] undefined!
>  ERROR: "max_low_pfn" [arch/ia64/kernel/mca_recovery.ko] undefined!
> 
> David suggested just exporting min_low_pfn & max_low_pfn in
> mm/memblock.c:
> https://lore.kernel.org/lkml/alpine.DEB.2.22.394.2006291911220.1118534@chino.kir.corp.google.com/
> 
> Reported-by: kernel test robot <lkp@intel.com>
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> Cc: linux-mm@kvack.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: linux-ia64@vger.kernel.org
> ---
>  arch/ia64/kernel/ia64_ksyms.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-next-20200825.orig/arch/ia64/kernel/ia64_ksyms.c
> +++ linux-next-20200825/arch/ia64/kernel/ia64_ksyms.c
> @@ -3,7 +3,7 @@
>   * Architecture-specific kernel symbols
>   */
>  
> -#ifdef CONFIG_VIRTUAL_MEM_MAP
> +#if defined(CONFIG_VIRTUAL_MEM_MAP) || defined(CONFIG_DISCONTIGMEM)
>  #include <linux/compiler.h>
>  #include <linux/export.h>
>  #include <linux/memblock.h>

-- 
Sincerely yours,
Mike.
