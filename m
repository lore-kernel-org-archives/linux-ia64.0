From: Bjorn Helgaas <helgaas@kernel.org>
Date: Tue, 26 Jan 2016 20:36:04 +0000
Subject: Re: [PATCH v9 3/6] arm64/arm, numa, dt: adding numa dt binding implementation for arm64 platforms.
Message-Id: <20160126203603.GC17600@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <1453134965-6125-1-git-send-email-gkulkarni@caviumnetworks.com>
 <1453134965-6125-4-git-send-email-gkulkarni@caviumnetworks.com>
In-Reply-To: <1453134965-6125-4-git-send-email-gkulkarni-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ganapatrao Kulkarni <gkulkarni-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Will.Deacon-5wv7dgnIgG8@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, leif.lindholm-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, rfranz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, msalter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, steve.capper-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, hanjun.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, al.stone-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org, lenb-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, marc.zyngier-5wv7dgnIgG8@public.gmane.org, lorenzo.pieralisi-5wv7dgnIgG8@public.gmane.org, bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, fenghua.yu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, james.hogan-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org, benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, mingo@r

Subject is "arm64/arm, numa, dt: adding ..."  What is the significance
of the "arm" part?  The other patches only mention "arm64".

General comment: the code below has little, if anything, that is
actually arm64-specific.  Maybe this is the first DT-based NUMA
platform?  I don't see other similar code for other arches, so maybe
it's too early to try to generalize it, but we should try to avoid
adding duplicates of this code if/when other arches do show up.

