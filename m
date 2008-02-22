From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 05:07:40 +0000
Subject: [PATCH 03/11] xen: add missing definitions for xen grant table which ia64/xen needs.
Message-Id: <12036568694177-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12036568683779-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12036568683779-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, yamahata@valinux.co.jp


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 drivers/xen/grant-table.c           |    2 +-
 include/asm-x86/xen/interface.h     |   24 ++++++++++++++++++++++++
 include/xen/interface/grant_table.h |   11 ++++++++---
 3 files changed, 33 insertions(+), 4 deletions(-)

diff --git a/drivers/xen/grant-table.c b/drivers/xen/grant-table.c
index ea94dba..95016fd 100644
--- a/drivers/xen/grant-table.c
+++ b/drivers/xen/grant-table.c
@@ -466,7 +466,7 @@ static int gnttab_map(unsigned int start_idx, unsigned int end_idx)
 
 	setup.dom        = DOMID_SELF;
 	setup.nr_frames  = nr_gframes;
-	setup.frame_list = frames;
+	set_xen_guest_handle(setup.frame_list, frames);
 
 	rc = HYPERVISOR_grant_table_op(GNTTABOP_setup_table, &setup, 1);
 	if (rc = -ENOSYS) {
diff --git a/include/asm-x86/xen/interface.h b/include/asm-x86/xen/interface.h
index 165c396..49993dd 100644
--- a/include/asm-x86/xen/interface.h
+++ b/include/asm-x86/xen/interface.h
@@ -22,6 +22,30 @@
 #define DEFINE_GUEST_HANDLE(name) __DEFINE_GUEST_HANDLE(name, name)
 #define GUEST_HANDLE(name)        __guest_handle_ ## name
 
+#ifdef __XEN__
+#if defined(__i386__)
+#define set_xen_guest_handle(hnd, val)			\
+	do {						\
+		if (sizeof(hnd) = 8)			\
+			*(uint64_t *)&(hnd) = 0;	\
+		(hnd).p = val;				\
+	} while (0)
+#elif defined(__x86_64__)
+#define set_xen_guest_handle(hnd, val)	do { (hnd).p = val; } while (0)
+#endif
+#else
+#if defined(__i386__)
+#define set_xen_guest_handle(hnd, val)			\
+	do {						\
+		if (sizeof(hnd) = 8)			\
+			*(uint64_t *)&(hnd) = 0;	\
+		(hnd) = val;				\
+	} while (0)
+#elif defined(__x86_64__)
+#define set_xen_guest_handle(hnd, val)	do { (hnd) = val; } while (0)
+#endif
+#endif
+
 #ifndef __ASSEMBLY__
 /* Guest handles for primitive C types. */
 __DEFINE_GUEST_HANDLE(uchar, unsigned char);
diff --git a/include/xen/interface/grant_table.h b/include/xen/interface/grant_table.h
index 2190498..39da93c 100644
--- a/include/xen/interface/grant_table.h
+++ b/include/xen/interface/grant_table.h
@@ -185,6 +185,7 @@ struct gnttab_map_grant_ref {
     grant_handle_t handle;
     uint64_t dev_bus_addr;
 };
+DEFINE_GUEST_HANDLE_STRUCT(gnttab_map_grant_ref);
 
 /*
  * GNTTABOP_unmap_grant_ref: Destroy one or more grant-reference mappings
@@ -206,6 +207,7 @@ struct gnttab_unmap_grant_ref {
     /* OUT parameters. */
     int16_t  status;              /* GNTST_* */
 };
+DEFINE_GUEST_HANDLE_STRUCT(gnttab_unmap_grant_ref);
 
 /*
  * GNTTABOP_setup_table: Set up a grant table for <dom> comprising at least
@@ -223,8 +225,9 @@ struct gnttab_setup_table {
     uint32_t nr_frames;
     /* OUT parameters. */
     int16_t  status;              /* GNTST_* */
-    ulong *frame_list;
+    GUEST_HANDLE(ulong) frame_list;
 };
+DEFINE_GUEST_HANDLE_STRUCT(gnttab_setup_table);
 
 /*
  * GNTTABOP_dump_table: Dump the contents of the grant table to the
@@ -237,6 +240,7 @@ struct gnttab_dump_table {
     /* OUT parameters. */
     int16_t status;               /* GNTST_* */
 };
+DEFINE_GUEST_HANDLE_STRUCT(gnttab_dump_table);
 
 /*
  * GNTTABOP_transfer_grant_ref: Transfer <frame> to a foreign domain. The
@@ -255,7 +259,7 @@ struct gnttab_transfer {
     /* OUT parameters. */
     int16_t       status;
 };
-
+DEFINE_GUEST_HANDLE_STRUCT(gnttab_transfer);
 
 /*
  * GNTTABOP_copy: Hypervisor based copy
@@ -296,6 +300,7 @@ struct gnttab_copy {
 	/* OUT parameters. */
 	int16_t       status;
 };
+DEFINE_GUEST_HANDLE_STRUCT(gnttab_copy);
 
 /*
  * GNTTABOP_query_size: Query the current and maximum sizes of the shared
@@ -313,7 +318,7 @@ struct gnttab_query_size {
     uint32_t max_nr_frames;
     int16_t  status;              /* GNTST_* */
 };
-
+DEFINE_GUEST_HANDLE_STRUCT(gnttab_query_size);
 
 /*
  * Bitfield values for update_pin_status.flags.
-- 
1.5.3

