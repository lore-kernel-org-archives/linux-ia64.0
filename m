From: Russ Anderson <rja@sgi.com>
Date: Wed, 01 Aug 2007 16:00:13 +0000
Subject: Re: ACPI: Uninitialized spinlocks & Unable to dump stack
Message-Id: <200708011600.l71G0DTN140035578@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0707312246390.14878@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0707312246390.14878@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kenji Kaneshige wrote:
> 
> 2007-07-31 (火) の 22:48 -0700 に Christoph Lameter さんは書きました:
> > With todays git I get (sn2_defconfig w/ spinlock debuggin):
> 
> (snip.)
> 
> > ACPI: Error parsing MADT - no IOSAPIC entries
> > register_intr: No IOSAPIC for GSI 52
> > BUG: spinlock bad magic on CPU#0, swapper/0
> >  lock: a000000100bf66d0, .magic: 00000000, .owner: <none>/-1, .owner_cpu: 
> > 0
> > unwind: cannot stack reg state!
> > 
> > Call Trace:
> >  [<a000000100013900>] show_stack+0x40/0xa0
> 
> (snip.)
> 
> Hi,
> 
> I don't know why no IOSAPIC entries was found on your system.
> But I think the cause of this stack trace is a bug in the code
> path of interrupt registering failure. Here is a patch to fix
> this bug. Could you try that?

The good news is you patch gets rid of the spinlock BUG.
The bad news is the kernel boot on SN2 still hangs in udevsettle.

 
> Thanks,
> Kenji Kaneshige
> 
> ---
> 
> Fix wrong access to irq_desc[] in iosapic_register_intr().
> 
> Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
> 
> ---
>  arch/ia64/kernel/iosapic.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6.23-rc1/arch/ia64/kernel/iosapic.c
> =================================> --- linux-2.6.23-rc1.orig/arch/ia64/kernel/iosapic.c
> +++ linux-2.6.23-rc1/arch/ia64/kernel/iosapic.c
> @@ -794,8 +794,9 @@ iosapic_register_intr (unsigned int gsi,
>  	err = register_intr(gsi, irq, IOSAPIC_LOWEST_PRIORITY,
>  			    polarity, trigger);
>  	if (err < 0) {
> +		spin_unlock(&irq_desc[irq].lock);
>  		irq = err;
> -		goto unlock_all;
> +		goto unlock_iosapic_lock;
>  	}
>  
>  	/*
> @@ -811,7 +812,7 @@ iosapic_register_intr (unsigned int gsi,
>  	       gsi, (trigger = IOSAPIC_EDGE ? "edge" : "level"),
>  	       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
>  	       cpu_logical_id(dest), dest, irq_to_vector(irq));
> - unlock_all:
> +
>  	spin_unlock(&irq_desc[irq].lock);
>   unlock_iosapic_lock:
>  	spin_unlock_irqrestore(&iosapic_lock, flags);
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
