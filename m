From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Wed, 14 Aug 2019 16:06:22 +0000
Subject: [PATCH 2/3] kbuild: rebuild modules when module linker scripts are updated
Message-Id: <20190814160623.24802-2-yamada.masahiro@socionext.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190814160623.24802-1-yamada.masahiro@socionext.com>
In-Reply-To: <20190814160623.24802-1-yamada.masahiro@socionext.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, Albert Ou <aou@eecs.berkeley.edu>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Helge Deller <deller@gmx.de>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Jonathan Corbet <corbet@lwn.net>, Michael Ellerman <mpe@ellerman.id.au>, Michal Marek <michal.lkml@markovi.net>, Palmer Dabbelt <palmer@sifive.com>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Will Deacon <will@kernel.org>, linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, linuxppc-dev@lists.ozlabs.org

Currently, the timestamp of module linker scripts are not checked.
Add them to the dependency of modules so they are correctly rebuilt.

Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
---

 Documentation/kbuild/makefiles.rst | 5 +++++
 Makefile                           | 3 ++-
 arch/arm/Makefile                  | 2 +-
 arch/arm64/Makefile                | 2 +-
 arch/ia64/Makefile                 | 2 +-
 arch/m68k/Makefile                 | 2 +-
 arch/parisc/Makefile               | 2 +-
 arch/powerpc/Makefile              | 2 +-
 arch/riscv/Makefile                | 2 +-
 scripts/Makefile.modpost           | 5 +++--
 10 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/Documentation/kbuild/makefiles.rst b/Documentation/kbuild/makefiles.rst
index d3448d2c8017..36ba92e199d2 100644
--- a/Documentation/kbuild/makefiles.rst
+++ b/Documentation/kbuild/makefiles.rst
@@ -999,6 +999,11 @@ When kbuild executes, the following steps are followed (roughly):
 
 	The linker script with full path. Assigned by the top-level Makefile.
 
+    KBUILD_LDS_MODULE
+
+	The module linker script with full path. Assigned by the top-level
+	Makefile and additionally by the arch Makefile.
+
     KBUILD_VMLINUX_OBJS
 
 	All object files for vmlinux. They are linked to vmlinux in the same
diff --git a/Makefile b/Makefile
index 164ca615e2f6..af808837a1f2 100644
--- a/Makefile
+++ b/Makefile
@@ -485,7 +485,8 @@ KBUILD_AFLAGS_KERNEL : KBUILD_CFLAGS_KERNEL : KBUILD_AFLAGS_MODULE  := -DMODULE
 KBUILD_CFLAGS_MODULE  := -DMODULE
-KBUILD_LDFLAGS_MODULE := -T $(srctree)/scripts/module-common.lds
+KBUILD_LDFLAGS_MODULE :+export KBUILD_LDS_MODULE := $(srctree)/scripts/module-common.lds
 KBUILD_LDFLAGS : GCC_PLUGINS_CFLAGS : CLANG_FLAGS :diff --git a/arch/arm/Makefile b/arch/arm/Makefile
index c3624ca6c0bc..fbe50eec8f34 100644
--- a/arch/arm/Makefile
+++ b/arch/arm/Makefile
@@ -17,7 +17,7 @@ KBUILD_LDFLAGS_MODULE	+= --be8
 endif
 
 ifeq ($(CONFIG_ARM_MODULE_PLTS),y)
-KBUILD_LDFLAGS_MODULE	+= -T $(srctree)/arch/arm/kernel/module.lds
+KBUILD_LDS_MODULE	+= $(srctree)/arch/arm/kernel/module.lds
 endif
 
 GZFLAGS		:=-9
diff --git a/arch/arm64/Makefile b/arch/arm64/Makefile
index 61de992bbea3..d4ed1869e536 100644
--- a/arch/arm64/Makefile
+++ b/arch/arm64/Makefile
@@ -101,7 +101,7 @@ endif
 CHECKFLAGS	+= -D__aarch64__
 
 ifeq ($(CONFIG_ARM64_MODULE_PLTS),y)
-KBUILD_LDFLAGS_MODULE	+= -T $(srctree)/arch/arm64/kernel/module.lds
+KBUILD_LDS_MODULE	+= $(srctree)/arch/arm64/kernel/module.lds
 endif
 
 # Default value
diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 171290f9f1de..5c3bcaee5980 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -20,7 +20,7 @@ CHECKFLAGS	+= -D__ia64=1 -D__ia64__=1 -D_LP64 -D__LP64__
 
 OBJCOPYFLAGS	:= --strip-all
 LDFLAGS_vmlinux	:= -static
