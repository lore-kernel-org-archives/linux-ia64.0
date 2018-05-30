From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Date: Wed, 30 May 2018 20:48:38 +0000
Subject: [PATCH] kbuild: add machine size to CHEKCFLAGS
Message-Id: <20180530204838.22079-1-luc.vanoostenryck@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Michal Marek <michal.lkml@markovi.net>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, "James E . J . Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Brendan Higgins <brendanhiggins@google.com>, Martin Blumenstingl <martin.blumenstingl@googlemail.com>

By default, sparse assumes a 64bit machine when compiled on x86-64
and 32bit when compiled on anything else.

This can of course create all sort of problems for the other archs, like
issuing false warnings ('shift too big (32) for type unsigned long'), or
worse, failing to emit legitimate warnings.

Fix this by adding the -m32/-m64 flag, depending on CONFIG_64BIT,
to CHECKFLAGS in the main Makefile (and so for all archs).
Also, remove the now unneeded -m32/-m64 in arch specific Makefiles.

Signed-off-by: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
---
 Makefile             | 3 +++
 arch/alpha/Makefile  | 2 +-
 arch/arm/Makefile    | 2 +-
 arch/arm64/Makefile  | 2 +-
 arch/ia64/Makefile   | 2 +-
 arch/mips/Makefile   | 3 ---
 arch/parisc/Makefile | 2 +-
 arch/sparc/Makefile  | 2 +-
 arch/x86/Makefile    | 2 +-
 9 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/Makefile b/Makefile
index 6c6610913..18379987c 100644
--- a/Makefile
+++ b/Makefile
@@ -881,6 +881,9 @@ endif
 # insure the checker run with the right endianness
 CHECKFLAGS += $(if $(CONFIG_CPU_BIG_ENDIAN),-mbig-endian,-mlittle-endian)
 
+# the checker needs the correct machine size
+CHECKFLAGS += $(if $(CONFIG_64BIT),-m64,-m32)
+
 # Default kernel image to build when no specific target is given.
 # KBUILD_IMAGE may be overruled on the command line or
 # set in the environment
diff --git a/arch/alpha/Makefile b/arch/alpha/Makefile
index 2cc3cc519..c5ec8c09c 100644
--- a/arch/alpha/Makefile
+++ b/arch/alpha/Makefile
@@ -11,7 +11,7 @@
 NM := $(NM) -B
 
 LDFLAGS_vmlinux	:= -static -N #-relax
-CHECKFLAGS	+= -D__alpha__ -m64
+CHECKFLAGS	+= -D__alpha__
 cflags-y	:= -pipe -mno-fp-regs -ffixed-8
 cflags-y	+= $(call cc-option, -fno-jump-tables)
 
diff --git a/arch/arm/Makefile b/arch/arm/Makefile
index e4e537f27..f32a5468d 100644
--- a/arch/arm/Makefile
+++ b/arch/arm/Makefile
@@ -135,7 +135,7 @@ endif
 KBUILD_CFLAGS	+=$(CFLAGS_ABI) $(CFLAGS_ISA) $(arch-y) $(tune-y) $(call cc-option,-mshort-load-bytes,$(call cc-option,-malignment-traps,)) -msoft-float -Uarm
 KBUILD_AFLAGS	+=$(CFLAGS_ABI) $(AFLAGS_ISA) $(arch-y) $(tune-y) -include asm/unified.h -msoft-float
 
-CHECKFLAGS	+= -D__arm__ -m32
+CHECKFLAGS	+= -D__arm__
 
 #Default value
 head-y		:= arch/arm/kernel/head$(MMUEXT).o
diff --git a/arch/arm64/Makefile b/arch/arm64/Makefile
index 87f7d2f9f..3c353b471 100644
--- a/arch/arm64/Makefile
+++ b/arch/arm64/Makefile
@@ -78,7 +78,7 @@ LDFLAGS		+= -maarch64linux
 UTS_MACHINE	:= aarch64
 endif
 
-CHECKFLAGS	+= -D__aarch64__ -m64
+CHECKFLAGS	+= -D__aarch64__
 
 ifeq ($(CONFIG_ARM64_MODULE_PLTS),y)
 KBUILD_LDFLAGS_MODULE	+= -T $(srctree)/arch/arm64/kernel/module.lds
diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 2dd7f519a..45f59808b 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -18,7 +18,7 @@ READELF := $(CROSS_COMPILE)readelf
 
 export AWK
 
-CHECKFLAGS	+= -m64 -D__ia64=1 -D__ia64__=1 -D_LP64 -D__LP64__
+CHECKFLAGS	+= -D__ia64=1 -D__ia64__=1 -D_LP64 -D__LP64__
 
 OBJCOPYFLAGS	:= --strip-all
 LDFLAGS_vmlinux	:= -static
diff --git a/arch/mips/Makefile b/arch/mips/Makefile
index 5e9fce076..e2122cca4 100644
--- a/arch/mips/Makefile
+++ b/arch/mips/Makefile
@@ -309,9 +309,6 @@ ifdef CONFIG_MIPS
 CHECKFLAGS += $(shell $(CC) $(KBUILD_CFLAGS) -dM -E -x c /dev/null | \
 	egrep -vw '__GNUC_(|MINOR_|PATCHLEVEL_)_' | \
 	sed -e "s/^\#define /-D'/" -e "s/ /'='/" -e "s/$$/'/" -e 's/\$$/&&/g')
-ifdef CONFIG_64BIT
-CHECKFLAGS		+= -m64
-endif
 endif
 
 OBJCOPYFLAGS		+= --remove-section=.reginfo
diff --git a/arch/parisc/Makefile b/arch/parisc/Makefile
index 348ae4779..714284ea6 100644
--- a/arch/parisc/Makefile
+++ b/arch/parisc/Makefile
@@ -28,7 +28,7 @@ export LIBGCC
 
 ifdef CONFIG_64BIT
 UTS_MACHINE	:= parisc64
-CHECKFLAGS	+= -D__LP64__=1 -m64
+CHECKFLAGS	+= -D__LP64__=1
 CC_ARCHES	= hppa64
 LD_BFD		:= elf64-hppa-linux
 else # 32-bit
diff --git a/arch/sparc/Makefile b/arch/sparc/Makefile
index edac927e4..966a13d2b 100644
--- a/arch/sparc/Makefile
+++ b/arch/sparc/Makefile
@@ -39,7 +39,7 @@ else
 # sparc64
 #
 
-CHECKFLAGS    += -D__sparc__ -D__sparc_v9__ -D__arch64__ -m64
+CHECKFLAGS    += -D__sparc__ -D__sparc_v9__ -D__arch64__
 LDFLAGS       := -m elf64_sparc
 export BITS   := 64
 UTS_MACHINE   := sparc64
diff --git a/arch/x86/Makefile b/arch/x86/Makefile
index 60135cbd9..f0a6ea224 100644
--- a/arch/x86/Makefile
+++ b/arch/x86/Makefile
@@ -94,7 +94,7 @@ ifeq ($(CONFIG_X86_32),y)
 else
         BITS := 64
         UTS_MACHINE := x86_64
-        CHECKFLAGS += -D__x86_64__ -m64
+        CHECKFLAGS += -D__x86_64__
 
         biarch := -m64
         KBUILD_AFLAGS += -m64
-- 
2.17.0

