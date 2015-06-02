From: Joerg Roedel <jroedel@suse.de>
Date: Tue, 02 Jun 2015 09:09:18 +0000
Subject: Re: [PATCH] ia64: Return -ENOMEM in ia64_mmap_check() error case
Message-Id: <20150602090918.GE16345@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1431984439-15008-1-git-send-email-joro@8bytes.org>
In-Reply-To: <1431984439-15008-1-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joro@8bytes.org>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Ping. Tony, Fenghua, any opinion on this?

On Mon, May 18, 2015 at 11:27:19PM +0200, Joerg Roedel wrote:
> From: Joerg Roedel <jroedel@suse.de>
> 
> The value -ENOMEM is the expected return code for mmap when
> the address range verification failes on a MAP_FIXED
> request, as stated in the specification:
> 
> 	[ENOMEM]
> 	    MAP_FIXED was specified, and the range
> 	    [addr,addr+len) exceeds that allowed for the
> 	    address space of a process;
> 
> The ia64_mmap_check() function is part of that verification
> and should return -ENOMEM too.
> 
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  arch/ia64/kernel/sys_ia64.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/ia64/kernel/sys_ia64.c b/arch/ia64/kernel/sys_ia64.c
> index 41e33f8..e927023 100644
> --- a/arch/ia64/kernel/sys_ia64.c
> +++ b/arch/ia64/kernel/sys_ia64.c
> @@ -124,7 +124,7 @@ int ia64_mmap_check(unsigned long addr, unsigned long len,
>  	 */
>  	roff = REGION_OFFSET(addr);
>  	if ((len > RGN_MAP_LIMIT) || (roff > (RGN_MAP_LIMIT - len)))
> -		return -EINVAL;
> +		return -ENOMEM;
>  	return 0;
>  }
>  
> -- 
> 1.8.4.5
