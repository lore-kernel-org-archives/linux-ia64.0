From: Wen Congyang <wency@cn.fujitsu.com>
Date: Mon, 20 Aug 2012 07:06:48 +0000
Subject: Re: [PATCH]mm/ia64: fix a node distance bug
Message-Id: <5031E208.2080202@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5031D763.9010808@gmail.com>
In-Reply-To: <5031D763.9010808@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wujianguo <wujianguo106@gmail.com>
Cc: tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, jiang.liu@huawei.com, guohanjun@huawei.com, qiuxishi@huawei.com, liuj97@gmail.com

At 08/20/2012 02:21 PM, wujianguo Wrote:
> From: Jianguo Wu <wujianguo@huawei.com>
> 
> Hi all,
> 	When doing memory-hot-plug, We found node distance is wrong after offline
> a node in IA64 platform. For example system has 4 nodes:
> node distances:
> node   0   1   2   3
>   0:  10  21  21  32
>   1:  21  10  32  21
>   2:  21  32  10  21
>   3:  32  21  21  10
> 
> linux-drf:/sys/devices/system/node/node0 # cat distance
> 10  21  21  32
> linux-drf:/sys/devices/system/node/node1 # cat distance
> 21  10  32  21
> 
> After offline node2:
> linux-drf:/sys/devices/system/node/node0 # cat distance
> 10 21 32
> linux-drf:/sys/devices/system/node/node1 # cat distance
> 32 21 32	--------->expected value is: 21  10  21
> 
> In arch IA, we have following definition:
> extern u8 numa_slit[MAX_NUMNODES * MAX_NUMNODES];
> #define node_distance(from,to) (numa_slit[(from) * num_online_nodes() + (to)])
> 
> node distance is setup as following:
> acpi_numa_arch_fixup()
> {
> 	...
> 	memset(numa_slit, -1, sizeof(numa_slit));
> 	for (i = 0; i < slit_table->locality_count; i++) {
> 		if (!pxm_bit_test(i))
> 			continue;
> 		node_from = pxm_to_node(i);
> 		for (j = 0; j < slit_table->locality_count; j++) {
> 			if (!pxm_bit_test(j))
> 				continue;
> 			node_to = pxm_to_node(j);
> 			node_distance(node_from, node_to) > 			    slit_table->entry[i * slit_table->locality_count + j];
> 		}
> 	}
> 	...
> }
> 	num_online_nodes() is a variable value, during system boot the return vale is 4,
> but after offline node2, the return value is 3, so we read a wrong node distance value.
> This patch is trying to fix this bug.
> 
> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
> ---
>  arch/ia64/include/asm/numa.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/arch/ia64/include/asm/numa.h b/arch/ia64/include/asm/numa.h
> index 6a8a27c..2e27ef1 100644
> --- a/arch/ia64/include/asm/numa.h
> +++ b/arch/ia64/include/asm/numa.h
> @@ -59,7 +59,7 @@ extern struct node_cpuid_s node_cpuid[NR_CPUS];
>   */
> 
>  extern u8 numa_slit[MAX_NUMNODES * MAX_NUMNODES];
> -#define node_distance(from,to) (numa_slit[(from) * num_online_nodes() + (to)])
> +#define node_distance(from,to) (numa_slit[(from) * MAX_NUMNODES + (to)])

Hmm, MAX_NUMNODES is too large. I think num_possible_nodes() is better.

Thanks
Wen Congyang

> 
>  extern int paddr_to_nid(unsigned long paddr);
> 

