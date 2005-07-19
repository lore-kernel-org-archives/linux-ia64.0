From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 19 Jul 2005 01:24:51 +0000
Subject: [PATCH] Fix uninitialised values in ia64_illegal_op_fault
Message-Id: <20050719012451.GC10518@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix

arch/ia64/kernel/traps.c: In function 'ia64_illegal_op_fault':
arch/ia64/kernel/traps.c:444: warning: 'rv.arg3' is used uninitialized in this function
arch/ia64/kernel/traps.c:444: warning: 'rv.arg2' is used uninitialized in this function
arch/ia64/kernel/traps.c:444: warning: 'rv.arg1' is used uninitialized in this function

--

Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>

diff --git a/arch/ia64/kernel/traps.c b/arch/ia64/kernel/traps.c
--- a/arch/ia64/kernel/traps.c
+++ b/arch/ia64/kernel/traps.c
@@ -435,6 +435,7 @@ ia64_illegal_op_fault (unsigned long ec,
 	sprintf(buf, "IA-64 Illegal operation fault");
 	die_if_kernel(buf, &regs, 0);
 
+	memset(&rv, 0, sizeof(rv));
 	memset(&si, 0, sizeof(si));
 	si.si_signo = SIGILL;
 	si.si_code = ILL_ILLOPC;
