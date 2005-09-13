From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 13 Sep 2005 16:02:15 +0000
Subject: ia64 circular dependency on asm-offsets.h
Message-Id: <200509131602.j8DG2Ffr005104@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am not proud of this patch (but Linus has already declared that
I have no taste :-).  More of a case of changing out one ugly hack for
a new ugly hack.  It's only merit is that this ugly hack works, where
the old one has run into terminal problems.

But unless someone can see a better way to fix this (in a simple patch
suitable for merging in -rc1 ... I'll be ecstatic to entertain better
patches for 2.6.15) then I'm going to submit it to Linus.

-Tony

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
