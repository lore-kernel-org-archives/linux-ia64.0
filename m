From: Keith Owens <kaos@sgi.com>
Date: Fri, 02 Jul 2004 01:37:15 +0000
Subject: [patch 2.6.7-ia64-040629] Correct invalid unwind data
Message-Id: <3948.1088732235@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ASM_UNW_PRLG_GRSAVE(n) must match the number of input registers in the
following alloc statement.  Otherwise you get invalid backtraces :(

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: 2.6.7-ia64-040629/arch/ia64/ia32/ia32_entry.S
=================================--- 2.6.7-ia64-040629.orig/arch/ia64/ia32/ia32_entry.S	Fri Jul  2 11:22:02 2004
+++ 2.6.7-ia64-040629/arch/ia64/ia32/ia32_entry.S	Fri Jul  2 11:26:04 2004
@@ -32,7 +32,7 @@ ENTRY(ia32_execve)
 END(ia32_execve)
 
 ENTRY(ia32_clone)
-	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2)
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(5)
 	alloc r16=ar.pfs,5,2,6,0
 	DO_SAVE_SWITCH_STACK
 	mov loc0=rp
Index: 2.6.7-ia64-040629/arch/ia64/kernel/pal.S
=================================--- 2.6.7-ia64-040629.orig/arch/ia64/kernel/pal.S	Fri Jul  2 11:22:02 2004
+++ 2.6.7-ia64-040629/arch/ia64/kernel/pal.S	Fri Jul  2 11:27:05 2004
@@ -54,7 +54,7 @@ END(ia64_pal_default_handler)
  *
  */
 GLOBAL_ENTRY(ia64_pal_call_static)
-	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(6)
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(5)
 	alloc loc1 = ar.pfs,5,5,0,0
 	movl loc2 = pal_entry_point
 1:	{
@@ -100,7 +100,7 @@ END(ia64_pal_call_static)
  * 	in2 - in3   Remaning PAL arguments
  */
 GLOBAL_ENTRY(ia64_pal_call_stacked)
-	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(5)
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(4)
 	alloc loc1 = ar.pfs,4,4,4,0
 	movl loc2 = pal_entry_point
 
@@ -147,7 +147,7 @@ END(ia64_pal_call_stacked)
 
 
 GLOBAL_ENTRY(ia64_pal_call_phys_static)
-	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(6)
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(4)
 	alloc loc1 = ar.pfs,4,7,0,0
 	movl loc2 = pal_entry_point
 1:	{

