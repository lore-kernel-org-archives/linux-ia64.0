From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 19 Jul 2005 01:22:10 +0000
Subject: [PATCH] Fix uninitalised value in do_copy_task_regs
Message-Id: <20050719012210.GB10518@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix

arch/ia64/kernel/process.c:503: warning: 'ip' may be used uninitialized in this function

--

Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>

diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -500,7 +500,7 @@ copy_thread (int nr, unsigned long clone
 static void
 do_copy_task_regs (struct task_struct *task, struct unw_frame_info *info, void *arg)
 {
-	unsigned long mask, sp, nat_bits = 0, ip, ar_rnat, urbs_end, cfm;
+	unsigned long mask, sp, nat_bits = 0, ip = 0, ar_rnat, urbs_end, cfm;
 	elf_greg_t *dst = arg;
 	struct pt_regs *pt;
 	char nat;
