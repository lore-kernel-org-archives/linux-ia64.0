From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 06 Jan 2005 21:30:48 +0000
Subject: Re: sn/kernel/bte_error.c build error
Message-Id: <200501061330.48941.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050106201841.GB6009@jale>
In-Reply-To: <20050106201841.GB6009@jale>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, January 6, 2005 12:18 pm, dann frazier wrote:
> A UP build of 2.6.10 fails in bte_error.c because HZ is undefined.  I added
> an include for <asm/param.h> to get further in the build - not sure if this
> is the correct solution.
>
> --- kernel-source-2.6.10/arch/ia64/sn/kernel/bte_error.c.orig 2005-01-06
> 13:20:10.954478087 -0700 +++
> kernel-source-2.6.10/arch/ia64/sn/kernel/bte_error.c 2005-01-06
> 12:54:41.483793698 -0700 @@ -15,6 +15,7 @@
>  #include "xtalk/xwidgetdev.h"
>  #include "xtalk/hubdev.h"
>  #include <asm/sn/bte.h>
> +#include <asm/param.h>

Ack.  Looks ok to me.

Thanks,
Jesse
