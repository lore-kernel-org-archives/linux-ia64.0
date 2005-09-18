From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Sun, 18 Sep 2005 23:10:14 +0000
Subject: Re: Remove warnings for gcc 4.0 IA64 compilation.
Message-Id: <17197.62422.487609.962660@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <17193.2147.591751.129603@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17193.2147.591751.129603@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Tony Luck wrote: 
On Thu, Sep 15, 2005 at 03:36:35PM +1000, Peter Chubb wrote:
> Index: linux-2.6-import/arch/ia64/kernel/time.c
> -	printk(KERN_DEBUG "CPU %d: base freq=%lu.%03luMHz, ITC ratio=%lu/%lu, "
> +	printk(KERN_DEBUG "CPU %d: base freq=%lu.%03luMHz, ITC ratio=%u/%u, "
>  	       "ITC freq=%lu.%03luMHz", smp_processor_id(),
>  	       platform_base_freq / 1000000, (platform_base_freq / 1000) % 1000,
>  	       itc_ratio.num, itc_ratio.den, itc_freq / 1000000, (itc_freq / 1000) % 1000);

Tony> This hunk is surely wrong?  itc_freq is unsigned long, so
Tony> itc_freq/1000000 still has unsigned long type.

Sure, but itc_ratio.num and itc_ratio.den (which are the only bits
affected, unless I've severely miscalculated the match between format
and args) are both 32-bit quantities

Peter C
--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
