From: Jan Kiszka <jan.kiszka@siemens.com>
Date: Mon, 28 Oct 2013 08:58:52 +0000
Subject: [PATCH v6 15/21] scripts/gdb: Add internal helper and convenience function to retrieve thread_info
Message-Id: <8e65e1db9430686f890d9ba31aacbc763dfd2930.1382950737.git.jan.kiszka@siemens.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1382950737.git.jan.kiszka@siemens.com>
In-Reply-To: <cover.1382950737.git.jan.kiszka@siemens.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Jason Wessel <jason.wessel@windriver.com>, kgdb-bugreport@lists.sourceforge.net, Andi Kleen <andi@firstfloor.org>, Tom Tromey <tromey@redhat.com>, Ben Widawsky <ben@bwidawsk.net>, Borislav Petkov <bp@suse.de>, Tatiana Al-Chueyr Martins <tatiana.alchueyr@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Add the internal helper get_thread_info that calculates the thread_info
from a given task variable. Also export this service as a convenience
function.

Note: ia64 version is untested.

CC: Tony Luck <tony.luck@intel.com>
CC: Fenghua Yu <fenghua.yu@intel.com>
CC: linux-ia64@vger.kernel.org
Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
---
 scripts/gdb/linux/tasks.py | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/scripts/gdb/linux/tasks.py b/scripts/gdb/linux/tasks.py
index 13bb97c..63cd6c5 100644
--- a/scripts/gdb/linux/tasks.py
+++ b/scripts/gdb/linux/tasks.py
@@ -71,3 +71,38 @@ return that task_struct variable which PID matches."""
 
 
 LxTaskByPidFunc()
+
+
+thread_info_type = utils.CachedType("struct thread_info")
+
+ia64_task_size = None
+
+
+def get_thread_info(task):
+    global thread_info_type
+    thread_info_ptr_type = thread_info_type.get_type().pointer()
+    if utils.is_target_arch("ia64"):
+        global ia64_task_size
+        if ia64_task_size is None:
+            ia64_task_size = gdb.parse_and_eval("sizeof(struct task_struct)")
+        thread_info_addr = task.address + ia64_task_size
+        thread_info = thread_info_addr.cast(thread_info_ptr_type)
+    else:
+        thread_info = task['stack'].cast(thread_info_ptr_type)
+    return thread_info.dereference()
+
+
+class LxThreadInfoFunc (gdb.Function):
+    """Calculate Linux thread_info from task variable.
+
+$lx_thread_info(TASK): Given TASK, return the corresponding thread_info
+variable."""
+
+    def __init__(self):
+        super(LxThreadInfoFunc, self).__init__("lx_thread_info")
+
+    def invoke(self, task):
+        return get_thread_info(task)
+
+
+LxThreadInfoFunc()
-- 
1.8.1.1.298.ge7eed54

