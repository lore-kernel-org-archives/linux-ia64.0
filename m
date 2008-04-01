From: Li Zefan <lizf@cn.fujitsu.com>
Date: Tue, 01 Apr 2008 04:29:34 +0000
Subject: [PATCH] IA64: use goto to jump out do/while_each_thread
Message-Id: <47F1BA2E.9040706@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

do_each_thread/while_each_thread is a double loop, so
should use 'goto' rather than 'break' to break out
the loop.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 arch/ia64/kernel/perfmon.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index a2aabfd..d1d24f4 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -4204,10 +4204,10 @@ pfm_check_task_exist(pfm_context_t *ctx)
 	do_each_thread (g, t) {
 		if (t->thread.pfm_context = ctx) {
 			ret = 0;
-			break;
+			goto out;
 		}
 	} while_each_thread (g, t);
-
+out:
 	read_unlock(&tasklist_lock);
 
 	DPRINT(("pfm_check_task_exist: ret=%d ctx=%p\n", ret, ctx));
-- 
1.5.4.rc3
