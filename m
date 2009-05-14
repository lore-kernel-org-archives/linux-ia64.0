From: Fenghua Yu <fenghua.yu@intel.com>
Date: Thu, 14 May 2009 17:59:44 +0000
Subject: Re: [PATCH] Fix Intel IOMMU Compilation Warnings on IA64
Message-Id: <20090514175944.GA5168@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090327212241.234500000@intel.com> <20090327212321.070229000@intel.com> <20090416001957.GA1527@linux-os.sc.intel.com> <1240135508.3589.75.camel@macbook.infradead.org> <A6AD88C3F2289247BE726C37303E1EB8A4DF7DB1@orsmsx505.amr.corp.intel.com> <20090513231351.GA22386@linux-os.sc.intel.com> <1242314271.3393.11.camel@macbook.infradead.org>
In-Reply-To: <1242314271.3393.11.camel@macbook.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: David Woodhouse <dwmw2@infradead.org>
Cc: "Yu, Fenghua" <fenghua.yu@intel.com>, "Luck, Tony" <tony.luck@intel.com>, 'lkml' <linux-kernel@vger.kernel.org>, 'iommu' <iommu@lists.linux-foundation.org>, 'ia64' <linux-ia64@vger.kernel.org>

On Thu, May 14, 2009 at 08:17:51AM -0700, David Woodhouse wrote:
> On Wed, 2009-05-13 at 16:13 -0700, Fenghua Yu wrote:
> > Compiling kernel on IA64 reports two warnings in intel-iommu.c:
> > 
> > drivers/pci/intel-iommu.c:3150: warning: format ?%llx? expects
> > type ?long long unsigned int?, but argument 4 has type ?u64?
> > drivers/pci/intel-iommu.c: In function ?intel_iommu_map_range?:
> > drivers/pci/intel-iommu.c:3201: warning: format ?%llx? expects
> > type ?long long unsigned int?, but argument 4 has type ?u64?
> 
> Charset corruption there? I'm sure GCC didn't actually use question
> marks...

Yes, somehow the charset is corrupted during procedure. Below is correct one:

drivers/pci/intel-iommu.c: In function ‘intel_iommu_attach_device’:
drivers/pci/intel-iommu.c:3150: warning: format ‘%llx’ expects type ‘long long unsigned int’, but argument 4 has type ‘u64’
drivers/pci/intel-iommu.c: In function ‘intel_iommu_map_range’:
drivers/pci/intel-iommu.c:3201: warning: format ‘%llx’ expects type ‘long long unsigned int’, but argument 4 has type ‘u64’

> 
> Perhaps this would be better, modelled after commit fe333321:
> 
> diff --git a/arch/ia64/include/asm/types.h b/arch/ia64/include/asm/types.h
> index e36b371..b0ecc20 100644
> --- a/arch/ia64/include/asm/types.h
> +++ b/arch/ia64/include/asm/types.h
> @@ -13,7 +13,11 @@
>   *	David Mosberger-Tang <davidm@hpl.hp.com>, Hewlett-Packard Co
>   */
>  
> +#ifdef __KERNEL__
> +#include <asm-generic/int-ll64.h>
> +#else
>  #include <asm-generic/int-l64.h>
> +#endif
>  
>  #ifdef __ASSEMBLY__
>  # define __IA64_UL(x)		(x)
> 

A lot of places in IA64 kernel assume l64. So it would be a big patch and
testing to change to ll64. I assume Matthew's patch will do that?

Thanks.

-Fenghua
