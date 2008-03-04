From: akpm@linux-foundation.org
Date: Tue, 04 Mar 2008 23:14:57 +0000
Subject: [patch 1/3] ia64: fix ptrace inside a namespace
Message-Id: <200803042314.m24NEwT5002321@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>

The ia64 has its own sys_ptrace implementation and it was overlooked when the
pid namespaces patches were sent.

Use find_task_by_vpid() in it.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/kernel/ptrace.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN arch/ia64/kernel/ptrace.c~ia64-fix-ptrace-inside-a-namespace arch/ia64/kernel/ptrace.c
--- a/arch/ia64/kernel/ptrace.c~ia64-fix-ptrace-inside-a-namespace
+++ a/arch/ia64/kernel/ptrace.c
@@ -1561,7 +1561,7 @@ sys_ptrace (long request, pid_t pid, uns
 	ret = -ESRCH;
 	read_lock(&tasklist_lock);
 	{
-		child = find_task_by_pid(pid);
+		child = find_task_by_vpid(pid);
 		if (child) {
 			if (peek_or_poke)
 				child = find_thread_for_addr(child, addr);
_
