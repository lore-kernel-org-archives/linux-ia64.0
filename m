From: David Hildenbrand <david@redhat.com>
Date: Wed, 09 Jun 2021 10:52:11 +0000
Subject: Re: [PATCH 2/9] arc: update comment about HIGHMEM implementation
Message-Id: <2764dca8-f395-f76a-0939-215eccdfd82e@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210602105348.13387-1-rppt@kernel.org>
 <20210602105348.13387-3-rppt@kernel.org>
In-Reply-To: <20210602105348.13387-3-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Jonathan Corbet <corbet@lwn.net>, Matt Turner <mattst88@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>, Richard Henderson <rth@twiddle.net>, Vineet Gupta <vgupta@synopsys.com>, kexec@lists.infradead.org, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On 02.06.21 12:53, Mike Rapoport wrote:
> From: Mike Rapoport <rppt@linux.ibm.com>
> 
> Arc does not use DISCONTIGMEM to implement high memory, update the comment
> describing how high memory works to reflect this.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>   arch/arc/mm/init.c | 13 +++++--------
>   1 file changed, 5 insertions(+), 8 deletions(-)
> 
> diff --git a/arch/arc/mm/init.c b/arch/arc/mm/init.c
> index e2ed355438c9..397a201adfe3 100644
> --- a/arch/arc/mm/init.c
> +++ b/arch/arc/mm/init.c
> @@ -139,16 +139,13 @@ void __init setup_arch_memory(void)
>   
>   #ifdef CONFIG_HIGHMEM
>   	/*
> -	 * Populate a new node with highmem
> -	 *
>   	 * On ARC (w/o PAE) HIGHMEM addresses are actually smaller (0 based)
> -	 * than addresses in normal ala low memory (0x8000_0000 based).
> +	 * than addresses in normal aka low memory (0x8000_0000 based).
>   	 * Even with PAE, the huge peripheral space hole would waste a lot of
> -	 * mem with single mem_map[]. This warrants a mem_map per region design.
> -	 * Thus HIGHMEM on ARC is imlemented with DISCONTIGMEM.
> -	 *
> -	 * DISCONTIGMEM in turns requires multiple nodes. node 0 above is
> -	 * populated with normal memory zone while node 1 only has highmem
> +	 * mem with single contiguous mem_map[].
> +	 * Thus when HIGHMEM on ARC is enabled the memory map corresponding
> +	 * to the hole is freed and ARC specific version of pfn_valid()
> +	 * handles the hole in the memory map.
>   	 */
>   #ifdef CONFIG_DISCONTIGMEM
>   	node_set_online(1);
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 
Thanks,

David / dhildenb
