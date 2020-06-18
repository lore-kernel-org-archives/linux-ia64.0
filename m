From: Gaurav Singh <gaurav1086@gmail.com>
Date: Thu, 18 Jun 2020 00:11:46 +0000
Subject: [PATCH] ia64: Add null pointer check for task in default_handler
Message-Id: <20200618001157.26035-1-gaurav1086@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200611150221.15665-1-gaurav1086@gmail.com>
In-Reply-To: <20200611150221.15665-1-gaurav1086@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: gaurav1086@gmail.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "open list:IA64 Itanium PLATFORM" <linux-ia64@vger.kernel.org>, open list <linux-kernel@vger.kernel.org>

If the task is NULL and the if condition is true 
then task->pid would cause null pointer dereference. 
Fix this by adding additional null check.

Signed-off-by: Gaurav Singh <gaurav1086@gmail.com>
---
 arch/ia64/kernel/perfmon_default_smpl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/perfmon_default_smpl.c b/arch/ia64/kernel/perfmon_default_smpl.c
index a40c56020fc5..2732b4cf4296 100644
--- a/arch/ia64/kernel/perfmon_default_smpl.c
+++ b/arch/ia64/kernel/perfmon_default_smpl.c
@@ -111,7 +111,7 @@ default_handler(struct task_struct *task, void *buf, pfm_ovfl_arg_t *arg, struct
 	unsigned char ovfl_notify;
 
 	if (unlikely(buf = NULL || arg = NULL|| regs = NULL || task = NULL)) {
-		DPRINT(("[%d] invalid arguments buf=%p arg=%p\n", task->pid, buf, arg));
+		DPRINT(("[%d] invalid arguments buf=%p arg=%p\n", task? task->pid : -1, buf, arg));
 		return -EINVAL;
 	}
 
-- 
2.17.1
