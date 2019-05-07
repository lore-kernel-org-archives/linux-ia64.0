From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 07 May 2019 21:17:16 +0000
Subject: Re: [PATCH v2 4/8] mm/memory_hotplug: Create memory block devices after arch_add_memory()
Message-Id: <CAPcyv4jiVyaPbUrQwSiy65xk=EegJwuGSDKkVYWkGiTJz847gg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190507183804.5512-1-david@redhat.com> <20190507183804.5512-5-david@redhat.com>
In-Reply-To: <20190507183804.5512-5-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, Linux-sh <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Ingo Molnar <mingo@kernel.org>, Andrew Banman <andrew.banman@hpe.com>, Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>, Wei Yang <richard.weiyang@gmail.com>, Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>

On Tue, May 7, 2019 at 11:38 AM David Hildenbrand <david@redhat.com> wrote:
>
> Only memory to be added to the buddy and to be onlined/offlined by
> user space using memory block devices needs (and should have!) memory
> block devices.
>
> Factor out creation of memory block devices Create all devices after
> arch_add_memory() succeeded. We can later drop the want_memblock parameter,
> because it is now effectively stale.
>
> Only after memory block devices have been added, memory can be onlined
> by user space. This implies, that memory is not visible to user space at
> all before arch_add_memory() succeeded.

Nice!

>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Andrew Banman <andrew.banman@hpe.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  drivers/base/memory.c  | 70 ++++++++++++++++++++++++++----------------
>  include/linux/memory.h |  2 +-
>  mm/memory_hotplug.c    | 15 ++++-----
>  3 files changed, 53 insertions(+), 34 deletions(-)
>
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 6e0cb4fda179..862c202a18ca 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -701,44 +701,62 @@ static int add_memory_block(int base_section_nr)
>         return 0;
>  }
>
> +static void unregister_memory(struct memory_block *memory)
> +{
> +       BUG_ON(memory->dev.bus != &memory_subsys);

Given this should never happen and only a future kernel developer
might trip over it, do we really need to kill that developer's
machine? I.e. s/BUG/WARN/? I guess an argument can be made to move
such a change that to a follow-on patch since you're just preserving
existing behavior, but I figure might as well address these as the
code is refactored.

> +
> +       /* drop the ref. we got via find_memory_block() */
> +       put_device(&memory->dev);
> +       device_unregister(&memory->dev);
> +}
> +
>  /*
> - * need an interface for the VM to add new memory regions,
> - * but without onlining it.
> + * Create memory block devices for the given memory area. Start and size
> + * have to be aligned to memory block granularity. Memory block devices
> + * will be initialized as offline.
>   */
> -int hotplug_memory_register(int nid, struct mem_section *section)
> +int hotplug_memory_register(unsigned long start, unsigned long size)
>  {
> -       int ret = 0;
> +       unsigned long block_nr_pages = memory_block_size_bytes() >> PAGE_SHIFT;
> +       unsigned long start_pfn = PFN_DOWN(start);
> +       unsigned long end_pfn = start_pfn + (size >> PAGE_SHIFT);
> +       unsigned long pfn;
>         struct memory_block *mem;
> +       int ret = 0;
>
> -       mutex_lock(&mem_sysfs_mutex);
> +       BUG_ON(!IS_ALIGNED(start, memory_block_size_bytes()));
> +       BUG_ON(!IS_ALIGNED(size, memory_block_size_bytes()));

Perhaps:

    if (WARN_ON(...))
        return -EINVAL;

>
> -       mem = find_memory_block(section);
> -       if (mem) {
> -               mem->section_count++;
> -               put_device(&mem->dev);
> -       } else {
> -               ret = init_memory_block(&mem, section, MEM_OFFLINE);
> +       mutex_lock(&mem_sysfs_mutex);
> +       for (pfn = start_pfn; pfn != end_pfn; pfn += block_nr_pages) {
> +               mem = find_memory_block(__pfn_to_section(pfn));
> +               if (mem) {
> +                       WARN_ON_ONCE(false);

?? Isn't that a nop?

> +                       put_device(&mem->dev);
> +                       continue;
> +               }
> +               ret = init_memory_block(&mem, __pfn_to_section(pfn),
> +                                       MEM_OFFLINE);
>                 if (ret)
> -                       goto out;
> -               mem->section_count++;
> +                       break;
> +               mem->section_count = memory_block_size_bytes() /
> +                                    MIN_MEMORY_BLOCK_SIZE;
> +       }
> +       if (ret) {
> +               end_pfn = pfn;
> +               for (pfn = start_pfn; pfn != end_pfn; pfn += block_nr_pages) {
> +                       mem = find_memory_block(__pfn_to_section(pfn));
> +                       if (!mem)
> +                               continue;
> +                       mem->section_count = 0;
> +                       unregister_memory(mem);
> +               }
>         }
> -
> -out:
>         mutex_unlock(&mem_sysfs_mutex);
>         return ret;
>  }
>
> -static void
> -unregister_memory(struct memory_block *memory)
> -{
> -       BUG_ON(memory->dev.bus != &memory_subsys);
> -
> -       /* drop the ref. we got via find_memory_block() */
> -       put_device(&memory->dev);
> -       device_unregister(&memory->dev);
> -}
> -
> -void unregister_memory_section(struct mem_section *section)
> +static int remove_memory_section(struct mem_section *section)
>  {
>         struct memory_block *mem;
>
> diff --git a/include/linux/memory.h b/include/linux/memory.h
> index 474c7c60c8f2..95505fbb5f85 100644
> --- a/include/linux/memory.h
> +++ b/include/linux/memory.h
> @@ -111,7 +111,7 @@ extern int register_memory_notifier(struct notifier_block *nb);
>  extern void unregister_memory_notifier(struct notifier_block *nb);
>  extern int register_memory_isolate_notifier(struct notifier_block *nb);
>  extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
> -int hotplug_memory_register(int nid, struct mem_section *section);
> +int hotplug_memory_register(unsigned long start, unsigned long size);
>  extern void unregister_memory_section(struct mem_section *);
>  extern int memory_dev_init(void);
>  extern int memory_notify(unsigned long val, void *v);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 7b5439839d67..e1637c8a0723 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -258,13 +258,7 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>                 return -EEXIST;
>
>         ret = sparse_add_one_section(nid, phys_start_pfn, altmap);
> -       if (ret < 0)
> -               return ret;
> -
> -       if (!want_memblock)
> -               return 0;
> -
> -       return hotplug_memory_register(nid, __pfn_to_section(phys_start_pfn));
> +       return ret < 0 ? ret : 0;
>  }
>
>  /*
> @@ -1106,6 +1100,13 @@ int __ref add_memory_resource(int nid, struct resource *res)
>         if (ret < 0)
>                 goto error;
>
> +       /* create memory block devices after memory was added */
> +       ret = hotplug_memory_register(start, size);
> +       if (ret) {
> +               arch_remove_memory(nid, start, size, NULL);
> +               goto error;
> +       }
> +
>         if (new_node) {
>                 /* If sysfs file of new node can't be created, cpu on the node
>                  * can't be hot-added. There is no rollback way now.
> --
> 2.20.1
>
