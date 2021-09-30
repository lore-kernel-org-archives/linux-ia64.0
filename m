From: Mike Rapoport <rppt@kernel.org>
Date: Thu, 30 Sep 2021 21:21:56 +0000
Subject: Re: [PATCH v1 3/4] memblock: add MEMBLOCK_DRIVER_MANAGED to mimic IORESOURCE_SYSRAM_DRIVER_MANAGED
Message-Id: <YVYqdN7MFdzBlCVm@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210927150518.8607-1-david@redhat.com>
 <20210927150518.8607-4-david@redhat.com>
 <YVSW3uuu7mIcJMm3@kernel.org>
 <830c1670-378b-0fb6-bd5e-208e545fa126@redhat.com>
In-Reply-To: <830c1670-378b-0fb6-bd5e-208e545fa126@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Oscar Salvador <osalvador@suse.de>, Jianyong Wu <Jianyong.Wu@arm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Vineet Gupta <vgupta@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Huacai Chen <chenhuacai@kernel.org>, Jiaxun Yang <jiaxun.yang@flygoat.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Eric Biederman <ebiederm@xmission.com>, Arnd Bergmann <arnd@arndb.de>, linux-snps-arc@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org

On Wed, Sep 29, 2021 at 06:54:01PM +0200, David Hildenbrand wrote:
> On 29.09.21 18:39, Mike Rapoport wrote:
> > Hi,
> > 
> > On Mon, Sep 27, 2021 at 05:05:17PM +0200, David Hildenbrand wrote:
> > > Let's add a flag that corresponds to IORESOURCE_SYSRAM_DRIVER_MANAGED.
> > > Similar to MEMBLOCK_HOTPLUG, most infrastructure has to treat such memory
> > > like ordinary MEMBLOCK_NONE memory -- for example, when selecting memory
> > > regions to add to the vmcore for dumping in the crashkernel via
> > > for_each_mem_range().
> > Can you please elaborate on the difference in semantics of MEMBLOCK_HOTPLUG
> > and MEMBLOCK_DRIVER_MANAGED?
> > Unless I'm missing something they both mark memory that can be unplugged
> > anytime and so it should not be used in certain cases. Why is there a need
> > for a new flag?
> 
> In the cover letter I have "Alternative B: Reuse MEMBLOCK_HOTPLUG.
> MEMBLOCK_HOTPLUG serves a different purpose, though.", but looking into the
> details it won't work as is.
> 
> MEMBLOCK_HOTPLUG is used to mark memory early during boot that can later get
> hotunplugged again and should be placed into ZONE_MOVABLE if the
> "movable_node" kernel parameter is set.
> 
> The confusing part is that we talk about "hotpluggable" but really mean
> "hotunpluggable": the reason is that HW flags DIMM slots that can later be
> hotplugged as "hotpluggable" even though there is already something
> hotplugged.

MEMBLOCK_HOTPLUG name is indeed somewhat confusing, but still it's core
meaning "this memory may be removed" which does not differ from what
IORESOURCE_SYSRAM_DRIVER_MANAGED means.

MEMBLOCK_HOTPLUG regions are indeed placed into ZONE_MOVABLE, but more
importantly, they are avoided when we allocate memory from memblock.

So, in my view, both flags mean that the memory may be removed and it
should not be used for certain types of allocations.
 
> For example, ranges in the ACPI SRAT that are marked as
> ACPI_SRAT_MEM_HOT_PLUGGABLE will be marked MEMBLOCK_HOTPLUG early during
> boot (drivers/acpi/numa/srat.c:acpi_numa_memory_affinity_init()). Later, we
> use that information to size ZONE_MOVABLE
> (mm/page_alloc.c:find_zone_movable_pfns_for_nodes()). This will make sure
> that these "hotpluggable" DIMMs can later get hotunplugged.
> 
> Also, see should_skip_region() how this relates to the "movable_node" kernel
> parameter:
> 
> 	/* skip hotpluggable memory regions if needed */
> 	if (movable_node_is_enabled() && memblock_is_hotpluggable(m) &&
> 	    (flags & MEMBLOCK_HOTPLUG))
> 		return true;

Hmm, I think that the movable_node_is_enabled() check here is excessive,
but I suspect we cannot simply remove it without breaking anything.

I'll take a deeper look on the potential consequences.

BTW, is there anything that prevents putting kexec to hot-unplugable memory
that was cold-plugged on boot?

-- 
Sincerely yours,
Mike.
