From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Mon, 03 Nov 2003 23:59:07 +0000
Subject: [Patch] Fix IA64 compilation with separate build tree.
Message-Id: <marc-linux-ia64-106790402625772@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi David,
   The appended patch (as we discussed before) is necessary to allow
separate source and build trees for IA64.  Without it, offsets.h
cannot be built if you do, say,
       make O=../build/linux-2.5-ia64
and the gas checks never succeed.

diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-import/arch/ia64/Makefile linux-2.5-ia64-up/arch/ia64/Makefile
--- linux-2.5-import/arch/ia64/Makefile	Wed Oct 15 15:30:03 2003
+++ linux-2.5-ia64-up/arch/ia64/Makefile	Wed Oct 15 15:43:31 2003
@@ -14,7 +14,7 @@
 
 OBJCOPYFLAGS	:= --strip-all
 LDFLAGS_vmlinux	:= -static
-LDFLAGS_MODULE	+= -T arch/ia64/module.lds
+LDFLAGS_MODULE	+= -T $(srctree)/arch/ia64/module.lds
 AFLAGS_KERNEL	:= -mconstant-gp
 EXTRA		: 
@@ -25,9 +25,9 @@
 GCC_VERSION=$(shell $(CC) -v 2>&1 | fgrep 'gcc version' | cut -f3 -d' ' | cut -f1 -d'.')
 GCC_MINOR_VERSION=$(shell $(CC) -v 2>&1 | fgrep 'gcc version' | cut -f3 -d' ' | cut -f2 -d'.')
 
-GAS_STATUS=$(shell arch/ia64/scripts/check-gas $(CC) $(OBJDUMP))
+GAS_STATUS=$(shell $(srctree)/arch/ia64/scripts/check-gas $(CC) $(OBJDUMP))
 
-CPPFLAGS	+= $(shell arch/ia64/scripts/toolchain-flags $(CC) $(OBJDUMP))
+CPPFLAGS	+= $(shell $(srctree)/arch/ia64/scripts/toolchain-flags $(CC) $(OBJDUMP))
 
 ifeq ($(GAS_STATUS),buggy)
 $(error Sorry, you need a newer version of the assember, one that is built from	\
@@ -88,12 +88,15 @@
 
 prepare: include/asm-ia64/offsets.h
 
-include/asm-$(ARCH)/offsets.h: arch/$(ARCH)/kernel/asm-offsets.s
+arch/ia64/kernel/asm-offsets.s: include/asm include/linux/version.h
+
+include/asm-ia64/offsets.h: arch/ia64/kernel/asm-offsets.s
 	$(call filechk,gen-asm-offsets)
 
 arch/ia64/kernel/asm-offsets.s: include/asm-ia64/.offsets.h.stamp
 
 include/asm-ia64/.offsets.h.stamp:
+	mkdir -p include/asm-ia64
 	[ -s include/asm-ia64/offsets.h ] \
 	 || echo "#define IA64_TASK_SIZE 0" > include/asm-ia64/offsets.h
 	touch $@
