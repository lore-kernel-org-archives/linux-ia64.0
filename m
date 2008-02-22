From: Robin Holt <holt@sgi.com>
Date: Fri, 22 Feb 2008 05:33:16 +0000
Subject: Re: [PATCH 03/28] ia64/xen: increase IA64_MAX_RSVD_REGIONS.
Message-Id: <20080222053316.GL11391@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12036570474112-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12036570474112-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 22, 2008 at 02:10:19PM +0900, Isaku Yamahata wrote:
> Xenlinux/ia64 needs to reserve one more region passed from xen hypervisor
> as start info.
> 
> Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
> ---
>  include/asm-ia64/meminit.h |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/include/asm-ia64/meminit.h b/include/asm-ia64/meminit.h
> index f93308f..7c12c08 100644
> --- a/include/asm-ia64/meminit.h
> +++ b/include/asm-ia64/meminit.h
> @@ -18,10 +18,17 @@
>   * 	- crash dumping code reserved region
>   * 	- Kernel memory map built from EFI memory map
>   * 	- ELF core header
> + * ifdef CONFIG_XEN
> + *	- xen start info
> + * endif
>   *
>   * More could be added if necessary
>   */
> +#ifdef CONFIG_XEN
>  #define IA64_MAX_RSVD_REGIONS 8
> +#else
> +#define IA64_MAX_RSVD_REGIONS 9
> +#endif

This one seems upside down to me.  You are saying there is an additional
region when CONFIG_XEN, but you are defining it larger for !CONFIG_XEN.
I concede the point that I know nothing about Xen, so please straighten
me out here.

Thanks,
Robin
