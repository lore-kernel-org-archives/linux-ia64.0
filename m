From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 16 Sep 2005 16:42:14 +0000
Subject: Re: Remove warnings for gcc 4.0 IA64 compilation.
Message-Id: <20050916164214.GA9285@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17193.2147.591751.129603@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17193.2147.591751.129603@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 15, 2005 at 03:36:35PM +1000, Peter Chubb wrote:
> Index: linux-2.6-import/arch/ia64/kernel/time.c
> -	printk(KERN_DEBUG "CPU %d: base freq=%lu.%03luMHz, ITC ratio=%lu/%lu, "
> +	printk(KERN_DEBUG "CPU %d: base freq=%lu.%03luMHz, ITC ratio=%u/%u, "
>  	       "ITC freq=%lu.%03luMHz", smp_processor_id(),
>  	       platform_base_freq / 1000000, (platform_base_freq / 1000) % 1000,
>  	       itc_ratio.num, itc_ratio.den, itc_freq / 1000000, (itc_freq / 1000) % 1000);

This hunk is surely wrong?  itc_freq is unsigned long, so itc_freq/1000000
still has unsigned long type.

The other pieces all look good.

-Tony
