From: =?UTF-8?Q?Matias_Bj=c3=b8rling?= <mb@lightnvm.io>
Date: Tue, 20 Nov 2018 08:34:05 +0000
Subject: Re: [PATCH] ia64: export node_distance function
Message-Id: <0e230c3f-15a6-1e07-53e0-b27f01ac1333@lightnvm.io>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181103183716.28841-1-mb@lightnvm.io>
In-Reply-To: <20181103183716.28841-1-mb@lightnvm.io>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, axboe@fb.com

On 11/03/2018 07:37 PM, Matias Bjørling wrote:
> The numa_slit variable used by node_distance is available to a
> module as long as it is linked at compile-time. However, it is
> not available to loadable modules. Leading to errors such as:
> 
>    ERROR: "numa_slit" [drivers/nvme/host/nvme-core.ko] undefined!
> 
> The error above is caused by the nvme multipath code that makes
> use of node_distance for its path calculation. When the patch was
> added, the lightnvm subsystem would select nvme and always compile
> it in, leading to the node_distance call to always succeed.
> However, when this requirement was removed, nvme could be compiled
> in as a module, which exposed this bug.
> 
> This patch extracts node_distance to a function and exports it.
> Since ACPI is depending on node_distance being a simple lookup to
> numa_slit, the previous behavior is exposed as slit_distance and its
> users updated.
> 
> Fixes: f333444708f82 "nvme: take node locality into account when selecting a path"
> Fixes: 73569e11032f "lightnvm: remove dependencies on BLK_DEV_NVME and PCI"
> Signed-off-by: Matias Bjøring <mb@lightnvm.io>
> ---
>   arch/ia64/include/asm/numa.h | 4 +++-
>   arch/ia64/kernel/acpi.c      | 6 +++---
>   arch/ia64/mm/numa.c          | 6 ++++++
>   3 files changed, 12 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/ia64/include/asm/numa.h b/arch/ia64/include/asm/numa.h
> index ebef7f40aabb..c5c253cb9bd6 100644
> --- a/arch/ia64/include/asm/numa.h
> +++ b/arch/ia64/include/asm/numa.h
> @@ -59,7 +59,9 @@ extern struct node_cpuid_s node_cpuid[NR_CPUS];
>    */
>   
>   extern u8 numa_slit[MAX_NUMNODES * MAX_NUMNODES];
> -#define node_distance(from,to) (numa_slit[(from) * MAX_NUMNODES + (to)])
> +#define slit_distance(from,to) (numa_slit[(from) * MAX_NUMNODES + (to)])
> +extern int __node_distance(int from, int to);
> +#define node_distance(from,to) __node_distance(from, to)
>   
>   extern int paddr_to_nid(unsigned long paddr);
>   
> diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
> index 1dacbf5e9e09..41eb281709da 100644
> --- a/arch/ia64/kernel/acpi.c
> +++ b/arch/ia64/kernel/acpi.c
> @@ -578,8 +578,8 @@ void __init acpi_numa_fixup(void)
>   	if (!slit_table) {
>   		for (i = 0; i < MAX_NUMNODES; i++)
>   			for (j = 0; j < MAX_NUMNODES; j++)
> -				node_distance(i, j) = i = j ? LOCAL_DISTANCE :
> -							REMOTE_DISTANCE;
> +				slit_distance(i, j) = i = j ?
> +					LOCAL_DISTANCE : REMOTE_DISTANCE;
>   		return;
>   	}
>   
> @@ -592,7 +592,7 @@ void __init acpi_numa_fixup(void)
>   			if (!pxm_bit_test(j))
>   				continue;
>   			node_to = pxm_to_node(j);
> -			node_distance(node_from, node_to) > +			slit_distance(node_from, node_to) >   			    slit_table->entry[i * slit_table->locality_count + j];
>   		}
>   	}
> diff --git a/arch/ia64/mm/numa.c b/arch/ia64/mm/numa.c
> index aa19b7ac8222..5769d4b21270 100644
> --- a/arch/ia64/mm/numa.c
> +++ b/arch/ia64/mm/numa.c
> @@ -36,6 +36,12 @@ struct node_cpuid_s node_cpuid[NR_CPUS] >    */
>   u8 numa_slit[MAX_NUMNODES * MAX_NUMNODES];
>   
> +int __node_distance(int from, int to)
> +{
> +	return slit_distance(from, to);
> +}
> +EXPORT_SYMBOL(__node_distance);
> +
>   /* Identify which cnode a physical address resides on */
>   int
>   paddr_to_nid(unsigned long paddr)
> 

Tony and Fenghua, could you please take a look at the above patch? 
kbuild has been bugging me for a fix.
