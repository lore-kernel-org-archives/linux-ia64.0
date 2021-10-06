From: Mike Rapoport <rppt@kernel.org>
Date: Wed, 06 Oct 2021 00:35:57 +0000
Subject: Re: [PATCH v2 2/5] memblock: improve MEMBLOCK_HOTPLUG documentation
Message-Id: <YVzvbUr2zO/Nw0Xf@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211004093605.5830-1-david@redhat.com>
 <20211004093605.5830-3-david@redhat.com>
In-Reply-To: <20211004093605.5830-3-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Oscar Salvador <osalvador@suse.de>, Jianyong Wu <Jianyong.Wu@arm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Vineet Gupta <vgupta@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Huacai Chen <chenhuacai@kernel.org>, Jiaxun Yang <jiaxun.yang@flygoat.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Eric Biederman <ebiederm@xmission.com>, Arnd Bergmann <arnd@arndb.de>, linux-snps-arc@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org

On Mon, Oct 04, 2021 at 11:36:02AM +0200, David Hildenbrand wrote:
> The description of MEMBLOCK_HOTPLUG is currently short and consequently
> misleading: we're actually dealing with a memory region that might get
> hotunplugged later (i.e., the platform+firmware supports it), yet it is
> indicated in the firmware-provided memory map as system ram that will just
> get used by the system for any purpose when not taking special care. The
> firmware marked this memory region as a hot(un)plugged (e.g., hotplugged
> before reboot), implying that it might get hotunplugged again later.
> 
> Whether we consider this information depends on the "movable_node" kernel
> commandline parameter: only with "movable_node" set, we'll try keeping
> this memory hotunpluggable, for example, by not serving early allocations
> from this memory region and by letting the buddy manage it using the
> ZONE_MOVABLE.
> 
> Let's make this clearer by extending the documentation.
> 
> Note: kexec *has to* indicate this memory to the second kernel. With
> "movable_node" set, we don't want to place kexec-images on this memory.
> Without "movable_node" set, we don't care and can place kexec-images on
> this memory. In both cases, after successful memory hotunplug, kexec has to
> be re-armed to update the memory map for the second kernel and to place the
> kexec-images somewhere else.
> 
> Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  include/linux/memblock.h | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 34de69b3b8ba..4ee8dd2d63a7 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -28,7 +28,11 @@ extern unsigned long long max_possible_pfn;
>  /**
>   * enum memblock_flags - definition of memory region attributes
>   * @MEMBLOCK_NONE: no special request
> - * @MEMBLOCK_HOTPLUG: hotpluggable region
> + * @MEMBLOCK_HOTPLUG: memory region indicated in the firmware-provided memory
> + * map during early boot as hot(un)pluggable system RAM (e.g., memory range
> + * that might get hotunplugged later). With "movable_node" set on the kernel
> + * commandline, try keeping this memory region hotunpluggable. Does not apply
> + * to memblocks added ("hotplugged") after early boot.
>   * @MEMBLOCK_MIRROR: mirrored region
>   * @MEMBLOCK_NOMAP: don't add to kernel direct mapping and treat as
>   * reserved in the memory map; refer to memblock_mark_nomap() description
> -- 
> 2.31.1
> 

-- 
Sincerely yours,
Mike.
