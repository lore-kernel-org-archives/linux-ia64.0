From: Matthew Wilcox <willy@debian.org>
Date: Sun, 16 Nov 2003 21:25:13 +0000
Subject: Re: [PATCH] - prof_cpu_mask problems
Message-Id: <marc-linux-ia64-106901866501139@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106901123527791@msgid-missing>
In-Reply-To: <marc-linux-ia64-106901123527791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Nov 16, 2003 at 01:30:43PM -0600, Jack Steiner wrote:
> 
> I ran into several problems with the prof_cpu_mask & other
> irq masks.

> -	len = 0;
> -	for (k = 0; k < sizeof(cpumask_t)/sizeof(u16); ++k) {
> -		int j = sprintf(page, "%04hx", (u16)cpus_coerce(tmp));
> +	i = sizeof(cpumask_t)/sizeof(u16);
> +	for (k = 0; k < i; ++k) {
> +		cpus_shift_right(mask, irqmask, 16*(i-k-1));
> +		j = sprintf(page, "%04hx", (u16)cpus_coerce(mask));
>  		len += j;
>  		page += j;
> -		cpus_shift_right(tmp, tmp, 16);

Why u16 rather than u32?  cpumask_t is guaranteed to be a multiple of
4, right?

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
