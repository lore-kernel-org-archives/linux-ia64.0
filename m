From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 29 Mar 2001 08:50:23 +0000
Subject: [Linux-ia64] kdb patch
Message-Id: <marc-linux-ia64-105590693005367@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a patch to make "rd s" and "rd %rN" (N>2) work again.
Without this patch, kdb dies when trying to access the stacked
registers, which isn't very useful.

	--david

--- arch/ia64/kdb/kdbasupport.c~	Wed Mar 28 21:59:06 2001
+++ arch/ia64/kdb/kdbasupport.c	Thu Mar 29 00:25:52 2001
@@ -424,48 +424,57 @@
 static int
 show_cur_stack_frame(struct pt_regs *regs, int regno, unsigned long *contents)
 {
-	/* FIXME: convert to unwind */
-        long sof = regs->cr_ifs & ((1<<7)-1) ;	/* size of frame */
-        unsigned long   i ;
-	int j;
-	struct switch_stack *prs_regs = getprsregs(regs) ;
-        unsigned long *sofptr = (prs_regs? ia64_rse_skip_regs(
-			(unsigned long *)prs_regs->ar_bspstore, -sof) : NULL) ;
+        unsigned long sof, i, cfm, val, sp, *bsp;
+	struct unw_frame_info info;
+	mm_segment_t old_fs;
+
+	/* XXX It would be better to simply create a copy of an unw_frame_info structure
+	 * that is set up in kdba_main_loop().  That way, we could avoid having to skip
+	 * over the first few frames every time...
+	 */
+	unw_init_frame_info(&info, current, kdb_sw[smp_processor_id()]);
+	do {
+		if (unw_unwind(&info) < 0) {
+			kdb_printf("Failed to unwind\n");
+			return 0;
+		}
+		unw_get_sp(&info, &sp);
+	} while (sp <= (unsigned long) regs);
+	unw_get_bsp(&info, (unsigned long *) &bsp);
+	unw_get_cfm(&info, &cfm);
 
-	if (!sofptr) {
-		kdb_printf("Unable to display Current Stack Frame\n") ;
-		return 0 ;
+	if (!bsp) {
+		kdb_printf("Unable to display Current Stack Frame\n");
+		return 0;
 	}
 
-	if (regno < 0) 
-		return 0 ;
+	sof = (cfm & 0x7f);
 
-	for (i=sof, j=0;i;i--,j++) {
-		/* remember to skip the nat collection dword */
-		if ((((unsigned long)sofptr>>3) & (((1<<6)-1))) 
-				= ((1<<6)-1))
-			sofptr++ ;
-
-		/* return the value in the reg if regno is non zero */
-
-		if (regno) {
-			if ((j+1) = regno) {
-				if (contents)
-					*contents = *sofptr ;
-				return -1;
-			}
-			sofptr++ ;
-		} else {
-			kdb_printf(" r%d: %016lx ", 32+j, *sofptr++) ;
-			if (!((j+1)%3)) kdb_printf("\n") ;
+	if (regno) {
+		if ((unsigned) regno - 32 >= sof)
+			return 0;
+		bsp = ia64_rse_skip_regs(bsp, regno - 32);
+		old_fs = set_fs(KERNEL_DS);
+		{
+			get_user(val, bsp);
 		}
+		set_fs(old_fs);
+		*contents = val;
+		return 1;
 	}
 
-	if (regno) {
-		if (!i) /* bogus rse number */
-			return 0 ;
-	} else
-		kdb_printf("\n") ;
+	old_fs = set_fs(KERNEL_DS);
+	{
+		for (i = 0; i < sof; ++i) {
+			get_user(val, bsp);
+			kdb_printf(" r%lu: %016lx ", 32 + i, val);
+			if (!((i + 1) % 3))
+				kdb_printf("\n");
+			bsp = ia64_rse_skip_regs(bsp, 1);
+		}
+		kdb_printf("\n");
+	}
+	set_fs(old_fs);
 
 	return 0 ;
 }
@@ -613,8 +622,7 @@
 	if (i = nkdbreglist) {
 		/* Lets check the rse maybe */
 		if (regname[0] = 'r')
-			if (show_cur_stack_frame(regs, simple_strtoul(regname+1, 0, 0) - 31, 
-					contents))
+			if (show_cur_stack_frame(regs, simple_strtoul(regname+1, 0, 0), contents))
 				return 0 ;
 		return KDB_BADREG;
 	}

