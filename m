From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Fri, 10 Oct 2003 00:38:59 +0000
Subject: [PATCH] fix IA64 builds for separate build and source trees.
Message-Id: <marc-linux-ia64-106574637501123@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


After all the discsussion, here's a patch that I *think* addresses all
the things that people have reported.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	v2.6.0-test7 -> 1.1513 
#	  arch/ia64/Makefile	1.60    -> 1.63   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/08	torvalds@home.osdl.org	1.1510
# Linux 2.6.0-test7
# --------------------------------------------
# 03/10/09	peterc@gelato.unsw.edu.au	1.1511
# Refer to scripts in the source tree explicitly
# --------------------------------------------
# 03/10/09	peterc@gelato.unsw.edu.au	1.1512
# [IA64] arch/ia64/Makefile: Fix as per Sam Ravnborg's request: use $(srctree) not $(src)
# --------------------------------------------
# 03/10/10	peterc@gelato.unsw.edu.au	1.1513
# Undo the ia64->$(ARCH) cosmetic change
# --------------------------------------------
#
diff -Nru a/arch/ia64/Makefile b/arch/ia64/Makefile
--- a/arch/ia64/Makefile	Fri Oct 10 10:34:32 2003
+++ b/arch/ia64/Makefile	Fri Oct 10 10:34:32 2003
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
