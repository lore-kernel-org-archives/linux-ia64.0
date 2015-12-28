From: Li Bin <huawei.libin@huawei.com>
Date: Mon, 28 Dec 2015 08:33:02 +0000
Subject: [PATCH] ia64: ftrace: remove the misleading comment for ftrace_dyn_arch_init
Message-Id: <1451291582-10346-1-git-send-email-huawei.libin@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ftrace_dyn_arch_init no longer in kstop_machine, so remove the
corresponding comment.

Signed-off-by: Li Bin <huawei.libin@huawei.com>
---
 arch/ia64/kernel/ftrace.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/ftrace.c b/arch/ia64/kernel/ftrace.c
index 3b0c2aa..0d07757 100644
--- a/arch/ia64/kernel/ftrace.c
+++ b/arch/ia64/kernel/ftrace.c
@@ -197,7 +197,6 @@ int ftrace_update_ftrace_func(ftrace_func_t func)
 	return 0;
 }
 
-/* run from kstop_machine */
 int __init ftrace_dyn_arch_init(void)
 {
 	return 0;
-- 
1.7.1

