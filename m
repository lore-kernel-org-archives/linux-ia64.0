From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 30 Jul 2003 16:44:57 +0000
Subject: Patch get supported TLB purge page sizes from PAL
Message-Id: <marc-linux-ia64-105958352410819@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I applied the attached patch to 2.4 (this is a backport of a couple
changes from 2.5).  Thanks, Rohit.

Bjorn


#### AUTHOR rohit.seth@intel.com
#### COMMENT START
### Comments for ChangeSet
[PATCH] ia64: patch to use >256MB purges

Attached is the updated patch that takes the supported purge page size
bits from PAL call.

Backported from 2.5, including two subsequent cleanups:
    ia64: Clean up purge-page-size-from-PAL patch a bit.
    ia64: Allow 4GB TLB purges by default.  Reported by Rohit Seth.
### Comments for arch/ia64/mm/tlb.c
ia64: patch to use >256MB purges

(purge): Use this struct to group "purge_pgbits" and "max_purge_size".
(flush_tlb_range): Mark while-loop condition as "unlikely()".
(ia64_tlb_init): Instead of panic'ing, default to architected purge page-sizes
        when PAL_VM_PAGE_SIZE fails.
(ia64_tlb_init): 4GB is also an architected page-size for purges, so allow it by
        default.  Reported by Rohit Seth.
#### COMMENT END

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1046  -> 1.1047 
#	  arch/ia64/mm/tlb.c	1.8     -> 1.9    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/07/30	bjorn.helgaas@hp.com	1.1047
# tlb purge patch
# --------------------------------------------
#
diff -Nru a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
--- a/arch/ia64/mm/tlb.c	Wed Jul 30 11:11:29 2003
+++ b/arch/ia64/mm/tlb.c	Wed Jul 30 11:11:29 2003
@@ -21,17 +21,10 @@
 #include <asm/pal.h>
 #include <asm/delay.h>
 
-#define SUPPORTED_PGBITS (			\
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
+static struct {
+	unsigned long mask;	/* mask of supported purge page-sizes */
+	unsigned long max_bits; /* log2() of largest supported purge page-size */
+} purge;
 
 struct ia64_ctx ia64_ctx = {
 	.lock =	SPIN_LOCK_UNLOCKED,
@@ -149,22 +142,10 @@
 	}
 
 	nbits = ia64_fls(size + 0xfff);
-	if (((1UL << nbits) & SUPPORTED_PGBITS) = 0) {
-		if (nbits > _PAGE_SIZE_256M)
-			nbits = _PAGE_SIZE_256M;
-		else
-			/*
-			 * Some page sizes are not implemented in the
-			 * IA-64 arch, so if we get asked to clear an
-			 * unsupported page size, round up to the
-			 * nearest page size.  Note that we depend on
-			 * the fact that if page size N is not
-			 * implemented, 2*N _is_ implemented.
-			 */
-			++nbits;
-		if (((1UL << nbits) & SUPPORTED_PGBITS) = 0)
-			panic("flush_tlb_range: BUG: nbits=%lu\n", nbits);
-	}
+	while (unlikely (((1UL << nbits) & purge.mask) = 0) && (nbits < purge.max_bits))
+		++nbits;
+	if (nbits > purge.max_bits)
+		nbits = purge.max_bits;
 	start &= ~((1UL << nbits) - 1);
 
 # ifdef CONFIG_SMP
@@ -185,6 +166,15 @@
 ia64_tlb_init (void)
 {
 	ia64_ptce_info_t ptce_info;
+	unsigned long tr_pgbits;
+	long status;
+
+	if ((status = ia64_pal_vm_page_size(&tr_pgbits, &purge.mask)) != 0) {
+		printk(KERN_ERR "PAL_VM_PAGE_SIZE failed with status=%ld;"
+		       "defaulting to architected purge page-sizes.\n", status);
+		purge.mask = 0x115557000;
+	}
+	purge.max_bits = ia64_fls(purge.mask);
 
 	ia64_get_ptce(&ptce_info);
 	local_cpu_data->ptce_base = ptce_info.base;

