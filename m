From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 12 Dec 2002 19:56:14 +0000
Subject: Re: [Linux-ia64] [PATCH] fix /proc/.../vm_info
Message-Id: <marc-linux-ia64-105590709805556@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805552@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805552@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 12 Dec 2002 14:49:10 +0100, Christian Hildner <christian.hildner@hob.de> said:

  Christian> Hi, in vm_info the information about the supported memory
  Christian> attributes is wrong. The patch is based on 2.4.18, but it
  Christian> should also work for 2.4.20 and 2.5.x. Please apply.

I'd like to keep the output a bit more concise.  How about the attached
patch (untested)?

	--david

=== arch/ia64/kernel/palinfo.c 1.7 vs edited ==--- 1.7/arch/ia64/kernel/palinfo.c	Sun Dec  1 22:17:31 2002
+++ edited/arch/ia64/kernel/palinfo.c	Thu Dec 12 11:54:24 2002
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
+	"UC",		/* 001 */
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
 
@@ -339,7 +329,14 @@
 
 	if (ia64_pal_mem_attrib(&attrib) != 0) return 0;
 
-	p += sprintf(p, "Supported memory attributes    : %s\n", mem_attrib[attrib&0x7]);
+	p += sprintf(p, "Supported memory attributes    : ");
+	sep = "";
+	for (i = 0; i < 8; i++) {
+		if (attrib & (1 << i)) {
+			p += sprintf(p, "%s%s\n", sep, mem_attrib[i]);
+			sep = ", ";
+		}
+	}
 
 	if ((status=ia64_pal_vm_page_size(&tr_pages, &vw_pages)) !=0) {
 		printk("ia64_pal_vm_page_size=%ld\n", status);

