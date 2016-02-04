From: Ganapatrao Kulkarni <gpkulkarni@gmail.com>
Date: Thu, 04 Feb 2016 11:27:44 +0000
Subject: Re: [PATCH v10 3/8] dt, numa: adding numa dt binding implementation.
Message-Id: <CAFpQJXUtZcWt9xSAL0MZiFZegPUwrppQgv4ipTNGstvHR6-pBg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1454407763-1017-1-git-send-email-gkulkarni@caviumnetworks.com>
	<1454407763-1017-4-git-send-email-gkulkarni@caviumnetworks.com>
	<20160202233417.GA4739@rob-hp-laptop>
In-Reply-To: <20160202233417.GA4739@rob-hp-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rob Herring <robh@kernel.org>
Cc: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-arch@vger.kernel.org, Will Deacon <Will.Deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, Grant Likely <grant.likely@linaro.org>, Leif Lindholm <leif.lindholm@linaro.org>, rfranz@cavium.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "msalter@redhat.com" <msalter@redhat.com>, Steve Capper <steve.capper@linaro.org>, Hanjun Guo <hanjun.guo@linaro.org>, Al Stone <al.stone@linaro.org>, A

Hi Rob,

On Wed, Feb 3, 2016 at 5:04 AM, Rob Herring <robh@kernel.org> wrote:
> On Tue, Feb 02, 2016 at 03:39:18PM +0530, Ganapatrao Kulkarni wrote:
>> dt node parsing for numa topology is done using device property
>> numa-node-id and device node distance-map.
>>
>> Reviewed-by: Robert Richter <rrichter@cavium.com>
>> Signed-off-by: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
>> ---
>>  drivers/of/Kconfig   |  11 +++
>>  drivers/of/Makefile  |   1 +
>>  drivers/of/of_numa.c | 207 +++++++++++++++++++++++++++++++++++++++++++++++++++
>>  include/linux/of.h   |   4 +
>>  4 files changed, 223 insertions(+)
>>  create mode 100644 drivers/of/of_numa.c
>>
>> diff --git a/drivers/of/Kconfig b/drivers/of/Kconfig
>> index e2a4841..8f9cc3a 100644
>> --- a/drivers/of/Kconfig
>> +++ b/drivers/of/Kconfig
>> @@ -112,4 +112,15 @@ config OF_OVERLAY
>>         While this option is selected automatically when needed, you can
>>         enable it manually to improve device tree unit test coverage.
>>
>> +config OF_NUMA
>> +     bool "Device Tree NUMA support"
>
> Does this need to be user visible?

thanks, not required, arch can select
>
>> +     depends on NUMA
>> +     depends on OF
>> +     depends on ARM64
>
> drop this (and make sure it compiles on other arches). It will fail
> because you also have a dependency on FDT.

