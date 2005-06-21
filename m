From: Bob Picco <bob.picco@hp.com>
Date: Tue, 21 Jun 2005 10:22:34 +0000
Subject: [PATCH] pfn_to_nid
Message-Id: <20050621102234.GF23911@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

This didn't make it into -mm.  So current -mm is broken for the
same reason which previous -mm was broken. Below is the text from the original 
post. 

Bjorn posted on IRC a problem building 2.6.12-rc6-mm1. pfn_to_nid is undefined.
We haven't had this interface on ia64.  The problem was introduced in a recent
sys_mbind change.  Bjorn has compiled, linked and booted the patch for me.

Oh, the paddr_to_nid call could fail when DISCONTIG+NUMA is configured
because there isn't any ACPI SRAT NUMA information.

bob

Signed-off-by: Bob Picco <bob.picco@hp.com>


Index: linux-2.6.12-rc6-mm1/include/asm-ia64/mmzone.h
=================================--- linux-2.6.12-rc6-mm1.orig/include/asm-ia64/mmzone.h	2005-06-07 13:36:51.000000000 -0400
+++ linux-2.6.12-rc6-mm1/include/asm-ia64/mmzone.h	2005-06-07 14:48:17.000000000 -0400
@@ -15,6 +15,20 @@
 #include <asm/page.h>
 #include <asm/meminit.h>
 
+static inline int pfn_to_nid(unsigned long pfn)
+{
+#ifdef CONFIG_NUMA
+	extern int paddr_to_nid(unsigned long);
+	int nid = paddr_to_nid(pfn << PAGE_SHIFT);
+	if (nid < 0)
+		return 0;
+	else
+		return nid;
+#else
+	return 0;
+#endif
+}
+
 #ifdef CONFIG_DISCONTIGMEM
 
 #ifdef CONFIG_IA64_DIG /* DIG systems are small */
