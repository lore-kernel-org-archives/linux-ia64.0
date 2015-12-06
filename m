From: Li Bin <huawei.libin@huawei.com>
Date: Sun, 06 Dec 2015 02:02:54 +0000
Subject: [PATCH v2 1/5] ia64: ftrace: fix the comments for ftrace_modify_code
Message-Id: <1449367378-29430-2-git-send-email-huawei.libin@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1449367378-29430-1-git-send-email-huawei.libin@huawei.com>
In-Reply-To: <1449367378-29430-1-git-send-email-huawei.libin@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, Li Bin <huawei.libin@huawei.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

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

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Suggested-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Li Bin <huawei.libin@huawei.com>
---
 arch/ia64/kernel/ftrace.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/kernel/ftrace.c b/arch/ia64/kernel/ftrace.c
index 3b0c2aa..cee411e 100644
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
1.7.1

