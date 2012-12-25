From: Jianguo Wu <wujianguo@huawei.com>
Date: Tue, 25 Dec 2012 08:09:53 +0000
Subject: Re: [PATCH v5 06/14] memory-hotplug: implement register_page_bootmem_info_section of sparse-vmemmap
Message-Id: <50D95F51.9090007@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-7-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1356350964-13437-7-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

On 2012/12/24 20:09, Tang Chen wrote:

> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>=20
> For removing memmap region of sparse-vmemmap which is allocated bootmem,
> memmap region of sparse-vmemmap needs to be registered by get_page_bootme=
m().
> So the patch searches pages of virtual mapping and registers the pages by
> get_page_bootmem().
>=20
> Note: register_page_bootmem_memmap() is not implemented for ia64, ppc, s3=
90,
> and sparc.
>=20
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> ---
>  arch/ia64/mm/discontig.c       |    6 ++++
>  arch/powerpc/mm/init_64.c      |    6 ++++
>  arch/s390/mm/vmem.c            |    6 ++++
>  arch/sparc/mm/init_64.c        |    6 ++++
>  arch/x86/mm/init_64.c          |   52 ++++++++++++++++++++++++++++++++++=
++++++
>  include/linux/memory_hotplug.h |   11 +-------
>  include/linux/mm.h             |    3 +-
>  mm/memory_hotplug.c            |   33 ++++++++++++++++++++++---
>  8 files changed, 109 insertions(+), 14 deletions(-)
>=20
> diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
> index c641333..33943db 100644
> --- a/arch/ia64/mm/discontig.c
> +++ b/arch/ia64/mm/discontig.c
> @@ -822,4 +822,10 @@ int __meminit vmemmap_populate(struct page *start_pa=
ge,
>  {
>  	return vmemmap_populate_basepages(start_page, size, node);
>  }
> +
> +void register_page_bootmem_memmap(unsigned long section_nr,
> +				  struct page *start_page, unsigned long size)
> +{
> +	/* TODO */
> +}
>  #endif
> diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
> index 95a4529..6466440 100644
> --- a/arch/powerpc/mm/init_64.c
> +++ b/arch/powerpc/mm/init_64.c
> @@ -297,5 +297,11 @@ int __meminit vmemmap_populate(struct page *start_pa=
ge,
> =20
>  	return 0;
>  }
> +
> +void register_page_bootmem_memmap(unsigned long section_nr,
> +				  struct page *start_page, unsigned long size)
> +{
> +	/* TODO */
> +}
>  #endif /* CONFIG_SPARSEMEM_VMEMMAP */
> =20
> diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
> index 6ed1426..2c14bc2 100644
> --- a/arch/s390/mm/vmem.c
> +++ b/arch/s390/mm/vmem.c
> @@ -272,6 +272,12 @@ out:
>  	return ret;
>  }
> =20
> +void register_page_bootmem_memmap(unsigned long section_nr,
> +				  struct page *start_page, unsigned long size)
> +{
> +	/* TODO */
> +}
> +
>  /*
>   * Add memory segment to the segment list if it doesn't overlap with
>   * an already present segment.
> diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
> index 85be1ca..7e28c9e 100644
> --- a/arch/sparc/mm/init_64.c
> +++ b/arch/sparc/mm/init_64.c
> @@ -2231,6 +2231,12 @@ void __meminit vmemmap_populate_print_last(void)
>  		node_start =3D 0;
>  	}
>  }
> +
> +void register_page_bootmem_memmap(unsigned long section_nr,
> +				  struct page *start_page, unsigned long size)
> +{
> +	/* TODO */
> +}
>  #endif /* CONFIG_SPARSEMEM_VMEMMAP */
> =20
>  static void prot_init_common(unsigned long page_none,
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index f78509c..aeaa27e 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -1000,6 +1000,58 @@ vmemmap_populate(struct page *start_page, unsigned=
 long size, int node)
>  	return 0;
>  }
> =20
> +void register_page_bootmem_memmap(unsigned long section_nr,
> +				  struct page *start_page, unsigned long size)
> +{
> +	unsigned long addr =3D (unsigned long)start_page;
> +	unsigned long end =3D (unsigned long)(start_page + size);
> +	unsigned long next;
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +
> +	for (; addr < end; addr =3D next) {
> +		pte_t *pte =3D NULL;
> +
> +		pgd =3D pgd_offset_k(addr);
> +		if (pgd_none(*pgd)) {
> +			next =3D (addr + PAGE_SIZE) & PAGE_MASK;
> +			continue;
> +		}
> +		get_page_bootmem(section_nr, pgd_page(*pgd), MIX_SECTION_INFO);
> +
> +		pud =3D pud_offset(pgd, addr);
> +		if (pud_none(*pud)) {
> +			next =3D (addr + PAGE_SIZE) & PAGE_MASK;
> +			continue;
> +		}
> +		get_page_bootmem(section_nr, pud_page(*pud), MIX_SECTION_INFO);
> +
> +		if (!cpu_has_pse) {
> +			next =3D (addr + PAGE_SIZE) & PAGE_MASK;
> +			pmd =3D pmd_offset(pud, addr);
> +			if (pmd_none(*pmd))
> +				continue;
> +			get_page_bootmem(section_nr, pmd_page(*pmd),
> +					 MIX_SECTION_INFO);
> +
> +			pte =3D pte_offset_kernel(pmd, addr);
> +			if (pte_none(*pte))
> +				continue;
> +			get_page_bootmem(section_nr, pte_page(*pte),
> +					 SECTION_INFO);
> +		} else {
> +			next =3D pmd_addr_end(addr, end);
> +
> +			pmd =3D pmd_offset(pud, addr);
> +			if (pmd_none(*pmd))
> +				continue;
> +			get_page_bootmem(section_nr, pmd_page(*pmd),
> +					 SECTION_INFO);

Hi Tang=EF=BC=8C
	In this case, pmd maps 512 pages, but you only get_page_bootmem() on the f=
irst page.
I think the whole 512 pages should be get_page_bootmem(), what do you think?

Thanks,
Jianguo Wu

> +		}
> +	}
> +}
> +
>  void __meminit vmemmap_populate_print_last(void)
>  {
>  	if (p_start) {
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplu=
g.h
> index 31a563b..2441f36 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -174,17 +174,10 @@ static inline void arch_refresh_nodedata(int nid, p=
g_data_t *pgdat)
>  #endif /* CONFIG_NUMA */
>  #endif /* CONFIG_HAVE_ARCH_NODEDATA_EXTENSION */
> =20
> -#ifdef CONFIG_SPARSEMEM_VMEMMAP
> -static inline void register_page_bootmem_info_node(struct pglist_data *p=
gdat)
> -{
> -}
> -static inline void put_page_bootmem(struct page *page)
> -{
> -}
> -#else
>  extern void register_page_bootmem_info_node(struct pglist_data *pgdat);
>  extern void put_page_bootmem(struct page *page);
> -#endif
> +extern void get_page_bootmem(unsigned long ingo, struct page *page,
> +			     unsigned long type);
> =20
>  /*
>   * Lock for memory hotplug guarantees 1) all callbacks for memory hotplug
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 6320407..1eca498 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1709,7 +1709,8 @@ int vmemmap_populate_basepages(struct page *start_p=
age,
>  						unsigned long pages, int node);
>  int vmemmap_populate(struct page *start_page, unsigned long pages, int n=
ode);
>  void vmemmap_populate_print_last(void);
> -
> +void register_page_bootmem_memmap(unsigned long section_nr, struct page =
*map,
> +				  unsigned long size);
> =20
>  enum mf_flags {
>  	MF_COUNT_INCREASED =3D 1 << 0,
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 2c5d734..34c656b 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -91,9 +91,8 @@ static void release_memory_resource(struct resource *re=
s)
>  }
> =20
>  #ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
> -#ifndef CONFIG_SPARSEMEM_VMEMMAP
> -static void get_page_bootmem(unsigned long info,  struct page *page,
> -			     unsigned long type)
> +void get_page_bootmem(unsigned long info,  struct page *page,
> +		      unsigned long type)
>  {
>  	page->lru.next =3D (struct list_head *) type;
>  	SetPagePrivate(page);
> @@ -128,6 +127,7 @@ void __ref put_page_bootmem(struct page *page)
> =20
>  }
> =20
> +#ifndef CONFIG_SPARSEMEM_VMEMMAP
>  static void register_page_bootmem_info_section(unsigned long start_pfn)
>  {
>  	unsigned long *usemap, mapsize, section_nr, i;
> @@ -161,6 +161,32 @@ static void register_page_bootmem_info_section(unsig=
ned long start_pfn)
>  		get_page_bootmem(section_nr, page, MIX_SECTION_INFO);
> =20
>  }
> +#else
> +static void register_page_bootmem_info_section(unsigned long start_pfn)
> +{
> +	unsigned long *usemap, mapsize, section_nr, i;
> +	struct mem_section *ms;
> +	struct page *page, *memmap;
> +
> +	if (!pfn_valid(start_pfn))
> +		return;
> +
> +	section_nr =3D pfn_to_section_nr(start_pfn);
> +	ms =3D __nr_to_section(section_nr);
> +
> +	memmap =3D sparse_decode_mem_map(ms->section_mem_map, section_nr);
> +
> +	register_page_bootmem_memmap(section_nr, memmap, PAGES_PER_SECTION);
> +
> +	usemap =3D __nr_to_section(section_nr)->pageblock_flags;
> +	page =3D virt_to_page(usemap);
> +
> +	mapsize =3D PAGE_ALIGN(usemap_size()) >> PAGE_SHIFT;
> +
> +	for (i =3D 0; i < mapsize; i++, page++)
> +		get_page_bootmem(section_nr, page, MIX_SECTION_INFO);
> +}
> +#endif
> =20
>  void register_page_bootmem_info_node(struct pglist_data *pgdat)
>  {
> @@ -203,7 +229,6 @@ void register_page_bootmem_info_node(struct pglist_da=
ta *pgdat)
>  			register_page_bootmem_info_section(pfn);
>  	}
>  }
> -#endif /* !CONFIG_SPARSEMEM_VMEMMAP */
> =20
>  static void grow_zone_span(struct zone *zone, unsigned long start_pfn,
>  			   unsigned long end_pfn)



