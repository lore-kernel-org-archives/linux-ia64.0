From: Keith Owens <kaos@sgi.com>
Date: Fri, 12 Sep 2003 02:25:52 +0000
Subject: [patch] 2.4.22-ia64-030909 build of offsets.h
Message-Id: <marc-linux-ia64-106333361620178@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

2.4.22 deleted include/asm-ia64/offsets.h from the kernel tree.  If
there is no other copy of that file on the include paths (say for cross
compiling) then make dep breaks, offsets.h is required before you can
build offsets.h.

Index: 22.6/arch/ia64/tools/Makefile
--- 22.6/arch/ia64/tools/Makefile Sat, 14 Sep 2002 01:17:57 +1000 kaos (linux-2.4/q/c/1_Makefile 1.1.2.1.1.1 644)
+++ 22.6(w)/arch/ia64/tools/Makefile Fri, 12 Sep 2003 12:20:15 +1000 kaos (linux-2.4/q/c/1_Makefile 1.1.2.1.1.1 644)
@@ -33,7 +33,7 @@ offsets.h: print_offsets
 
 comma	:= ,
 
-print_offsets: print_offsets.c FORCE_RECOMPILE
+print_offsets: emptyoffsets print_offsets.c FORCE_RECOMPILE
 	$(CC) $(CFLAGS) -DKBUILD_BASENAME=$(subst $(comma),_,$(subst -,_,$(*F))) print_offsets.c -o $@
 
 FORCE_RECOMPILE:
@@ -43,9 +43,20 @@ else
 offsets.h: print_offsets.s
 	$(AWK) -f print_offsets.awk $^ > $@
 
-print_offsets.s: print_offsets.c
+print_offsets.s: emptyoffsets print_offsets.c
 	$(CC) $(CFLAGS) -DKBUILD_BASENAME=$(subst $(comma),_,$(subst -,_,$(*F))) -S print_offsets.c -o $@
 
 endif
 
+#
+# The TARGET offsets.h is included by ptrace.h, which is included by
+# print_offsets.c, so can't compile print_offsets.c to create offsets.h
+# until we already have offsets.h.  Break the chicken-and-egg cycle by
+# creating a dummy offsets.h with sufficient define's to bootstrap
+# the first compilation of print_offsets.c.
+#
+
+emptyoffsets:
+	test -f ${TARGET} || echo '#define IA64_TASK_THREAD_OFFSET 0' > ${TARGET}
+
 .PHONY: all modules modules_install

