From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 05:10:41 +0000
Subject: [PATCH 22/28] ia64/xen: mca paravirtualization
Message-Id: <12036570472598-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/mca.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 6e17aed..94f1023 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -339,11 +339,33 @@ typedef struct ia64_state_log_s
 
 static ia64_state_log_t ia64_state_log[IA64_MAX_LOG_TYPES];
 
+#ifdef CONFIG_XEN
+DEFINE_SPINLOCK(ia64_mca_xencomm_lock);
+LIST_HEAD(ia64_mca_xencomm_list);
+
+#define IA64_MCA_XENCOMM_ALLOCATE(rec, desc) \
+	if (is_running_on_xen()) { \
+		ia64_mca_xencomm_t *entry; \
+		entry = alloc_bootmem(sizeof(ia64_mca_xencomm_t)); \
+		entry->record = rec; \
+		entry->handle = desc; \
+		list_add(&entry->list, &ia64_mca_xencomm_list); \
+	}
+#define IA64_LOG_ALLOCATE(it, size) \
+	{ia64_err_rec_t *rec; \
+	ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)] = rec = \
+		(ia64_err_rec_t *)alloc_bootmem(size); \
+	IA64_MCA_XENCOMM_ALLOCATE(rec, xencomm_map(rec, size)); \
+	ia64_state_log[it].isl_log[IA64_LOG_NEXT_INDEX(it)] = rec = \
+		(ia64_err_rec_t *)alloc_bootmem(size); \
+	IA64_MCA_XENCOMM_ALLOCATE(rec, xencomm_map(rec, size));}
+#else
 #define IA64_LOG_ALLOCATE(it, size) \
 	{ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)] = \
 		(ia64_err_rec_t *)alloc_bootmem(size); \
 	ia64_state_log[it].isl_log[IA64_LOG_NEXT_INDEX(it)] = \
 		(ia64_err_rec_t *)alloc_bootmem(size);}
+#endif
 #define IA64_LOG_LOCK_INIT(it) spin_lock_init(&ia64_state_log[it].isl_lock)
 #define IA64_LOG_LOCK(it)      spin_lock_irqsave(&ia64_state_log[it].isl_lock, s)
 #define IA64_LOG_UNLOCK(it)    spin_unlock_irqrestore(&ia64_state_log[it].isl_lock,s)
-- 
1.5.3

