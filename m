From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 06 Jan 2005 21:36:58 +0000
Subject: Re: fixing 2.6.10 UP builds
Message-Id: <20050106213658.GA25747@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050106201427.GA6009@jale>
In-Reply-To: <20050106201427.GA6009@jale>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 06, 2005 at 01:14:27PM -0700, dann frazier wrote:
> Debian is putting together 2.6.10 packages, and we noticed that we still
> need to forward port Jesse's patches.  Attached is the patch Ubuntu forward
> ported, and Debian is including.  It would be great to get this merged upstream
> so we don't need to port it for each release.

should be mentioned it's original from Jesse Barnes (OTOH the numa.c
copyright message implies that already).

I'd like to second the request for inclusion, distributions like Debian
really need a generic UP kernel, and having to forward-port patches
everytime a new upstream release is out is extremly annoying.

> --- kernel-source-2.6.8.defconfig/arch/ia64/kernel/cyclone.c	2004-08-14 13:07:37.000000000 -0600
> +++ kernel-source-2.6.8.newupfix.defconfig/arch/ia64/kernel/cyclone.c	2004-08-15 15:49:31.000000000 -0600
> @@ -1,8 +1,6 @@
> -#include <linux/module.h>
>  #include <linux/smp.h>
>  #include <linux/time.h>
>  #include <linux/errno.h>
> -#include <asm/io.h>
>  
>  /* IBM Summit (EXA) Cyclone counter code*/
>  #define CYCLONE_CBAR_ADDR 0xFEB00CD0

this hunk looks bogus.

