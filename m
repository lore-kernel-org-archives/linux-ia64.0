From: John Levon <levon@movementarian.org>
Date: Thu, 23 Oct 2003 00:27:32 +0000
Subject: [PATCH] yet more trivial perfmon cleanups
Message-Id: <marc-linux-ia64-106686887320395@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


All the wrappers tend to make the code hard to follow IMHO. This also
fixes a slight debug printk error, removes an always-NULL argument to
fmt_exit, and makes it return void to reflect usage.

 3 files changed, 17 insertions(+), 48 deletions(-)

I'm not really sure what use passing pt_regs into the format's exit
routine would ever be ? It's only done on create failure path.

There's a lot more of these trivial things that would make perfmon more
readable IMHO, but I suppose now is not the right time to be doing
stuff, so I'll stop here.

Just one last thing - why :

    303         unsigned long           ctx_used_monitors[4];   /* bitmask of monitor PMC being used */

and friends ? If the intention was to support more than 64 PMCs at some
point, all the code using these things need to use set_bit() instead of
just C, unless I'm missing something (i.e. [1]-[3] in these are never
touched or read).

regards,
john

Index: linux-cvs/arch/ia64/kernel/perfmon.c
=================================RCS file: /home/cvs/linux-2.5/arch/ia64/kernel/perfmon.c,v
retrieving revision 1.37
diff -u -a -p -r1.37 perfmon.c
--- linux-cvs/arch/ia64/kernel/perfmon.c	17 Oct 2003 04:46:41 -0000	1.37
+++ linux-cvs/arch/ia64/kernel/perfmon.c	23 Oct 2003 00:14:05 -0000
@@ -1150,41 +1150,6 @@ pfm_uuid_cmp(pfm_uuid_t a, pfm_uuid_t b)
 }
 
 static inline int
-pfm_buf_fmt_exit(pfm_buffer_fmt_t *fmt, struct task_struct *task, void *buf, struct pt_regs *regs)
-{
-	int ret = 0;
-	if (fmt->fmt_exit) ret = (*fmt->fmt_exit)(task, buf, regs);
-	return ret;
-}
-
-static inline int
-pfm_buf_fmt_getsize(pfm_buffer_fmt_t *fmt, struct task_struct *task, unsigned int flags, int cpu, void *arg, unsigned long *size)
-{
-	int ret = 0;
-	if (fmt->fmt_getsize) ret = (*fmt->fmt_getsize)(task, flags, cpu, arg, size);
-	return ret;
-}
-
-
-static inline int
-pfm_buf_fmt_validate(pfm_buffer_fmt_t *fmt, struct task_struct *task, unsigned int flags,
-		     int cpu, void *arg)
-{
-	int ret = 0;
-	if (fmt->fmt_validate) ret = (*fmt->fmt_validate)(task, flags, cpu, arg);
-	return ret;
-}
-
-static inline int
-pfm_buf_fmt_init(pfm_buffer_fmt_t *fmt, struct task_struct *task, void *buf, unsigned int flags,
-		     int cpu, void *arg)
-{
-	int ret = 0;
-	if (fmt->fmt_init) ret = (*fmt->fmt_init)(task, buf, flags, cpu, arg);
-	return ret;
-}
-
-static inline int
 pfm_buf_fmt_restart(pfm_buffer_fmt_t *fmt, struct task_struct *task, pfm_ovfl_ctrl_t *ctrl, void *buf, struct pt_regs *regs)
 {
 	int ret = 0;
@@ -1443,7 +1408,8 @@ pfm_free_smpl_buffer(pfm_context_t *ctx)
 		ctx->ctx_smpl_size,
 		ctx->ctx_smpl_vaddr));
 
-	pfm_buf_fmt_exit(fmt, current, NULL, NULL);
+	if (fmt->fmt_exit)
+		fmt->fmt_exit(current, NULL);
 
 	/*
 	 * free the buffer
@@ -1466,7 +1432,8 @@ pfm_exit_smpl_buffer(pfm_buffer_fmt_t *f
 {
 	if (fmt = NULL) return;
 
-	pfm_buf_fmt_exit(fmt, current, NULL, NULL);
+	if (fmt->fmt_exit)
+		fmt->fmt_exit(current, NULL);
 
 }
 
@@ -1516,7 +1483,7 @@ pfm_read(struct file *filp, char *buf, s
 	unsigned long flags;
   	DECLARE_WAITQUEUE(wait, current);
 	if (PFM_IS_FILE(filp) = 0) {
-		printk(KERN_ERR "perfmon: pfm_poll: bad magic [%d]\n", current->pid);
+		printk(KERN_ERR "perfmon: pfm_read: bad magic [%d]\n", current->pid);
 		return -EINVAL;
 	}
 
@@ -2413,7 +2380,8 @@ pfm_setup_buffer_fmt(struct task_struct 
 	 */
 	if (fmt->fmt_arg_size) fmt_arg = PFM_CTXARG_BUF_ARG(arg);
 
