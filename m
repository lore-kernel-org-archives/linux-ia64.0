From: John Levon <levon@movementarian.org>
Date: Wed, 08 Oct 2003 14:20:02 +0000
Subject: [PATCH] small cleanups + fixes for perfmon.c
Message-Id: <marc-linux-ia64-106562332002217@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The following patch, compile-tested only so far, does the following :

o removes the [UN]LOCK_BUF_FMT_LIST defines - there is no abstraction
  benefit to them, and they just look ugly
o fixes two KERN_ERR that should be KERN_INFO
o removes the "nolock" parameter to the find function (was unused)
o homogenises the names related to buffer formats
o removes the hand-crafted list in favour of standard linux list methods
o reduces code duplication

OK ?

regards
john

Index: linux-ia64/arch/ia64/kernel/perfmon.c
=================================RCS file: /home/cvs/linux-2.5/arch/ia64/kernel/perfmon.c,v
retrieving revision 1.35
diff -u -a -p -r1.35 perfmon.c
--- linux-ia64/arch/ia64/kernel/perfmon.c	19 Sep 2003 21:01:14 -0000	1.35
+++ linux-ia64/arch/ia64/kernel/perfmon.c	8 Oct 2003 12:21:04 -0000
@@ -513,10 +513,8 @@ static pfm_session_t		pfm_sessions;	/* g
 static struct proc_dir_entry 	*perfmon_dir;
 static pfm_uuid_t		pfm_null_uuid = {0,};
 
-static spinlock_t		pfm_smpl_fmt_lock;
-static pfm_buffer_fmt_t		*pfm_buffer_fmt_list;
-#define LOCK_BUF_FMT_LIST()	    spin_lock(&pfm_smpl_fmt_lock)
-#define UNLOCK_BUF_FMT_LIST()	    spin_unlock(&pfm_smpl_fmt_lock)
+static spinlock_t		pfm_buffer_fmt_lock;
+static LIST_HEAD(pfm_buffer_fmt_list);
 
 /* sysctl() controls */
 static pfm_sysctl_t pfm_sysctl;
@@ -1206,12 +1204,36 @@ pfm_buf_fmt_restart_active(pfm_buffer_fm
 	return ret;
 }
 
+static pfm_buffer_fmt_t *
+__pfm_find_buffer_fmt(pfm_uuid_t uuid)
+{
+	struct list_head * pos;
+	pfm_buffer_fmt_t * entry;
+
+	list_for_each(pos, &pfm_buffer_fmt_list) {
+		entry = list_entry(pos, pfm_buffer_fmt_t, fmt_list);
+		if (pfm_uuid_cmp(uuid, entry->fmt_uuid) = 0)
+			return entry;
+	}
+	return NULL;
+}
 
