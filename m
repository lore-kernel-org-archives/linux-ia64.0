From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 18 Mar 2005 05:01:16 +0000
Subject: Re: recent fix for pgd_addr_end
Message-Id: <200503180501.j2I51Gh25686@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
In-Reply-To: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's the version that handles region 5 correctly too.

-Tony

=== include/asm-ia64/pgtable.h 1.55 vs edited ==--- 1.55/include/asm-ia64/pgtable.h	2005-03-16 09:33:36 -08:00
+++ edited/include/asm-ia64/pgtable.h	2005-03-17 20:46:40 -08:00
@@ -553,17 +553,25 @@
 
 /*
  * Override for pgd_addr_end() to deal with the virtual address space holes
- * in each region.  Virtual address bits are used like this:
+ * in each region.  In regions 0..4 virtual address bits are used like this:
  *      +--------+------+--------+-----+-----+--------+
  *      | pgdhi3 | rsvd | pgdlow | pmd | pte | offset |
  *      +--------+------+--------+-----+-----+--------+
- *  The high bit of 'pgdlow' must be sign extended across the 'rsvd' bits.
+ *  'pgdlow' overflows to pgdhi3 (a.k.a. region bits) leaving rsvd=0
  */
-#define IA64_PGD_SIGNEXTEND (PGDIR_SIZE << (PAGE_SHIFT-7))
+#define IA64_PGD_OVERFLOW (PGDIR_SIZE << (PAGE_SHIFT-6))
+
 #define pgd_addr_end(addr, end)						\
 ({	unsigned long __boundary = ((addr) + PGDIR_SIZE) & PGDIR_MASK;	\
-	if (__boundary & IA64_PGD_SIGNEXTEND)				\
-		__boundary |= (RGN_SIZE - 1) & ~(IA64_PGD_SIGNEXTEND-1);\
+	if (addr < DEFAULT_TASK_SIZE && __boundary & IA64_PGD_OVERFLOW)	\
+		__boundary += (RGN_SIZE - 1) & ~(IA64_PGD_OVERFLOW - 1);\
+	(__boundary - 1 < (end) - 1)? __boundary: (end);		\
+})
+
+#define pmd_addr_end(addr, end)						\
+({	unsigned long __boundary = ((addr) + PMD_SIZE) & PMD_MASK;	\
+	if (addr < DEFAULT_TASK_SIZE && __boundary & IA64_PGD_OVERFLOW)	\
+		__boundary += (RGN_SIZE - 1) & ~(IA64_PGD_OVERFLOW - 1);\
 	(__boundary - 1 < (end) - 1)? __boundary: (end);		\
 })
 
