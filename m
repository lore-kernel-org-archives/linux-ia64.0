From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 04 Aug 2003 23:20:37 +0000
Subject: Re: milstone reached: ia64 linux builds out of Linus' tree
Message-Id: <marc-linux-ia64-106003933924110@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106001867501939@msgid-missing>
In-Reply-To: <marc-linux-ia64-106001867501939@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David, can you apply this one too?  It's better than having it changed
in XFS.  Thanks Andreas.

Thanks,
Jesse

On Mon, Aug 04, 2003 at 09:18:57PM +0200, Andreas Schwab wrote:
> Alternatively you could use this patch (following the other
> architectures):
> 
> --- linux-2.5.73/include/asm-ia64/statfs.h.~1~	2003-06-22 20:32:55.000000000 +0200
> +++ linux-2.5.73/include/asm-ia64/statfs.h	2003-07-01 16:14:44.000000000 +0200
> @@ -6,6 +6,11 @@
>   * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
>   */
>  
> +#ifndef __KERNEL_STRICT_NAMES
> +# include <linux/types.h>
> +typedef __kernel_fsid_t	fsid_t;
> +#endif
> +
>  /*
>   * This is ugly --- we're already 64-bit, so just duplicate the definitions
>   */
