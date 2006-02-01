From: Akinobu Mita <mita@miraclelinux.com>
Date: Wed, 01 Feb 2006 09:03:06 +0000
Subject: [patch 42/44] ia64: make partial_page.bitmap an unsigned long
Message-Id: <20060201090335.666881000@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060201090224.536581000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, Akinobu Mita <mita@miraclelinux.com>

The *_bit() routines are defined to work on a pointer to unsigned long.
But partial_page.bitmap is unsigned int and it is passed to find_*_bit()
in arch/ia64/ia32/sys_ia32.c. So the compiler will print warnings.

This patch changes to unsigned long instead.

Signed-off-by: Akinobu Mita <mita@miraclelinux.com>
 arch/ia64/ia32/ia32priv.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Index: 2.6-git/arch/ia64/ia32/ia32priv.h
=================================--- 2.6-git.orig/arch/ia64/ia32/ia32priv.h
+++ 2.6-git/arch/ia64/ia32/ia32priv.h
@@ -29,9 +29,9 @@
 struct partial_page {
 	struct partial_page	*next; /* linked list, sorted by address */
 	struct rb_node		pp_rb;
-	/* 64K is the largest "normal" page supported by ia64 ABI. So 4K*32
+	/* 64K is the largest "normal" page supported by ia64 ABI. So 4K*64
 	 * should suffice.*/
-	unsigned int		bitmap;
+	unsigned long		bitmap;
 	unsigned int		base;
 };
 

--
