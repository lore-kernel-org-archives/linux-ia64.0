From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 08 May 2008 06:05:09 +0000
Subject: Re: [PATCH] ia64: fix interrupt masking for pending works on kernel
Message-Id: <48229815.4090406@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <48229532.7000809@jp.fujitsu.com>
In-Reply-To: <48229532.7000809@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm careless...

diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index c7d4885..a3a34b4 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -169,7 +169,7 @@ void tsk_clear_notify_resume(struct task_struct *tsk)
 
 /*
  * do_notify_resume_user():
- *	Called from notify_from_user at entry.S, with interrupts disabled.
+ *	Called from notify_resume_user at entry.S, with interrupts disabled.
  */
 void
 do_notify_resume_user(sigset_t *unused, struct sigscratch *scr, long in_syscall)
