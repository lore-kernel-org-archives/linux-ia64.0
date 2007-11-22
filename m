From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 22 Nov 2007 08:40:16 +0000
Subject: Re: [patch 1/3] IA64: Slim down __clear_bit_unlock
Message-Id: <47454070.3020002@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200711212258.lALMwPnR013399@imap1.linux-foundation.org>
In-Reply-To: <200711212258.lALMwPnR013399@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Almost there :-)

> +static __inline__ void
> +__clear_bit_unlock(int nr, volatile void *addr)
> +{
> +	__u32 mask, new;
> +	volatile __u32 *m;
> +
> +	m = (volatile __u32 *)addr + (nr >> 5);

Still cannot see why you need an ".acq" on this load.
Why do you use "volatile"?

What about this one?

static __inline__ void
__clear_bit_unlock(int const nr, void * const addr)
{
        __u32 * const m = addr + (nr >> 5);
        __u32 new;

        new = *m & ~(1 << (nr & 31));
        barrier();
        asm volatile ("st4.rel.nta [%0] = %1\n\t" :: "r"(m), "r"(new));
}

Thanks,

Zoltan Menyhart
