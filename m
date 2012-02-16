From: Masanari Iida <standby24x7@gmail.com>
Date: Thu, 16 Feb 2012 13:20:03 +0000
Subject: [PATCH] [trivial] ia64: Fix typo in irq_xen.c
Message-Id: <1329398403-1701-1-git-send-email-standby24x7@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, linux-ia64@vger.kernel.org
Cc: trivial@kernel.org, linux-kernel@vger.kernel.org, standby24x7@gmail.com

Correct spelling "vecotr" to "vector" in
arch/ia64/xen/irq_xen.c

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 arch/ia64/xen/irq_xen.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/xen/irq_xen.c b/arch/ia64/xen/irq_xen.c
index b279e14..3bb1223 100644
--- a/arch/ia64/xen/irq_xen.c
+++ b/arch/ia64/xen/irq_xen.c
@@ -58,7 +58,7 @@ xen_free_irq_vector(int vector)
 
 	irq_op.vector = vector;
 	if (HYPERVISOR_physdev_op(PHYSDEVOP_free_irq_vector, &irq_op))
-		printk(KERN_WARNING "%s: xen_free_irq_vecotr fail vector=%d\n",
+		printk(KERN_WARNING "%s: xen_free_irq_vector fail vector=%d\n",
 		       __func__, vector);
 }
 
-- 
1.7.4.4

