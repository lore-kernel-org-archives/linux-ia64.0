From: Keith Owens <kaos@sgi.com>
Date: Fri, 19 Sep 2003 07:22:25 +0000
Subject: [patch] 2.4.2* documentation fix for mca_asm.h
Message-Id: <marc-linux-ia64-106395616709929@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Documentation fix for mca_asm.h.  Refer to the released Intel manual
and correct a field name.  No functional changes.

--- linux/include/asm-ia64/mca_asm.h.orig	2003-09-19 14:51:14.000000000 +1000
+++ linux/include/asm-ia64/mca_asm.h	2003-09-19 15:01:17.000000000 +1000
@@ -227,7 +227,8 @@
  * saved onto the new stack frame.
  *
  *	+-----------------------+
- *	|NDIRTY [BSP - BSPSTORE]|
+ *	|NDIRTY_WORDS           |
+ *	|       [BSP - BSPSTORE]|
  *	+-----------------------+
  *	|	RNAT		|
  *	+-----------------------+
@@ -245,7 +246,7 @@
 #define  rse_ifs_offset		(rse_pfs_offset+0x08)
 #define  rse_bspstore_offset	(rse_ifs_offset+0x08)
 #define  rse_rnat_offset	(rse_bspstore_offset+0x08)
-#define  rse_ndirty_offset	(rse_rnat_offset+0x08)
+#define  rse_ndirty_words_offset	(rse_rnat_offset+0x08)
 
 /*
  * rse_switch_context
@@ -258,7 +259,8 @@
  *	6. Save the old RNAT on the new stack frame
  *	7. Write BSPSTORE with the new backing store pointer
  *	8. Read and save the new BSP to calculate the #dirty registers
- * NOTE: Look at pages 11-10, 11-11 in PRM Vol 2
+ * NOTE: Look at section 6.11 in Intel IA-64 Architecture Software Developer's
+ *       Manual, Volume 2, System Architecture.
  */
 #define rse_switch_context(temp,p_stackframe,p_bspstore)			\
 	;;									\
@@ -295,12 +297,12 @@
 #define rse_return_context(psr_mask_reg,temp,p_stackframe)			\
 	;;									\
 	alloc   temp=ar.pfs,0,0,0,0;						\
-	add     p_stackframe=rse_ndirty_offset,p_stackframe;;			\
+	add     p_stackframe=rse_ndirty_words_offset,p_stackframe;;		\
 	ld8     temp=[p_stackframe];;						\
 	shl     temp=temp,16;;							\
 	mov     ar.rsc=temp;;							\
 	loadrs;;								\
-	add     p_stackframe=-rse_ndirty_offset+rse_bspstore_offset,p_stackframe;;\
+	add     p_stackframe=-rse_ndirty_words_offset+rse_bspstore_offset,p_stackframe;;\
 	ld8     temp=[p_stackframe];;						\
 	mov     ar.bspstore=temp;;						\
 	add     p_stackframe=-rse_bspstore_offset+rse_rnat_offset,p_stackframe;;\


