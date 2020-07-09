From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 09 Jul 2020 03:38:30 +0000
Subject: Re: [PATCH v3 5/6] device-dax: use fallback nid when numa_node is invalid
Message-Id: <CAPcyv4gfVhHyo-c=9bXd=z3=9Xqy7ato30D8p2aNsKBUONosug@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200709020629.91671-1-justin.he@arm.com> <20200709020629.91671-6-justin.he@arm.com>
In-Reply-To: <20200709020629.91671-6-justin.he@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Jia He <justin.he@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, David Hildenbrand <david@redhat.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Chuhong Yuan <hslester96@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>, Masahiro Yamada <masahiroy@kernel.org>, Michal Hocko <mhocko@suse.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linux-sh <linux-sh@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, , Jonathan Cameron <Jonathan.Cameron@huawei.com>, Kaly Xin <Kaly.Xin@arm.com>

On Wed, Jul 8, 2020 at 7:07 PM Jia He <justin.he@arm.com> wrote:
>
> numa_off is set unconditionally at the end of dummy_numa_init(),
> even with a fake numa node. ACPI detects node id as NUMA_NO_NODE(-1) in
> acpi_map_pxm_to_node() because it regards numa_off as turning off the numa
> node. Hence dev_dax->target_node is NUMA_NO_NODE on arm64 with fake numa.
>
> Without this patch, pmem can't be probed as a RAM device on arm64 if SRAT=
 table
> isn't present:
> $ndctl create-namespace -fe namespace0.0 --mode=DEvdax --map=DEv -s 1g -a=
 64K
> kmem dax0.0: rejecting DAX region [mem 0x240400000-0x2bfffffff] with inva=
lid node: -1
> kmem: probe of dax0.0 failed with error -22
>
> This fixes it by using fallback memory_add_physaddr_to_nid() as nid.
>
> Suggested-by: David Hildenbrand <david@redhat.com>
> Signed-off-by: Jia He <justin.he@arm.com>
> ---
>  drivers/dax/kmem.c | 21 +++++++++++++--------
>  1 file changed, 13 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/dax/kmem.c b/drivers/dax/kmem.c
> index 275aa5f87399..218f66057994 100644
> --- a/drivers/dax/kmem.c
> +++ b/drivers/dax/kmem.c
> @@ -31,22 +31,23 @@ int dev_dax_kmem_probe(struct device *dev)
>         int numa_node;
>         int rc;
>
> +       /* Hotplug starting at the beginning of the next block: */
> +       kmem_start =3D ALIGN(res->start, memory_block_size_bytes());
> +
>         /*
>          * Ensure good NUMA information for the persistent memory.
>          * Without this check, there is a risk that slow memory
>          * could be mixed in a node with faster memory, causing
> -        * unavoidable performance issues.
> +        * unavoidable performance issues. Furthermore, fallback node
> +        * id can be used when numa_node is invalid.
>          */
>         numa_node =3D dev_dax->target_node;
>         if (numa_node < 0) {
> -               dev_warn(dev, "rejecting DAX region %pR with invalid node=
: %d\n",
> -                        res, numa_node);
> -               return -EINVAL;
> +               numa_node =3D memory_add_physaddr_to_nid(kmem_start);

I think this fixup belongs to the core to set a fallback value for
dev_dax->target_node.

I'm close to having patches to provide a functional
phys_addr_to_target_node() for arm64.