thanks will add OF_EARLY_FLATTREE
>
>> +     default y
>> +     help
>> +       Enable Device Tree NUMA support.
>> +       This enables the numa mapping of cpu, memory, io and
>> +       inter node distances using dt bindings.
>> +
>>  endif # OF
>> diff --git a/drivers/of/Makefile b/drivers/of/Makefile
>> index 156c072..bee3fa9 100644
>> --- a/drivers/of/Makefile
>> +++ b/drivers/of/Makefile
>> @@ -14,5 +14,6 @@ obj-$(CONFIG_OF_MTD)        += of_mtd.o
>>  obj-$(CONFIG_OF_RESERVED_MEM) += of_reserved_mem.o
>>  obj-$(CONFIG_OF_RESOLVE)  += resolver.o
>>  obj-$(CONFIG_OF_OVERLAY) += overlay.o
>> +obj-$(CONFIG_OF_NUMA) += of_numa.o
>>
>>  obj-$(CONFIG_OF_UNITTEST) += unittest-data/
>> diff --git a/drivers/of/of_numa.c b/drivers/of/of_numa.c
>> new file mode 100644
>> index 0000000..1142cdb
>> --- /dev/null
>> +++ b/drivers/of/of_numa.c
>> @@ -0,0 +1,207 @@
>> +/*
>> + * OF NUMA Parsing support.
>> + *
>> + * Copyright (C) 2015 Cavium Inc.
>> + * Author: Ganapatrao Kulkarni <gkulkarni@cavium.com>
>> + *
>> + * This program is free software; you can redistribute it and/or modify
>> + * it under the terms of the GNU General Public License version 2 as
>> + * published by the Free Software Foundation.
>> + *
>> + * This program is distributed in the hope that it will be useful,
>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>> + * GNU General Public License for more details.
>> + *
>> + * You should have received a copy of the GNU General Public License
>> + * along with this program.  If not, see <http://www.gnu.org/licenses/>.
>> + */
>> +
>> +#include <linux/of.h>
>> +#include <linux/of_fdt.h>
>
> Surely you need some numa related includes.
ok
>
>> +
>> +/* define default numa node to 0 */
>> +#define DEFAULT_NODE 0
>> +
>> +/* Returns nid in the range [0..MAX_NUMNODES-1],
>> + * or NUMA_NO_NODE if no valid numa-node-id entry found
>> + * or DEFAULT_NODE if no numa-node-id entry exists
>> + */
>> +static int of_numa_prop_to_nid(const __be32 *of_numa_prop, int length)
>> +{
>> +     int nid;
>> +
>> +     if (!of_numa_prop)
>> +             return DEFAULT_NODE;
>> +
>> +     if (length != sizeof(*of_numa_prop)) {
>> +             pr_warn("NUMA: Invalid of_numa_prop length %d found.\n",
>> +                             length);
>> +             return NUMA_NO_NODE;
>> +     }
>> +
>> +     nid = of_read_number(of_numa_prop, 1);
>> +     if (nid >= MAX_NUMNODES) {
>> +             pr_warn("NUMA: Invalid numa node %d found.\n", nid);
>> +             return NUMA_NO_NODE;
>> +     }
>> +
>> +     return nid;
>> +}
>> +
>> +static int __init early_init_of_node_to_nid(unsigned long node)
>> +{
>> +     int length;
>> +     const __be32 *of_numa_prop;
>> +
>> +     of_numa_prop = of_get_flat_dt_prop(node, "numa-node-id", &length);
>> +
>> +     return of_numa_prop_to_nid(of_numa_prop, length);
>> +}
>> +
>> +/*
>> + * Even though we connect cpus to numa domains later in SMP
>> + * init, we need to know the node ids now for all cpus.
>> +*/
>> +static int __init early_init_parse_cpu_node(unsigned long node)
>> +{
>> +     int nid;
>> +     const char *type = of_get_flat_dt_prop(node, "device_type", NULL);
>> +
>> +     if (type = NULL)
>> +             return 0;
>> +
>> +     if (strcmp(type, "cpu") != 0)
>> +             return 0;
>> +
>> +     nid = early_init_of_node_to_nid(node);
>> +     if (nid = NUMA_NO_NODE)
>> +             return -EINVAL;
>> +
>> +     node_set(nid, numa_nodes_parsed);
>> +     return 0;
>> +}
>> +
>> +static int __init early_init_parse_memory_node(unsigned long node)
>> +{
>> +     const __be32 *reg, *endp;
>> +     int length;
>> +     int nid;
>> +     const char *type = of_get_flat_dt_prop(node, "device_type", NULL);
>> +
>> +     if (type = NULL)
>> +             return 0;
>> +
>> +     if (strcmp(type, "memory") != 0)
>> +             return 0;
>> +
>> +     nid = early_init_of_node_to_nid(node);
>> +     if (nid = NUMA_NO_NODE)
>> +             return -EINVAL;
>> +
>> +     reg = of_get_flat_dt_prop(node, "reg", &length);
>> +     endp = reg + (length / sizeof(__be32));
>> +
>> +     while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
>> +             u64 base, size;
>> +
>> +             base = dt_mem_next_cell(dt_root_addr_cells, &reg);
>> +             size = dt_mem_next_cell(dt_root_size_cells, &reg);
>> +             pr_debug("NUMA:  base = %llx , node = %u\n",
>> +                             base, nid);
>> +
>
> We already have code to parse memory nodes. Can the NUMA part be
> combined somehow.

it is too early to parse numa in core code since there are no
variables ready to hold parsed information.
which is done in numa_init()
>
>> +             if (numa_add_memblk(nid, base, size) < 0)
>> +                     return -EINVAL;
>> +     }
>> +
>> +     return 0;
>> +}
>> +
>> +static int __init early_init_parse_distance_map_v1(unsigned long node,
>> +             const char *uname)
>> +{
>> +     const __be32 *prop_dist_matrix;
>> +     int length = 0, i, matrix_count;
>> +     int nr_size_cells = OF_ROOT_NODE_SIZE_CELLS_DEFAULT;
>> +
>> +     pr_info("NUMA: parsing numa-distance-map-v1\n");
>> +
>> +     prop_dist_matrix >> +             of_get_flat_dt_prop(node, "distance-matrix", &length);
>> +
>> +     if (!length) {
>> +             pr_err("NUMA: failed to parse distance-matrix\n");
>> +             return -ENODEV;
>> +     }
>> +
>> +     matrix_count = ((length / sizeof(__be32)) / (3 * nr_size_cells));
>> +
>> +     if ((matrix_count * sizeof(__be32) * 3 * nr_size_cells) !=  length) {
>> +             pr_warn("NUMA: invalid distance-matrix length %d\n", length);
>> +             return -EINVAL;
>> +     }
>> +
>> +     for (i = 0; i < matrix_count; i++) {
>> +             u32 nodea, nodeb, distance;
>> +
>> +             nodea = dt_mem_next_cell(nr_size_cells, &prop_dist_matrix);
>> +             nodeb = dt_mem_next_cell(nr_size_cells, &prop_dist_matrix);
>> +             distance = dt_mem_next_cell(nr_size_cells, &prop_dist_matrix);
>> +             numa_set_distance(nodea, nodeb, distance);
>> +             pr_debug("NUMA:  distance[node%d -> node%d] = %d\n",
>> +                             nodea, nodeb, distance);
>> +
>> +             /* Set default distance of node B->A same as A->B */
>> +             if (nodeb > nodea)
>> +                     numa_set_distance(nodeb, nodea, distance);
>> +     }
>> +
>> +     return 0;
>> +}
>> +
>> +static int __init early_init_parse_distance_map(unsigned long node,
>> +             const char *uname)
>> +{
>> +     if (strcmp(uname, "distance-map") != 0)
>> +             return 0;
>> +
>> +     if (of_flat_dt_is_compatible(node, "numa-distance-map-v1"))
>> +             return early_init_parse_distance_map_v1(node, uname);
>> +
>> +     pr_err("NUMA: invalid distance-map device node\n");
>> +     return -EINVAL;
>> +}
>> +
>> +static int __init early_init_of_scan_numa_map(unsigned long node, const char *uname,
>> +                                  int depth, void *data)
>> +{
>> +     int ret;
>> +
>> +     ret = early_init_parse_cpu_node(node);
>> +     if (ret)
>> +             return ret;
>> +
>> +     ret = early_init_parse_memory_node(node);
>> +     if (ret)
>> +             return ret;
>> +
>> +     return early_init_parse_distance_map(node, uname);
>> +}
>> +
>> +int of_node_to_nid(struct device_node *device)
>> +{
>> +     const __be32 *of_numa_prop;
>> +     int length;
>> +
>> +     of_numa_prop = of_get_property(device, "numa-node-id", &length);
>> +     if (of_numa_prop)
>> +             return of_numa_prop_to_nid(of_numa_prop, length);
>> +
>> +     return NUMA_NO_NODE;
>> +}
>> +
>> +/* DT node mapping is done already early_init_of_scan_memory */
>> +int __init of_numa_init(void)
>> +{
>> +     return of_scan_flat_dt(early_init_of_scan_numa_map, NULL);
>> +}
>> diff --git a/include/linux/of.h b/include/linux/of.h
>> index dd10626..23e5bad 100644
>> --- a/include/linux/of.h
>> +++ b/include/linux/of.h
>> @@ -685,6 +685,10 @@ static inline int of_node_to_nid(struct device_node *device)
>>  }
>>  #endif
>>
>> +#ifdef CONFIG_OF_NUMA
>> +extern int __init of_numa_init(void);
>> +#endif
>
> You don't need an ifdef here unless you need an empty function.
>
> Can this be called internally by the DT code when it does the all
> the other flat scanning instead of adding another call from arch code to
> DT code. Ideally, the arch code would call DT code once and it would do
> all the parsing it needs to.

It is too early to include numa related dt parsing in the core dt
parsing like early_init_dt_scan()
since, numa init is called in bootmem_init after some mmblk related
variables are set.
which is little late in sequence to setup_machine_fdt

of_numa_init is called through numa_init, after required variables are
initialized.
In current implementation, the dt scan for numa parsing like memory
node, cpus and distance map
happens after the required data structures are initialized, moving this parsing
to core dt parsing will make this implementation in to 2 levels and
makes it complex,
which is at present fairly simple and straightforward.

>
> Rob

thanks
Ganapat
