From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 14 Sep 2005 22:23:00 +0000
Subject: bugfix git pull on ia64 linux tree
Message-Id: <200509142223.j8EMN0qk011773@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

Bugfix only pull from my ia64 release tree.

	rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

The new and improved asm-offsets.h generation has tripped over a long
standing issue with dependencies in the ia64 tree:  namely that files
that use the symbol IA64_TASK_SIZE are included in our asm-offsets.c
which creates a circular dependency.  This didn't used to hurt too badly
because kbuild had incomplete dependency information, but now I see
about a third of the from-scratch builds fail because we end up with
just the fake definition of IA64_TASK_SIZE in asm-offsets.h, and Peter
Chubb reports that subsequent builds recompile everything because we
regenerate asm-offsets.h every time.

Solving the circular dependency is not a suitable patch for a -rc1
time frame, so I proposed this tasteless hack.  Sam Ravnborg "blessed"
it with the comment: "I have no better ideas than this one."

Thanks!

-Tony

 arch/ia64/Makefile             |   12 +-----------
 arch/ia64/kernel/asm-offsets.c |    1 +
 include/asm-ia64/ptrace.h      |    2 ++
 include/asm-ia64/thread_info.h |    7 +++++++
 4 files changed, 11 insertions(+), 11 deletions(-)

Tony Luck:
  [IA64] fix circular dependency on generation of asm-offsets.h

diff-tree 82f1b07b9ad88066c0fa867dd6b32ce43ae7ad22 (from 2f4ba45a75d6383b4a1201169a808ffea416ffa0)
Author: Tony Luck <tony.luck@intel.com>
Date:   Tue Sep 13 08:50:39 2005 -0700

    [IA64] fix circular dependency on generation of asm-offsets.h
    
    Fix?  One ugly hack is replaced by a different ugly hack.
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -82,17 +82,7 @@ unwcheck: vmlinux
 archclean:
 	$(Q)$(MAKE) $(clean)=$(boot)
 
-archprepare:  include/asm-ia64/.offsets.h.stamp
-
-include/asm-ia64/.offsets.h.stamp:
-	mkdir -p include/asm-ia64
-	[ -s include/asm-ia64/asm-offsets.h ] \
-	|| echo "#define IA64_TASK_SIZE 0" > include/asm-ia64/asm-offsets.h
-	touch $@
-
-
-
-CLEAN_FILES += vmlinux.gz bootloader include/asm-ia64/.offsets.h.stamp
+CLEAN_FILES += vmlinux.gz bootloader
 
 boot:	lib/lib.a vmlinux
 	$(Q)$(MAKE) $(build)=$(boot) $@
diff --git a/arch/ia64/kernel/asm-offsets.c b/arch/ia64/kernel/asm-offsets.c
--- a/arch/ia64/kernel/asm-offsets.c
+++ b/arch/ia64/kernel/asm-offsets.c
@@ -4,6 +4,7 @@
  * to extract and format the required data.
  */
 
+#define ASM_OFFSETS_C 1
 #include <linux/config.h>
 
 #include <linux/sched.h>
diff --git a/include/asm-ia64/ptrace.h b/include/asm-ia64/ptrace.h
--- a/include/asm-ia64/ptrace.h
+++ b/include/asm-ia64/ptrace.h
@@ -57,7 +57,9 @@
 #include <linux/config.h>
 
 #include <asm/fpu.h>
+#ifndef ASM_OFFSETS_C
 #include <asm/asm-offsets.h>
+#endif
 
 /*
  * Base-2 logarithm of number of pages to allocate per task structure
diff --git a/include/asm-ia64/thread_info.h b/include/asm-ia64/thread_info.h
--- a/include/asm-ia64/thread_info.h
+++ b/include/asm-ia64/thread_info.h
@@ -5,7 +5,9 @@
 #ifndef _ASM_IA64_THREAD_INFO_H
 #define _ASM_IA64_THREAD_INFO_H
 
+#ifndef ASM_OFFSETS_C
 #include <asm/asm-offsets.h>
+#endif
 #include <asm/processor.h>
 #include <asm/ptrace.h>
 
@@ -51,9 +53,14 @@ struct thread_info {
 	},					\
 }
 
+#ifndef ASM_OFFSETS_C
 /* how to get the thread information struct from C */
 #define current_thread_info()	((struct thread_info *) ((char *) current + IA64_TASK_SIZE))
 #define alloc_thread_info(tsk)	((struct thread_info *) ((char *) (tsk) + IA64_TASK_SIZE))
+#else
+#define current_thread_info()	((struct thread_info *) 0)
+#define alloc_thread_info(tsk)	((struct thread_info *) 0)
+#endif
 #define free_thread_info(ti)	/* nothing */
 
 #define __HAVE_ARCH_TASK_STRUCT_ALLOCATOR
