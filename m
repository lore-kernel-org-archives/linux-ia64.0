From: Jack Steiner <steiner@sgi.com>
Date: Fri, 23 Jul 2004 12:29:08 +0000
Subject: [PATCH] - Update function prototype for sn_io_addr
Message-Id: <20040723122907.GA7308@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add "const" to function prototype for sn_io_addr. Cuts boot time
on simulator in half.

Signed-off-by: Jack Steiner <steiner@sgi.com>



Index: linux/include/asm-ia64/sn/sn2/io.h
=================================--- linux.orig/include/asm-ia64/sn/sn2/io.h
+++ linux/include/asm-ia64/sn/sn2/io.h
@@ -9,7 +9,7 @@
 #ifndef _ASM_SN_SN2_IO_H
 #define _ASM_SN_SN2_IO_H
 
-extern void * sn_io_addr(unsigned long port); /* Forward definition */
+extern void * sn_io_addr(unsigned long port) __attribute__ ((__const__)); /* Forward definition */
 extern void sn_mmiob(void); /* Forward definition */
 #include <asm/intrinsics.h>
 
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


