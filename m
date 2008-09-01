From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 01 Sep 2008 01:42:45 +0000
Subject: Re: [PATCH] x86: kill sys32_pause
Message-Id: <20080901014245.GA11445@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080901013924.GA7947@lst.de>
In-Reply-To: <20080901013924.GA7947@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Mon, Sep 01, 2008 at 03:39:24AM +0200, Christoph Hellwig wrote:
> It's just a duplicate of the native sys_pause.

Oops, this also includes ia64.  Should be safe anyway :)

> 
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> Index: linux-2.6/arch/x86/ia32/sys_ia32.c
> =================================> --- linux-2.6.orig/arch/x86/ia32/sys_ia32.c	2008-08-22 12:48:34.000000000 -0300
> +++ linux-2.6/arch/x86/ia32/sys_ia32.c	2008-08-22 12:48:40.000000000 -0300
> @@ -556,15 +556,6 @@ asmlinkage long sys32_rt_sigqueueinfo(in
>  	return ret;
>  }
>  
> -/* These are here just in case some old ia32 binary calls it. */
> -asmlinkage long sys32_pause(void)
> -{
> -	current->state = TASK_INTERRUPTIBLE;
> -	schedule();
> -	return -ERESTARTNOHAND;
> -}
> -
> -
>  #ifdef CONFIG_SYSCTL_SYSCALL
>  struct sysctl_ia32 {
>  	unsigned int	name;
> Index: linux-2.6/arch/ia64/ia32/ia32_entry.S
> =================================> --- linux-2.6.orig/arch/ia64/ia32/ia32_entry.S	2008-08-22 12:49:25.000000000 -0300
> +++ linux-2.6/arch/ia64/ia32/ia32_entry.S	2008-08-22 12:49:29.000000000 -0300
> @@ -202,7 +202,7 @@ ia32_syscall_table:
>  	data8 sys32_ptrace
>  	data8 sys32_alarm
>  	data8 sys_ni_syscall
> -	data8 sys32_pause
> +	data8 sys_pause
>  	data8 compat_sys_utime	  /* 30 */
>  	data8 sys_ni_syscall	  /* old stty syscall holder */
>  	data8 sys_ni_syscall	  /* old gtty syscall holder */
> Index: linux-2.6/arch/ia64/ia32/sys_ia32.c
> =================================> --- linux-2.6.orig/arch/ia64/ia32/sys_ia32.c	2008-08-22 12:49:33.000000000 -0300
> +++ linux-2.6/arch/ia64/ia32/sys_ia32.c	2008-08-22 12:49:37.000000000 -0300
> @@ -1795,14 +1795,6 @@ out:
>  }
>  
>  asmlinkage int
> -sys32_pause (void)
> -{
> -	current->state = TASK_INTERRUPTIBLE;
> -	schedule();
> -	return -ERESTARTNOHAND;
> -}
> -
> -asmlinkage int
>  sys32_msync (unsigned int start, unsigned int len, int flags)
>  {
>  	unsigned int addr;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
---end quoted text---
