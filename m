From: Christian Hildner <christian.hildner@hob.de>
Date: Thu, 12 Dec 2002 13:49:10 +0000
Subject: [Linux-ia64] [PATCH] fix /proc/.../vm_info
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------50CC7D09CE71AE2F0065E291"
Message-Id: <marc-linux-ia64-105590709805552@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

Dies ist eine mehrteilige Nachricht im MIME-Format.
--------------50CC7D09CE71AE2F0065E291
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

in vm_info the information about the supported memory attributes is
wrong. The patch  is based on 2.4.18, but it should also work for 2.4.20
and 2.5.x. Please apply.

Christian

--------------50CC7D09CE71AE2F0065E291
Content-Type: text/plain; charset=us-ascii;
 name="palinfo.c_patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="palinfo.c_patch"

--- palinfo.c_orig	Tue Mar 19 11:22:28 2002
+++ palinfo.c	Thu Dec 12 14:33:51 2002
@@ -113,14 +113,14 @@
  *      bit 7 - 111 - NatPage
  */
 static const char *mem_attrib[]={
-	"Write Back (WB)",		/* 000 */
-	"Uncacheable (UC)",		/* 001 */
-	"Reserved",			/* 010 */
-	"Reserved",			/* 011 */
-	"Uncacheable (UC)",		/* 100 */
-	"Uncacheable Exported (UCE)",	/* 101 */
-	"Write Coalescing (WC)",	/* 110 */
-	"NaTPage"			/* 111 */
+	"Write Back (WB) ma=000",		/* 000 */
+	"Uncacheable (UC) ma=001",		/* 001 */
+	"Reserved ma=010",			/* 010 */
+	"Reserved ma=011",			/* 011 */
+	"Uncacheable (UC) ma=100",		/* 100 */
+	"Uncacheable Exported (UCE) ma=101",	/* 101 */
+	"Write Coalescing (WC) ma=110",	/* 110 */
+	"NaTPage ma=111"			/* 111 */
 };
 
 /*
@@ -339,7 +339,15 @@
 
 	if (ia64_pal_mem_attrib(&attrib) != 0) return 0;
 
-	p += sprintf(p, "Supported memory attributes    : %s\n", mem_attrib[attrib&0x7]);
+	p += sprintf(p, "Supported memory attributes    : ");
+	j = 0;					// first line
+	for (i=0; i < 8; i++) {
+		if (attrib & (1 << i)) {
+			if (j) p += sprintf(p, "                                 ");
+			p += sprintf(p, "%s\n", mem_attrib[i]);
+			j = 1;
+		}
+	}
 
 	if ((status=ia64_pal_vm_page_size(&tr_pages, &vw_pages)) !=0) {
 		printk("ia64_pal_vm_page_size=%ld\n", status);
@@ -971,3 +979,7 @@
 
 module_init(palinfo_init);
 module_exit(palinfo_exit);
+
+
+
+

--------------50CC7D09CE71AE2F0065E291--


