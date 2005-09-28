From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 28 Sep 2005 21:50:50 +0000
Subject: [patch 2.6.14-rc2 5/6] swiotlb: file header comments
Message-Id: <09282005175050.10409@bilbo.tuxdriver.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <09282005175049.10344@bilbo.tuxdriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz
Cc: ak@suse.de, tony.luck@intel.com, Asit.K.Mallick@intel.com, gregkh@suse.de

Change comment at top of swiotlb.c to reflect that the code is shared
with EM64T (i.e. Intel x86_64). Also add an entry for myself so that
if I "broke it", everyone knows who "bought it"... :-)

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 lib/swiotlb.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/swiotlb.c b/lib/swiotlb.c
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -1,7 +1,7 @@
 /*
  * Dynamic DMA mapping support.
  *
- * This implementation is for IA-64 platforms that do not support
+ * This implementation is for IA-64 and EM64T platforms that do not support
  * I/O TLBs (aka DMA address translation hardware).
  * Copyright (C) 2000 Asit Mallick <Asit.K.Mallick@intel.com>
  * Copyright (C) 2000 Goutham Rao <goutham.rao@intel.com>
@@ -11,7 +11,9 @@
  * 03/05/07 davidm	Switch from PCI-DMA to generic device DMA API.
  * 00/12/13 davidm	Rename to swiotlb.c and add mark_clean() to avoid
  *			unnecessary i-cache flushing.
- * 04/07/.. ak          Better overflow handling. Assorted fixes.
+ * 04/07/.. ak		Better overflow handling. Assorted fixes.
+ * 05/09/10 linville	Add support for syncing ranges, support syncing for
+ *			DMA_BIDIRECTIONAL mappings, miscellaneous cleanup.
  */
 
 #include <linux/cache.h>
