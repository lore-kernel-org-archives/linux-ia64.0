From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 18 Jun 2003 17:48:21 +0000
Subject: Re: [RFC/PATCH] discontig update for linux-ia64-2.5 bk tree
Message-Id: <marc-linux-ia64-105595850922322@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105595347015732@msgid-missing>
In-Reply-To: <marc-linux-ia64-105595347015732@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 18, 2003 at 10:42:55AM -0700, David Mosberger wrote:
> Jesse,
> 
>  Jesse> There are a few hunks that remove #ifdef CONFIG_VIRTUAL_MEMMAP lines,
>  Jesse> but maybe that config option should be removed altogether and made the
>  Jesse> default?
> 
> Why?  I want the CONFIG_VIRTUAL_MEMMAP there, because it clearly
> identifies the code and if we ever have any doubts about its
> performance effects, we can easily try without virtual mem_map.

That's a good point, but I just figured that if it worked for everyone
maybe we should make it unconditional.  I don't mind either way though.

> -	default y if IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
> +	default y if IA64_GENERIC || IA64_DIG || IA64_HP_ZX1 || IA64_SGI_SN2
> 
> Looks like this should be changed to:
> 
> +	default y if !IA64_HP_SIM
> 
> Ditto for the other places.

Ok.

> Please declare as "extern":
> 
> +int filter_rsvd_memory(unsigned long start, unsigned long end, void *arg);
> 
> THanks,

Ok.  Thanks for looking at it.
Jesse
