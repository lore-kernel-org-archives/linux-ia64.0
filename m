From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 23 Jul 2004 03:20:05 +0000
Subject: Re: [PATCH] - Initialize sched domain table
Message-Id: <410083E5.6010502@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040723010257.GA27350@sgi.com>
In-Reply-To: <20040723010257.GA27350@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jack Steiner <steiner@sgi.com>, Andrew Morton <akpm@osdl.org>
Cc: mingo@elte.hu, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Jack Steiner wrote:
> Here is a trivial patch that is required to boot the latest 2.6.7 tree 
> on the SGI 512p system.
> 
> 	Initial the busy_factor in the sched_domain_init table.
> 	Otherwise, booting hangs doing excessive load balance
> 	operations.
> 
> 	Signed-off-by: Jack Steiner <steiner@sgi.com>
> 

Thanks. Andrew please apply.

> 
> 
> Index: linux/kernel/sched.c
> =================================> --- linux.orig/kernel/sched.c
> +++ linux/kernel/sched.c
> @@ -3922,6 +3922,7 @@ void __init sched_init(void)
>  	sched_domain_init.groups = &sched_group_init;
>  	sched_domain_init.last_balance = jiffies;
>  	sched_domain_init.balance_interval = INT_MAX; /* Don't balance */
> +	sched_domain_init.busy_factor = 1;
>  
>  	memset(&sched_group_init, 0, sizeof(struct sched_group));
>  	sched_group_init.cpumask = CPU_MASK_ALL;

