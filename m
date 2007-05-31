From: Len Brown <lenb@kernel.org>
Date: Thu, 31 May 2007 17:11:36 +0000
Subject: Re: [PATCH] Section mismatch ... acpi_map_pxm_to_node
Message-Id: <200705311311.36629.lenb@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A018B0FBA@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A018B0FBA@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org

Applied.

thanks,
-Len

On Thursday 24 May 2007 16:57, Luck, Tony wrote:
> Last of the "Section mismatch" errors from ia64 builds! acpi_map_pxm_to_node()
> is defined with attribute __cpuinit, but is called by "normal" kernel functions
> acpi_getnode() and acpi_map_cpu2node().
> 
> Commit f363d16fbb9374c0bd7f2757d412c287169094c9 moved the data structures on
> which this routine operates from __cpuinitdata to regular memory, so this
> routine can also move out of init space.
> 
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> 
> ---
> 
> diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
> index a2efae8..0c9f15c 100644
> --- a/drivers/acpi/numa.c
> +++ b/drivers/acpi/numa.c
> @@ -59,7 +59,7 @@ int node_to_pxm(int node)
>  	return node_to_pxm_map[node];
>  }
>  
> -int __cpuinit acpi_map_pxm_to_node(int pxm)
> +int acpi_map_pxm_to_node(int pxm)
>  {
>  	int node = pxm_to_node_map[pxm];
>  
> diff --git a/include/acpi/acpi_numa.h b/include/acpi/acpi_numa.h
> index b62cd36..e2fcee2 100644
> --- a/include/acpi/acpi_numa.h
> +++ b/include/acpi/acpi_numa.h
> @@ -13,7 +13,7 @@
>  
>  extern int pxm_to_node(int);
>  extern int node_to_pxm(int);
> -extern int __cpuinit acpi_map_pxm_to_node(int);
> +extern int acpi_map_pxm_to_node(int);
>  extern void __cpuinit acpi_unmap_pxm_to_node(int);
>  
>  #endif				/* CONFIG_ACPI_NUMA */
> -
> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
