From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 20 Jan 2005 17:57:01 +0000
Subject: [PATCH] fix early SAL init for sn2
Message-Id: <200501200957.01335.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_tD/7BHEM4FIuMcl"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_tD/7BHEM4FIuMcl
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

sn2 does early initialization of the SAL so it can use it for early console 
support.  Unfortunately, the loop to find the SAL entry point was buggy so 
when we tried out new EFI and SAL system table layouts, the loop didn't 
terminate.  Here's the fix (doh!, use two different loop counters instead of 
one and just return if we find the SAL entry point).

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_tD/7BHEM4FIuMcl
Content-Type: text/plain;
  charset="us-ascii";
  name="sal-handler-init-fix-2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sal-handler-init-fix-2.patch"

===== include/asm-ia64/sal.h 1.26 vs edited =====
--- 1.26/include/asm-ia64/sal.h	2004-12-13 15:13:54 -08:00
+++ edited/include/asm-ia64/sal.h	2005-01-20 09:45:23 -08:00
@@ -833,6 +833,8 @@
 extern int ia64_sal_oemcall_reentrant(struct ia64_sal_retval *, u64, u64, u64,
 				      u64, u64, u64, u64, u64);
 
+extern void ia64_sal_handler_init(void *entry_point, void *gpval);
+
 #endif /* __ASSEMBLY__ */
 
 #endif /* _ASM_IA64_SAL_H */
===== arch/ia64/sn/kernel/setup.c 1.47 vs edited =====
--- 1.47/arch/ia64/sn/kernel/setup.c	2005-01-18 12:27:58 -08:00
+++ edited/arch/ia64/sn/kernel/setup.c	2005-01-20 09:48:03 -08:00
@@ -163,13 +163,12 @@
 
 void __init early_sn_setup(void)
 {
-	void ia64_sal_handler_init(void *entry_point, void *gpval);
 	efi_system_table_t *efi_systab;
 	efi_config_table_t *config_tables;
 	struct ia64_sal_systab *sal_systab;
 	struct ia64_sal_desc_entry_point *ep;
 	char *p;
-	int i;
+	int i, j;
 
 	/*
 	 * Parse enough of the SAL tables to locate the SAL entry point. Since, console
@@ -185,19 +184,21 @@
 		    0) {
 			sal_systab = __va(config_tables[i].table);
 			p = (char *)(sal_systab + 1);
-			for (i = 0; i < sal_systab->entry_count; i++) {
+			for (j = 0; j < sal_systab->entry_count; j++) {
 				if (*p == SAL_DESC_ENTRY_POINT) {
 					ep = (struct ia64_sal_desc_entry_point
 					      *)p;
 					ia64_sal_handler_init(__va
 							      (ep->sal_proc),
 							      __va(ep->gp));
-					break;
+					return;
 				}
 				p += SAL_DESC_SIZE(*p);
 			}
 		}
 	}
+	/* Uh-oh, SAL not available?? */
+	printk(KERN_ERR "failed to find SAL entry point\n");
 }
 
 extern int platform_intr_list[];

--Boundary-00=_tD/7BHEM4FIuMcl--
