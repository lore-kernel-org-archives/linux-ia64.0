From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Fri, 03 Jan 2003 19:53:12 +0000
Subject: [Linux-ia64] important perfmon fix for 2.4.20
MIME-Version: 1
Content-Type: multipart/mixed; boundary="5/uDoXvLw7AC5HRs"
Message-Id: <marc-linux-ia64-105590709805636@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--5/uDoXvLw7AC5HRs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

I discovered a problem with perfmon in the latest 2.4.20 kernel from Bjorn.

System wide monitoring in SMP system was broken due to a bug introduced in
my previous patch. The task pinning was done incorrectly, leading to conflicts
detected by pfmon. Other tools running system wide are also affected.

Please apply the attached patch to your 2.4.20 tree to correct the problem.

Happy New Year!

-- 
-Stephane

--5/uDoXvLw7AC5HRs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="perfmon-030103.diff"

--- linux.2420-official/arch/ia64/kernel/perfmon.c	2003-01-03 10:09:11.000000000 -0800
+++ build.2420-new/arch/ia64/kernel/perfmon.c	2003-01-03 11:15:53.000000000 -0800
@@ -261,7 +261,7 @@
 
 	u64			ctx_saved_psr;		/* copy of psr used for lazy ctxsw */
 	unsigned long		ctx_saved_cpus_allowed;	/* copy of the task cpus_allowed (system wide) */
-	unsigned long		ctx_cpu;		/* cpu to which perfmon is applied (system wide) */
+	unsigned long		ctx_cpu_mask;		/* where owner can run, 1 bit set system wide) */
 
 	atomic_t		ctx_saving_in_progress;	/* flag indicating actual save in progress */
 	atomic_t		ctx_is_busy;		/* context accessed by overflow handler */
@@ -1089,7 +1089,7 @@
 {
 	pfarg_context_t tmp;
 	void *uaddr = NULL;
-	int ret, cpu = 0;
+	int ret;
 	int ctx_flags;
 	pid_t notify_pid;
 
@@ -1204,7 +1204,7 @@
 	ctx->ctx_fl_protected = 0;
 
 	/* for system wide mode only (only 1 bit set) */
-	ctx->ctx_cpu         = cpu;
+	ctx->ctx_cpu_mask = tmp.ctx_cpu_mask;
 
 	atomic_set(&ctx->ctx_last_cpu,-1); /* SMP only, means no CPU */
 
@@ -1237,7 +1237,7 @@
 	 */
 	if (ctx->ctx_fl_system) {
 		ctx->ctx_saved_cpus_allowed = task->cpus_allowed;
-		task->cpus_allowed = 1UL << cpu;
+		task->cpus_allowed = ctx->ctx_cpu_mask;
 		task->need_resched = 1;
 		DBprintk(("[%d] rescheduled allowed=0x%lx\n", task->pid,task->cpus_allowed));
 	}
@@ -4048,7 +4048,7 @@
 
 	UNLOCK_CTX(ctx);
 
-	pfm_unreserve_session(task, ctx->ctx_fl_system, 1UL << ctx->ctx_cpu);
+	pfm_unreserve_session(task, ctx->ctx_fl_system, ctx->ctx_cpu_mask);
 
 	if (ctx->ctx_fl_system) {
 		/*

--5/uDoXvLw7AC5HRs--

