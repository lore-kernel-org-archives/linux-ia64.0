From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 13 Aug 2004 15:29:28 +0000
Subject: Re: r996 - in trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7: . debian
Message-Id: <200408130829.28232.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040810071417.GA5080@lst.de>
In-Reply-To: <20040810071417.GA5080@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday, August 13, 2004 2:32 am, Christoph Hellwig wrote:
> --- /dev/null	Wed Dec 31 16:00:00 196900
> +++ b/arch/ia64/kernel/numa.c	2004-08-12 18:28:06 -07:00
> @@ -0,0 +1,46 @@
> +#include <linux/config.h>
> +#include <linux/topology.h>
> +#include <linux/module.h>
> +#include <asm/processor.h>
> +#include <asm/smp.h>
> +
> +#ifdef CONFIG_NUMA
>
> You build this file conditional on CONFIG_
> UMA, no need for this ifdef.

Yep, you're right.

Jesse
