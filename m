From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Mon, 27 Feb 2006 20:12:17 +0000
Subject: [patch] Increase severity of MCA recovery messages
Message-Id: <200602272012.k1RKCHwW1469428@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Increase severity of MCA recovery messages

The MCA recovery messages are currently KERN_DEBUG,
so they don't show up in /var/log/messages (by default).
Increase the severity to KERN_CRIT, which is the 
severity used when the kernel kills out of memory 
processes.

Signed-off-by: Russ Anderson (rja@sgi.com)

---
 arch/ia64/kernel/mca_drv.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

Index: test/arch/ia64/kernel/mca_drv.c
=================================--- test.orig/arch/ia64/kernel/mca_drv.c	2006-02-24 14:01:34.000000000 -0600
+++ test/arch/ia64/kernel/mca_drv.c	2006-02-27 13:49:21.476589856 -0600
@@ -124,7 +124,7 @@ mca_page_isolate(unsigned long paddr)
 void
 mca_handler_bh(unsigned long paddr, void *iip, unsigned long ipsr)
 {
-	printk(KERN_DEBUG "OS_MCA: process [cpu %d, pid: %d, uid: %d, "
+	printk(KERN_CRIT "OS_MCA: process [cpu %d, pid: %d, uid: %d, "
 		"iip: %p, psr: 0x%lx,paddr: 0x%lx](%s) encounters MCA.\n",
 		raw_smp_processor_id(), current->pid, current->uid,
 		iip, ipsr, paddr, current->comm);
@@ -132,10 +132,10 @@ mca_handler_bh(unsigned long paddr, void
 	spin_lock(&mca_bh_lock);
 	switch (mca_page_isolate(paddr)) {
 	case ISOLATE_OK:
-		printk(KERN_DEBUG "Page isolation: ( %lx ) success.\n", paddr);
+		printk(KERN_CRIT "Page isolation: ( %lx ) success.\n", paddr);
 		break;
 	case ISOLATE_NG:
-		printk(KERN_DEBUG "Page isolation: ( %lx ) failure.\n", paddr);
+		printk(KERN_CRIT "Page isolation: ( %lx ) failure.\n", paddr);
 		break;
 	default:
 		break;
