From: Simon Horman <horms@verge.net.au>
Date: Tue, 30 Oct 2007 05:07:36 +0000
Subject: Re: [2.6 patch] ia64/mm/init.c: fix section mismatches
Message-Id: <20071030050734.GD5361@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071029124947.GM7227@stusta.de>
In-Reply-To: <20071029124947.GM7227@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Adrian Bunk <bunk@kernel.org>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Oct 29, 2007 at 01:49:47PM +0100, Adrian Bunk wrote:
> This patch fixes the following section mismatches:
> 
> <--  snip  -->
> 
> ...
> WARNING: vmlinux.o(.text+0x5b5c2): Section mismatch: reference to .init.text:memmap_init_zone (between 'memmap_init' and 'virtual_memmap_init')
> WARNING: vmlinux.o(.text+0x5b842): Section mismatch: reference to .init.text:memmap_init_zone (between 'virtual_memmap_init' and 'ia64_mmu_init')
> ...
> 
> <--  snip  -->
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

That seems correct me and makes the warnings go away in my build.

Acked-by: Simon Horman <horms@verge.net.au>

> 
> ---
> 
>  arch/ia64/mm/init.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> 45c99ede63b0f76fe3dcc906ae550193a4d41626 
> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> index c6c19bf..25aef62 100644
> --- a/arch/ia64/mm/init.c
> +++ b/arch/ia64/mm/init.c
> @@ -472,7 +472,7 @@ struct memmap_init_callback_data {
>  	unsigned long zone;
>  };
>  
> -static int
> +static int __meminit
>  virtual_memmap_init (u64 start, u64 end, void *arg)
>  {
>  	struct memmap_init_callback_data *args;
> @@ -503,7 +503,7 @@ virtual_memmap_init (u64 start, u64 end, void *arg)
>  	return 0;
>  }
>  
> -void
> +void __meminit
>  memmap_init (unsigned long size, int nid, unsigned long zone,
>  	     unsigned long start_pfn)
>  {
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

