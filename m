From: Al Viro <viro@ftp.linux.org.uk>
Date: Sun, 27 Apr 2008 01:18:02 +0000
Subject: [PATCH] fix file and descriptor handling in perfmon
Message-Id: <E1JpvWk-0003lk-FT@ZenIV.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org


Please, review; if there's no objections, to Linus it goes, along with
the rest of arch/* files_struct sanitizing.

Races galore...  General rule: as soon as it's in descriptor table,
it's over; another thread might have started IO on it/dup2() it
elsewhere/dup2() something *over* it/etc.  fd_install() is the very
last step one should take - it's a point of no return.

Besides, the damn thing leaked on failure exits...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 arch/ia64/kernel/perfmon.c |  198 +++++++++++++++++++-------------------------
 1 files changed, 86 insertions(+), 112 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index c8e4037..520749b 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -867,7 +867,7 @@ pfm_rvfree(void *mem, unsigned long size)
 }
 
 static pfm_context_t *
-pfm_context_alloc(void)
+pfm_context_alloc(int ctx_flags)
 {
 	pfm_context_t *ctx;
 
@@ -878,6 +878,46 @@ pfm_context_alloc(void)
 	ctx = kzalloc(sizeof(pfm_context_t), GFP_KERNEL);
 	if (ctx) {
 		DPRINT(("alloc ctx @%p\n", ctx));
+
+		/*
+		 * init context protection lock
+		 */
+		spin_lock_init(&ctx->ctx_lock);
+
+		/*
+		 * context is unloaded
+		 */
+		ctx->ctx_state = PFM_CTX_UNLOADED;
+
+		/*
+		 * initialization of context's flags
+		 */
+		ctx->ctx_fl_block       = (ctx_flags & PFM_FL_NOTIFY_BLOCK) ? 1 : 0;
+		ctx->ctx_fl_system      = (ctx_flags & PFM_FL_SYSTEM_WIDE) ? 1: 0;
+		ctx->ctx_fl_no_msg      = (ctx_flags & PFM_FL_OVFL_NO_MSG) ? 1: 0;
+		/*
+		 * will move to set properties
+		 * ctx->ctx_fl_excl_idle   = (ctx_flags & PFM_FL_EXCL_IDLE) ? 1: 0;
+		 */
+
+		/*
+		 * init restart semaphore to locked
+		 */
+		init_completion(&ctx->ctx_restart_done);
+
+		/*
+		 * activation is used in SMP only
+		 */
+		ctx->ctx_last_activation = PFM_INVALID_ACTIVATION;
+		SET_LAST_CPU(ctx, -1);
+
+		/*
+		 * initialize notification message queue
+		 */
+		ctx->ctx_msgq_head = ctx->ctx_msgq_tail = 0;
+		init_waitqueue_head(&ctx->ctx_msgq_wait);
+		init_waitqueue_head(&ctx->ctx_zombieq);
+
 	}
 	return ctx;
 }
@@ -2165,28 +2205,20 @@ static struct dentry_operations pfmfs_dentry_operations = {
 };
 
 
-static int
-pfm_alloc_fd(struct file **cfile)
+static struct file *pfm_alloc_file(pfm_context_t *ctx)
 {
-	int fd, ret = 0;
-	struct file *file = NULL;
-	struct inode * inode;
+	struct file *file;
+	struct inode *inode;
+	struct dentry *dentry;
 	char name[32];
 	struct qstr this;
 
-	fd = get_unused_fd();
-	if (fd < 0) return -ENFILE;
-
-	ret = -ENFILE;
-
-	file = get_empty_filp();
-	if (!file) goto out;
-
 	/*
 	 * allocate a new inode
 	 */
 	inode = new_inode(pfmfs_mnt->mnt_sb);
-	if (!inode) goto out;
+	if (!inode)
+		return ERR_PTR(-ENOMEM);
 
 	DPRINT(("new inode ino=%ld @%p\n", inode->i_ino, inode));
 
@@ -2199,59 +2231,28 @@ pfm_alloc_fd(struct file **cfile)
 	this.len  = strlen(name);
 	this.hash = inode->i_ino;
 
-	ret = -ENOMEM;
-
 	/*
 	 * allocate a new dcache entry
 	 */
-	file->f_path.dentry = d_alloc(pfmfs_mnt->mnt_sb->s_root, &this);
-	if (!file->f_path.dentry) goto out;
+	dentry = d_alloc(pfmfs_mnt->mnt_sb->s_root, &this);
+	if (!dentry) {
+		iput(inode);
+		return ERR_PTR(-ENOMEM);
+	}
 
-	file->f_path.dentry->d_op = &pfmfs_dentry_operations;
+	dentry->d_op = &pfmfs_dentry_operations;
+	d_add(dentry, inode);
 
-	d_add(file->f_path.dentry, inode);
-	file->f_path.mnt = mntget(pfmfs_mnt);
-	file->f_mapping = inode->i_mapping;
+	file = alloc_file(pfmfs_mnt, dentry, FMODE_READ, &pfm_file_ops);
+	if (!file) {
+		dput(dentry);
+		return ERR_PTR(-ENFILE);
+	}
 
-	file->f_op    = &pfm_file_ops;
-	file->f_mode  = FMODE_READ;
 	file->f_flags = O_RDONLY;
-	file->f_pos   = 0;
-
-	/*
-	 * may have to delay until context is attached?
-	 */
-	fd_install(fd, file);
-
-	/*
-	 * the file structure we will use
-	 */
-	*cfile = file;
-
-	return fd;
-out:
-	if (file) put_filp(file);
-	put_unused_fd(fd);
-	return ret;
-}
-
-static void
-pfm_free_fd(int fd, struct file *file)
-{
-	struct files_struct *files = current->files;
-	struct fdtable *fdt;
+	file->private_data = ctx;
 
-	/* 
-	 * there ie no fd_uninstall(), so we do it here
-	 */
-	spin_lock(&files->file_lock);
-	fdt = files_fdtable(files);
-	rcu_assign_pointer(fdt->fd[fd], NULL);
-	spin_unlock(&files->file_lock);
-
-	if (file)
-		put_filp(file);
-	put_unused_fd(fd);
+	return file;
 }
 
 static int