On Mon, Jan 18, 2016 at 10:06:02PM +0530, Ganapatrao Kulkarni wrote:
> Adding numa dt binding support for arm64 based platforms.
> dt node parsing for numa topology is done using device property
> numa-node-id and device node distance-map.
> 
> Reviewed-by: Robert Richter <rrichter@cavium.com>
> Signed-off-by: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
> ---
>  arch/arm64/Kconfig            |  10 ++
>  arch/arm64/include/asm/numa.h |  10 ++
>  arch/arm64/kernel/Makefile    |   1 +
>  arch/arm64/kernel/of_numa.c   | 257 ++++++++++++++++++++++++++++++++++++++++++
>  arch/arm64/kernel/smp.c       |   2 +
>  arch/arm64/mm/numa.c          |  10 +-
>  6 files changed, 289 insertions(+), 1 deletion(-)
>  create mode 100644 arch/arm64/kernel/of_numa.c
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 74f5d73..775cf4a 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -515,6 +515,16 @@ config NUMA
>  	  local memory of the CPU and add some more
>  	  NUMA awareness to the kernel.
>  
> +config OF_NUMA
> +	bool "Device Tree NUMA support"
> +	depends on NUMA
> +	depends on OF
> +	default y
> +	help
> +	  Enable Device Tree NUMA support.
> +	  This enables the numa mapping of cpu, memory, io and
> +	  inter node distances using dt bindings.
> +
>  config NODES_SHIFT
>  	int "Maximum NUMA Nodes (as a power of 2)"
>  	range 1 10
> diff --git a/arch/arm64/include/asm/numa.h b/arch/arm64/include/asm/numa.h
> index f28f15b0..54deb38 100644
> --- a/arch/arm64/include/asm/numa.h
> +++ b/arch/arm64/include/asm/numa.h
> @@ -37,4 +37,14 @@ void numa_store_cpu_info(unsigned int cpu);
>  static inline void numa_store_cpu_info(unsigned int cpu)		{ }
>  static inline void arm64_numa_init(void)		{ }
>  #endif	/* CONFIG_NUMA */
> +
> +struct device_node;
> +#ifdef CONFIG_OF_NUMA
> +int __init arm64_of_numa_init(void);
> +void __init of_numa_set_node_info(unsigned int cpu, struct device_node *dn);
> +#else
> +static inline void of_numa_set_node_info(unsigned int cpu,
> +		struct device_node *dn) { }
> +#endif
> +
>  #endif	/* __ASM_NUMA_H */
> diff --git a/arch/arm64/kernel/Makefile b/arch/arm64/kernel/Makefile
> index 474691f..7987763 100644
> --- a/arch/arm64/kernel/Makefile
> +++ b/arch/arm64/kernel/Makefile
> @@ -41,6 +41,7 @@ arm64-obj-$(CONFIG_EFI)			+= efi.o efi-entry.stub.o
>  arm64-obj-$(CONFIG_PCI)			+= pci.o
>  arm64-obj-$(CONFIG_ARMV8_DEPRECATED)	+= armv8_deprecated.o
>  arm64-obj-$(CONFIG_ACPI)		+= acpi.o
> +arm64-obj-$(CONFIG_OF_NUMA)		+= of_numa.o
>  
>  obj-y					+= $(arm64-obj-y) vdso/
>  obj-m					+= $(arm64-obj-m)
> diff --git a/arch/arm64/kernel/of_numa.c b/arch/arm64/kernel/of_numa.c
> new file mode 100644
> index 0000000..2f9e34b
> --- /dev/null
> +++ b/arch/arm64/kernel/of_numa.c
> @@ -0,0 +1,257 @@
> +/*
> + * OF NUMA Parsing support.
> + *
> + * Copyright (C) 2015 Cavium Inc.
> + * Author: Ganapatrao Kulkarni <gkulkarni@cavium.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program.  If not, see <http://www.gnu.org/licenses/>.
> + */
> +
> +#include <linux/ctype.h>
> +#include <linux/memblock.h>
> +#include <linux/module.h>
> +#include <linux/nodemask.h>
> +#include <linux/of.h>
> +#include <linux/of_fdt.h>
> +
> +#include <asm/smp_plat.h>
> +
> +/* define default numa node to 0 */
> +#define DEFAULT_NODE 0
> +#define OF_NUMA_PROP "numa-node-id"
> +
> +/* Returns nid in the range [0..MAX_NUMNODES-1],
> + * or NUMA_NO_NODE if no valid numa-node-id entry found
> + * or DEFAULT_NODE if no numa-node-id entry exists
> + */
> +static int of_numa_prop_to_nid(const __be32 *of_numa_prop, int length)
> +{
> +	int nid;
> +
> +	if (!of_numa_prop)
> +		return DEFAULT_NODE;
> +
> +	if (length != sizeof(*of_numa_prop)) {
> +		pr_warn("NUMA: Invalid of_numa_prop length %d found.\n",
> +				length);
> +		return NUMA_NO_NODE;
> +	}
> +
> +	nid = of_read_number(of_numa_prop, 1);
> +	if (nid >= MAX_NUMNODES) {
> +		pr_warn("NUMA: Invalid numa node %d found.\n", nid);
> +		return NUMA_NO_NODE;
> +	}
> +
> +	return nid;
> +}
> +
> +/* Must hold reference to node during call */
> +static int of_get_numa_nid(struct device_node *device)
> +{
> +	int length;
> +	const __be32 *of_numa_prop;
> +
> +	of_numa_prop = of_get_property(device, OF_NUMA_PROP, &length);
> +
> +	return of_numa_prop_to_nid(of_numa_prop, length);
> +}
> +
> +static int __init early_init_of_get_numa_nid(unsigned long node)
> +{
> +	int length;
> +	const __be32 *of_numa_prop;
> +
> +	of_numa_prop = of_get_flat_dt_prop(node, OF_NUMA_PROP, &length);
> +
> +	return of_numa_prop_to_nid(of_numa_prop, length);
> +}
> +
> +/* Walk the device tree upwards, looking for a numa-node-id property */
> +int of_node_to_nid(struct device_node *device)
> +{
> +	struct device_node *parent;
> +	int nid = NUMA_NO_NODE;
> +
> +	of_node_get(device);
> +	while (device) {
> +		const __be32 *of_numa_prop;
> +		int length;
> +
> +		of_numa_prop = of_get_property(device, OF_NUMA_PROP, &length);
> +		if (of_numa_prop) {
> +			nid = of_numa_prop_to_nid(of_numa_prop, length);
> +			break;
> +		}
> +
> +		parent = device;
> +		device = of_get_parent(parent);
> +		of_node_put(parent);
> +	}
> +	of_node_put(device);
> +
> +	return nid;
> +}
> +
> +void __init of_numa_set_node_info(unsigned int cpu, struct device_node *device)
> +{
> +	int nid = DEFAULT_NODE;
> +
> +	if (device)
> +		nid = of_get_numa_nid(device);
> +
> +	cpu_to_node_map[cpu] = nid;
> +}
> +
> +/*
> + * Even though we connect cpus to numa domains later in SMP
> + * init, we need to know the node ids now for all cpus.
> +*/
> +static int __init early_init_parse_cpu_node(unsigned long node)
> +{
> +	int nid;
> +
> +	const char *type = of_get_flat_dt_prop(node, "device_type", NULL);
> +
> +	/* We are scanning "cpu" nodes only */
> +	if (type = NULL)
> +		return 0;
> +	else if (strcmp(type, "cpu") != 0)
> +		return 0;
> +
> +	nid = early_init_of_get_numa_nid(node);
> +
> +	if (nid = NUMA_NO_NODE)
> +		return -EINVAL;
> +
> +	node_set(nid, numa_nodes_parsed);
> +	return 0;
> +}
> +
> +static int __init early_init_parse_memory_node(unsigned long node)
> +{
> +	const __be32 *reg, *endp;
> +	int length;
> +	int nid;
> +
> +	const char *type = of_get_flat_dt_prop(node, "device_type", NULL);
> +
> +	/* We are scanning "memory" nodes only */
> +	if (type = NULL)
> +		return 0;
> +	else if (strcmp(type, "memory") != 0)
> +		return 0;
> +
> +	nid = early_init_of_get_numa_nid(node);
> +
> +	if (nid = NUMA_NO_NODE)
> +		return -EINVAL;
> +
> +	reg = of_get_flat_dt_prop(node, "reg", &length);
> +	endp = reg + (length / sizeof(__be32));
> +
> +	while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
> +		u64 base, size;
> +
> +		base = dt_mem_next_cell(dt_root_addr_cells, &reg);
> +		size = dt_mem_next_cell(dt_root_size_cells, &reg);
> +		pr_debug("NUMA-DT:  base = %llx , node = %u\n",
> +				base, nid);
> +
> +		if (numa_add_memblk(nid, base, size) < 0)
> +			return -EINVAL;
> +	}
> +
> +	return 0;
> +}
> +
> +static int __init early_init_parse_distance_map_v1(unsigned long node,
> +		const char *uname)
> +{
> +
> +	const __be32 *prop_dist_matrix;
> +	int length = 0, i, matrix_count;
> +	int nr_size_cells = OF_ROOT_NODE_SIZE_CELLS_DEFAULT;
> +
> +	pr_info("NUMA: parsing numa-distance-map-v1\n");
> +
> +	prop_dist_matrix > +		of_get_flat_dt_prop(node, "distance-matrix", &length);
> +
> +	if (!length) {
> +		pr_err("NUMA: failed to parse distance-matrix\n");
> +		return  -ENODEV;
> +	}
> +
> +	matrix_count = ((length / sizeof(__be32)) / (3 * nr_size_cells));
> +
> +	if ((matrix_count * sizeof(__be32) * 3 * nr_size_cells) !=  length) {
> +		pr_warn("NUMA: invalid distance-matrix length %d\n", length);
> +		return -EINVAL;
> +	}
> +
> +	for (i = 0; i < matrix_count; i++) {
> +		u32 nodea, nodeb, distance;
> +
> +		nodea = dt_mem_next_cell(nr_size_cells, &prop_dist_matrix);
> +		nodeb = dt_mem_next_cell(nr_size_cells, &prop_dist_matrix);
> +		distance = dt_mem_next_cell(nr_size_cells, &prop_dist_matrix);
> +		numa_set_distance(nodea, nodeb, distance);
> +		pr_debug("NUMA-DT:  distance[node%d -> node%d] = %d\n",
> +				nodea, nodeb, distance);
> +
> +		/* Set default distance of node B->A same as A->B */
> +		if (nodeb > nodea)
> +			numa_set_distance(nodeb, nodea, distance);
> +	}
> +
> +	return 0;
> +}
> +
> +static int __init early_init_parse_distance_map(unsigned long node,
> +		const char *uname)
> +{
> +
> +	if (strcmp(uname, "distance-map") != 0)
> +		return 0;
> +
> +	if (of_flat_dt_is_compatible(node, "numa-distance-map-v1"))
> +		return early_init_parse_distance_map_v1(node, uname);
> +
> +	return -EINVAL;
> +}
> +
> +/**
> + * early_init_of_scan_numa_map - parse memory node and map nid to memory range.
> + */
> +int __init early_init_of_scan_numa_map(unsigned long node, const char *uname,
> +				     int depth, void *data)
> +{
> +	int ret;
> +
> +	ret = early_init_parse_cpu_node(node);
> +
> +	if (!ret)
> +		ret = early_init_parse_memory_node(node);
> +
> +	if (!ret)
> +		ret = early_init_parse_distance_map(node, uname);
> +
> +	return ret;
> +}
> +
> +/* DT node mapping is done already early_init_of_scan_memory */
> +int __init arm64_of_numa_init(void)
> +{
> +	return of_scan_flat_dt(early_init_of_scan_numa_map, NULL);
> +}
> diff --git a/arch/arm64/kernel/smp.c b/arch/arm64/kernel/smp.c
> index d6e7d6a..a2a8c2d 100644
> --- a/arch/arm64/kernel/smp.c
> +++ b/arch/arm64/kernel/smp.c
> @@ -520,6 +520,8 @@ static void __init of_parse_and_init_cpus(void)
>  
>  		pr_debug("cpu logical map 0x%llx\n", hwid);
>  		cpu_logical_map(cpu_count) = hwid;
> +		/* map logical cpu to node */
> +		of_numa_set_node_info(cpu_count, dn);
>  next:
>  		cpu_count++;
>  	}
> diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
> index 050b083..9e8704b 100644
> --- a/arch/arm64/mm/numa.c
> +++ b/arch/arm64/mm/numa.c
> @@ -383,5 +383,13 @@ static int __init dummy_numa_init(void)
>   */
>  void __init arm64_numa_init(void)
>  {
> -	numa_init(dummy_numa_init);
> +	int ret = -ENODEV;
> +
> +#ifdef CONFIG_OF_NUMA
> +	if (!numa_off)
> +		ret = numa_init(arm64_of_numa_init);
> +#endif
> +
> +	if (ret)
> +		numa_init(dummy_numa_init);
>  }
> -- 
> 1.8.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-arch" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
