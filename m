From: David Hildenbrand <david@redhat.com>
Date: Wed, 29 Sep 2021 16:54:01 +0000
Subject: Re: [PATCH v1 3/4] memblock: add MEMBLOCK_DRIVER_MANAGED to mimic IORESOURCE_SYSRAM_DRIVER_MANAGED
Message-Id: <830c1670-378b-0fb6-bd5e-208e545fa126@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210927150518.8607-1-david@redhat.com>
 <20210927150518.8607-4-david@redhat.com> <YVSW3uuu7mIcJMm3@kernel.org>
In-Reply-To: <YVSW3uuu7mIcJMm3@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@kernel.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Oscar Salvador <osalvador@suse.de>, Jianyong Wu <Jianyong.Wu@arm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Vineet Gupta <vgupta@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Huacai Chen <chenhuacai@kernel.org>, Jiaxun Yang <jiaxun.yang@flygoat.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Eric Biederman <ebiederm@xmission.com>, Arnd Bergmann <arnd@arndb.de>, linux-snps-arc@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org

On 29.09.21 18:39, Mike Rapoport wrote:
> Hi,
> 
> On Mon, Sep 27, 2021 at 05:05:17PM +0200, David Hildenbrand wrote:
>> Let's add a flag that corresponds to IORESOURCE_SYSRAM_DRIVER_MANAGED.
>> Similar to MEMBLOCK_HOTPLUG, most infrastructure has to treat such memory
>> like ordinary MEMBLOCK_NONE memory -- for example, when selecting memory
>> regions to add to the vmcore for dumping in the crashkernel via
>> for_each_mem_range().
>   
> Can you please elaborate on the difference in semantics of MEMBLOCK_HOTPLUG
> and MEMBLOCK_DRIVER_MANAGED?
> Unless I'm missing something they both mark memory that can be unplugged
> anytime and so it should not be used in certain cases. Why is there a need
> for a new flag?

In the cover letter I have "Alternative B: Reuse MEMBLOCK_HOTPLUG. 
MEMBLOCK_HOTPLUG serves a different purpose, though.", but looking into 
the details it won't work as is.

MEMBLOCK_HOTPLUG is used to mark memory early during boot that can later 
get hotunplugged again and should be placed into ZONE_MOVABLE if the 
"movable_node" kernel parameter is set.

The confusing part is that we talk about "hotpluggable" but really mean 
"hotunpluggable": the reason is that HW flags DIMM slots that can later 
be hotplugged as "hotpluggable" even though there is already something 
hotplugged.

For example, ranges in the ACPI SRAT that are marked as 
ACPI_SRAT_MEM_HOT_PLUGGABLE will be marked MEMBLOCK_HOTPLUG early during 
boot (drivers/acpi/numa/srat.c:acpi_numa_memory_affinity_init()). Later, 
we use that information to size ZONE_MOVABLE 
(mm/page_alloc.c:find_zone_movable_pfns_for_nodes()). This will make 
sure that these "hotpluggable" DIMMs can later get hotunplugged.

Also, see should_skip_region() how this relates to the "movable_node" 
kernel parameter:

	/* skip hotpluggable memory regions if needed */
	if (movable_node_is_enabled() && memblock_is_hotpluggable(m) &&
	    (flags & MEMBLOCK_HOTPLUG))
		return true;

Long story short: MEMBLOCK_HOTPLUG has different semantics and is a 
special case for "movable_node".

-- 
Thanks,

David / dhildenb
