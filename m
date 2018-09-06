From: Michal Hocko <mhocko@kernel.org>
Date: Thu, 06 Sep 2018 07:55:46 +0000
Subject: Re: [RFC PATCH 12/29] memblock: replace alloc_bootmem_low with memblock_alloc_low
Message-Id: <20180906075546.GU14951@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-13-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1536163184-26356-13-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 05-09-18 18:59:27, Mike Rapoport wrote:
> The alloc_bootmem_low(size) allocates low memory with default alignement
> and can be replcaed by memblock_alloc_low(size, 0)
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Again _virt renaming thing...
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  arch/arm64/kernel/setup.c     | 2 +-
>  arch/unicore32/kernel/setup.c | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
> index 5b4fac4..cf7a7b7 100644
> --- a/arch/arm64/kernel/setup.c
> +++ b/arch/arm64/kernel/setup.c
> @@ -213,7 +213,7 @@ static void __init request_standard_resources(void)
>  	kernel_data.end     = __pa_symbol(_end - 1);
>  
>  	for_each_memblock(memory, region) {
> -		res = alloc_bootmem_low(sizeof(*res));
> +		res = memblock_alloc_low(sizeof(*res), 0);
>  		if (memblock_is_nomap(region)) {
>  			res->name  = "reserved";
>  			res->flags = IORESOURCE_MEM;
> diff --git a/arch/unicore32/kernel/setup.c b/arch/unicore32/kernel/setup.c
> index c2bffa5..9f163f9 100644
> --- a/arch/unicore32/kernel/setup.c
> +++ b/arch/unicore32/kernel/setup.c
> @@ -207,7 +207,7 @@ request_standard_resources(struct meminfo *mi)
>  		if (mi->bank[i].size = 0)
>  			continue;
>  
> -		res = alloc_bootmem_low(sizeof(*res));
> +		res = memblock_alloc_low(sizeof(*res), 0);
>  		res->name  = "System RAM";
>  		res->start = mi->bank[i].start;
>  		res->end   = mi->bank[i].start + mi->bank[i].size - 1;
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs
