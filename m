From: Keith Owens <kaos@sgi.com>
Date: Tue, 08 Feb 2005 08:25:14 +0000
Subject: [patch 2.6.11-rc3-bk4] Correctly dereference ia64_mca_data
Message-Id: <23464.1107851114@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

arch/ia64/kernel/mca_asm.S is treating per_cpu__ia64_mca_data as the
start of the mca data, instead of as a pointer to the mca data.  It
ends up overwriting the rest of the per cpu area with the MCA stack and
bspstore.  Since we dereference ia64_mca_data several times, make it a
macro.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/kernel/mca_asm.S
=================================--- linux.orig/arch/ia64/kernel/mca_asm.S	2005-02-08 18:02:43.000000000 +1100
+++ linux/arch/ia64/kernel/mca_asm.S	2005-02-08 19:08:25.000000000 +1100
@@ -101,6 +101,11 @@
 	ld8	tmp=[sal_to_os_handoff];;				\
 	st8     [os_to_sal_handoff]=tmp;;
 
+#define GET_IA64_MCA_DATA(reg)						\
+	GET_THIS_PADDR(reg, ia64_mca_data)				\
+	;;								\
+	ld8 reg=[reg]
+
 	.global ia64_os_mca_dispatch
 	.global ia64_os_mca_dispatch_end
 	.global ia64_sal_to_os_handoff_state
@@ -309,14 +314,14 @@ err:
 done_tlb_purge_and_reload:
 
 	// Setup new stack frame for OS_MCA handling
-	GET_THIS_PADDR(r2, ia64_mca_data)
+	GET_IA64_MCA_DATA(r2)
 	;;
 	add r3 = IA64_MCA_CPU_STACKFRAME_OFFSET, r2
 	add r2 = IA64_MCA_CPU_RBSTORE_OFFSET, r2
 	;;
 	rse_switch_context(r6,r3,r2);;	// RSC management in this new context
 
-	GET_THIS_PADDR(r2, ia64_mca_data)
+	GET_IA64_MCA_DATA(r2)
 	;;
 	add r2 = IA64_MCA_CPU_STACK_OFFSET+IA64_MCA_STACK_SIZE-16, r2
 	;;
@@ -336,7 +341,7 @@ ia64_os_mca_virtual_begin:
 ia64_os_mca_virtual_end:
 
 	// restore the original stack frame here
-	GET_THIS_PADDR(r2, ia64_mca_data)
+	GET_IA64_MCA_DATA(r2)
 	;;
 	add r2 = IA64_MCA_CPU_STACKFRAME_OFFSET, r2
 	;;
@@ -380,7 +385,7 @@ ia64_os_mca_dispatch_end:
 ia64_os_mca_proc_state_dump:
 // Save bank 1 GRs 16-31 which will be used by c-language code when we switch
 //  to virtual addressing mode.
-	GET_THIS_PADDR(r2, ia64_mca_data)
+	GET_IA64_MCA_DATA(r2)
 	;;
 	add r2 = IA64_MCA_CPU_PROC_STATE_DUMP_OFFSET, r2
 	;;
@@ -613,7 +618,7 @@ end_os_mca_dump:
 ia64_os_mca_proc_state_restore:
 
 // Restore bank1 GR16-31
-	GET_THIS_PADDR(r2, ia64_mca_data)
+	GET_IA64_MCA_DATA(r2)
 	;;
 	add r2 = IA64_MCA_CPU_PROC_STATE_DUMP_OFFSET, r2
 

