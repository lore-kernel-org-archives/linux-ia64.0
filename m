From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 11 Feb 2005 14:26:55 +0000
Subject: Re: [PATCH 2.6.11-rc2 1/1] altix: Device driver support for the CX port of SGI's TIO chip
Message-Id: <20050211142655.GA6113@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050211140321.20148.62620.40637@attica.americas.sgi.com>
In-Reply-To: <20050211140321.20148.62620.40637@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> -#include "xtalk/xwidgetdev.h"
> +#include <asm/sn/xtalk/xwidgetdev.h>
>  #include <asm/sn/geo.h>
> -#include "xtalk/hubdev.h"
> +#include <asm/sn/xtalk/hubdev.h>

please put moving around headers in a separate patch.

>  DEFINE_PER_CPU(struct pda_s, pda_percpu);
> +EXPORT_PER_CPU_SYMBOL(pda_percpu);

As mentioned the last time you posted it please use a proper accessor.

> +static void tiocx_bus_release(struct device *dev)
> +{
> +}

this is broken.  See the tweleve gazillion times it came up on lkml.
The driver core doesn't warn about the lack of a release function because
it's a nice way to waste time but because there's an actual reason.

> +struct cx_drv {
> +	char *name;
> +	const struct cx_device_id *id_table;
> +	struct device_driver driver;
> +	int (*probe) (struct cx_dev * dev, const struct cx_device_id * id);
> +};

To make it work sanely you also need a ->remove callout.


With the above issues fixed it's fine to be queued up until you submit
an actual user of this interface.
