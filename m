From: Sergei Trofimovich <slyich@gmail.com>
Date: Thu, 20 Oct 2022 18:56:11 +0000
Subject: Re: [PATCH linux-next] ia64: Replace IS_ERR() with IS_ERR_VALUE()
Message-Id: <20221020195611.234ca44e@nz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221020113004.400031-1-ye.xingchen@zte.com.cn>
In-Reply-To: <20221020113004.400031-1-ye.xingchen@zte.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: yexingchen116@gmail.com
Cc: akpm@linux-foundation.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, ye xingchen <ye.xingchen@zte.com.cn>

On Thu, 20 Oct 2022 11:30:04 +0000
yexingchen116@gmail.com wrote:

> From: ye xingchen <ye.xingchen@zte.com.cn>
> 
> Avoid type casts that are needed for IS_ERR() and use
> IS_ERR_VALUE() instead.

Looks good to me!

Signed-off-by: Sergei Trofimovich <slyich@gmail.com>

> Signed-off-by: ye xingchen <ye.xingchen@zte.com.cn>
> ---
>  arch/ia64/kernel/sys_ia64.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/ia64/kernel/sys_ia64.c b/arch/ia64/kernel/sys_ia64.c
> index 215bf3f8cb20..f6a502e8f02c 100644
> --- a/arch/ia64/kernel/sys_ia64.c
> +++ b/arch/ia64/kernel/sys_ia64.c
> @@ -140,7 +140,7 @@ asmlinkage unsigned long
>  sys_mmap2 (unsigned long addr, unsigned long len, int prot, int flags, int fd, long pgoff)
>  {
>  	addr = ksys_mmap_pgoff(addr, len, prot, flags, fd, pgoff);
> -	if (!IS_ERR((void *) addr))
> +	if (!IS_ERR_VALUE(addr))
>  		force_successful_syscall_return();
>  	return addr;
>  }
> @@ -152,7 +152,7 @@ sys_mmap (unsigned long addr, unsigned long len, int prot, int flags, int fd, lo
>  		return -EINVAL;
>  
>  	addr = ksys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
> -	if (!IS_ERR((void *) addr))
> +	if (!IS_ERR_VALUE(addr))
>  		force_successful_syscall_return();
>  	return addr;
>  }
> @@ -162,7 +162,7 @@ ia64_mremap (unsigned long addr, unsigned long old_len, unsigned long new_len, u
>  	     unsigned long new_addr)
>  {
>  	addr = sys_mremap(addr, old_len, new_len, flags, new_addr);
> -	if (!IS_ERR((void *) addr))
> +	if (!IS_ERR_VALUE(addr))
>  		force_successful_syscall_return();
>  	return addr;
>  }
> -- 
> 2.25.1
> 


-- 

  Sergei
