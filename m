From: Horms <horms@verge.net.au>
Date: Tue, 06 Feb 2007 03:14:45 +0000
Subject: Re: [PATCH] [IA64]: add newline to PAL-code warning message
Message-Id: <20070206031445.GA12585@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 05, 2007 at 01:18:16PM +0100, Gerald Pfeifer wrote:
> On Mon, 5 Feb 2007, Horms wrote:
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> > -	printk(KERN_WARNING "%s: no PAL-code memory-descriptor found",
> > +	printk(KERN_WARNING "%s: no PAL-code memory-descriptor found\n",
>                                                                     ^^
> 
> This is usually referred to as newline, not return.  Return, or
> carriage return, would be '\r' instead of '\n'.

Thanks, updated accordingly.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

[IA64]: Add newline to PAL-code warning message

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/kernel/efi.c
=================================--- linux-2.6.orig/arch/ia64/kernel/efi.c	2007-01-31 16:54:43.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/efi.c	2007-01-31 16:54:46.000000000 +0900
@@ -380,7 +380,7 @@
 #endif
 		return __va(md->phys_addr);
 	}
-	printk(KERN_WARNING "%s: no PAL-code memory-descriptor found",
+	printk(KERN_WARNING "%s: no PAL-code memory-descriptor found\n",
 	       __FUNCTION__);
 	return NULL;
 }
