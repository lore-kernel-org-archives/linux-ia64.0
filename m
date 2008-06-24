From: Robin Holt <holt@sgi.com>
Date: Tue, 24 Jun 2008 15:41:10 +0000
Subject: Re: FW: [BISECT] Boot failure on ia64.
Message-Id: <20080624154109.GA28897@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080624143922.GK10123@sgi.com>
In-Reply-To: <20080624143922.GK10123@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yep, that gets it.

Thanks,
Robin

On Tue, Jun 24, 2008 at 11:30:09AM -0400, Jes Sorensen wrote:
> >>>>> "Robin" = Robin Holt <holt@sgi.com> writes:
> 
> Robin> Oops, missed sending this to the ia64 mailing list.  Robin
> 
> Hi Robin,
> 
> Just hit the same problem and did a little digging. It's because
> platform_send_ipi() ends up doing a cpuid_to_nasid() on sn2, which
> relies on NUMA information etc. being setup. 
> 
> In fact, check_sal_cache_flush() is called a fair bit before
> platform_setup() in arch/ia64/kernel/setup.c, which I would claim is
> completely broken.
> 
> Either check_sal_cache_flush() needs to be moved to after
> platform_setup() or Alex's patch should be reverted until a better
> solution is found. I am attaching a patch that does the former, but I
> don't know if this is safe on HP's systems.
> 
> This boots on SN2.
> 
> Cheers,
> Jes
> 
> Call check_sal_cache_flush() after platform_setup() as
> check_sal_cache_flush() now relies on being able to call platform
> vector code.
> 
> Signed-off-by: Jes Sorensen <jes@sgi.com>
> ---
>  arch/ia64/kernel/setup.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> Index: linux-2.6.git/arch/ia64/kernel/setup.c
> =================================> --- linux-2.6.git.orig/arch/ia64/kernel/setup.c
> +++ linux-2.6.git/arch/ia64/kernel/setup.c
> @@ -578,8 +578,6 @@ setup_arch (char **cmdline_p)
>  	cpu_init();	/* initialize the bootstrap CPU */
>  	mmu_context_init();	/* initialize context_id bitmap */
>  
> -	check_sal_cache_flush();
> -
>  #ifdef CONFIG_ACPI
>  	acpi_boot_init();
>  #endif
> @@ -607,6 +605,7 @@ setup_arch (char **cmdline_p)
>  		ia64_mca_init();
>  
>  	platform_setup(cmdline_p);
> +	check_sal_cache_flush();
>  	paging_init();
>  }
>  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
