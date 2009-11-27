From: Jiri Slaby <jslaby@suse.cz>
Date: Fri, 27 Nov 2009 23:05:55 +0000
Subject: [PATCH v3 15/27] IA64: use helpers for rlimits
Message-Id: <1259363167-9347-15-git-send-email-jslaby@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1259363167-9347-1-git-send-email-jslaby@suse.cz>
In-Reply-To: <1259363167-9347-1-git-send-email-jslaby@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jirislaby@gmail.com
Cc: mingo@elte.hu, nhorman@tuxdriver.com, sfr@canb.auug.org.au, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, marcin.slusarz@gmail.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, torvalds@linux-foundation.org, oleg@redhat.com, James Morris <jmorris@namei.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-ia64@vger.kernel.org

Make sure compiler won't do weird things with limits. E.g. fetching
them twice may return 2 different values after writable limits are
implemented.

I.e. either use newly added rlimit helpers or ACCESS_ONCE if not
applicable.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: James Morris <jmorris@namei.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/perfmon.c  |    2 +-
 arch/ia64/kernel/sys_ia64.c |    2 +-
 arch/ia64/mm/init.c         |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index f178270..82429cc 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -2298,7 +2298,7 @@ pfm_smpl_buffer_alloc(struct task_struct *task, struct file *filp, pfm_context_t
 	 * if ((mm->total_vm << PAGE_SHIFT) + len> task->rlim[RLIMIT_AS].rlim_cur)
 	 * 	return -ENOMEM;
 	 */
-	if (size > task->signal->rlim[RLIMIT_MEMLOCK].rlim_cur)
+	if (size > task_rlim_get_cur(task, RLIMIT_MEMLOCK))
 		return -ENOMEM;
 
 	/*
diff --git a/arch/ia64/kernel/sys_ia64.c b/arch/ia64/kernel/sys_ia64.c
index 92ed83f..ad663c8 100644
--- a/arch/ia64/kernel/sys_ia64.c
+++ b/arch/ia64/kernel/sys_ia64.c
@@ -129,7 +129,7 @@ ia64_brk (unsigned long brk)
 		goto out;
 
 	/* Check against rlimit.. */
-	rlim = current->signal->rlim[RLIMIT_DATA].rlim_cur;
+	rlim = rlim_get_cur(RLIMIT_DATA);
 	if (rlim < RLIM_INFINITY && brk - mm->start_data > rlim)
 		goto out;
 
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 1857766..0995019 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -91,7 +91,7 @@ dma_mark_clean(void *addr, size_t size)
 inline void
 ia64_set_rbs_bot (void)
 {
-	unsigned long stack_size = current->signal->rlim[RLIMIT_STACK].rlim_max & -16;
+	unsigned long stack_size = rlim_get_max(RLIMIT_STACK) & -16;
 
 	if (stack_size > MAX_USER_STACK_SIZE)
 		stack_size = MAX_USER_STACK_SIZE;
-- 
1.6.5.3

