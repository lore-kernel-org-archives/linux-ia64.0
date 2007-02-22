From: "Akiyama, Nobuyuki" <akiyama.nobuyuk@jp.fujitsu.com>
Date: Thu, 22 Feb 2007 13:50:38 +0000
Subject: [PATCH] ia64: add missing syscall trace clear
Message-Id: <20070222225038.ec1ab826.akiyama.nobuyuk@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

The ptrace misses clearing the syscall trace flag.
The increased syscall overhead is retained after the trace is finished.
This case happens when strace is terminated by force.

Thanks,
Akiyama

Signed-off-by: Akiyama, Nobuyuki <akiyama.nobuyuk@jp.fujitsu.com>
---

diff -Nurp linux-2.6.21-rc1.orig/arch/ia64/kernel/ptrace.c linux-2.6.21-rc1.mod/arch/ia64/kernel/ptrace.c
--- linux-2.6.21-rc1.orig/arch/ia64/kernel/ptrace.c	2007-02-22 17:15:38.000000000 +0900
+++ linux-2.6.21-rc1.mod/arch/ia64/kernel/ptrace.c	2007-02-22 22:12:50.000000000 +0900
@@ -1573,6 +1573,7 @@ sys_ptrace (long request, pid_t pid, uns
 
 	      case PTRACE_DETACH:
 		/* detach a process that was attached. */
+		clear_tsk_thread_flag(child, TIF_SYSCALL_TRACE);
 		ret = ptrace_detach(child, data);
 		goto out_tsk;

