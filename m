From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 20 Jun 2003 19:49:00 +0000
Subject: Re: 2.5.72 for ia64 released
Message-Id: <marc-linux-ia64-105613855924960@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105605890319553@msgid-missing>
In-Reply-To: <marc-linux-ia64-105605890319553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

What's your .config look like?  Is CONFIG_NUMA=y?  I'm trying a fresh
build now...

Jesse

On Fri, Jun 20, 2003 at 09:44:13PM +0200, Andreas Schwab wrote:
> jbarnes@sgi.com (Jesse Barnes) writes:
> 
> |> This one Works For Me (tm).  Does it look ok?
> 
> Does it require other patches?
> 
>   CC      arch/ia64/kernel/asm-offsets.s
> In file included from include/asm/processor.h:99,
>                  from include/asm/thread_info.h:9,
>                  from include/linux/thread_info.h:21,
>                  from include/linux/spinlock.h:12,
>                  from include/linux/capability.h:45,
>                  from include/linux/sched.h:7,
>                  from arch/ia64/kernel/asm-offsets.c:9:
> include/asm/nodedata.h:27: error: `NR_NODES' undeclared here (not in a function)
> include/asm/nodedata.h:28: error: `NR_BANKS' undeclared here (not in a function)
> include/asm/nodedata.h:29: error: `NR_NODES' undeclared here (not in a function)
> include/asm/nodedata.h:30: error: `NR_BANKS' undeclared here (not in a function)
> In file included from include/linux/gfp.h:4,
>                  from include/linux/slab.h:15,
>                  from include/linux/percpu.h:4,
>                  from include/linux/sched.h:30,
>                  from arch/ia64/kernel/asm-offsets.c:9:
> include/linux/mmzone.h:163: error: `NR_NODES' undeclared here (not in a function)
> include/linux/mmzone.h:191: confused by earlier errors, bailing out
> 
> Andreas.
> 
> -- 
> Andreas Schwab, SuSE Labs, schwab@suse.de
> SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N?rnberg
> Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
> "And now for something completely different."
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
