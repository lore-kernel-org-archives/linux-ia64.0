From: Matthew Wilcox <matthew@wil.cx>
Date: Mon, 09 Jan 2006 17:21:49 +0000
Subject: Re: [PATCH] ia64: including <asm/signal.h> alone causes compilation errors
Message-Id: <20060109172149.GQ19769@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060109171514.GA25096@locomotive.unixthugs.org>
In-Reply-To: <20060109171514.GA25096@locomotive.unixthugs.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeff Mahoney <jeffm@suse.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Jan 09, 2006 at 12:15:14PM -0500, Jeff Mahoney wrote:
> +++ linux-2.6.15-ocfs2/include/asm-ia64/signal.h	2006-01-09 11:08:16.404700640 -0500
> @@ -1,6 +1,8 @@
>  #ifndef _ASM_IA64_SIGNAL_H
>  #define _ASM_IA64_SIGNAL_H
>  
> +#include <linux/types.h>
> +
>  /*
>   * Modified 1998-2001, 2003
>   *	David Mosberger-Tang <davidm@hpl.hp.com>, Hewlett-Packard Co
> @@ -122,8 +124,6 @@
>  
>  # ifndef __ASSEMBLY__
>  
> -#  include <linux/types.h>
> -
>  /* Avoid too many header ordering problems.  */
>  struct siginfo;

Is it still possible to include this file from assembly?  Do we still
need to do that?
