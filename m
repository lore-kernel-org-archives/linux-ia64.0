From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 09 Mar 2005 22:31:42 +0000
Subject: Re: [PATCH] Altix system controller event handling
Message-Id: <20050309223142.GB9395@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.58.0503090818080.99386@gallifrey.americas.sgi.com>
In-Reply-To: <Pine.SGI.4.58.0503090818080.99386@gallifrey.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> +	extern nasid_t master_nasid;

please put externs always in headers (that are included by the file
defining the blobal symbol, too)

> +#include "snsc.h"
> +#include <asm/sn/sn_sal.h>
> +#include <linux/interrupt.h>
> +#include <linux/sched.h>

header ordering is <linux/*.h> first, then <asm/*.h>, then local
headers.

> +scdrv_event_interrupt(int irq, void *subch_data, struct pt_regs *regs)
> +{
> +	struct subch_data_s *sd = (struct subch_data_s *) subch_data;

no need to cast.

> +static unsigned int
> +scdrv_buffer_to_int(char *buf)
> +{
> +	int i;
> +	unsigned int n = 0;
> +	for( i = 0; i < sizeof(n); i++ ) {
> +		n |= ((unsigned)(*(unsigned char *)buf++)
> +		      << (8 * ((sizeof(n) - i) - 1)));

urgg.  the (*(unsigned char *)buf++) should be just *(buf++), no?
address arithmetics on signed and unsigned char are the same.

So
	for (i = 0; i < sizeof(n); i++)
		n |= ((unsigned int)buf[i] << (8 * (sizeof(n) - i - 1)));

should do the same, no?

> +	event_sd = (struct subch_data_s *) kmalloc
> +	  (sizeof (struct subch_data_s), GFP_KERNEL);

no need to cast

