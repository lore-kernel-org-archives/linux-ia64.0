From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 13 Nov 2008 06:22:53 +0000
Subject: Re: [PATCH] Ensure PSR.ac is cleared for early userspace
Message-Id: <20081113062253.GH21311%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
In-Reply-To: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Nov 11, 2008 at 05:35:50PM -0800, Luck, Tony wrote:
> Does the use of "rum" instruction need some paravirtualization? It is
> not in a critical path (used a couple of times during boot).

No, because rum isn't privileged instruction.
At lease xen/ia64 doesn't need it.

thanks,

> 
> diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
> index 7ef0c59..595a0b6 100644
> --- a/arch/ia64/kernel/entry.S
> +++ b/arch/ia64/kernel/entry.S
> @@ -499,6 +499,7 @@ GLOBAL_ENTRY(prefetch_stack)
>  END(prefetch_stack)
>  
>  GLOBAL_ENTRY(kernel_execve)
> +	rum IA64_PSR_AC
>  	mov r15=__NR_execve			// put syscall number in place
>  	break __BREAK_SYSCALL
>  	br.ret.sptk.many rp
> 

-- 
yamahata
