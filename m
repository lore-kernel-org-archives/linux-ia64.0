From: Masahiro Yamada <masahiroy@kernel.org>
Date: Wed, 28 Sep 2022 06:39:40 +0000
Subject: [PATCH v3 1/8] kbuild: move modules.builtin(.modinfo) rules to Makefile.vmlinux_o
Message-Id: <20220928063947.299333-2-masahiroy@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220928063947.299333-1-masahiroy@kernel.org>
In-Reply-To: <20220928063947.299333-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Ard Biesheuvel <ardb@kernel.org>, Nicolas Pitre <npitre@baylibre.com>, Masahiro Yamada <masahiroy@kernel.org>, Michal Marek <michal.lkml@markovi.net>, Nick Desaulniers <ndesaulniers@google.com>

Do not build modules.builtin(.modinfo) as a side-effect of vmlinux.

There are no good reason to rebuild them just because any of vmlinux's
prerequistes (vmlinux.lds, .vmlinux.export.c, etc.) has been updated.

Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
---

Changes in v3:
  - Move to the head of the series

Changes in v2:
  - New patch

 Makefile                   |  6 +++++-
 scripts/Makefile.vmlinux_o | 26 +++++++++++++++++++++++++-
 scripts/link-vmlinux.sh    |  7 -------
 3 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/Makefile b/Makefile
index 2b4980490ecb..83d8ff1d521a 100644
--- a/Makefile
+++ b/Makefile
@@ -1153,9 +1153,13 @@ targets += vmlinux.a
 vmlinux.a: $(KBUILD_VMLINUX_OBJS) scripts/head-object-list.txt FORCE
 	$(call if_changed,ar_vmlinux.a)
 
-vmlinux.o: autoksyms_recursive vmlinux.a $(KBUILD_VMLINUX_LIBS) FORCE
+PHONY += vmlinux_o
+vmlinux_o: autoksyms_recursive vmlinux.a $(KBUILD_VMLINUX_LIBS)
 	$(Q)$(MAKE) -f $(srctree)/scripts/Makefile.vmlinux_o
 
+vmlinux.o modules.builtin.modinfo modules.builtin: vmlinux_o
+	@:
+
 ARCH_POSTLINK := $(wildcard $(srctree)/arch/$(SRCARCH)/Makefile.postlink)
 
 # Final link of vmlinux with optional arch pass after final link
diff --git a/scripts/Makefile.vmlinux_o b/scripts/Makefile.vmlinux_o
index 68c22879bade..0edfdb40364b 100644
--- a/scripts/Makefile.vmlinux_o
+++ b/scripts/Makefile.vmlinux_o
@@ -1,7 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0-only
 
 PHONY := __default
-__default: vmlinux.o
+__default: vmlinux.o modules.builtin.modinfo modules.builtin
 
 include include/config/auto.conf
 include $(srctree)/scripts/Kbuild.include
@@ -62,6 +62,30 @@ vmlinux.o: $(initcalls-lds) vmlinux.a $(KBUILD_VMLINUX_LIBS) FORCE
 
 targets += vmlinux.o
 
+# module.builtin.modinfo
+# ---------------------------------------------------------------------------
+
+OBJCOPYFLAGS_modules.builtin.modinfo := -j .modinfo -O binary
+
+targets += modules.builtin.modinfo
+modules.builtin.modinfo: vmlinux.o FORCE
+	$(call if_changed,objcopy)
+
+# module.builtin
+# ---------------------------------------------------------------------------
+
+# The second line aids cases where multiple modules share the same object.
+
+quiet_cmd_modules_builtin = GEN     $@
+      cmd_modules_builtin = \
+	tr '\0' '\n' < $< | \
+	sed -n 's/^[[:alnum:]:_]*\.file=//p' | \
+	tr ' ' '\n' | uniq | sed -e 's:^:kernel/:' -e 's/$$/.ko/' > $@
+
+targets += modules.builtin
+modules.builtin: modules.builtin.modinfo FORCE
+	$(call if_changed,modules_builtin)
+
 # Add FORCE to the prequisites of a target to force it to be always rebuilt.
 # ---------------------------------------------------------------------------
 
diff --git a/scripts/link-vmlinux.sh b/scripts/link-vmlinux.sh
index 2782c5d1518b..e3d42202e54c 100755
--- a/scripts/link-vmlinux.sh
+++ b/scripts/link-vmlinux.sh
@@ -214,13 +214,6 @@ if [ "$1" = "clean" ]; then
 	exit 0
 fi
 
-info MODINFO modules.builtin.modinfo
-${OBJCOPY} -j .modinfo -O binary vmlinux.o modules.builtin.modinfo
-info GEN modules.builtin
-# The second line aids cases where multiple modules share the same object.
-tr '\0' '\n' < modules.builtin.modinfo | sed -n 's/^[[:alnum:]:_]*\.file=//p' |
-	tr ' ' '\n' | uniq | sed -e 's:^:kernel/:' -e 's/$/.ko/' > modules.builtin
-
 if is_enabled CONFIG_MODULES; then
 	${MAKE} -f "${srctree}/scripts/Makefile.vmlinux" .vmlinux.export.o
 fi
-- 
2.34.1
