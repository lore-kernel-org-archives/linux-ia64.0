From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 17 Sep 2003 14:35:20 +0000
Subject: Re: [patch] include/asm-ia64/sn/router.h cleanup
Message-Id: <marc-linux-ia64-106380946013251@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 17, 2003 at 09:31:57AM -0400, Jes Sorensen wrote:
> --- /usr/tmp/TmpDir.5666-0/linux/include/asm-ia64/sn/router.h_1.5	Wed Sep 17 06:24:43 2003
> +++ linux/include/asm-ia64/sn/router.h	Wed Sep 17 06:16:17 2003
> @@ -1,5 +1,4 @@
> -
> -/* $Id$
> +/* $id$

Just kill that crap.  It just causes endless confusion if people import
the tree into a RCS-like SCM.  (See groggy's attribution of the SGI/SCO
code to Marcelo)

> -#include <linux/devfs_fs_kernel.h>
>  #include <asm/sn/vector.h>

I think you don't need this one either.

