From: Masahiro Yamada <masahiroy@kernel.org>
Date: Wed, 28 Sep 2022 06:39:41 +0000
Subject: [PATCH v3 2/8] kbuild: rebuild .vmlinux.export.o when its prerequisite is updated
Message-Id: <20220928063947.299333-3-masahiroy@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220928063947.299333-1-masahiroy@kernel.org>
In-Reply-To: <20220928063947.299333-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Ard Biesheuvel <ardb@kernel.org>, Nicolas Pitre <npitre@baylibre.com>, Masahiro Yamada <masahiroy@kernel.org>, Michal Marek <michal.lkml@markovi.net>, Nick Desaulniers <ndesaulniers@google.com>

When include/linux/export-internal.h is updated, .vmlinux.export.o
must be rebuilt, but it does not happen because its rule is hidden
behind scripts/link-vmlinux.sh.

Move it out of the shell script, so that Make can see the dependency
between vmlinux and .vmlinux.export.o.

Move the vmlinux rule to scripts/Makefile.vmlinux.

Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
---

Changes in v3:
  - New patch

 Makefile                 | 16 ++++------------
 scripts/Makefile.vmlinux | 21 ++++++++++++++++++++-
 scripts/link-vmlinux.sh  |  5 -----
 3 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/Makefile b/Makefile
index 83d8ff1d521a..79488f155fae 100644
--- a/Makefile
+++ b/Makefile
@@ -1160,17 +1160,9 @@ vmlinux_o: autoksyms_recursive vmlinux.a $(KBUILD_VMLINUX_LIBS)
 vmlinux.o modules.builtin.modinfo modules.builtin: vmlinux_o
 	@:
 
-ARCH_POSTLINK := $(wildcard $(srctree)/arch/$(SRCARCH)/Makefile.postlink)
-
-# Final link of vmlinux with optional arch pass after final link
-cmd_link-vmlinux =                                                 \
-	$(CONFIG_SHELL) $< "$(LD)" "$(KBUILD_LDFLAGS)" "$(LDFLAGS_vmlinux)";    \
-	$(if $(ARCH_POSTLINK), $(MAKE) -f $(ARCH_POSTLINK) $@, true)
-
-vmlinux: scripts/link-vmlinux.sh vmlinux.o $(KBUILD_LDS) modpost FORCE
-	+$(call if_changed_dep,link-vmlinux)
-
-targets += vmlinux
+PHONY += vmlinux
+vmlinux: vmlinux.o $(KBUILD_LDS) modpost
+	$(Q)$(MAKE) -f $(srctree)/scripts/Makefile.vmlinux
 
 # The actual objects are generated when descending,
 # make sure no implicit rule kicks in
@@ -1501,7 +1493,7 @@ endif # CONFIG_MODULES
 # Directories & files removed with 'make clean'
 CLEAN_FILES += include/ksym vmlinux.symvers modules-only.symvers \
 	       modules.builtin modules.builtin.modinfo modules.nsdeps \
-	       compile_commands.json .thinlto-cache .vmlinux.objs
+	       compile_commands.json .thinlto-cache .vmlinux.objs .vmlinux.export.c
 
 # Directories & files removed with 'make mrproper'
 MRPROPER_FILES += include/config include/generated          \
diff --git a/scripts/Makefile.vmlinux b/scripts/Makefile.vmlinux
index 7a63abf22399..49946cb96844 100644
--- a/scripts/Makefile.vmlinux
+++ b/scripts/Makefile.vmlinux
@@ -1,18 +1,37 @@
 # SPDX-License-Identifier: GPL-2.0-only
 
+PHONY := __default
+__default: vmlinux
+
 include include/config/auto.conf
 include $(srctree)/scripts/Kbuild.include
 
 # for c_flags
 include $(srctree)/scripts/Makefile.lib
 
+targets :+
 quiet_cmd_cc_o_c = CC      $@
       cmd_cc_o_c = $(CC) $(c_flags) -c -o $@ $<
 
 %.o: %.c FORCE
 	$(call if_changed_dep,cc_o_c)
 
-targets := $(MAKECMDGOALS)
+ifdef CONFIG_MODULES
+targets += .vmlinux.export.o
+vmlinux: .vmlinux.export.o
+endif
+
+ARCH_POSTLINK := $(wildcard $(srctree)/arch/$(SRCARCH)/Makefile.postlink)
+
+# Final link of vmlinux with optional arch pass after final link
+cmd_link_vmlinux =							\
+	$< "$(LD)" "$(KBUILD_LDFLAGS)" "$(LDFLAGS_vmlinux)";		\
+	$(if $(ARCH_POSTLINK), $(MAKE) -f $(ARCH_POSTLINK) $@, true)
+
+targets += vmlinux
+vmlinux: scripts/link-vmlinux.sh vmlinux.o $(KBUILD_LDS) FORCE
+	+$(call if_changed_dep,link_vmlinux)
 
 # Add FORCE to the prequisites of a target to force it to be always rebuilt.
 # ---------------------------------------------------------------------------
diff --git a/scripts/link-vmlinux.sh b/scripts/link-vmlinux.sh
index e3d42202e54c..918470d768e9 100755
--- a/scripts/link-vmlinux.sh
+++ b/scripts/link-vmlinux.sh
@@ -199,7 +199,6 @@ cleanup()
 	rm -f System.map
 	rm -f vmlinux
 	rm -f vmlinux.map
-	rm -f .vmlinux.export.c
 }
 
 # Use "make V=1" to debug this script
@@ -214,10 +213,6 @@ if [ "$1" = "clean" ]; then
 	exit 0
 fi
 
-if is_enabled CONFIG_MODULES; then
-	${MAKE} -f "${srctree}/scripts/Makefile.vmlinux" .vmlinux.export.o
-fi
-
 ${MAKE} -f "${srctree}/scripts/Makefile.build" obj=init init/version-timestamp.o
 
 btf_vmlinux_bin_o=""
-- 
2.34.1
