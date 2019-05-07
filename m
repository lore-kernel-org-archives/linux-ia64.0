From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 07 May 2019 20:46:08 +0000
Subject: Re: [PATCH v2 2/8] s390x/mm: Implement arch_remove_memory()
Message-Id: <CAPcyv4gtAMn2mDz0s1GRTJ52MeTK3jJYLQne6MiEx_ipPFUsmA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190507183804.5512-1-david@redhat.com> <20190507183804.5512-3-david@redhat.com>
In-Reply-To: <20190507183804.5512-3-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Oscar Salvador <osalvador@suse.com>

On Tue, May 7, 2019 at 11:38 AM David Hildenbrand <david@redhat.com> wrote:
>
> Will come in handy when wanting to handle errors after
> arch_add_memory().
>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Vasily Gorbik <gor@linux.ibm.com>
> Cc: Oscar Salvador <osalvador@suse.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  arch/s390/mm/init.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
>
> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> index 31b1071315d7..1e0cbae69f12 100644
> --- a/arch/s390/mm/init.c
> +++ b/arch/s390/mm/init.c
> @@ -237,12 +237,13 @@ int arch_add_memory(int nid, u64 start, u64 size,
>  void arch_remove_memory(int nid, u64 start, u64 size,
>                         struct vmem_altmap *altmap)
>  {
> -       /*
> -        * There is no hardware or firmware interface which could trigger a
> -        * hot memory remove on s390. So there is nothing that needs to be
> -        * implemented.
> -        */
> -       BUG();
> +       unsigned long start_pfn = start >> PAGE_SHIFT;
> +       unsigned long nr_pages = size >> PAGE_SHIFT;
> +       struct zone *zone;
> +
> +       zone = page_zone(pfn_to_page(start_pfn));

Does s390 actually support passing in an altmap? If 'yes', I think it
also needs the vmem_altmap_offset() fixup like x86-64:

        /* With altmap the first mapped page is offset from @start */
        if (altmap)
                page += vmem_altmap_offset(altmap);

...but I suspect it does not support altmap since
arch/s390/mm/vmem.c::vmemmap_populate() does not arrange for 'struct
page' capacity to be allocated out of an altmap defined page pool.

I think it would be enough to disallow any arch_add_memory() on s390
where @altmap is non-NULL. At least until s390 gains ZONE_DEVICE
support and can enable the pmem use case.
