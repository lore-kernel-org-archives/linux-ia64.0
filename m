From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 27 Dec 2001 09:12:03 +0000
Subject: [Linux-ia64] missing ia32 fixes
Message-Id: <marc-linux-ia64-105590698805719@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

To my surprise, the GDT initialization bug fix that Don posted back in
October never made it into my released patches.  I didn't notice until
now.  The attached patch fixes this problem and also fixes a problem
with the GDT table initialization which shows when running on an MP
machine.  With these two patches, I'm able to run TurboTax 2000 under
WINE again.  TaxCut 2000 also seems to work (mostly).  Haven't tried
the 2001 versions yet.  In any case, don't sue me if ia64 linux + wine
+ your favorite tax program gives you a bad return! ;-)

	--david

--- linux-2.4.17/arch/ia64/ia32/ia32_support.c	Mon Nov 26 11:18:20 2001
+++ lia64-2.4/arch/ia64/ia32/ia32_support.c	Thu Dec 27 01:06:02 2001
@@ -153,10 +153,12 @@
 	/* We never change the TSS and LDT descriptors, so we can share them across all CPUs.  */
 	ldt_size = PAGE_ALIGN(IA32_LDT_ENTRIES*IA32_LDT_ENTRY_SIZE);
 	for (nr = 0; nr < NR_CPUS; ++nr) {
-		ia32_gdt[_TSS(nr)] = IA32_SEG_DESCRIPTOR(IA32_TSS_OFFSET, 235,
-							 0xb, 0, 3, 1, 1, 1, 0);
-		ia32_gdt[_LDT(nr)] = IA32_SEG_DESCRIPTOR(IA32_LDT_OFFSET, ldt_size - 1,
-							 0x2, 0, 3, 1, 1, 1, 0);
+		ia32_gdt[_TSS(nr) >> IA32_SEGSEL_INDEX_SHIFT]
+			= IA32_SEG_DESCRIPTOR(IA32_TSS_OFFSET, 235,
+					      0xb, 0, 3, 1, 1, 1, 0);
+		ia32_gdt[_LDT(nr) >> IA32_SEGSEL_INDEX_SHIFT]
+			= IA32_SEG_DESCRIPTOR(IA32_LDT_OFFSET, ldt_size - 1,
+					      0x2, 0, 3, 1, 1, 1, 0);
 	}
 }
 
--- linux-2.4.17/arch/ia64/ia32/binfmt_elf32.c	Mon Nov 26 11:18:19 2001
+++ lia64-2.4/arch/ia64/ia32/binfmt_elf32.c	Thu Dec 27 00:23:46 2001
@@ -142,10 +142,11 @@
 	/*
 	 * Setup GDTD.  Note: GDTD is the descrambled version of the pseudo-descriptor
 	 * format defined by Figure 3-11 "Pseudo-Descriptor Format" in the IA-32
-	 * architecture manual.
+	 * architecture manual. Also note that the only fields that are not ignored are
+	 * `base', `limit', 'G', `P' (must be 1) and `S' (must be 0).
 	 */
-	regs->r31 = IA32_SEG_UNSCRAMBLE(IA32_SEG_DESCRIPTOR(IA32_GDT_OFFSET, IA32_PAGE_SIZE - 1, 0,
-							    0, 0, 0, 0, 0, 0));
+	regs->r31 = IA32_SEG_UNSCRAMBLE(IA32_SEG_DESCRIPTOR(IA32_GDT_OFFSET, IA32_PAGE_SIZE - 1,
+							    0, 0, 0, 1, 0, 0, 0));
 	/* Setup the segment selectors */
 	regs->r16 = (__USER_DS << 16) | __USER_DS; /* ES = DS, GS, FS are zero */
 	regs->r17 = (__USER_DS << 16) | __USER_CS; /* SS, CS; ia32_load_state() sets TSS and LDT */

