From: Jack Steiner <steiner@sgi.com>
Date: Tue, 27 Sep 2005 13:25:32 +0000
Subject: [PATCH] - Increase max system size of SGI SN systems
Message-Id: <20050927132532.GA1133@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Increase the maximum system size of SGI SN systems. Note that
this is not the maximum SSI size. The maximum system size is
the number of nodes in the numalink domain.


	Signed-off-by: Jack Steiner <steiner@sgi.com>




Index: linux/include/asm-ia64/sn/arch.h
=================================--- linux.orig/include/asm-ia64/sn/arch.h	2005-09-26 21:05:31.067476367 -0500
+++ linux/include/asm-ia64/sn/arch.h	2005-09-27 08:04:43.866202191 -0500
@@ -41,7 +41,7 @@
  * This value is also the value of the maximum number of NASIDs in the numalink
  * fabric.
  */
-#define MAX_NUMALINK_NODES	2048
+#define MAX_NUMALINK_NODES	16384
 
 /*
  * The following defines attributes of the HUB chip. These attributes are