-KBUILD_LDFLAGS_MODULE += -T $(srctree)/arch/ia64/module.lds
+KBUILD_LDS_MODULE += $(srctree)/arch/ia64/module.lds
 KBUILD_AFLAGS_KERNEL := -mconstant-gp
 EXTRA		: 
diff --git a/arch/m68k/Makefile b/arch/m68k/Makefile
index 482513b9af2c..5d9288384096 100644
--- a/arch/m68k/Makefile
+++ b/arch/m68k/Makefile
@@ -73,7 +73,7 @@ KBUILD_AFLAGS += -D__uClinux__
 endif
 
 KBUILD_LDFLAGS := -m m68kelf
-KBUILD_LDFLAGS_MODULE += -T $(srctree)/arch/m68k/kernel/module.lds
+KBUILD_LDS_MODULE += $(srctree)/arch/m68k/kernel/module.lds
 
 ifdef CONFIG_SUN3
 LDFLAGS_vmlinux = -N
diff --git a/arch/parisc/Makefile b/arch/parisc/Makefile
index 3b77d729057f..36b834f1c933 100644
--- a/arch/parisc/Makefile
+++ b/arch/parisc/Makefile
@@ -60,7 +60,7 @@ KBUILD_CFLAGS += -DCC_USING_PATCHABLE_FUNCTION_ENTRY=1 \
 		 -DFTRACE_PATCHABLE_FUNCTION_SIZE=$(NOP_COUNT)
 
 CC_FLAGS_FTRACE := -fpatchable-function-entry=$(NOP_COUNT),$(shell echo $$(($(NOP_COUNT)-1)))
-KBUILD_LDFLAGS_MODULE += -T $(srctree)/arch/parisc/kernel/module.lds
+KBUILD_LDS_MODULE += $(srctree)/arch/parisc/kernel/module.lds
 endif
 
 OBJCOPY_FLAGS =-O binary -R .note -R .comment -S
diff --git a/arch/powerpc/Makefile b/arch/powerpc/Makefile
index c345b79414a9..b2227855de20 100644
--- a/arch/powerpc/Makefile
+++ b/arch/powerpc/Makefile
@@ -67,7 +67,7 @@ UTS_MACHINE := $(subst $(space),,$(machine-y))
 ifdef CONFIG_PPC32
 KBUILD_LDFLAGS_MODULE += arch/powerpc/lib/crtsavres.o
 else
-KBUILD_LDFLAGS_MODULE += -T $(srctree)/arch/powerpc/kernel/module.lds
+KBUILD_LDS_MODULE += $(srctree)/arch/powerpc/kernel/module.lds
 ifeq ($(call ld-ifversion, -ge, 225000000, y),y)
 # Have the linker provide sfpr if possible.
 # There is a corresponding test in arch/powerpc/lib/Makefile
diff --git a/arch/riscv/Makefile b/arch/riscv/Makefile
index 7a117be8297c..426d989125a8 100644
--- a/arch/riscv/Makefile
+++ b/arch/riscv/Makefile
@@ -52,7 +52,7 @@ ifeq ($(CONFIG_CMODEL_MEDANY),y)
 	KBUILD_CFLAGS += -mcmodel=medany
 endif
 ifeq ($(CONFIG_MODULE_SECTIONS),y)
-	KBUILD_LDFLAGS_MODULE += -T $(srctree)/arch/riscv/kernel/module.lds
+	KBUILD_LDS_MODULE += $(srctree)/arch/riscv/kernel/module.lds
 endif
 
 KBUILD_CFLAGS_MODULE += $(call cc-option,-mno-relax)
diff --git a/scripts/Makefile.modpost b/scripts/Makefile.modpost
index bf15818f6947..905db30d6622 100644
--- a/scripts/Makefile.modpost
+++ b/scripts/Makefile.modpost
@@ -126,10 +126,11 @@ quiet_cmd_ld_ko_o = LD [M]  $@
       cmd_ld_ko_o =                                                     \
 	$(LD) -r $(KBUILD_LDFLAGS)                                      \
                  $(KBUILD_LDFLAGS_MODULE) $(LDFLAGS_MODULE)             \
-                 -o $@ $(real-prereqs) ;                                \
+                 $(addprefix -T , $(KBUILD_LDS_MODULE))                 \
+                 -o $@ $(filter %.o, $^);                               \
 	$(if $(ARCH_POSTLINK), $(MAKE) -f $(ARCH_POSTLINK) $@, true)
 
-$(modules): %.ko :%.o %.mod.o FORCE
+$(modules): %.ko :%.o %.mod.o $(KBUILD_LDS_MODULE) FORCE
 	+$(call if_changed,ld_ko_o)
 
 targets += $(modules)
-- 
2.17.1
