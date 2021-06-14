From: David Hildenbrand <david@redhat.com>
Date: Mon, 14 Jun 2021 11:32:25 +0000
Subject: Re: [RFC PATCH 0/7] Memory hotplug/hotremove at subsection size
Message-Id: <640bd1da-4bcb-cfda-18c0-da0ddb90b661@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210506152623.178731-1-zi.yan@sent.com>
 <fb60eabd-f8ef-2cb1-7338-7725efe3c286@redhat.com>
 <YJUqrOacyqI+kiKW@dhcp22.suse.cz>
 <792d73e2-5d63-74a5-5554-20351d5532ff@redhat.com>
 <746780E5-0288-494D-8B19-538049F1B891@nvidia.com>
 <289DA3C0-9AE5-4992-A35A-C13FCE4D8544@nvidia.com>
In-Reply-To: <289DA3C0-9AE5-4992-A35A-C13FCE4D8544@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Zi Yan <ziy@nvidia.com>, Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On 02.06.21 17:56, Zi Yan wrote:
> On 10 May 2021, at 10:36, Zi Yan wrote:
> 
>> On 7 May 2021, at 10:00, David Hildenbrand wrote:
>>
>>> On 07.05.21 13:55, Michal Hocko wrote:
>>>> [I haven't read through respective patches due to lack of time but let
>>>>    me comment on the general idea and the underlying justification]
>>>>
>>>> On Thu 06-05-21 17:31:09, David Hildenbrand wrote:
>>>>> On 06.05.21 17:26, Zi Yan wrote:
>>>>>> From: Zi Yan <ziy@nvidia.com>
>>>>>>
>>>>>> Hi all,
>>>>>>
>>>>>> This patchset tries to remove the restriction on memory hotplug/hotremove
>>>>>> granularity, which is always greater or equal to memory section size[1].
>>>>>> With the patchset, kernel is able to online/offline memory at a size independent
>>>>>> of memory section size, as small as 2MB (the subsection size).
>>>>>
>>>>> ... which doesn't make any sense as we can only online/offline whole memory
>>>>> block devices.
>>>>
>>>> Agreed. The subsection thingy is just a hack to workaround pmem
>>>> alignement problems. For the real memory hotplug it is quite hard to
>>>> argue for reasonable hotplug scenarios for very small physical memory
>>>> ranges wrt. to the existing sparsemem memory model.
>>>>
>>>>>> The motivation is to increase MAX_ORDER of the buddy allocator and pageblock
>>>>>> size without increasing memory hotplug/hotremove granularity at the same time,
>>>>>
>>>>> Gah, no. Please no. No.
>>>>
>>>> Agreed. Those are completely independent concepts. MAX_ORDER is can be
>>>> really arbitrary irrespective of the section size with vmemmap sparse
>>>> model. The existing restriction is due to old sparse model not being
>>>> able to do page pointer arithmetic across memory sections. Is there any
>>>> reason to stick with that memory model for an advance feature you are
>>>> working on?
>>
>> No. I just want to increase MAX_ORDER. If the existing restriction can
>> be removed, that will be great.
>>
>>>
>>> I gave it some more thought yesterday. I guess the first thing we should look into is increasing MAX_ORDER and leaving pageblock_order and section size as is -- finding out what we have to tweak to get that up and running. Once we have that in place, we can actually look into better fragmentation avoidance etc. One step at a time.
>>
>> It makes sense to me.
>>
>>>
>>> Because that change itself might require some thought. Requiring that bigger MAX_ORDER depends on SPARSE_VMEMMAP is something reasonable to do.
>>
>> OK, if with SPARSE_VMEMMAP MAX_ORDER can be set to be bigger than
>> SECTION_SIZE, it is perfectly OK to me. Since 1GB THP support, which I
>> want to add ultimately, will require SPARSE_VMEMMAP too (otherwise,
>> all page++ will need to be changed to nth_page(page,1)).
>>
>>>
>>> As stated somewhere here already, we'll have to look into making alloc_contig_range() (and main users CMA and virtio-mem) independent of MAX_ORDER and mainly rely on pageblock_order. The current handling in alloc_contig_range() is far from optimal as we have to isolate a whole MAX_ORDER - 1 page -- and on ZONE_NORMAL we'll fail easily if any part contains something unmovable although we don't even want to allocate that part. I actually have that on my list (to be able to fully support pageblock_order instead of MAX_ORDER -1 chunks in virtio-mem), however didn't have time to look into it.
>>
>> So in your mind, for gigantic page allocation (> MAX_ORDER), alloc_contig_range()
>> should be used instead of buddy allocator while pageblock_order is kept at a small
>> granularity like 2MB. Is that the case? Isn’t it going to have high fail rate
>> when any of the pageblocks within a gigantic page range (like 1GB) becomes unmovable?
>> Are you thinking additional mechanism/policy to prevent such thing happening as
>> an additional step for gigantic page allocation? Like your ZONE_PREFER_MOVABLE idea?
>>
>>>
>>> Further, page onlining / offlining code and early init code most probably also needs care if MAX_ORDER - 1 crosses sections. Memory holes we might suddenly have in MAX_ORDER - 1 pages might become a problem and will have to be handled. Not sure which other code has to be tweaked (compaction? page isolation?).
>>
>> Can you elaborate it a little more? From what I understand, memory holes mean valid
>> PFNs are not contiguous before and after a hole, so pfn++ will not work, but
>> struct pages are still virtually contiguous assuming SPARSE_VMEMMAP, meaning page++
>> would still work. So when MAX_ORDER - 1 crosses sections, additional code would be
>> needed instead of simple pfn++. Is there anything I am missing?
>>
>> BTW, to test a system with memory holes, do you know is there an easy of adding
>> random memory holes to an x86_64 VM, which can help reveal potential missing pieces
>> in the code? Changing BIOS-e820 table might be one way, but I have no idea on
>> how to do it on QEMU.
>>
>>>
>>> Figuring out what needs care itself might take quite some effort.
>>>
>>> One thing I was thinking about as well: The bigger our MAX_ORDER, the slower it could be to allocate smaller pages. If we have 1G pages, splitting them down to 4k then takes 8 additional steps if I'm, not wrong. Of course, that's the worst case. Would be interesting to evaluate.
>>
>> Sure. I am planning to check it too. As a simple start, I am going to run will it scale
>> benchmarks to see if there is any performance difference between different MAX_ORDERs.
> 
> I ran vm-scalablity and memory-related will-it-scale on a server with 256GB memory to
> see the impact of increasing MAX_ORDER and didn’t see much difference for most of
> the workloads like page_fault1, page_fault2, and page_fault3 from will-it-scale.
> But feel free to check the attached complete results and let me know what should be
> looked into. Thanks.

Right, for will-it-scale it looks like there are mostly minor 
differences, although I am not sure if the results are really stable 
(reaching from -6% to +6%). For vm-scalability the numbers seem to vary 
even more (e.g., stddev of ± 63%), so I have no idea how expressive they 
are. But I guess for these benchmarks, the net change won't really be 
significant.

Thanks!

-- 
Thanks,

David / dhildenb
