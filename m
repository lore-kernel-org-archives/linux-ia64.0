From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 23 Dec 2003 21:40:30 +0000
Subject: [patch] 2.6.0 MCA TLB error recovery (cleanup)
Message-Id: <marc-linux-ia64-107221614015823@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

While backporting to 2.4 I noticed a few bits
of fluff that I'd introduced into 2.6.  Clean
up the mess.

-Tony

diff -ru linux-2.6.0/arch/ia64/kernel/mca_asm.S cleanup/arch/ia64/kernel/mca_asm.S
--- linux-2.6.0/arch/ia64/kernel/mca_asm.S	2003-12-23 08:47:50.766048240 -0800
+++ cleanup/arch/ia64/kernel/mca_asm.S	2003-12-23 08:52:44.442802455 -0800
@@ -114,9 +114,7 @@
 ia64_os_mca_dispatch:
 
 	// Serialize all MCA processing
-//	movl	r2=ia64_mca_serialize
 	mov	r3=1;;
-//	DATA_VA_TO_PA(r2);;
 	LOAD_PHYSICAL(p0,r2,ia64_mca_serialize);;
 ia64_os_mca_spin:
 	xchg8	r4=[r2],r3;;
@@ -138,7 +136,6 @@
 
 ia64_os_mca_done_dump:
 
-//	movl r16=__pa(ia64_sal_to_os_handoff_state)+56
 	LOAD_PHYSICAL(p0,r16,ia64_sal_to_os_handoff_state+56)
 	;;
 	ld8 r18=[r16]		// Get processor state parameter on existing PALE_CHECK.
@@ -150,7 +147,6 @@
 	// Purge percpu data TC entries.
 begin_tlb_purge_and_reload:
 	mov r16=cr.lid
-//	movl r17=__pa(ia64_mca_tlb_list) // Physical address of ia64_mca_tlb_list
 	LOAD_PHYSICAL(p0,r17,ia64_mca_tlb_list) // Physical address of ia64_mca_tlb_list
 	mov r19=0
 	mov r20=NR_CPUS
@@ -168,8 +164,6 @@
 	mov r23=r17		// save current ia64_mca_percpu_info addr pointer.
 	adds r17,r17
 	;;
-	.global aegl
-aegl:
 	ld8 r18=[r17],8		// r18=ptce_base
   	;;
 	ld4 r19=[r17],4		// r19=ptce_count[0]
@@ -393,8 +387,6 @@
 ia64_os_mca_proc_state_dump:
 // Save bank 1 GRs 16-31 which will be used by c-language code when we switch
 //  to virtual addressing mode.
-//	movl		r2=ia64_mca_proc_state_dump;;           // Os state dump area
-//        DATA_VA_TO_PA(r2)                   // convert to to physical address
 	LOAD_PHYSICAL(p0,r2,ia64_mca_proc_state_dump)// convert OS state dump area to physical address
 
 // save ar.NaT
diff -ru linux-2.6.0/arch/ia64/kernel/mca.c cleanup/arch/ia64/kernel/mca.c
--- linux-2.6.0/arch/ia64/kernel/mca.c	2003-12-23 08:47:50.764095115 -0800
+++ cleanup/arch/ia64/kernel/mca.c	2003-12-23 08:49:10.408625389 -0800
@@ -1363,8 +1363,8 @@
 void
 ia64_log_prt_guid (efi_guid_t *p_guid, prfunc_t prfunc)
 {
-	//char out[40];
-	//printk(KERN_DEBUG "GUID = %s\n", efi_guid_unparse(p_guid, out));
+	char out[40];
+	printk(KERN_DEBUG "GUID = %s\n", efi_guid_unparse(p_guid, out));
 }
 
 static void
