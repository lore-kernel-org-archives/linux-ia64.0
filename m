From: Martin Pool <mbp@samba.org>
Date: Fri, 02 May 2003 05:45:09 +0000
Subject: [Linux-ia64] janitor patch for _PAGE_SIZE_*
Message-Id: <marc-linux-ia64-105590723705627@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I was looking at the ia64 port and noticed the _PAGE_SIZE* definitions
are inconsistent with other uses of this term in the kernel.  

This patch just renames them to _PAGE_SHIFT.  It only touches ia64
code.

diff -ur linux-2.5.67-ia64/arch/ia64/mm/tlb.c linux-2.5.67-ia64-mbp/arch/ia64/mm/tlb.c
--- linux-2.5.67-ia64/arch/ia64/mm/tlb.c	2003-04-28 11:55:16.000000000 +1000
+++ linux-2.5.67-ia64-mbp/arch/ia64/mm/tlb.c	2003-05-02 15:35:26.000000000 +1000
@@ -23,16 +23,16 @@
 #include <asm/tlbflush.h>
 
 #define SUPPORTED_PGBITS (			\
-		1 << _PAGE_SIZE_256M |		\
-		1 << _PAGE_SIZE_64M  |		\
-		1 << _PAGE_SIZE_16M  |		\
-		1 << _PAGE_SIZE_4M   |		\
-		1 << _PAGE_SIZE_1M   |		\
-		1 << _PAGE_SIZE_256K |		\
-		1 << _PAGE_SIZE_64K  |		\
-		1 << _PAGE_SIZE_16K  |		\
-		1 << _PAGE_SIZE_8K   |		\
-		1 << _PAGE_SIZE_4K )
+		1 << _PAGE_SHIFT_256M |		\
+		1 << _PAGE_SHIFT_64M  |		\
+		1 << _PAGE_SHIFT_16M  |		\
+		1 << _PAGE_SHIFT_4M   |		\
+		1 << _PAGE_SHIFT_1M   |		\
+		1 << _PAGE_SHIFT_256K |		\
+		1 << _PAGE_SHIFT_64K  |		\
+		1 << _PAGE_SHIFT_16K  |		\
+		1 << _PAGE_SHIFT_8K   |		\
+		1 << _PAGE_SHIFT_4K )
 
 struct ia64_ctx ia64_ctx = {
 	.lock =		SPIN_LOCK_UNLOCKED,
@@ -155,8 +155,8 @@
 
 	nbits = ia64_fls(size + 0xfff);
 	if (((1UL << nbits) & SUPPORTED_PGBITS) = 0) {
-		if (nbits > _PAGE_SIZE_256M)
-			nbits = _PAGE_SIZE_256M;
+		if (nbits > _PAGE_SHIFT_256M)
+			nbits = _PAGE_SHIFT_256M;
 		else
 			/*
 			 * Some page sizes are not implemented in the
diff -ur linux-2.5.67-ia64/include/asm-ia64/pgtable.h linux-2.5.67-ia64-mbp/include/asm-ia64/pgtable.h
--- linux-2.5.67-ia64/include/asm-ia64/pgtable.h	2003-05-02 15:29:33.000000000 +1000
+++ linux-2.5.67-ia64-mbp/include/asm-ia64/pgtable.h	2003-05-02 15:35:25.000000000 +1000
@@ -65,16 +65,16 @@
 #define _PFN_MASK		_PAGE_PPN_MASK
 #define _PAGE_CHG_MASK		(_PFN_MASK | _PAGE_A | _PAGE_D)
 
-#define _PAGE_SIZE_4K	12
-#define _PAGE_SIZE_8K	13
-#define _PAGE_SIZE_16K	14
-#define _PAGE_SIZE_64K	16
-#define _PAGE_SIZE_256K	18
-#define _PAGE_SIZE_1M	20
-#define _PAGE_SIZE_4M	22
-#define _PAGE_SIZE_16M	24
-#define _PAGE_SIZE_64M	26
-#define _PAGE_SIZE_256M	28
+#define _PAGE_SHIFT_4K	12
+#define _PAGE_SHIFT_8K	13
+#define _PAGE_SHIFT_16K	14
+#define _PAGE_SHIFT_64K	16
+#define _PAGE_SHIFT_256K	18
+#define _PAGE_SHIFT_1M	20
+#define _PAGE_SHIFT_4M	22
+#define _PAGE_SHIFT_16M	24
+#define _PAGE_SHIFT_64M	26
+#define _PAGE_SHIFT_256M	28
 
 #define __ACCESS_BITS		_PAGE_ED | _PAGE_A | _PAGE_P | _PAGE_MA_WB
 #define __DIRTY_BITS_NO_ED	_PAGE_A | _PAGE_P | _PAGE_D | _PAGE_MA_WB
@@ -475,15 +475,15 @@
  * know...
  */
 #if defined(CONFIG_IA64_GRANULE_64MB)
-# define IA64_GRANULE_SHIFT	_PAGE_SIZE_64M
+# define IA64_GRANULE_SHIFT	_PAGE_SHIFT_64M
 #elif defined(CONFIG_IA64_GRANULE_16MB)
-# define IA64_GRANULE_SHIFT	_PAGE_SIZE_16M
+# define IA64_GRANULE_SHIFT	_PAGE_SHIFT_16M
 #endif
 #define IA64_GRANULE_SIZE	(1 << IA64_GRANULE_SHIFT)
 /*
  * log2() of the page size we use to map the kernel image (IA64_TR_KERNEL):
  */
-#define KERNEL_TR_PAGE_SHIFT	_PAGE_SIZE_64M
+#define KERNEL_TR_PAGE_SHIFT	_PAGE_SHIFT_64M
 #define KERNEL_TR_PAGE_SIZE	(1 << KERNEL_TR_PAGE_SHIFT)
 #define KERNEL_TR_PAGE_NUM	((KERNEL_START - PAGE_OFFSET) / KERNEL_TR_PAGE_SIZE)
 

-- 
Martin 

