From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 11 Apr 2003 01:24:35 +0000
Subject: Re: [Linux-ia64] [BUG] perfmon doesn't send SIGPROF in kernel 2.5.64
MIME-Version: 1
Content-Type: multipart/mixed; boundary="opJtzjQTFsWo+cga"
Message-Id: <marc-linux-ia64-105590723705461@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705454@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705454@msgid-missing>
To: linux-ia64@vger.kernel.org

--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Eric,

Yes, I realized that a while back and never got around to fixing it.

Please try the (mostly untested) attached patch against 2.5.67 but it 
should apply to older versions as well.

Let me know how it goes, especially on SMP.

PS: there is a dedicated mailing-list for perfmon.
    Visit http://www.hpl.hp.com/research/linux/perfmon for details.

--
-Stephane

--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="perfmon-2.5-030410.diff"

diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet bk-official-extra/arch/ia64/kernel/perfmon.c bk-base/arch/ia64/kernel/perfmon.c
--- bk-official-extra/arch/ia64/kernel/perfmon.c	Thu Apr 10 14:01:35 2003
+++ bk-base/arch/ia64/kernel/perfmon.c	Thu Apr 10 12:24:05 2003
@@ -1883,7 +1883,10 @@
 		DBprintk(("unblocking %d \n", task->pid));
 		up(sem);
 	} else {
+		struct thread_info *info = (struct thread_info *) ((char *) task + IA64_TASK_SIZE);
 		task->thread.pfm_ovfl_block_reset = 1;
+		ctx->ctx_fl_trap_reason = PFM_TRAP_REASON_RESET;
+		set_bit(TIF_NOTIFY_RESUME, &info->flags);
 	}
 #if 0
 	/*
@@ -2733,6 +2736,7 @@
 	 * again
 	 */
 	th->pfm_ovfl_block_reset = 0;
+	clear_thread_flag(TIF_NOTIFY_RESUME);
 
 	/*
 	 * do some sanity checks first
@@ -2907,8 +2911,9 @@
 static unsigned long
 pfm_overflow_handler(struct task_struct *task, pfm_context_t *ctx, u64 pmc0, struct pt_regs *regs)
 {
-	unsigned long mask;
 	struct thread_struct *t;
+	struct thread_info *info;
+	unsigned long mask;
 	unsigned long old_val;
 	unsigned long ovfl_notify = 0UL, ovfl_pmds = 0UL;
 	int i;
@@ -3053,6 +3058,8 @@
 		t->pfm_ovfl_block_reset = 1; /* will cause blocking */
 		ctx->ctx_fl_trap_reason = PFM_TRAP_REASON_SIG;
 	}
+	info = (struct thread_info *) ((char *) task + IA64_TASK_SIZE);
+	set_bit(TIF_NOTIFY_RESUME, &info->flags);
 
 	/*
 	 * keep the PMU frozen until either pfm_restart() or 

--opJtzjQTFsWo+cga--

