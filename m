From: Jack Steiner <steiner@sgi.com>
Date: Fri, 23 Jul 2004 21:56:29 +0000
Subject: Re: [PATCH] - Update function prototype for sn_io_addr
Message-Id: <20040723215628.GA14272@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040723122907.GA7308@sgi.com>
In-Reply-To: <20040723122907.GA7308@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jul 23, 2004 at 10:15:44AM -0700, David Mosberger wrote:
> >>>>> On Fri, 23 Jul 2004 07:29:08 -0500, Jack Steiner <steiner@sgi.com> said:
> 
>   Jack> Add "const" to function prototype for sn_io_addr. Cuts boot
>   Jack> time on simulator in half.
> 
>   Jack> Signed-off-by: Jack Steiner <steiner@sgi.com>
> 
>   Jack> __attribute__ ((__const__));
> 
> I think you're supposed to use __attribute_const__.

Right..

Add "const" to function prototype for sn_io_addr. Cuts boot time
on simulator in half.


Signed-off-by: Jack Steiner <steiner@sgi.com>


Index: linux/include/asm-ia64/sn/sn2/io.h
=================================--- linux.orig/include/asm-ia64/sn/sn2/io.h
+++ linux/include/asm-ia64/sn/sn2/io.h
@@ -8,10 +8,11 @@
 
 #ifndef _ASM_SN_SN2_IO_H
 #define _ASM_SN_SN2_IO_H
+#include <linux/compiler.h>
+#include <asm/intrinsics.h>
 
-extern void * sn_io_addr(unsigned long port); /* Forward definition */
+extern void * sn_io_addr(unsigned long port) __attribute_const__; /* Forward definition */
 extern void sn_mmiob(void); /* Forward definition */
-#include <asm/intrinsics.h>
 
 #define __sn_mf_a()   ia64_mfa()
 
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


