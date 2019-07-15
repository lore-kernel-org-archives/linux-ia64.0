From: David Hildenbrand <david@redhat.com>
Date: Mon, 15 Jul 2019 10:58:22 +0000
Subject: Re: [PATCH v3 09/11] mm/memory_hotplug: Remove memory block devices before arch_remove_memory()
Message-Id: <54a2f873-374e-b132-ae0f-4924a7e332c0@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-10-david@redhat.com>
 <20190701084129.GI6376@dhcp22.suse.cz>
In-Reply-To: <20190701084129.GI6376@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, Arun KS <arunks@codeaurora.org>, Ingo Molnar <mingo@kernel.org>, linux-s390@vger.kernel.org, "Rafael J. Wysocki" <rafael@kernel.org>, Pavel Tatashin <pavel.tatashin@microsoft.com>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Mark Brown <broonie@kernel.org>, Jonathan Cameron <Jonathan.Cameron@huawei.com>, Dan Williams <dan.j.williams@intel.com>, Chris Wilson <chris@chris-wilson.co.uk>, linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>, Andrew Banman <andrew.banman@hpe.com>, Mathieu Malaterre <malat@debian.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, Alex Deucher <alexander.deucher@amd.com>, Igor Mammedov <imammedo@redhat.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On 01.07.19 10:41, Michal Hocko wrote:
> On Mon 27-05-19 13:11:50, David Hildenbrand wrote:
>> Let's factor out removing of memory block devices, which is only
>> necessary for memory added via add_memory() and friends that created
>> memory block devices. Remove the devices before calling
>> arch_remove_memory().
>>
>> This finishes factoring out memory block device handling from
>> arch_add_memory() and arch_remove_memory().
> 
> OK, this makes sense again. Just a nit. Calling find_memory_block_by_id
> for each memory block looks a bit suboptimal, especially when we are
> removing consequent physical memblocks. I have to confess that I do not
> know how expensive is the search and I also expect that there won't be
> that many memblocks in the removed range anyway as large setups have
> large memblocks.
> 

The devices are not allocated sequentially, so there is no easy way to
look them up.

There is a comment for find_memory_block():

"For now, we have a linear search to go find the appropriate
memory_block corresponding to a particular phys_index. If this gets to
be a real problem, we can always use a radix tree or something here."

So if this becomes a problem, we need a separate data structure to speed
up the lookup. (IOW, this was already the same in the old code)

Thanks!

-- 

Thanks,

David / dhildenb