-	ret = pfm_buf_fmt_validate(fmt, task, ctx_flags, cpu, fmt_arg);
+	if (fmt->fmt_validate)
+		ret = fmt->fmt_validate(task, ctx_flags, cpu, fmt_arg);
 
 	DPRINT(("[%d] after validate(0x%x,%d,%p)=%d\n", task->pid, ctx_flags, cpu, fmt_arg, ret));
 
@@ -2425,7 +2393,8 @@ pfm_setup_buffer_fmt(struct task_struct 
 	/*
 	 * check if buffer format wants to use perfmon buffer allocation/mapping service
 	 */
-	ret = pfm_buf_fmt_getsize(fmt, task, ctx_flags, cpu, fmt_arg, &size);
+	if (fmt->fmt_getsize)
+		ret = fmt->fmt_getsize(task, ctx_flags, cpu, fmt_arg, &size);
 	if (ret) goto error;
 
 	if (size) {
@@ -2438,7 +2407,8 @@ pfm_setup_buffer_fmt(struct task_struct 
 		/* keep track of user address of buffer */
 		arg->ctx_smpl_vaddr = uaddr;
 	}
-	ret = pfm_buf_fmt_init(fmt, task, ctx->ctx_smpl_hdr, ctx_flags, cpu, fmt_arg);
+	if (fmt->fmt_init)
+		ret = fmt->fmt_init(task, ctx->ctx_smpl_hdr, ctx_flags, cpu, fmt_arg);
 
 error:
 	return ret;
@@ -2704,8 +2674,8 @@ pfm_context_create(pfm_context_t *ctx, v
 buffer_error:
 	pfm_free_fd(ctx->ctx_fd, filp);
 
-	if (ctx->ctx_buf_fmt) {
-		pfm_buf_fmt_exit(ctx->ctx_buf_fmt, current, NULL, regs);
+	if (ctx->ctx_buf_fmt && ctx->ctx_buf_fmt->fmt_exit) {
+		ctx->ctx_buf_fmt->fmt_exit(current, regs);
 	}
 error_file:
 	pfm_context_free(ctx);
Index: linux-cvs/arch/ia64/kernel/perfmon_default_smpl.c
=================================RCS file: /home/cvs/linux-2.5/arch/ia64/kernel/perfmon_default_smpl.c,v
retrieving revision 1.3
diff -u -a -p -r1.3 perfmon_default_smpl.c
--- linux-cvs/arch/ia64/kernel/perfmon_default_smpl.c	22 Aug 2003 00:40:41 -0000	1.3
+++ linux-cvs/arch/ia64/kernel/perfmon_default_smpl.c	23 Oct 2003 00:14:05 -0000
@@ -245,11 +245,10 @@ default_restart(struct task_struct *task
 	return 0;
 }
 
-static int
-default_exit(struct task_struct *task, void *buf, struct pt_regs *regs)
+static void
+default_exit(struct task_struct *task, struct pt_regs *regs)
 {
-	DPRINT(("[%d] exit(%p)\n", task->pid, buf));
-	return 0;
+	DPRINT(("[%d] exit\n", task->pid));
 }
 
 static pfm_buffer_fmt_t default_fmt={
Index: linux-cvs/include/asm//perfmon.h
=================================RCS file: /home/cvs/linux-2.5/include/asm-ia64/perfmon.h,v
retrieving revision 1.14
diff -u -a -p -r1.14 perfmon.h
--- linux-cvs/include/asm//perfmon.h	16 Oct 2003 22:37:58 -0000	1.14
+++ linux-cvs/include/asm//perfmon.h	23 Oct 2003 00:14:30 -0000
@@ -231,7 +231,7 @@ typedef struct {
 	int		(*fmt_handler)(struct task_struct *task, void *buf, pfm_ovfl_arg_t *arg, struct pt_regs *regs, unsigned long stamp);
 	int		(*fmt_restart)(struct task_struct *task, pfm_ovfl_ctrl_t *ctrl, void *buf, struct pt_regs *regs);
 	int		(*fmt_restart_active)(struct task_struct *task, pfm_ovfl_ctrl_t *ctrl, void *buf, struct pt_regs *regs);
-	int		(*fmt_exit)(struct task_struct *task, void *buf, struct pt_regs *regs);
+	void		(*fmt_exit)(struct task_struct *task, struct pt_regs *regs);
 
 	struct list_head fmt_list;
 } pfm_buffer_fmt_t;
