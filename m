From: Michal Hocko <mhocko@kernel.org>
Date: Thu, 06 Sep 2018 07:39:31 +0000
Subject: Re: [RFC PATCH 08/29] memblock: replace alloc_bootmem_align with memblock_alloc
Message-Id: <20180906073931.GQ14951@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-9-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1536163184-26356-9-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 05-09-18 18:59:23, Mike Rapoport wrote:
> The functions are equivalent, just the later does not require nobootmem
> translation layer.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  arch/x86/xen/p2m.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/x86/xen/p2m.c b/arch/x86/xen/p2m.c
> index 159a897..68c0f14 100644
> --- a/arch/x86/xen/p2m.c
> +++ b/arch/x86/xen/p2m.c
> @@ -180,7 +180,7 @@ static void p2m_init_identity(unsigned long *p2m, unsigned long pfn)
>  static void * __ref alloc_p2m_page(void)
>  {
>  	if (unlikely(!slab_is_available()))
> -		return alloc_bootmem_align(PAGE_SIZE, PAGE_SIZE);
> +		return memblock_alloc(PAGE_SIZE, PAGE_SIZE);
>  
>  	return (void *)__get_free_page(GFP_KERNEL);
>  }
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs
