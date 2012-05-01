From: Tony Luck <tony.luck@intel.com>
Date: Tue, 01 May 2012 23:05:49 +0000
Subject: [PATCH] [IA64] Removed "task_size" element from thread_struct - it is now constant
Message-Id: <f570e9ebfaf5eb31a83808ce7c71e574fa716443.1335913478.git.tony.luck@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When the 32-bit compat code was deleted, we should also have removed
the task_size element from the thread structure - threads can only
be 64-bit now, so no need to keep track of how much virtual address
space each task can have ... everyone gets 0xa000000000000000.

Suggested-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 arch/ia64/include/asm/processor.h |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/include/asm/processor.h b/arch/ia64/include/asm/processor.h
index 483f6c6..a1e7022 100644
--- a/arch/ia64/include/asm/processor.h
+++ b/arch/ia64/include/asm/processor.h
@@ -34,8 +34,7 @@
  * each (assuming 8KB page size), for a total of 8TB of user virtual
  * address space.
  */
-#define TASK_SIZE_OF(tsk)	((tsk)->thread.task_size)
-#define TASK_SIZE       	TASK_SIZE_OF(current)
+#define TASK_SIZE       	DEFAULT_TASK_SIZE
 
 /*
  * This decides where the kernel will search for a free chunk of vm
@@ -280,7 +279,6 @@ struct thread_struct {
 	__u8 pad[3];
 	__u64 ksp;			/* kernel stack pointer */
 	__u64 map_base;			/* base address for get_unmapped_area() */
-	__u64 task_size;		/* limit for task size */
 	__u64 rbs_bot;			/* the base address for the RBS */
 	int last_fph_cpu;		/* CPU that may hold the contents of f32-f127 */
 
@@ -303,7 +301,6 @@ struct thread_struct {
 	.ksp =		0,					\
 	.map_base =	DEFAULT_MAP_BASE,			\
 	.rbs_bot =	STACK_TOP - DEFAULT_USER_STACK_SIZE,	\
-	.task_size =	DEFAULT_TASK_SIZE,			\
 	.last_fph_cpu =  -1,					\
 	INIT_THREAD_PM						\
 	.dbr =		{0, },					\
-- 
1.7.9.rc2.1.g69204

