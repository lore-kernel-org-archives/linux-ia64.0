From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 17 Nov 2004 19:33:57 +0000
Subject: [PATCH 2.6.10-rc2-mm1] Fix ia64 flush_tlb_page build error
Message-Id: <200411171233.57689.bjorn.helgaas@hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_le6mB9jUnagidf7"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_le6mB9jUnagidf7
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Fix ia64 build error: implicit declaration of function `flush_tlb_page'

--Boundary-00=_le6mB9jUnagidf7
Content-Type: text/x-diff;
  charset="us-ascii";
  name="flush_tlb_page-ia64-build-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="flush_tlb_page-ia64-build-fix.patch"

Fix ia64 build error: implicit declaration of function `flush_tlb_page'

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

--- a/mm/mempolicy.c.orig	2004-11-17 10:24:04.538856116 -0700
+++ b/mm/mempolicy.c	2004-11-17 10:42:06.584741299 -0700
@@ -80,6 +80,7 @@
 #include <linux/rmap.h>
 #include <linux/swap.h>
 #include <asm/pgalloc.h>
+#include <asm/tlbflush.h>
 #include <asm/uaccess.h>
 
 static kmem_cache_t *policy_cache;

--Boundary-00=_le6mB9jUnagidf7--
