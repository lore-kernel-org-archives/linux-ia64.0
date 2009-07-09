From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 09 Jul 2009 04:44:09 +0000
Subject: Re: [PATCH] IA64: Fix IS_ERR() Compilation Errors
Message-Id: <20090709044409.GA12504%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090708195400.GA13171@linux-os.sc.intel.com>
In-Reply-To: <20090708195400.GA13171@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thank you for fixing it.
Acked-by: Isaku Yamahata <yamahata@valinux.co.jp>

On Wed, Jul 08, 2009 at 12:54:00PM -0700, Fenghua Yu wrote:
> Fix ia64 IS_ERR() compilation errors.
> 
> When building ia64 kernel with CONFIG_XEN_SYS_HYPERVISOR, compiler reports
> errors:
> 
> drivers/xen/sys-hypervisor.c: In function ‘uuid_show’:
> drivers/xen/sys-hypervisor.c:125: error: implicit declaration of function ‘IS_ERR’
> drivers/xen/sys-hypervisor.c:126: error: implicit declaration of function ‘PTR_ERR’
> 
> This patch fixes the errors.
> 
> Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>
> 
> ---
>  arch/ia64/include/asm/xen/hypervisor.h |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/arch/ia64/include/asm/xen/hypervisor.h b/arch/ia64/include/asm/xen/hypervisor.h
> index e425227..88afb54 100644
> --- a/arch/ia64/include/asm/xen/hypervisor.h
> +++ b/arch/ia64/include/asm/xen/hypervisor.h
> @@ -33,6 +33,7 @@
>  #ifndef _ASM_IA64_XEN_HYPERVISOR_H
>  #define _ASM_IA64_XEN_HYPERVISOR_H
>  
> +#include <linux/err.h>
>  #include <xen/interface/xen.h>
>  #include <xen/interface/version.h>	/* to compile feature.c */
>  #include <xen/features.h>		/* to comiple xen-netfront.c */

-- 
yamahata
