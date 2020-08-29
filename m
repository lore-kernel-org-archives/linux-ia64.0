From: David Rientjes <rientjes@google.com>
Date: Sat, 29 Aug 2020 21:39:11 +0000
Subject: Re: [PATCH] ia64: fix min_low_pfn/max_low_pfn build errors
Message-Id: <alpine.DEB.2.23.453.2008291439020.3955211@chino.kir.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200829000126.2463-1-rdunlap@infradead.org>
In-Reply-To: <20200829000126.2463-1-rdunlap@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-kernel@vger.kernel.org, kernel test robot <lkp@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.ibm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Fri, 28 Aug 2020, Randy Dunlap wrote:

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

Acked-by: David Rientjes <rientjes@google.com>

Thanks Randy!