+/*
+ * find a buffer format based on its uuid
+ */
+static pfm_buffer_fmt_t *
+pfm_find_buffer_fmt(pfm_uuid_t uuid)
+{
+	pfm_buffer_fmt_t * fmt;
+	spin_lock(&pfm_buffer_fmt_lock);
+	fmt = __pfm_find_buffer_fmt(uuid);
+	spin_unlock(&pfm_buffer_fmt_lock);
+	return fmt;
+}
 
 int
 pfm_register_buffer_fmt(pfm_buffer_fmt_t *fmt)
 {
-	pfm_buffer_fmt_t *p;
 	int ret = 0;
 
 	/* some sanity checks */
@@ -1224,78 +1246,43 @@ pfm_register_buffer_fmt(pfm_buffer_fmt_t
 	 * XXX: need check validity of fmt_arg_size
 	 */
 
-	LOCK_BUF_FMT_LIST();
-	p = pfm_buffer_fmt_list;
-
-
-	while (p) {
-		if (pfm_uuid_cmp(fmt->fmt_uuid, p->fmt_uuid) = 0) break;
-		p = p->fmt_next;
-	}
+	spin_lock(&pfm_buffer_fmt_lock);
 
-	if (p) {
+	if (__pfm_find_buffer_fmt(fmt->fmt_uuid)) {
 		printk(KERN_ERR "perfmon: duplicate sampling format: %s\n", fmt->fmt_name);
 		ret = -EBUSY;
-	} else {
-		fmt->fmt_prev = NULL;
-		fmt->fmt_next = pfm_buffer_fmt_list;
-		pfm_buffer_fmt_list = fmt;
-		printk(KERN_ERR "perfmon: added sampling format %s\n", fmt->fmt_name);
+		goto out;
 	}
-	UNLOCK_BUF_FMT_LIST();
 
+	list_add(&fmt->fmt_list, &pfm_buffer_fmt_list);
+	printk(KERN_INFO "perfmon: added sampling format %s\n", fmt->fmt_name);
+
+out:
+	spin_unlock(&pfm_buffer_fmt_lock);
 	return ret;
 }
 
 int
 pfm_unregister_buffer_fmt(pfm_uuid_t uuid)
 {
-	pfm_buffer_fmt_t *p;
+	pfm_buffer_fmt_t *fmt;
 	int ret = 0;
 
-	LOCK_BUF_FMT_LIST();
-	p = pfm_buffer_fmt_list;
-	while (p) {
-		if (memcmp(uuid, p->fmt_uuid, sizeof(pfm_uuid_t)) = 0) break;
-		p = p->fmt_next;
-	}
-	if (p) {
-		if (p->fmt_prev)
-			p->fmt_prev->fmt_next = p->fmt_next;
-		else
-			pfm_buffer_fmt_list = p->fmt_next;
-
-		if (p->fmt_next)
-			p->fmt_next->fmt_prev = p->fmt_prev;
+	spin_lock(&pfm_buffer_fmt_lock);
 
-		printk(KERN_ERR "perfmon: removed sampling format: %s\n",  p->fmt_name);
-		p->fmt_next = p->fmt_prev = NULL;
-	} else {
+	fmt = __pfm_find_buffer_fmt(uuid);
+	if (!fmt) {
 		printk(KERN_ERR "perfmon: cannot unregister format, not found\n");
 		ret = -EINVAL;
+		goto out;
 	}
-	UNLOCK_BUF_FMT_LIST();
 
-	return ret;
+	list_del_init(&fmt->fmt_list);
+	printk(KERN_INFO "perfmon: removed sampling format: %s\n", fmt->fmt_name);
 
-}
-
-/*
- * find a buffer format based on its uuid
- */
-static pfm_buffer_fmt_t *
-pfm_find_buffer_fmt(pfm_uuid_t uuid, int nolock)
-{
-	pfm_buffer_fmt_t *p;
-
-	LOCK_BUF_FMT_LIST();
-	for (p = pfm_buffer_fmt_list; p ; p = p->fmt_next) {
-		if (pfm_uuid_cmp(uuid, p->fmt_uuid) = 0) break;
-	}
-
-	UNLOCK_BUF_FMT_LIST();
-
-	return p;
+out:
+	spin_unlock(&pfm_buffer_fmt_lock);
+	return ret;
 }
 
 static int
@@ -2419,8 +2406,7 @@ pfm_setup_buffer_fmt(struct task_struct 
 	int ret = 0;
 #define PFM_CTXARG_BUF_ARG(a)	(pfm_buffer_fmt_t *)(a+1)
 
-	/* invoke and lock buffer format, if found */
-	fmt = pfm_find_buffer_fmt(arg->ctx_smpl_buf_id, 0);
+	fmt = pfm_find_buffer_fmt(arg->ctx_smpl_buf_id);
 	if (fmt = NULL) {
 		DPRINT(("[%d] cannot find buffer format\n", task->pid));
 		return -EINVAL;
@@ -2528,8 +2514,7 @@ pfm_ctx_getsize(void *arg, size_t *sz)
 
 	if (!pfm_uuid_cmp(req->ctx_smpl_buf_id, pfm_null_uuid)) return 0;
 
-	/* no buffer locking here, will be called again */
-	fmt = pfm_find_buffer_fmt(req->ctx_smpl_buf_id, 1);
+	fmt = pfm_find_buffer_fmt(req->ctx_smpl_buf_id);
 	if (fmt = NULL) {
 		DPRINT(("cannot find buffer format\n"));
 		return -EINVAL;
@@ -5445,7 +5430,8 @@ static int
 pfm_proc_info(char *page)
 {
 	char *p = page;
-	pfm_buffer_fmt_t *b;
+	struct list_head * pos;
+	pfm_buffer_fmt_t * entry;
 	unsigned long psr;
 	int i;
 
@@ -5495,29 +5481,30 @@ pfm_proc_info(char *page)
 			pfm_sessions.pfs_ptrace_use_dbregs);
 	UNLOCK_PFS();
 
-	LOCK_BUF_FMT_LIST();
+	spin_lock(&pfm_buffer_fmt_lock);
 
-	for (b = pfm_buffer_fmt_list; b ; b = b->fmt_next) {
+	list_for_each(pos, &pfm_buffer_fmt_list) {
+		entry = list_entry(pos, pfm_buffer_fmt_t, fmt_list);
 		p += sprintf(p, "format                    : %02x-%02x-%02x-%02x-%02x-%02x-%02x-%02x-%02x-%02x-%02x-%02x-%02x-%02x-%02x-%02x %s\n",
-				b->fmt_uuid[0],
-				b->fmt_uuid[1],
-				b->fmt_uuid[2],
-				b->fmt_uuid[3],
-				b->fmt_uuid[4],
-				b->fmt_uuid[5],
-				b->fmt_uuid[6],
-				b->fmt_uuid[7],
-				b->fmt_uuid[8],
-				b->fmt_uuid[9],
-				b->fmt_uuid[10],
-				b->fmt_uuid[11],
-				b->fmt_uuid[12],
-				b->fmt_uuid[13],
-				b->fmt_uuid[14],
-				b->fmt_uuid[15],
-				b->fmt_name);
+				entry->fmt_uuid[0],
+				entry->fmt_uuid[1],
+				entry->fmt_uuid[2],
+				entry->fmt_uuid[3],
+				entry->fmt_uuid[4],
+				entry->fmt_uuid[5],
+				entry->fmt_uuid[6],
+				entry->fmt_uuid[7],
+				entry->fmt_uuid[8],
+				entry->fmt_uuid[9],
+				entry->fmt_uuid[10],
+				entry->fmt_uuid[11],
+				entry->fmt_uuid[12],
+				entry->fmt_uuid[13],
+				entry->fmt_uuid[14],
+				entry->fmt_uuid[15],
+				entry->fmt_name);
 	}
-	UNLOCK_BUF_FMT_LIST();
+	spin_unlock(&pfm_buffer_fmt_lock);
 
 	return p - page;
 }
@@ -6338,7 +6325,7 @@ pfm_init(void)
 	 * initialize all our spinlocks
 	 */
 	spin_lock_init(&pfm_sessions.pfs_lock);
-	spin_lock_init(&pfm_smpl_fmt_lock);
+	spin_lock_init(&pfm_buffer_fmt_lock);
 
 	init_pfm_fs();
 
Index: linux-ia64/include/asm-ia64//perfmon.h
=================================RCS file: /home/cvs/linux-2.5/include/asm-ia64/perfmon.h,v
retrieving revision 1.13
diff -u -a -p -r1.13 perfmon.h
--- linux-ia64/include/asm-ia64//perfmon.h	22 Aug 2003 00:40:41 -0000	1.13
+++ linux-ia64/include/asm-ia64//perfmon.h	8 Oct 2003 12:21:53 -0000
@@ -223,7 +223,7 @@ typedef struct {
 } pfm_ovfl_arg_t;
 
 
-typedef struct _pfm_buffer_fmt_t {
+typedef struct {
 	char		*fmt_name;
 	pfm_uuid_t	fmt_uuid;
 	size_t		fmt_arg_size;
@@ -237,8 +237,7 @@ typedef struct _pfm_buffer_fmt_t {
 	int		(*fmt_restart_active)(struct task_struct *task, pfm_ovfl_ctrl_t *ctrl, void *buf, struct pt_regs *regs);
 	int		(*fmt_exit)(struct task_struct *task, void *buf, struct pt_regs *regs);
 
-	struct _pfm_buffer_fmt_t *fmt_next;
-	struct _pfm_buffer_fmt_t *fmt_prev;
+	struct list_head fmt_list;
 } pfm_buffer_fmt_t;
 
 extern int pfm_register_buffer_fmt(pfm_buffer_fmt_t *fmt);
