From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 08 Oct 2003 23:52:12 +0000
Subject: [PATCH] Fix IA64 build with separate source and build trees.
Message-Id: <marc-linux-ia64-106565735409518@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



Hi David,
   This patch against 2.6.0-test7 fixes building in a separate output
directory.  Without it, offsets.h isn't built, and the check-gas and
toolchain-flags sscripts aren't found.


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	v2.6.0-test7 -> 1.1512 
#	  arch/ia64/Makefile	1.60    -> 1.62   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/08	torvalds@home.osdl.org	1.1510
# Linux 2.6.0-test7
# --------------------------------------------
# 03/10/09	peterc@gelato.unsw.edu.au	1.1511
# Fix IA64 build with separate source and build trees.
# --------------------------------------------
# 03/10/09	peterc@gelato.unsw.edu.au	1.1512
# [IA64] arch/ia64/Makefile: Fix as per Sam Ravnborg's request: use $(srctree) not $(src)
# --------------------------------------------
#
diff -Nru a/arch/ia64/Makefile b/arch/ia64/Makefile
--- a/arch/ia64/Makefile	Thu Oct  9 09:49:12 2003
+++ b/arch/ia64/Makefile	Thu Oct  9 09:49:12 2003
@@ -25,9 +25,9 @@
 GCC_VERSION=$(shell $(CC) -v 2>&1 | fgrep 'gcc version' | cut -f3 -d' ' | cut -f1 -d'.')
 GCC_MINOR_VERSION=$(shell $(CC) -v 2>&1 | fgrep 'gcc version' | cut -f3 -d' ' | cut -f2 -d'.')
 
-GAS_STATUS=$(shell arch/ia64/scripts/check-gas $(CC) $(OBJDUMP))
+GAS_STATUS=$(shell $(srctree)/arch/ia64/scripts/check-gas $(CC) $(OBJDUMP))
 
-CPPFLAGS	+= $(shell arch/ia64/scripts/toolchain-flags $(CC) $(OBJDUMP))
+CPPFLAGS	+= $(shell $(srctree)/arch/ia64/scripts/toolchain-flags $(CC) $(OBJDUMP))
 
 ifeq ($(GAS_STATUS),buggy)
 $(error Sorry, you need a newer version of the assember, one that is built from	\
@@ -84,18 +84,21 @@
 archclean:
 	$(Q)$(MAKE) $(clean)=$(boot)
 
-CLEAN_FILES += include/asm-ia64/.offsets.h.stamp include/asm-ia64/offsets.h vmlinux.gz bootloader
+CLEAN_FILES += include/asm-$(ARCH)/.offsets.h.stamp include/asm-$(ARCH)/offsets.h vmlinux.gz bootloader
 
-prepare: include/asm-ia64/offsets.h
+prepare: include/asm-$(ARCH)/offsets.h
+
+arch/$(ARCH)/kernel/asm-offsets.s: include/asm include/linux/version.h
 
 include/asm-$(ARCH)/offsets.h: arch/$(ARCH)/kernel/asm-offsets.s
 	$(call filechk,gen-asm-offsets)
 
-arch/ia64/kernel/asm-offsets.s: include/asm-ia64/.offsets.h.stamp
+arch/ia64/kernel/asm-offsets.s: include/asm-$(ARCH)/.offsets.h.stamp
 
-include/asm-ia64/.offsets.h.stamp:
-	[ -s include/asm-ia64/offsets.h ] \
-	 || echo "#define IA64_TASK_SIZE 0" > include/asm-ia64/offsets.h
+include/asm-$(ARCH)/.offsets.h.stamp:
+	mkdir -p include/asm-$(ARCH)
+	[ -s include/asm-$(ARCH)/offsets.h ] \
+	 || echo "#define IA64_TASK_SIZE 0" > include/asm-$(ARCH)/offsets.h
 	touch $@
 
 boot:	lib/lib.a vmlinux
