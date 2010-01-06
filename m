From: Jiri Slaby <jslaby@suse.cz>
Date: Wed, 06 Jan 2010 15:24:30 +0000
Subject: [PATCH] IA64: use helpers for rlimits
Message-Id: <1262791479-26594-2-git-send-email-jslaby@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1262791479-26594-1-git-send-email-jslaby@suse.cz>
In-Reply-To: <1262791479-26594-1-git-send-email-jslaby@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jirislaby@gmail.com
Cc: linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Make sure compiler won't do weird things with limits. E.g. fetching
them twice may return 2 different values after writable limits are
implemented.

I.e. either use rlimit helpers added in
3e10e716abf3c71bdb5d86b8f507f9e72236c9cd
or ACCESS_ONCE if not applicable.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/perfmon.c |    2 +-
 arch/ia64/mm/init.c        |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 5246285..6bcbe21 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -2293,7 +2293,7 @@ pfm_smpl_buffer_alloc(struct task_struct *task, struct file *filp, pfm_context_t
 	 * if ((mm->total_vm << PAGE_SHIFT) + len> task->rlim[RLIMIT_AS].rlim_cur)
 	 * 	return -ENOMEM;
 	 */
-	if (size > task->signal->rlim[RLIMIT_MEMLOCK].rlim_cur)
+	if (size > task_rlimit(task, RLIMIT_MEMLOCK))
 		return -ENOMEM;
 
 	/*
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index b9609c6..7c0d481 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -91,7 +91,7 @@ dma_mark_clean(void *addr, size_t size)
 inline void
 ia64_set_rbs_bot (void)
 {
-	unsigned long stack_size = current->signal->rlim[RLIMIT_STACK].rlim_max & -16;
+	unsigned long stack_size = rlimit_max(RLIMIT_STACK) & -16;
 
 	if (stack_size > MAX_USER_STACK_SIZE)
 		stack_size = MAX_USER_STACK_SIZE;
-- 
1.6.5.7

