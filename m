From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Thu, 18 Dec 2003 09:28:39 +0000
Subject: [PATCH] enable out-of-tree compilation for IA64
Message-Id: <marc-linux-ia64-107173976509987@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi David,
   You said to send this along for 2.6.1
2.6.0 has just been announced....

This patch enables make O=../build/linux-ia64
for ia64 kernels.  It is against 2.6.0.

diff -Nru a/arch/ia64/Makefile b/arch/ia64/Makefile
--- a/arch/ia64/Makefile	Thu Dec 18 20:25:40 2003
+++ b/arch/ia64/Makefile	Thu Dec 18 20:25:40 2003
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
