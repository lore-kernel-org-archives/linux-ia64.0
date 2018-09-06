From: Michal Hocko <mhocko@kernel.org>
Date: Thu, 06 Sep 2018 07:41:14 +0000
Subject: Re: [RFC PATCH 09/29] memblock: replace alloc_bootmem_low with memblock_alloc_low
Message-Id: <20180906074114.GR14951@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-10-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1536163184-26356-10-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 05-09-18 18:59:24, Mike Rapoport wrote:
> The functions are equivalent, just the later does not require nobootmem
> translation layer.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

modulo @memblock_alloc_low@@memblock_virt_alloc_low@
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  arch/x86/kernel/tce_64.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/x86/kernel/tce_64.c b/arch/x86/kernel/tce_64.c
> index f386bad..54c9b5a 100644
> --- a/arch/x86/kernel/tce_64.c
> +++ b/arch/x86/kernel/tce_64.c
> @@ -173,7 +173,7 @@ void * __init alloc_tce_table(void)
>  	size = table_size_to_number_of_entries(specified_table_size);
>  	size *= TCE_ENTRY_SIZE;
>  
> -	return __alloc_bootmem_low(size, size, 0);
> +	return memblock_alloc_low(size, size);
>  }
>  
>  void __init free_tce_table(void *tbl)
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs
