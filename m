From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 06 Jan 2005 17:14:06 +0000
Subject: Re: [patch] per cpu MCA/INIT fixes.
Message-Id: <200501060914.06506.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060308.j0638M7s194286@ben.americas.sgi.com>
In-Reply-To: <200501060308.j0638M7s194286@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, January 5, 2005 7:08 pm, Russ Anderson wrote:
>  #ifdef CONFIG_VIRTUAL_MEM_MAP
> Index: linux/arch/ia64/mm/discontig.c
> =================================> --- linux.orig/arch/ia64/mm/discontig.c 2005-01-05 15:26:42.455970944 -0600
> +++ linux/arch/ia64/mm/discontig.c 2005-01-05 15:33:50.644044221 -0600
> @@ -348,12 +348,12 @@
>    mem_data[node].node_data = __va(pernode);
>    pernode += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
>
> -  mca_data_phys = (void *)pernode;
> -  pernode += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t)) * phys_cpus;
> -
>    mem_data[node].pgdat->bdata = bdp;
>    pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
>
> +  mca_data_phys = (void *)pernode;
> +  pernode += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t)) * phys_cpus;
> +

The above will probably conflict with Jack's recent change to stagger the 
per-node structures by one cacheline.  You may have to rediff against one of 
Tony's test trees.

> +#ifdef CONFIG_SMP
> +#include <asm/mca.h>
> +#endif

Just a nit, header files should always be safe to include unconditionally.  If 
they're not, the headers need fixing (barring out of tree stuff like kdb of 
course).

Jesse

