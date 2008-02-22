From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 05:10:42 +0000
Subject: [PATCH 23/28] ia64/xen: sal paravirtualization.
Message-Id: <12036570473013-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/salinfo.c |   44 ++++++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/sal.h     |   36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 80 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/salinfo.c b/arch/ia64/kernel/salinfo.c
index 779c3cc..91bc631 100644
--- a/arch/ia64/kernel/salinfo.c
+++ b/arch/ia64/kernel/salinfo.c
@@ -378,6 +378,25 @@ salinfo_log_open(struct inode *inode, struct file *file)
 		data->open = 0;
 		return -ENOMEM;
 	}
+#ifdef CONFIG_XEN
+	if (is_running_on_xen()) {
+		ia64_mca_xencomm_t *entry;
+		unsigned long flags;
+
+		entry = vmalloc(sizeof(ia64_mca_xencomm_t));
+		if (!entry) {
+			data->open = 0;
+			vfree(data->log_buffer);
+			return -ENOMEM;
+		}
+		entry->record = data->log_buffer;
+		entry->handle = xencomm_map(data->log_buffer,
+					ia64_sal_get_state_info_size(data->type));
+		spin_lock_irqsave(&ia64_mca_xencomm_lock, flags);
+		list_add(&entry->list, &ia64_mca_xencomm_list);
+		spin_unlock_irqrestore(&ia64_mca_xencomm_lock, flags);
+	}
+#endif
 
 	return 0;
 }
@@ -389,6 +408,31 @@ salinfo_log_release(struct inode *inode, struct file *file)
 	struct salinfo_data *data = entry->data;
 
 	if (data->state = STATE_NO_DATA) {
+#ifdef CONFIG_XEN
+		if (is_running_on_xen()) {
+			struct list_head *pos, *n;
+			ia64_mca_xencomm_t *found_entry = NULL;
+			unsigned long flags;
+
+			spin_lock_irqsave(&ia64_mca_xencomm_lock, flags);
+			list_for_each_safe(pos, n, &ia64_mca_xencomm_list) {
+				ia64_mca_xencomm_t *entry;
+
+				entry = list_entry(pos, ia64_mca_xencomm_t,
+						   list);
+				if (entry->record = data->log_buffer) {
+					list_del(&entry->list);
+					found_entry = entry;
+					break;
+				}
+			}
+			spin_unlock_irqrestore(&ia64_mca_xencomm_lock, flags);
+			if (found_entry) {
+				xencomm_free(found_entry->handle);
+				vfree(found_entry);
+			}
+		}
+#endif
 		vfree(data->log_buffer);
 		vfree(data->oemdata);
 		data->log_buffer = NULL;
diff --git a/include/asm-ia64/sal.h b/include/asm-ia64/sal.h
index 2251118..3c20a58 100644
--- a/include/asm-ia64/sal.h
+++ b/include/asm-ia64/sal.h
@@ -42,6 +42,9 @@
 #include <asm/pal.h>
 #include <asm/system.h>
 #include <asm/fpu.h>
+#ifdef CONFIG_XEN
+#include <asm/xen/xencomm.h>
+#endif
 
 extern spinlock_t sal_lock;
 
@@ -679,10 +682,43 @@ ia64_sal_clear_state_info (u64 sal_info_type)
 /* Get the processor and platform information logged by SAL with respect to the machine
  * state at the time of the MCAs, INITs, CMCs, or CPEs.
  */
+#ifdef CONFIG_XEN
+static inline u64 ia64_sal_get_state_info_size (u64 sal_info_type);
+typedef struct ia64_mca_xencomm_t {
+	void *record;
+	struct xencomm_handle *handle;
+	struct list_head list;
+} ia64_mca_xencomm_t;
+extern struct list_head ia64_mca_xencomm_list;
+extern spinlock_t ia64_mca_xencomm_lock;
+#endif
+
 static inline u64
 ia64_sal_get_state_info (u64 sal_info_type, u64 *sal_info)
 {
 	struct ia64_sal_retval isrv;
+#ifdef CONFIG_XEN
+	if (is_running_on_xen()) {
+		ia64_mca_xencomm_t *entry;
+		struct xencomm_handle *desc = NULL;
+		unsigned long flags;
+
+		spin_lock_irqsave(&ia64_mca_xencomm_lock, flags);
+		list_for_each_entry(entry, &ia64_mca_xencomm_list, list) {
+			if (entry->record = sal_info) {
+				desc = entry->handle;
+				break;
+			}
+		}
+		spin_unlock_irqrestore(&ia64_mca_xencomm_lock, flags);
+
+		if (desc = NULL)
+			return 0;
+
+		SAL_CALL_REENTRANT(isrv, SAL_GET_STATE_INFO, sal_info_type, 0,
+				   desc, 0, 0, 0, 0);
+	} else
+#endif
 	SAL_CALL_REENTRANT(isrv, SAL_GET_STATE_INFO, sal_info_type, 0,
 	              sal_info, 0, 0, 0, 0);
 	if (isrv.status)
-- 
1.5.3

