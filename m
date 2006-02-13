From: Jes Sorensen <jes@sgi.com>
Date: Mon, 13 Feb 2006 10:35:01 +0000
Subject: [patch] remove compile time warning
Message-Id: <yq0oe1by2ay.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

This one falls into the present for Andrew Morton category to address
his wishlist for a compiler warning free build ;-)

Cheers,
Jes

 arch/ia64/sn/kernel/setup.c |    2 ++
 1 files changed, 2 insertions(+)

Index: linux-2.6/arch/ia64/sn/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/setup.c
+++ linux-2.6/arch/ia64/sn/kernel/setup.c
@@ -317,6 +317,7 @@
 #define PCDP_PCI_TRANS_IOPORT	0x02
 #define PCDP_PCI_TRANS_MMIO	0x01
 
+#if defined(CONFIG_VT) && defined(CONFIG_VGA_CONSOLE)
 static void
 sn_scan_pcdp(void)
 {
@@ -358,6 +359,7 @@
 		break; /* once we find the primary, we're done */
 	}
 }
+#endif
 
 static unsigned long sn2_rtc_initial;
 
