From: Jack Steiner <steiner@sgi.com>
Date: Tue, 15 Mar 2005 15:37:21 +0000
Subject: Re: Export pda_percpu?
Message-Id: <20050315153721.GE27618@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503142038340.16107@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0503142038340.16107@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 14, 2005 at 08:44:10PM -0800, Christoph Lameter wrote:
> In order for mmtimer to properly build as a module, it seems that we need
> access to the pda structure. This has been discussed before
> http://www.mail-archive.com/linux-ia64@vger.kernel.org/msg00472.html
> and was rejected. What else can I do? Define functions as suggested? Do
> these exist somewhere?

What fields from the pda do you need? I think we need to eliminate the pda.
The pda made sense in the 2.4 kernels but not in 2.6.

Some of the fields were recently removed as part of a SHUB2 patch.
The rest should be eliminated or moved.


> 
> The mmtimer driver needs to muck around with pretty low level things in order
> to program the timer registers correctly.
> 
> Index: linux-2.6.11/arch/ia64/sn/kernel/setup.c
> =================================> --- linux-2.6.11.orig/arch/ia64/sn/kernel/setup.c	2005-03-14 20:25:43.000000000 -0800
> +++ linux-2.6.11/arch/ia64/sn/kernel/setup.c	2005-03-14 20:31:49.000000000 -0800
> @@ -54,6 +54,9 @@
> 
>  DEFINE_PER_CPU(struct pda_s, pda_percpu);
> 
> +/* mmtimer needs this to properly function */
> +EXPORT_SYMBOL(per_cpu__pda_percpu);
> +
>  #define MAX_PHYS_MEMORY		(1UL << 49)	/* 1 TB */
> 
>  lboard_t *root_lboard[MAX_COMPACT_NODES];
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


