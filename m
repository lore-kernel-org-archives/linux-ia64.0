From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 05:07:45 +0000
Subject: [PATCH 08/11] xen: replace callers of alloc_vm_area()/free_vm_area() with xen_ prefixed one.
Message-Id: <12036568693857-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12036568683779-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12036568683779-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, yamahata@valinux.co.jp

Don't use alloc_vm_area()/free_vm_area() directly, instead define
xen_alloc_vm_area()/xen_free_vm_area() and use them.

alloc_vm_area()/free_vm_area() are used to allocate/free area which
are for grant table mapping. Xen/x86 grant table is based on virtual
address so that alloc_vm_area()/free_vm_area() are suitable.
On the other hand Xen/ia64 (and Xen/powerpc) grant table is based on
pseudo physical address (guest physical address) so that allocation
should be done differently.
The original version of xenified Linux/IA64 have its own
allocate_vm_area()/free_vm_area() definitions which don't allocate vm area
contradictory to those names.
Now vanilla Linux already has its definitions so that it's impossible
to have IA64 definitions of allocate_vm_area()/free_vm_area().
Instead introduce xen_allocate_vm_area()/xen_free_vm_area() and use them.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 drivers/xen/grant-table.c          |    2 +-
 drivers/xen/xenbus/xenbus_client.c |    6 +++---
 include/asm-x86/xen/hypervisor.h   |    3 +++
 3 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/xen/grant-table.c b/drivers/xen/grant-table.c
index 95016fd..9fcde20 100644
--- a/drivers/xen/grant-table.c
+++ b/drivers/xen/grant-table.c
@@ -478,7 +478,7 @@ static int gnttab_map(unsigned int start_idx, unsigned int end_idx)
 
 	if (shared = NULL) {
 		struct vm_struct *area;
-		area = alloc_vm_area(PAGE_SIZE * max_nr_grant_frames());
+		area = xen_alloc_vm_area(PAGE_SIZE * max_nr_grant_frames());
 		BUG_ON(area = NULL);
 		shared = area->addr;
 	}
diff --git a/drivers/xen/xenbus/xenbus_client.c b/drivers/xen/xenbus/xenbus_client.c
index 9fd2f70..0f86b0f 100644
--- a/drivers/xen/xenbus/xenbus_client.c
+++ b/drivers/xen/xenbus/xenbus_client.c
@@ -399,7 +399,7 @@ int xenbus_map_ring_valloc(struct xenbus_device *dev, int gnt_ref, void **vaddr)
 
 	*vaddr = NULL;
 
-	area = alloc_vm_area(PAGE_SIZE);
+	area = xen_alloc_vm_area(PAGE_SIZE);
 	if (!area)
 		return -ENOMEM;
 
@@ -409,7 +409,7 @@ int xenbus_map_ring_valloc(struct xenbus_device *dev, int gnt_ref, void **vaddr)
 		BUG();
 
 	if (op.status != GNTST_okay) {
-		free_vm_area(area);
+		xen_free_vm_area(area);
 		xenbus_dev_fatal(dev, op.status,
 				 "mapping in shared page %d from domain %d",
 				 gnt_ref, dev->otherend_id);
@@ -508,7 +508,7 @@ int xenbus_unmap_ring_vfree(struct xenbus_device *dev, void *vaddr)
 		BUG();
 
 	if (op.status = GNTST_okay)
-		free_vm_area(area);
+		xen_free_vm_area(area);
 	else
 		xenbus_dev_error(dev, op.status,
 				 "unmapping page at handle %d error %d",
diff --git a/include/asm-x86/xen/hypervisor.h b/include/asm-x86/xen/hypervisor.h
index 138ee8a..31836ad 100644
--- a/include/asm-x86/xen/hypervisor.h
+++ b/include/asm-x86/xen/hypervisor.h
@@ -57,6 +57,9 @@ extern struct shared_info *HYPERVISOR_shared_info;
 extern struct start_info *xen_start_info;
 #define is_initial_xendomain() (xen_start_info->flags & SIF_INITDOMAIN)
 
+#define xen_alloc_vm_area(size)	alloc_vm_area(size)
+#define xen_free_vm_area(area)	free_vm_area(area)
+
 /* arch/i386/mach-xen/evtchn.c */
 /* Force a proper event-channel callback from Xen. */
 extern void force_evtchn_callback(void);
-- 
1.5.3

