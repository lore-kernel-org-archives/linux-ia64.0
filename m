From: Steven Rostedt <rostedt@goodmis.org>
Date: Thu, 24 Dec 2015 14:28:02 +0000
Subject: [for-next][PATCH 10/13] ia64: ftrace: Fix the comments for ftrace_modify_code()
Message-Id: <20151224142901.064357467@goodmis.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20151224142752.534947674@goodmis.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Li Bin <huawei.libin@huawei.com>

From: Li Bin <huawei.libin@huawei.com>

There is no need to worry about module and __init text disappearing
case, because that ftrace has a module notifier that is called when
a module is being unloaded and before the text goes away and this
code grabs the ftrace_lock mutex and removes the module functions
from the ftrace list, such that it will no longer do any
modifications to that module's text, the update to make functions
be traced or not is done under the ftrace_lock mutex as well.
And by now, __init section codes should not been modified
by ftrace, because it is black listed in recordmcount.c and
ignored by ftrace.

Link: http://lkml.kernel.org/r/1449214067-12177-2-git-send-email-huawei.libin@huawei.com

Cc: linux-ia64@vger.kernel.org
Acked-by: Tony Luck <tony.luck@intel.com>
Suggested-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Li Bin <huawei.libin@huawei.com>
Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
---
 arch/ia64/kernel/ftrace.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/kernel/ftrace.c b/arch/ia64/kernel/ftrace.c
index 3b0c2aa07857..cee411e647ca 100644
--- a/arch/ia64/kernel/ftrace.c
+++ b/arch/ia64/kernel/ftrace.c
@@ -97,13 +97,11 @@ ftrace_modify_code(unsigned long ip, unsigned char *old_code,
 	unsigned char replaced[MCOUNT_INSN_SIZE];
 
 	/*
-	 * Note: Due to modules and __init, code can
-	 *  disappear and change, we need to protect against faulting
-	 *  as well as code changing. We do this by using the
-	 *  probe_kernel_* functions.
-	 *
-	 * No real locking needed, this code is run through
-	 * kstop_machine, or before SMP starts.
+	 * Note:
+	 * We are paranoid about modifying text, as if a bug was to happen, it
+	 * could cause us to read or write to someplace that could cause harm.
+	 * Carefully read and modify the code with probe_kernel_*(), and make
+	 * sure what we read is what we expected it to be before modifying it.
 	 */
 
 	if (!do_check)
-- 
2.6.2


