From: David Hildenbrand <david@redhat.com>
Date: Fri, 04 Oct 2019 09:00:27 +0000
Subject: Re: [PATCH v5 01/10] mm/memunmap: Use the correct start and end pfn when removing pages from zone
Message-Id: <6e71cd24-7696-e7ca-15a1-8f126b0860ee@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191001144011.3801-1-david@redhat.com>
 <20191001144011.3801-2-david@redhat.com>
 <933f9cd8-9a32-8566-bd97-7e475a009275@redhat.com>
 <09b61ab1-6099-d825-8e04-fbfb43abe4d2@redhat.com>
 <cb6807a4-93c8-3964-bd65-e7087a0c7bf1@linux.ibm.com>
In-Reply-To: <cb6807a4-93c8-3964-bd65-e7087a0c7bf1@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>
Cc: linux-s390@vger.kernel.org, linux-ia64@vger.kernel.org, Ira Weiny <ira.weiny@intel.com>, linux-sh@vger.kernel.org, Jason Gunthorpe <jgg@ziepe.ca>, Logan Gunthorpe <logang@deltatee.com>, Pankaj Gupta <pagupta@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On 03.10.19 18:48, Aneesh Kumar K.V wrote:
> On 10/1/19 8:33 PM, David Hildenbrand wrote:
>> On 01.10.19 16:57, David Hildenbrand wrote:
>>> On 01.10.19 16:40, David Hildenbrand wrote:
>>>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
>>>>
>>>> With altmap, all the resource pfns are not initialized. While initializing
>>>> pfn, altmap reserve space is skipped. Hence when removing pfn from zone
>>>> skip pfns that were never initialized.
>>>>
>>>> Update memunmap_pages to calculate start and end pfn based on altmap
>>>> values. This fixes a kernel crash that is observed when destroying
>>>> a namespace.
>>>>
>>>> [   81.356173] kernel BUG at include/linux/mm.h:1107!
>>>> cpu 0x1: Vector: 700 (Program Check) at [c000000274087890]
>>>>      pc: c0000000004b9728: memunmap_pages+0x238/0x340
>>>>      lr: c0000000004b9724: memunmap_pages+0x234/0x340
>>>> ...
>>>>      pid   = 3669, comm = ndctl
>>>> kernel BUG at include/linux/mm.h:1107!
>>>> [c000000274087ba0] c0000000009e3500 devm_action_release+0x30/0x50
>>>> [c000000274087bc0] c0000000009e4758 release_nodes+0x268/0x2d0
>>>> [c000000274087c30] c0000000009dd144 device_release_driver_internal+0x174/0x240
>>>> [c000000274087c70] c0000000009d9dfc unbind_store+0x13c/0x190
>>>> [c000000274087cb0] c0000000009d8a24 drv_attr_store+0x44/0x60
>>>> [c000000274087cd0] c0000000005a7470 sysfs_kf_write+0x70/0xa0
>>>> [c000000274087d10] c0000000005a5cac kernfs_fop_write+0x1ac/0x290
>>>> [c000000274087d60] c0000000004be45c __vfs_write+0x3c/0x70
>>>> [c000000274087d80] c0000000004c26e4 vfs_write+0xe4/0x200
>>>> [c000000274087dd0] c0000000004c2a6c ksys_write+0x7c/0x140
>>>> [c000000274087e20] c00000000000bbd0 system_call+0x5c/0x68
>>>>
>>>> Cc: Dan Williams <dan.j.williams@intel.com>
>>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>>> Cc: Jason Gunthorpe <jgg@ziepe.ca>
>>>> Cc: Logan Gunthorpe <logang@deltatee.com>
>>>> Cc: Ira Weiny <ira.weiny@intel.com>
>>>> Reviewed-by: Pankaj Gupta <pagupta@redhat.com>
>>>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>>>> [ move all pfn-realted declarations into a single line ]
>>>> Signed-off-by: David Hildenbrand <david@redhat.com>
>>>> ---
>>>>   mm/memremap.c | 13 ++++++++-----
>>>>   1 file changed, 8 insertions(+), 5 deletions(-)
>>>>
>>>> diff --git a/mm/memremap.c b/mm/memremap.c
>>>> index 557e53c6fb46..026788b2ac69 100644
>>>> --- a/mm/memremap.c
>>>> +++ b/mm/memremap.c
>>>> @@ -123,7 +123,7 @@ static void dev_pagemap_cleanup(struct dev_pagemap *pgmap)
>>>>   void memunmap_pages(struct dev_pagemap *pgmap)
>>>>   {
>>>>   	struct resource *res = &pgmap->res;
>>>> -	unsigned long pfn;
>>>> +	unsigned long pfn, nr_pages, start_pfn, end_pfn;
>>>>   	int nid;
>>>>   
>>>>   	dev_pagemap_kill(pgmap);
>>>> @@ -131,14 +131,17 @@ void memunmap_pages(struct dev_pagemap *pgmap)
>>>>   		put_page(pfn_to_page(pfn));
>>>>   	dev_pagemap_cleanup(pgmap);
>>>>   
>>>> +	start_pfn = pfn_first(pgmap);
>>>> +	end_pfn = pfn_end(pgmap);
>>>> +	nr_pages = end_pfn - start_pfn;
>>>> +
>>>>   	/* pages are dead and unused, undo the arch mapping */
>>>> -	nid = page_to_nid(pfn_to_page(PHYS_PFN(res->start)));
>>>> +	nid = page_to_nid(pfn_to_page(start_pfn));
>>>>   
>>>>   	mem_hotplug_begin();
>>>>   	if (pgmap->type = MEMORY_DEVICE_PRIVATE) {
>>>> -		pfn = PHYS_PFN(res->start);
>>>> -		__remove_pages(page_zone(pfn_to_page(pfn)), pfn,
>>>> -				 PHYS_PFN(resource_size(res)), NULL);
>>>> +		__remove_pages(page_zone(pfn_to_page(start_pfn)), start_pfn,
>>>> +			       nr_pages, NULL);
>>>>   	} else {
>>>>   		arch_remove_memory(nid, res->start, resource_size(res),
>>>>   				pgmap_altmap(pgmap));
>>>>
>>>
>>> Aneesh, I was wondering why the use of "res->start" is correct (and we
>>> shouldn't also witch to start_pfn/nr_pages here. It would be good if Dan
>>> could review.
>>>
>>
>> To be more precise, I wonder if it should actually be
>>
>> __remove_pages(page_zone(pfn_to_page(start_pfn)), res->start,
>>                 resource_size(res))
>>
> 
> yes, that would be make it much clear.
> 
> But for MEMORY_DEVICE_PRIVATE start_pfn and pfn should be same?

Okay, let's recap. We should call add_pages()/__remove_pages()
and arch_add_memory()/arch_remove_memory() with the exact same ranges.

So with PHYS_PFN(res->start) and PHYS_PFN(resource_size(res)

Now, only a subset of the pages gets actually initialized,
meaning the NID and the ZONE we read could be stale.
That, we have to fix.

What about something like this (am I missing something?):

From d77b5c50f86570819a437517a897cc40ed29eefb Mon Sep 17 00:00:00 2001
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Fri, 27 Sep 2019 16:02:24 +0530
Subject: [PATCH] mm/memunmap: Don't access uninitialized memmap in
 memunmap_pages()

With an altmap, the memmap falling into the reserved altmap space are
not initialized and, therefore, contain a garbage NID and a garbage
zone. Make sure to read the NID/zone from a memmap that was initialzed.

This fixes a kernel crash that is observed when destroying a namespace:

[   81.356173] kernel BUG at include/linux/mm.h:1107!
cpu 0x1: Vector: 700 (Program Check) at [c000000274087890]
    pc: c0000000004b9728: memunmap_pages+0x238/0x340
    lr: c0000000004b9724: memunmap_pages+0x234/0x340
...
    pid   = 3669, comm = ndctl
kernel BUG at include/linux/mm.h:1107!
[c000000274087ba0] c0000000009e3500 devm_action_release+0x30/0x50
[c000000274087bc0] c0000000009e4758 release_nodes+0x268/0x2d0
[c000000274087c30] c0000000009dd144 device_release_driver_internal+0x174/0x240
[c000000274087c70] c0000000009d9dfc unbind_store+0x13c/0x190
[c000000274087cb0] c0000000009d8a24 drv_attr_store+0x44/0x60
[c000000274087cd0] c0000000005a7470 sysfs_kf_write+0x70/0xa0
[c000000274087d10] c0000000005a5cac kernfs_fop_write+0x1ac/0x290
[c000000274087d60] c0000000004be45c __vfs_write+0x3c/0x70
[c000000274087d80] c0000000004c26e4 vfs_write+0xe4/0x200
[c000000274087dd0] c0000000004c2a6c ksys_write+0x7c/0x140
[c000000274087e20] c00000000000bbd0 system_call+0x5c/0x68

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
[ minimze code changes, rephrase description ]
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memremap.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/memremap.c b/mm/memremap.c
index 557e53c6fb46..8b11c0da345c 100644
--- a/mm/memremap.c
+++ b/mm/memremap.c
@@ -123,6 +123,7 @@ static void dev_pagemap_cleanup(struct dev_pagemap *pgmap)
 void memunmap_pages(struct dev_pagemap *pgmap)
 {
 	struct resource *res = &pgmap->res;
+	struct page *first_page;
 	unsigned long pfn;
 	int nid;
 
@@ -131,14 +132,16 @@ void memunmap_pages(struct dev_pagemap *pgmap)
 		put_page(pfn_to_page(pfn));
 	dev_pagemap_cleanup(pgmap);
 
+	/* make sure to access a memmap that was actually initialized */
+	first_page = pfn_to_page(pfn_first(pgmap));
+
 	/* pages are dead and unused, undo the arch mapping */
-	nid = page_to_nid(pfn_to_page(PHYS_PFN(res->start)));
+	nid = page_to_nid(first_page);
 
 	mem_hotplug_begin();
 	if (pgmap->type = MEMORY_DEVICE_PRIVATE) {
-		pfn = PHYS_PFN(res->start);
-		__remove_pages(page_zone(pfn_to_page(pfn)), pfn,
-				 PHYS_PFN(resource_size(res)), NULL);
+		__remove_pages(page_zone(first_page), res->start,
+			       resource_size(res), NULL);
 	} else {
 		arch_remove_memory(nid, res->start, resource_size(res),
 				pgmap_altmap(pgmap));
-- 
2.21.0




-- 

Thanks,

David / dhildenb
