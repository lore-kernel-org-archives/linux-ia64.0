From: Robin Holt <holt@sgi.com>
Date: Sun, 03 Aug 2008 11:10:25 +0000
Subject: Re: [Patch] Cleanup generated files not ignored by .gitignore.
Message-Id: <20080803111025.GI6824@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080802181458.GD6824@sgi.com>
In-Reply-To: <20080802181458.GD6824@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Oops, just catching up on email and found Sam gave a reason to NACK this.
The vmlinux.lds should probably still go in, but the relocation of
nr-irqs.h needs to go.

Thanks,
Robin

On Sat, Aug 02, 2008 at 01:14:58PM -0500, Robin Holt wrote:
> This patch moves nr-irqs.h to arch/ia64/include/asm and fixes up some
> .gitignore files to get git-status clean.
> 
> Signed-off-by: Robin Holt <holt@sgi.com>
> 
> 
> ---
> 
> Tony,
> 
> This patch leaves a relatively small arch/ia64/kernel/.gitignore.  That
> could certainly be moved into arch/ia64 if you would like.
> 
> Thanks,
> Robin
> 
> 
> Index: contention_unroll/arch/ia64/kernel/.gitignore
> =================================> --- contention_unroll.orig/arch/ia64/kernel/.gitignore	2008-07-29 07:01:56.000000000 -0500
> +++ contention_unroll/arch/ia64/kernel/.gitignore	2008-08-02 09:12:06.522384719 -0500
> @@ -1 +1,2 @@
>  gate.lds
> +vmlinux.lds
> Index: contention_unroll/arch/ia64/Makefile
> =================================> --- contention_unroll.orig/arch/ia64/Makefile	2008-07-28 18:19:56.000000000 -0500
> +++ contention_unroll/arch/ia64/Makefile	2008-08-02 12:28:47.374270146 -0500
> @@ -105,4 +105,4 @@ archprepare: make_nr_irqs_h FORCE
>  PHONY += make_nr_irqs_h FORCE
>  
>  make_nr_irqs_h: FORCE
> -	$(Q)$(MAKE) $(build)=arch/ia64/kernel include/asm-ia64/nr-irqs.h
> +	$(Q)$(MAKE) $(build)=arch/ia64/kernel arch/ia64/include/asm/nr-irqs.h
> Index: contention_unroll/arch/ia64/include/asm/irq.h
> =================================> --- contention_unroll.orig/arch/ia64/include/asm/irq.h	2008-08-01 19:31:08.000000000 -0500
> +++ contention_unroll/arch/ia64/include/asm/irq.h	2008-08-02 12:34:01.493286456 -0500
> @@ -13,7 +13,7 @@
>  
>  #include <linux/types.h>
>  #include <linux/cpumask.h>
> -#include <asm-ia64/nr-irqs.h>
> +#include <asm/nr-irqs.h>
>  
>  static __inline__ int
>  irq_canonicalize (int irq)
> Index: contention_unroll/arch/ia64/kernel/Makefile
> =================================> --- contention_unroll.orig/arch/ia64/kernel/Makefile	2008-07-28 18:19:56.000000000 -0500
> +++ contention_unroll/arch/ia64/kernel/Makefile	2008-08-02 12:32:08.319227814 -0500
> @@ -100,11 +100,11 @@ arch/$(SRCARCH)/kernel/nr-irqs.s: $(srct
>  	$(Q)mkdir -p $(dir $@)
>  	$(call if_changed_dep,cc_s_c)
>  
> -include/asm-ia64/nr-irqs.h: arch/$(SRCARCH)/kernel/nr-irqs.s
> +arch/ia64/include/asm/nr-irqs.h: arch/$(SRCARCH)/kernel/nr-irqs.s
>  	$(Q)mkdir -p $(dir $@)
>  	$(call cmd,nr_irqs)
>  
> -clean-files += $(objtree)/include/asm-ia64/nr-irqs.h
> +clean-files += $(objtree)/arch/ia64/include/asm/nr-irqs.h
>  
>  #
>  # native ivt.S and entry.S
> Index: contention_unroll/arch/ia64/.gitignore
> =================================> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ contention_unroll/arch/ia64/.gitignore	2008-08-02 12:39:22.945217365 -0500
> @@ -0,0 +1 @@
> +include/asm/nr-irqs.h
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
