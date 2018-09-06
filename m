From: Michal Hocko <mhocko@kernel.org>
Date: Thu, 06 Sep 2018 08:06:14 +0000
Subject: Re: [RFC PATCH 14/29] memblock: add align parameter to memblock_alloc_node()
Message-Id: <20180906080614.GW14951@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-15-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1536163184-26356-15-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 05-09-18 18:59:29, Mike Rapoport wrote:
> With the align parameter memblock_alloc_node() can be used as drop in
> replacement for alloc_bootmem_pages_node().

Why do we need an additional translation later? Sparse code which is the
only one to use it already uses memblock_alloc_try_nid elsewhere
(sparse_mem_map_populate).
 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
>  include/linux/bootmem.h | 4 ++--
>  mm/sparse.c             | 2 +-
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
> index 7d91f0f..3896af2 100644
> --- a/include/linux/bootmem.h
> +++ b/include/linux/bootmem.h
> @@ -157,9 +157,9 @@ static inline void * __init memblock_alloc_from_nopanic(
>  }
>  
>  static inline void * __init memblock_alloc_node(
> -						phys_addr_t size, int nid)
> +		phys_addr_t size, phys_addr_t align, int nid)
>  {
> -	return memblock_alloc_try_nid(size, 0, BOOTMEM_LOW_LIMIT,
> +	return memblock_alloc_try_nid(size, align, BOOTMEM_LOW_LIMIT,
>  					    BOOTMEM_ALLOC_ACCESSIBLE, nid);
>  }
>  
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 04e97af..509828f 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -68,7 +68,7 @@ static noinline struct mem_section __ref *sparse_index_alloc(int nid)
>  	if (slab_is_available())
>  		section = kzalloc_node(array_size, GFP_KERNEL, nid);
>  	else
> -		section = memblock_alloc_node(array_size, nid);
> +		section = memblock_alloc_node(array_size, 0, nid);
>  
>  	return section;
>  }
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs
