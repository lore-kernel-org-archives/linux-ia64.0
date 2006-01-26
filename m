From: mita@miraclelinux.com (Akinobu Mita)
Date: Thu, 26 Jan 2006 03:31:56 +0000
Subject: [PATCH 3/12] generic ffz()
Message-Id: <20060126033156.GB11138@miraclelinux.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com> <20060125113206.GD18584@miraclelinux.com> <20060125200250.GA26443@flint.arm.linux.org.uk> <20060125205907.GF9995@esmail.cup.hp.com> <20060126032713.GA9984@miraclelinux.com>
In-Reply-To: <20060126032713.GA9984@miraclelinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

This patch introduces the C-language equivalent of the function:
unsigned long ffz(unsigned long word);

HAVE_ARCH_FFZ_BITOPS is defined when the architecture has its own
version of these functions.

This code largely copied from:
include/asm-sparc64/bitops.h


Index: 2.6-git/include/asm-generic/bitops.h
=================================--- 2.6-git.orig/include/asm-generic/bitops.h	2006-01-25 19:14:09.000000000 +0900
+++ 2.6-git/include/asm-generic/bitops.h	2006-01-25 19:14:10.000000000 +0900
@@ -230,6 +230,13 @@
 
 #endif /* HAVE_ARCH___FFS_BITOPS */
 
+#ifndef HAVE_ARCH_FFZ_BITOPS
+
+/* Undefined if no bit is zero. */
+#define ffz(x)	__ffs(~x)
+
+#endif /* HAVE_ARCH_FFZ_BITOPS */
+
 /*
  * fls: find last bit set.
  */
