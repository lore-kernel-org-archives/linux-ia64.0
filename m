From: David Rientjes <rientjes@google.com>
Date: Thu, 22 Apr 2010 20:51:38 +0000
Subject: Re: [patch 05/14] ia64: invoke oom-killer from page fault
Message-Id: <alpine.DEB.2.00.1004221351280.25350@chino.kir.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100422160613.723698029@suse.de> <20100422161223.462054441@suse.de>
In-Reply-To: <20100422161223.462054441@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: npiggin@suse.de
Cc: linux-arch@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On Fri, 23 Apr 2010, npiggin@suse.de wrote:

> As explained in commit 1c0fe6e3bd, we want to call the architecture independent
> oom killer when getting an unexplained OOM from handle_mm_fault, rather than
> simply killing current.
> 
> Cc: linux-ia64@vger.kernel.org
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: linux-arch@vger.kernel.org
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Acked-by: David Rientjes <rientjes@google.com>

> ---
> Index: linux-2.6/arch/ia64/mm/fault.c
> =================================> --- linux-2.6.orig/arch/ia64/mm/fault.c
> +++ linux-2.6/arch/ia64/mm/fault.c
> @@ -276,13 +276,7 @@ ia64_do_page_fault (unsigned long addres
>  
>    out_of_memory:
>  	up_read(&mm->mmap_sem);
> -	if (is_global_init(current)) {
> -		yield();
> -		down_read(&mm->mmap_sem);
> -		goto survive;
> -	}
> -	printk(KERN_CRIT "VM: killing process %s\n", current->comm);
> -	if (user_mode(regs))
> -		do_group_exit(SIGKILL);
> -	goto no_context;
> +	if (!user_mode(regs))
> +		goto no_context;
> +	pagefault_out_of_memory();
>  }
> 
> 
> 
