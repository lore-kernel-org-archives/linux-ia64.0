From: Simon Horman <horms@verge.net.au>
Date: Tue, 06 Nov 2007 01:58:37 +0000
Subject: Re: [PATCH 03/12] arch/ia64: Remove duplicate includes.
Message-Id: <20071106015837.GA5460@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <472F7968.1090408@gmail.com>
In-Reply-To: <472F7968.1090408@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel-janitors@vger.kernel.org

On Tue, Nov 06, 2007 at 07:13:28AM +1100, Lucas Woods wrote:
> 
> Signed-off-by: Lucas Woods <woodzy@gmail.com>

This looks correct to me. Acked.

> ---
>  arch/ia64/ia32/ia32priv.h |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/arch/ia64/ia32/ia32priv.h b/arch/ia64/ia32/ia32priv.h
> index 466bbcb..c5c872b 100644
> --- a/arch/ia64/ia32/ia32priv.h
> +++ b/arch/ia64/ia32/ia32priv.h
> @@ -290,7 +290,6 @@ struct old_linux32_dirent {
>  #define _ASM_IA64_ELF_H		/* Don't include elf.h */
>  
>  #include <linux/sched.h>
> -#include <asm/processor.h>
>  
>  /*
>   * This is used to ensure we don't load something for the wrong architecture.
> -- 
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

