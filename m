From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 13 Oct 2004 01:46:32 +0000
Subject: Re: bug in 2.6.9-rc4-mm1 ia64/mm/init.c
Message-Id: <416C88F8.5030109@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.33.0410121705510.31839-100000@localhost.localdomain>
 <416C83EB.1090608@jp.fujitsu.com>
In-Reply-To: <416C83EB.1090608@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akepner@sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@osdl.org, jbarnes@sgi.com


Can you try with this patch ?
It's maybe because page table is not created correctly.

Kame <kamezawa.hiroyu@jp.fujitsu.com>
======== cut from here =========
--- arch/ia64/mm/init.c.org     2004-10-13 10:32:09.969725576 +0900
+++ arch/ia64/mm/init.c 2004-10-13 10:33:25.636222520 +0900
@@ -371,7 +371,8 @@ create_mem_map_page_table (u64 start, u6
         pgd_t *pgd;
         pmd_t *pmd;
         pte_t *pte;
-
+       start = GRANULEROUNDDOWN(start);
+       end = GRANULEROUNDUP(end);
         map_start = vmem_map + (__pa(start) >> PAGE_SHIFT);
         map_end   = vmem_map + (__pa(end) >> PAGE_SHIFT);





Hiroyuki KAMEZAWA wrote:

> Hi,
> 
> akepner@sgi.com wrote:
> 
>> Hi Folks;
>> Tried a kernel built with akpm's 2.6.9-rc4-mm1 patch today (using a 
>> default sn2 .config file.) It crashes on boot with:
>>
>> ....
>> SGI SAL version 3.40
>> Virtual mem_map starts at 0xa0007ffe85938000
>> Unable to handle kernel paging request at virtual address 
>> a0007ffeaf970000
>> swapper[0]: Oops 8813272891392 [1]
>> Modules linked in:
> 
> <snip>
> 
>> I traced this down to a recent patch (see 
>> http://marc.theaimsgroup.com/?l=linux-mm&m9723728329408&w=2) which 
>> contains:
>>
>> diff -puN arch/ia64/mm/init.c~ia64_fix arch/ia64/mm/init.c
>> --- test-kernel/arch/ia64/mm/init.c~ia64_fix    2004-10-08 
>> 18:29:20.510992392 +0900
>> +++ test-kernel-kamezawa/arch/ia64/mm/init.c    2004-10-08 
>> 18:29:20.515991632 +0900
>> @@ -410,7 +410,8 @@ virtual_memmap_init (u64 start, u64 end,
>>         struct page *map_start, *map_end;
>>
>>         args = (struct memmap_init_callback_data *) arg;
>> -
>> +       start = GRANULEROUNDDOWN(start);
>> +       end = GRANULEROUNDUP(end);
>>         map_start = vmem_map + (__pa(start) >> PAGE_SHIFT);
>>         map_end   = vmem_map + (__pa(end) >> PAGE_SHIFT);
>>
>>
>> Merely commenting out the new lines containting GRANULEROUNDDOWN, and 
>> GRANULEROUNDUP allowed the system to boot and me to finish the testing 
>> I needed to do.
>> Looks like the above patch needs to be revised. I could test it if 
>> necessary. Please email me directly as I'm not subscribed to lkml or 
>> linux-ia64.
>>
> Hmm.. I added above 2 lines for making vmemmap to be aligned with ia64's 
> GRANULE.
> But it looks troublesome here, revising it will be needed currently.
> I'd like to check my codes again and fix it.
> 
> 
> Kame <kamezawa.hiroyu@jp.fujitsu.com>
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