@@ -2475,6 +2476,7 @@ pfm_setup_buffer_fmt(struct task_struct *task, struct file *filp, pfm_context_t
 
 	/* link buffer format and context */
 	ctx->ctx_buf_fmt = fmt;
+	ctx->ctx_fl_is_sampling = 1; /* assume record() is defined */
 
 	/*
 	 * check if buffer format wants to use perfmon buffer allocation/mapping service
@@ -2669,78 +2671,45 @@ pfm_context_create(pfm_context_t *ctx, void *arg, int count, struct pt_regs *reg
 {
 	pfarg_context_t *req = (pfarg_context_t *)arg;
 	struct file *filp;
+	struct path path;
 	int ctx_flags;
+	int fd;
 	int ret;
 
 	/* let's check the arguments first */
 	ret = pfarg_is_sane(current, req);
-	if (ret < 0) return ret;
+	if (ret < 0)
+		return ret;
 
 	ctx_flags = req->ctx_flags;
 
 	ret = -ENOMEM;
 
-	ctx = pfm_context_alloc();
-	if (!ctx) goto error;
+	fd = get_unused_fd();
+	if (fd < 0)
+		return fd;
 
-	ret = pfm_alloc_fd(&filp);
-	if (ret < 0) goto error_file;
+	ctx = pfm_context_alloc(ctx_flags);
+	if (!ctx)
+		goto error;
 
-	req->ctx_fd = ctx->ctx_fd = ret;
+	filp = pfm_alloc_file(ctx);
+	if (IS_ERR(filp)) {
+		ret = PTR_ERR(filp);
+		goto error_file;
+	}
 
-	/*
-	 * attach context to file
-	 */
-	filp->private_data = ctx;
+	req->ctx_fd = ctx->ctx_fd = fd;
 
 	/*
 	 * does the user want to sample?
 	 */
 	if (pfm_uuid_cmp(req->ctx_smpl_buf_id, pfm_null_uuid)) {
 		ret = pfm_setup_buffer_fmt(current, filp, ctx, ctx_flags, 0, req);
-		if (ret) goto buffer_error;
+		if (ret)
+			goto buffer_error;
 	}
 
-	/*
-	 * init context protection lock
-	 */
-	spin_lock_init(&ctx->ctx_lock);
-
-	/*
-	 * context is unloaded
-	 */
-	ctx->ctx_state = PFM_CTX_UNLOADED;
-
-	/*
-	 * initialization of context's flags
-	 */
-	ctx->ctx_fl_block       = (ctx_flags & PFM_FL_NOTIFY_BLOCK) ? 1 : 0;
-	ctx->ctx_fl_system      = (ctx_flags & PFM_FL_SYSTEM_WIDE) ? 1: 0;
-	ctx->ctx_fl_is_sampling = ctx->ctx_buf_fmt ? 1 : 0; /* assume record() is defined */
-	ctx->ctx_fl_no_msg      = (ctx_flags & PFM_FL_OVFL_NO_MSG) ? 1: 0;
-	/*
-	 * will move to set properties
-	 * ctx->ctx_fl_excl_idle   = (ctx_flags & PFM_FL_EXCL_IDLE) ? 1: 0;
-	 */
-
-	/*
-	 * init restart semaphore to locked
-	 */
-	init_completion(&ctx->ctx_restart_done);
-
-	/*
-	 * activation is used in SMP only
-	 */
-	ctx->ctx_last_activation = PFM_INVALID_ACTIVATION;
-	SET_LAST_CPU(ctx, -1);
-
-	/*
-	 * initialize notification message queue
-	 */
-	ctx->ctx_msgq_head = ctx->ctx_msgq_tail = 0;
-	init_waitqueue_head(&ctx->ctx_msgq_wait);
-	init_waitqueue_head(&ctx->ctx_zombieq);
-
 	DPRINT(("ctx=%p flags=0x%x system=%d notify_block=%d excl_idle=%d no_msg=%d ctx_fd=%d \n",
 		ctx,
 		ctx_flags,
@@ -2755,10 +2724,14 @@ pfm_context_create(pfm_context_t *ctx, void *arg, int count, struct pt_regs *reg
 	 */
 	pfm_reset_pmu_state(ctx);
 
+	fd_install(fd, filp);
+
 	return 0;
 
 buffer_error:
-	pfm_free_fd(ctx->ctx_fd, filp);
+	path = filp->f_path;
+	put_filp(filp);
+	path_put(&path);
 
 	if (ctx->ctx_buf_fmt) {
 		pfm_buf_fmt_exit(ctx->ctx_buf_fmt, current, NULL, regs);
@@ -2767,6 +2740,7 @@ error_file:
 	pfm_context_free(ctx);
 
 error:
+	put_unused_fd(fd);
 	return ret;
 }
 
-- 
1.5.5.1


