From: Grant Grundler <iod00d@hp.com>
Date: Thu, 05 Aug 2004 18:49:33 +0000
Subject: Re: [PATCH&RFC 2/2] OS_MCA Recovery from poisoned memory read
Message-Id: <20040805184933.GG6526@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41121484.40804@jp.fujitsu.com>
In-Reply-To: <41121484.40804@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Aug 05, 2004 at 08:05:40PM +0900, Hidetoshi Seto wrote:
> The MCA offending process will restart from handler_bh, and
> will suicide after isolating the poisoned page.

Hidetoshi,
Wow! I'm impressed - this is amazing functionality.

I only noticed the three new driver files didn't have either
a copyright nor license embedded in it.

I'm told the license is optional because the "linux-2,6/COPYING"
contains a blanket statement for the rest of the kernel.
But many lawyers still like to see it in each file.

grant

> +++ linux-2.6.8-rc3-mcadrv-v2/arch/ia64/kernel/mca_drv.c	2004-08-04 19:17:09.676773696 +0900
> @@ -0,0 +1,647 @@
> +/*
> + * File:	mca_drv.c
> + * Purpose:	Generic MCA handling layer
> + */
...

> --- linux-2.6.8-rc3/arch/ia64/kernel/mca_drv.h	1970-01-01 09:00:00.000000000 +0900
> +++ linux-2.6.8-rc3-mcadrv-v2/arch/ia64/kernel/mca_drv.h	2004-08-04 18:08:39.000000000 +0900
> @@ -0,0 +1,111 @@
...

> +/*
> + * File:	mca_drv.h
> + * Purpose:	Define helpers for Generic MCA handling
> + */
...

> --- linux-2.6.8-rc3/arch/ia64/kernel/mca_drv_asm.S	1970-01-01 09:00:00.000000000 +0900
> +++ linux-2.6.8-rc3-mcadrv-v2/arch/ia64/kernel/mca_drv_asm.S	2004-08-04 19:16:51.045914549 +0900
> @@ -0,0 +1,38 @@
...

