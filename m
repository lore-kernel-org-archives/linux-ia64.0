From: John Hesterberg <jh@sgi.com>
Date: Fri, 18 Apr 2003 19:31:51 +0000
Subject: [Linux-ia64] palinfo.c changes
Message-Id: <marc-linux-ia64-105590723705568@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bjorn,
The patch below to palinfo.c is a backport of a 2.5 patch.
Is this something that could go into your 2.4 ia64 patch?

The first mail about it was:
    Date: Thu, 12 Dec 2002 14:49:10 +0100
    From: Christian Hildner <christian.hildner@hob.de>
    To: linux ia64 kernel list <linux-ia64@linuxia64.org>
    Subject: [Linux-ia64] [PATCH] fix /proc/.../vm_info

John Hesterberg


--- 2.4-ia64/arch/ia64/kernel/palinfo.c_1.8	Fri Apr 18 13:40:54 2003
+++ 2.4-sgi/arch/ia64/kernel/palinfo.c_1.9	Fri Apr 18 13:40:54 2003
@@ -101,26 +101,15 @@
 
 #define RSE_HINTS_COUNT (sizeof(rse_hints)/sizeof(const char *))
 
-/*
- * The current revision of the Volume 2 (July 2000) of
- * IA-64 Architecture Software Developer's Manual is wrong.
- * Table 4-10 has invalid information concerning the ma field:
- * Correct table is:
- *      bit 0 - 001 - UC
- *      bit 4 - 100 - UC
- *      bit 5 - 101 - UCE
- *      bit 6 - 110 - WC
- *      bit 7 - 111 - NatPage
- */
 static const char *mem_attrib[]={
-	"Write Back (WB)",		/* 000 */
-	"Uncacheable (UC)",		/* 001 */
-	"Reserved",			/* 010 */
-	"Reserved",			/* 011 */
-	"Uncacheable (UC)",		/* 100 */
-	"Uncacheable Exported (UCE)",	/* 101 */
-	"Write Coalescing (WC)",	/* 110 */
-	"NaTPage"			/* 111 */
+	"WB",		/* 000 */
+	"SW",		/* 001 */
+	"010",		/* 010 */
+	"011",		/* 011 */
+	"UC",		/* 100 */
+	"UCE",		/* 101 */
+	"WC",		/* 110 */
+	"NaTPage"	/* 111 */
 };
 
 /*
@@ -315,6 +304,7 @@
 	pal_vm_info_2_u_t vm_info_2;
 	pal_tc_info_u_t	tc_info;
 	ia64_ptce_info_t ptce;
+	const char *sep;
 	int i, j;
 	s64 status;
 
@@ -339,7 +329,15 @@
 
 	if (ia64_pal_mem_attrib(&attrib) != 0) return 0;
 
-	p += sprintf(p, "Supported memory attributes    : %s\n", mem_attrib[attrib&0x7]);
+	p += sprintf(p, "Supported memory attributes    : ");
+	sep = "";
+	for (i = 0; i < 8; i++) {
+		if (attrib & (1 << i)) {
+			p += sprintf(p, "%s%s", sep, mem_attrib[i]);
+			sep = ", ";
+		}
+	}
+	p += sprintf(p, "\n");
 
 	if ((status=ia64_pal_vm_page_size(&tr_pages, &vw_pages)) !=0) {
 		printk("ia64_pal_vm_page_size=%ld\n", status);

