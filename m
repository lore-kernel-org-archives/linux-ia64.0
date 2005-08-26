From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Fri, 26 Aug 2005 00:39:18 +0000
Subject: RE: Allow /proc/pal/cpu0/vm_info under the simulator
Message-Id: <17166.25782.457377.46172@berry.gelato.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <17165.4305.205911.684685@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17165.4305.205911.684685@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi Tony,
	Here's an even more tolerant version of palinfo.c.
I don't much like gotos if there's a reasonable alternative, so I just
used the else branches to avoid printing guff that wasn't valid.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>

diff --git a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
--- a/arch/ia64/kernel/palinfo.c
+++ b/arch/ia64/kernel/palinfo.c
@@ -240,7 +240,7 @@ cache_info(char *page)
 			}
 			p += sprintf(p,
 				     "%s Cache level %lu:\n"
-				     "\tSize           : %lu bytes\n"
+				     "\tSize           : %u bytes\n"
 				     "\tAttributes     : ",
 				     cache_types[j+cci.pcci_unified], i+1,
 				     cci.pcci_cache_size);
@@ -307,11 +307,9 @@ vm_info(char *page)
 
 	if ((status = ia64_pal_vm_summary(&vm_info_1, &vm_info_2)) !=0) {
 		printk(KERN_ERR "ia64_pal_vm_summary=%ld\n", status);
-		return 0;
-	}
+	} else {
 
-
-	p += sprintf(p,
+		p += sprintf(p,
 		     "Physical Address Space         : %d bits\n"
 		     "Virtual Address Space          : %d bits\n"
 		     "Protection Key Registers(PKR)  : %d\n"
@@ -322,47 +320,44 @@ vm_info(char *page)
 		     vm_info_2.pal_vm_info_2_s.impl_va_msb+1, vm_info_1.pal_vm_info_1_s.max_pkr+1,
 		     vm_info_1.pal_vm_info_1_s.key_size, vm_info_1.pal_vm_info_1_s.hash_tag_id,
 		     vm_info_2.pal_vm_info_2_s.rid_size);
+	}
 
-	if (ia64_pal_mem_attrib(&attrib) != 0)
-		return 0;
-
-	p += sprintf(p, "Supported memory attributes    : ");
-	sep = "";
-	for (i = 0; i < 8; i++) {
-		if (attrib & (1 << i)) {
-			p += sprintf(p, "%s%s", sep, mem_attrib[i]);
-			sep = ", ";
+	if (ia64_pal_mem_attrib(&attrib) = 0) {
+		p += sprintf(p, "Supported memory attributes    : ");
+		sep = "";
+		for (i = 0; i < 8; i++) {
+			if (attrib & (1 << i)) {
+				p += sprintf(p, "%s%s", sep, mem_attrib[i]);
+				sep = ", ";
+			}
 		}
+		p += sprintf(p, "\n");
 	}
-	p += sprintf(p, "\n");
 
 	if ((status = ia64_pal_vm_page_size(&tr_pages, &vw_pages)) !=0) {
 		printk(KERN_ERR "ia64_pal_vm_page_size=%ld\n", status);
-		return 0;
-	}
-
-	p += sprintf(p,
-		     "\nTLB walker                     : %simplemented\n"
-		     "Number of DTR                  : %d\n"
-		     "Number of ITR                  : %d\n"
-		     "TLB insertable page sizes      : ",
-		     vm_info_1.pal_vm_info_1_s.vw ? "" : "not ",
-		     vm_info_1.pal_vm_info_1_s.max_dtr_entry+1,
-		     vm_info_1.pal_vm_info_1_s.max_itr_entry+1);
+	} else {
 
+		p += sprintf(p,
+			     "\nTLB walker                     : %simplemented\n"
+			     "Number of DTR                  : %d\n"
+			     "Number of ITR                  : %d\n"
+			     "TLB insertable page sizes      : ",
+			     vm_info_1.pal_vm_info_1_s.vw ? "" : "not ",
+			     vm_info_1.pal_vm_info_1_s.max_dtr_entry+1,
+			     vm_info_1.pal_vm_info_1_s.max_itr_entry+1);
 
-	p = bitvector_process(p, tr_pages);
 
-	p += sprintf(p, "\nTLB purgeable page sizes       : ");
+		p = bitvector_process(p, tr_pages);
 
-	p = bitvector_process(p, vw_pages);
+		p += sprintf(p, "\nTLB purgeable page sizes       : ");
 
+		p = bitvector_process(p, vw_pages);
+	}
 	if ((status=ia64_get_ptce(&ptce)) != 0) {
 		printk(KERN_ERR "ia64_get_ptce=%ld\n", status);
-		return 0;
-	}
-
-	p += sprintf(p,
+	} else {
+		p += sprintf(p,
 		     "\nPurge base address             : 0x%016lx\n"
 		     "Purge outer loop count         : %d\n"
 		     "Purge inner loop count         : %d\n"
@@ -370,23 +365,23 @@ vm_info(char *page)
 		     "Purge inner loop stride        : %d\n",
 		     ptce.base, ptce.count[0], ptce.count[1], ptce.stride[0], ptce.stride[1]);
 
-	p += sprintf(p,
+		p += sprintf(p,
 		     "TC Levels                      : %d\n"
 		     "Unique TC(s)                   : %d\n",
 		     vm_info_1.pal_vm_info_1_s.num_tc_levels,
 		     vm_info_1.pal_vm_info_1_s.max_unique_tcs);
 
-	for(i=0; i < vm_info_1.pal_vm_info_1_s.num_tc_levels; i++) {
-		for (j=2; j>0 ; j--) {
-			tc_pages = 0; /* just in case */
+		for(i=0; i < vm_info_1.pal_vm_info_1_s.num_tc_levels; i++) {
+			for (j=2; j>0 ; j--) {
+				tc_pages = 0; /* just in case */
 
 
-			/* even without unification, some levels may not be present */
-			if ((status=ia64_pal_vm_info(i,j, &tc_info, &tc_pages)) != 0) {
-				continue;
-			}
+				/* even without unification, some levels may not be present */
+				if ((status=ia64_pal_vm_info(i,j, &tc_info, &tc_pages)) != 0) {
+					continue;
+				}
 
-			p += sprintf(p,
+				p += sprintf(p,
 				     "\n%s Translation Cache Level %d:\n"
 				     "\tHash sets           : %d\n"
 				     "\tAssociativity       : %d\n"
@@ -395,16 +390,21 @@ vm_info(char *page)
 				     cache_types[j+tc_info.tc_unified], i+1, tc_info.tc_num_sets,
 				     tc_info.tc_associativity, tc_info.tc_num_entries);
 
-			if (tc_info.tc_pf) p += sprintf(p, "PreferredPageSizeOptimized ");
-			if (tc_info.tc_unified) p += sprintf(p, "Unified ");
-			if (tc_info.tc_reduce_tr) p += sprintf(p, "TCReduction");
-
-			p += sprintf(p, "\n\tSupported page sizes: ");
-
-			p = bitvector_process(p, tc_pages);
-
-			/* when unified date (j=2) is enough */
-			if (tc_info.tc_unified) break;
+				if (tc_info.tc_pf) 
+					p += sprintf(p, "PreferredPageSizeOptimized ");
+				if (tc_info.tc_unified) 
+					p += sprintf(p, "Unified ");
+				if (tc_info.tc_reduce_tr)
+					p += sprintf(p, "TCReduction");
+
+				p += sprintf(p, "\n\tSupported page sizes: ");
+
+				p = bitvector_process(p, tc_pages);
+
+				/* when unified date (j=2) is enough */
+				if (tc_info.tc_unified) 
+					break;
+			}
 		}
 	}
 	p += sprintf(p, "\n");
@@ -440,14 +440,14 @@ register_info(char *page)
 		p += sprintf(p, "\n");
 	}
 
-	if (ia64_pal_rse_info(&phys_stacked, &hints) != 0) return 0;
+	if (ia64_pal_rse_info(&phys_stacked, &hints) = 0) {
 
 	p += sprintf(p,
 		     "RSE stacked physical registers   : %ld\n"
 		     "RSE load/store hints             : %ld (%s)\n",
 		     phys_stacked, hints.ph_data,
 		     hints.ph_data < RSE_HINTS_COUNT ? rse_hints[hints.ph_data]: "(??)");
-
+	}
 	if (ia64_pal_debug_info(&iregs, &dregs))
 		return 0;
 
