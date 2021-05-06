From: David Hildenbrand <david@redhat.com>
Date: Thu, 06 May 2021 15:38:47 +0000
Subject: Re: [RFC PATCH 0/7] Memory hotplug/hotremove at subsection size
Message-Id: <596173b0-310f-7719-d432-11a13e325eab@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210506152623.178731-1-zi.yan@sent.com>
 <fb60eabd-f8ef-2cb1-7338-7725efe3c286@redhat.com>
In-Reply-To: <fb60eabd-f8ef-2cb1-7338-7725efe3c286@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zi Yan <ziy@nvidia.com>, Oscar Salvador <osalvador@suse.de>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Wei Yang <richard.weiyang@linux.alibaba.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On 06.05.21 17:31, David Hildenbrand wrote:
> On 06.05.21 17:26, Zi Yan wrote:
>> From: Zi Yan <ziy@nvidia.com>
>>
>> Hi all,
>>
>> This patchset tries to remove the restriction on memory hotplug/hotremove
>> granularity, which is always greater or equal to memory section size[1].
>> With the patchset, kernel is able to online/offline memory at a size independent
>> of memory section size, as small as 2MB (the subsection size).
> 
> ... which doesn't make any sense as we can only online/offline whole
> memory block devices.
> 
>>
>> The motivation is to increase MAX_ORDER of the buddy allocator and pageblock
>> size without increasing memory hotplug/hotremove granularity at the same time,
> 
> Gah, no. Please no. No.
> 
>> so that the kernel can allocator 1GB pages using buddy allocator and utilizes
>> existing pageblock based anti-fragmentation, paving the road for 1GB THP
>> support[2].
> 
> Not like this, please no.
> 
>>
>> The patchset utilizes the existing subsection support[3] and changes the
>> section size alignment checks to subsection size alignment checks. There are
>> also changes to pageblock code to support partial pageblocks, when pageblock
>> size is increased along with MAX_ORDER. Increasing pageblock size can enable
>> kernel to utilize existing anti-fragmentation mechanism for gigantic page
>> allocations.
> 
> Please not like this.
> 
>>
>> The last patch increases SECTION_SIZE_BITS to demonstrate the use of memory
>> hotplug/hotremove subsection, but is not intended to be merged as is. It is
>> there in case one wants to try this out and will be removed during the final
>> submission.
>>
>> Feel free to give suggestions and comments. I am looking forward to your
>> feedback.
> 
> Please not like this.
> 

And just to be clear (I think I mentioned this already to you?): Nack to 
increasing the section size. Nack to increasing the pageblock order. 
Please find different ways to group on gigantic-pages level. There are 
alternative ideas floating around.

Semi-nack to increasing MAX_ORDER. I first want to see 
alloc_contig_range() be able to fully and cleanly handle allocations < 
MAX_ORDER in all cases (especially !CMA and !ZONE_MOVABLE) before we go 
down that path.

-- 
Thanks,

David / dhildenb
