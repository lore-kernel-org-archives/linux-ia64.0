From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 16 Jun 2004 16:39:44 +0000
Subject: Re: [PATCH 1/4] SGI Altix cross partition functionality
Message-Id: <20040616163944.GA15227@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163339.GA27891@sgi.com>
In-Reply-To: <20040616163339.GA27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 16, 2004 at 11:33:39AM -0500, Dean Nelson wrote:
>  #include <asm/page.h>
>  #include <asm/sal.h>
>  #include <asm/pal.h>
>  
>  spinlock_t sal_lock __cacheline_aligned = SPIN_LOCK_UNLOCKED;
> +EXPORT_SYMBOL(sal_lock);

No.  Please don't make random sal calls from modules.

> +
>  unsigned long sal_platform_features;
>  
>  unsigned short sal_revision;
> @@ -38,6 +41,8 @@ default_handler (void)
>  }
>  
>  ia64_sal_handler ia64_sal = (ia64_sal_handler) default_handler;
> +EXPORT_SYMBOL(ia64_sal);

Dito.  I think you need to find a better abstraction.

> Index: linux/arch/ia64/kernel/smpboot.c
> =================================> --- linux.orig/arch/ia64/kernel/smpboot.c	Thu Jun 10 14:47:53 2004
> +++ linux/arch/ia64/kernel/smpboot.c	Thu Jun 10 16:31:55 2004
> @@ -498,6 +498,7 @@ u8 cpu_to_node_map[NR_CPUS] __cacheline_
>  EXPORT_SYMBOL(cpu_to_node_map);
>  /* which logical CPUs are on which nodes */
>  cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
> +EXPORT_SYMBOL(node_to_cpu_mask);

Isn't there a higher level interface for this?

> =================================> --- linux.orig/arch/ia64/sn/kernel/setup.c	Thu Jun 10 16:29:44 2004
> +++ linux/arch/ia64/sn/kernel/setup.c	Thu Jun 10 16:31:55 2004
> @@ -50,6 +50,7 @@
>  #include <asm/sn/sn2/shub.h>
>  
>  DEFINE_PER_CPU(struct pda_s, pda_percpu);
> +EXPORT_SYMBOL(per_cpu__pda_percpu);

Umm, no.  Poking into kernel per-cpu data like the pda from modules sounds
like a bad idea.  And if you absolutely must use the proper helpers for
exporting it.

> Index: linux/kernel/exit.c
> =================================> --- linux.orig/kernel/exit.c	Thu Jun 10 15:04:09 2004
> +++ linux/kernel/exit.c	Thu Jun 10 16:31:55 2004
> @@ -1184,6 +1184,7 @@ end_wait4:
>  	remove_wait_queue(&current->wait_chldexit,&wait);
>  	return retval;
>  }
> +EXPORT_SYMBOL(sys_wait4);

No way.  Calling syscalls from kernelspace is always a bad idea.  (And this
is not linux-ia64 material anyway)

> Index: linux/kernel/sched.c
> =================================> --- linux.orig/kernel/sched.c	Thu Jun 10 16:30:39 2004
> +++ linux/kernel/sched.c	Thu Jun 10 16:31:55 2004
> @@ -2814,6 +2814,7 @@ asmlinkage long sys_sched_setscheduler(p
>  {
>  	return setscheduler(pid, policy, param);
>  }
> +EXPORT_SYMBOL(sys_sched_setscheduler);

Again, don't mess with scheduler paramters from your modules.

>  /**
>   * sys_sched_setparam - set/change the RT priority of a thread
> Index: linux/mm/page_alloc.c
> =================================> --- linux.orig/mm/page_alloc.c	Thu Jun 10 14:47:51 2004
> +++ linux/mm/page_alloc.c	Thu Jun 10 16:31:55 2004
> @@ -40,6 +40,7 @@ unsigned long totalram_pages;
>  unsigned long totalhigh_pages;
>  int nr_swap_pages;
>  int numnodes = 1;
> +EXPORT_SYMBOL(numnodes);

bad idea.  I have patches to completely kill numnodes, don't try to
mess with it.  So far it's also completly an architecture-thing.

