From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Thu, 21 Feb 2008 23:45:05 +0000
Subject: Re: [PATCH 21/28] ia64/xen: define xen related address conversion
Message-Id: <47BE0D01.4020902@goop.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

yamahata@valinux.co.jp wrote:
> diff --git a/include/asm-ia64/page.h b/include/asm-ia64/page.h
> index 4999a6c..effd2af 100644
> --- a/include/asm-ia64/page.h
> +++ b/include/asm-ia64/page.h
> @@ -227,4 +227,15 @@ get_order (unsigned long size)
>  					 (((current->personality & READ_IMPLIES_EXEC) != 0)	\
>  					  ? VM_EXEC : 0))
>  
> +#ifndef __ASSEMBLY__
> +
> +#include <linux/kernel.h>
>   

Why?  asm-ia64/xen/page.h already includes this.

> +
> +#ifdef CONFIG_XEN
> +
> +#include <asm/xen/page.h>
>   

This shouldn't be necessary; anyone wanting Xen-specific definitions 
should explicitly include <xen/page.h>.

> +
> +#endif /* CONFIG_XEN */
> +#endif /* __ASSEMBLY__ */
> +
>  #endif /* _ASM_IA64_PAGE_H */
> diff --git a/include/asm-ia64/xen/page.h b/include/asm-ia64/xen/page.h
> new file mode 100644
> index 0000000..9ab8148
> --- /dev/null
> +++ b/include/asm-ia64/xen/page.h
> @@ -0,0 +1,19 @@
> +#ifndef _ASM_IA64_MADDR_H
> +#define _ASM_IA64_MADDR_H
> +
> +#include <linux/kernel.h>
> +#include <asm/xen/hypervisor.h>
> +#include <asm/xen/hypercall.h>
> +#include <xen/features.h>
> +#include <xen/interface/xen.h>
> +
> +#define mfn_to_pfn(mfn) (mfn)
> +#define pfn_to_mfn(pfn) (pfn)
> +
> +#define mfn_to_virt(mfn) (__va((mfn) << PAGE_SHIFT))
> +#define virt_to_mfn(virt) (__pa(virt) >> PAGE_SHIFT)
> +#define virt_to_machine(virt) __pa(virt) /* for tpmfront.c */
> +
> +#define set_phys_to_machine(pfn, mfn) do { } while (0)
>   

Probably worth turning these into inlines so that they get properly 
typechecked.  Especially things like set_phys_to_machine(), which 
doesn't use its arguments.

    J
