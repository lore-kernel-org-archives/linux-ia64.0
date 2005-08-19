From: Greg Edwards <edwardsg@sgi.com>
Date: Fri, 19 Aug 2005 21:52:18 +0000
Subject: clean up sn2 region definitions
Message-Id: <20050819215218.GA21689@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Clean up some region definitions we had in sn2 code.  Requires Peter's
patch:

Rationalise Region Definitions
http://marc.theaimsgroup.com/?l=linux-ia64&m2424745806814&w=2

Signed-off-by: Greg Edwards <edwardsg@sgi.com>


 include/asm-ia64/sn/addrs.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

Index: git-linus/include/asm-ia64/sn/addrs.h
=================================--- git-linus.orig/include/asm-ia64/sn/addrs.h	2005-08-19 16:06:57.517692735 -0500
+++ git-linus/include/asm-ia64/sn/addrs.h	2005-08-19 16:12:34.967177871 -0500
@@ -65,7 +65,7 @@
 
 #define NASID_MASK              ((u64)NASID_BITMASK << NASID_SHIFT)
 #define AS_MASK			((u64)AS_BITMASK << AS_SHIFT)
-#define REGION_BITS		0xe000000000000000UL
+#define REGION_BITS		RGN_BASE(KHIGH)
 
 
 /*
@@ -82,9 +82,9 @@
 /*
  * Base addresses for various address ranges.
  */
-#define CACHED			0xe000000000000000UL
-#define UNCACHED                0xc000000000000000UL
-#define UNCACHED_PHYS           0x8000000000000000UL
+#define CACHED			RGN_BASE(RGN_KERNEL)
+#define UNCACHED                RGN_BASE(RGN_UNCACHED)
+#define UNCACHED_PHYS           RGN_BASE(RGN_HPAGE)
 
 
 /* 
