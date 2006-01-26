From: mita@miraclelinux.com (Akinobu Mita)
Date: Thu, 26 Jan 2006 03:39:11 +0000
Subject: [PATCH 12/12] generic minix_{test,set,test_and_clear,test,find_first_zero}_bit()
Message-Id: <20060126033910.GK11138@miraclelinux.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com> <20060125113206.GD18584@miraclelinux.com> <20060125200250.GA26443@flint.arm.linux.org.uk> <20060125205907.GF9995@esmail.cup.hp.com> <20060126032713.GA9984@miraclelinux.com>
In-Reply-To: <20060126032713.GA9984@miraclelinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

This patch introduces the C-language equivalents of the functions below:

HAVE_ARCH_MINIX_BITOPS is defined when the architecture has its own
version of these functions.

int minix_test_and_set_bit(int nr, volatile unsigned long *addr);
int minix_set_bit(int nr, volatile unsigned long *addr);
int minix_test_and_clear_bit(int nr, volatile unsigned long *addr);
int minix_test_bit(int nr, const volatile unsigned long *addr);
unsigned long minix_find_first_zero_bit(const unsigned long *addr,
                                        unsigned long size);

This code largely copied from:
include/asm-sparc/bitops.h

Index: 2.6-git/include/asm-generic/bitops.h
=================================--- 2.6-git.orig/include/asm-generic/bitops.h	2006-01-25 19:14:12.000000000 +0900
+++ 2.6-git/include/asm-generic/bitops.h	2006-01-25 19:14:12.000000000 +0900
@@ -667,6 +667,21 @@
 
 #endif /* HAVE_ARCH_EXT2_ATOMIC_BITOPS */
 
+#ifndef HAVE_ARCH_MINIX_BITOPS
+
+#define minix_test_and_set_bit(nr,addr)	\
+	__test_and_set_bit((nr),(unsigned long *)(addr))
+#define minix_set_bit(nr,addr)		\
+	__set_bit((nr),(unsigned long *)(addr))
+#define minix_test_and_clear_bit(nr,addr) \
+	__test_and_clear_bit((nr),(unsigned long *)(addr))
+#define minix_test_bit(nr,addr)		\
+	test_bit((nr),(unsigned long *)(addr))
+#define minix_find_first_zero_bit(addr,size) \
+	find_first_zero_bit((unsigned long *)(addr),(size))
+
+#endif /* HAVE_ARCH_MINIX_BITOPS */
+
 #endif /* __KERNEL__ */
 
 #endif /* _ASM_GENERIC_BITOPS_H */
