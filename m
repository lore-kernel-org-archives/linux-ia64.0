From: Daniel J Blueman <daniel.blueman@quadrics.com>
Date: Thu, 05 Aug 2004 11:13:51 +0000
Subject: pte_modify fix backport...
Message-Id: <1091704431.1829.235.camel@pc107.quadrics.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, marcelo.tosatti@cyclades.com

This patch [1] corrects the behaviour of pte_modify() on ia64 to not
clear page protection flags it shouldn't touch.

Without this patch, it clears the uncacheable flag on UC memory regions,
which can cause MCAs with device I/O.

It was taken into 2.6.0 a while ago, but is yet to be included in 2.4 -
the patch here is rediffed against 2.4.26-rc5.

Is there chance of it being taken in?

--- [1]

diff -durN linux-2.4.26-rc5-orig/include/asm-ia64/pgtable.h linux-2.4.26-rc5-patched/include/asm-ia64/pgtable.h
--- linux-2.4.26-rc5-orig/include/asm-ia64/pgtable.h	2004-02-18 13:36:32.000000000 +0000
+++ linux-2.4.26-rc5-patched/include/asm-ia64/pgtable.h	2004-08-05 11:46:03.000000000 +0100
@@ -60,7 +60,8 @@
 #define _PAGE_PROTNONE		(__IA64_UL(1) << 63)
 
 #define _PFN_MASK		_PAGE_PPN_MASK
-#define _PAGE_CHG_MASK		(_PFN_MASK | _PAGE_A | _PAGE_D)
+/* Mask of bits which may be changed by pte_modify(); the odd bits are there for _PAGE_PROTNONE */
+#define _PAGE_CHG_MASK		(_PAGE_P | _PAGE_PROTNONE | _PAGE_PL_MASK | _PAGE_AR_MASK | _PAGE_ED)
 
 #define _PAGE_SIZE_4K	12
 #define _PAGE_SIZE_8K	13
@@ -216,7 +217,7 @@
 ({ pte_t __pte; pte_val(__pte) = physpage + pgprot_val(pgprot); __pte; })
 
 #define pte_modify(_pte, newprot) \
-	(__pte((pte_val(_pte) & _PAGE_CHG_MASK) | pgprot_val(newprot)))
+	(__pte((pte_val(_pte) & ~_PAGE_CHG_MASK) | (pgprot_val(newprot) & _PAGE_CHG_MASK)))
 
 #define page_pte_prot(page,prot)	mk_pte(page, prot)
 #define page_pte(page)			page_pte_prot(page, __pgprot(0))

-- 
Daniel J Blueman
Software Engineer, Quadrics Ltd

