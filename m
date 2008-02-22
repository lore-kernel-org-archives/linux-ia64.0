From: Robin Holt <holt@sgi.com>
Date: Fri, 22 Feb 2008 05:42:28 +0000
Subject: Re: [PATCH 04/28] ia64/xen: introduce synch bitops which is
Message-Id: <20080222054228.GM11391@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12036570474076-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12036570474076-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 22, 2008 at 02:10:20PM +0900, Isaku Yamahata wrote:
...
> --- /dev/null
> +++ b/include/asm-ia64/sync_bitops.h
> @@ -0,0 +1,61 @@
> +#ifndef __XEN_SYNC_BITOPS_H__
> +#define __XEN_SYNC_BITOPS_H__

Typically, these #defines are made to match the filename.

...

> +#define ADDR (*(volatile long *) addr)

This seems like a leftover #define.  Additionally, ADDR seems a bit
vague and easily misused.  Since I don't see it used anywhere else in
that patch, I will assume it should be tossed, but reserve the right to
rescind this comment later.

...
> +#endif /* __XEN_SYNC_BITOPS_H__ */

Same as the first.

Thanks,
Robin
