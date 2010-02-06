From: Frans Pop <elendil@planet.nl>
Date: Sat, 06 Feb 2010 17:47:10 +0000
Subject: [PATCH 03/16] ia64: remove trailing space in messages
Message-Id: <1265478443-31072-3-git-send-email-elendil@planet.nl>
List-Id: <linux-ia64.vger.kernel.org>
References: <201002061844.45212.elendil@planet.nl>
In-Reply-To: <201002061844.45212.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Frans Pop <elendil@planet.nl>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

Signed-off-by: Frans Pop <elendil@planet.nl>
Cc: linux-ia64@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
---
 arch/ia64/ia32/sys_ia32.c  |    4 ++--
 arch/ia64/kernel/perfmon.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/ia32/sys_ia32.c b/arch/ia64/ia32/sys_ia32.c
index 045b746..8e441a4 100644
--- a/arch/ia64/ia32/sys_ia32.c
+++ b/arch/ia64/ia32/sys_ia32.c
@@ -2219,8 +2219,8 @@ static void access_fpreg_ia32(int regno, void *reg,
 	else if (regno <= 7)
 		f = &sw->f12 + (regno - 4);
 	else {
-		printk(KERN_ERR "regno must be less than 7 \n");
-		 return;
+		printk(KERN_ERR "regno must be less than 7\n");
+		return;
 	}
 
 	if (write)
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 6bcbe21..b81e46b 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -2713,7 +2713,7 @@ pfm_context_create(pfm_context_t *ctx, void *arg, int count, struct pt_regs *reg
 			goto buffer_error;
 	}
 
-	DPRINT(("ctx=%p flags=0x%x system=%d notify_block=%d excl_idle=%d no_msg=%d ctx_fd=%d \n",
+	DPRINT(("ctx=%p flags=0x%x system=%d notify_block=%d excl_idle=%d no_msg=%d ctx_fd=%d\n",
 		ctx,
 		ctx_flags,
 		ctx->ctx_fl_system,
@@ -3677,7 +3677,7 @@ pfm_restart(pfm_context_t *ctx, void *arg, int count, struct pt_regs *regs)
 	 * "self-monitoring".
 	 */
 	if (CTX_OVFL_NOBLOCK(ctx) = 0 && state = PFM_CTX_MASKED) {
-		DPRINT(("unblocking [%d] \n", task_pid_nr(task)));
+		DPRINT(("unblocking [%d]\n", task_pid_nr(task)));
 		complete(&ctx->ctx_restart_done);
 	} else {
 		DPRINT(("[%d] armed exit trap\n", task_pid_nr(task)));
-- 
1.6.6.1

