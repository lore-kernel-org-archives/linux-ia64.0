From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 15 Jan 2005 02:26:52 +0000
Subject: fix sparse buglet
Message-Id: <16872.32620.437078.407896@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

I was getting a lot of spurious warnings with "make C=1", due to a
missing "__user" attribute.  I'm not sure whether this got lost or
whether earlier versions of sparse failed to warn about it, but it's
clearly needed (and the i386 version of uaccess.h does the same).

Please apply.

Thanks,

	--david

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=== include/asm-ia64/uaccess.h 1.21 vs edited ==--- 1.21/include/asm-ia64/uaccess.h	2004-10-05 11:27:40 -07:00
+++ edited/include/asm-ia64/uaccess.h	2005-01-14 17:47:23 -08:00
@@ -132,7 +132,7 @@
 
 #ifdef ASM_SUPPORTED
   struct __large_struct { unsigned long buf[100]; };
-# define __m(x) (*(struct __large_struct *)(x))
+# define __m(x) (*(struct __large_struct __user *)(x))
 
 /* We need to declare the __ex_table section before we can use it in .xdata.  */
 asm (".section \"__ex_table\", \"a\"\n\t.previous");
