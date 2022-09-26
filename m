From: Masahiro Yamada <masahiroy@kernel.org>
Date: Mon, 26 Sep 2022 20:36:25 +0000
Subject: [PATCH v2 7/7] kbuild: move modules.builtin(.modinfo) rules to Makefile.vmlinux_o
Message-Id: <20220926203625.1117261-8-masahiroy@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220926203625.1117261-1-masahiroy@kernel.org>
In-Reply-To: <20220926203625.1117261-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Ard Biesheuvel <ardb@kernel.org>, Nicolas Pitre <npitre@baylibre.com>, Masahiro Yamada <masahiroy@kernel.org>, Michal Marek <michal.lkml@markovi.net>, Nick Desaulniers <ndesaulniers@google.com>

Do not build modules.builtin(.modinfo) as a side-effect of vmlinux.

There are no good reason to rebuild them just because vmlinux's
prerequistes (vmlinux.lds, .vmlinux.export.c, etc.) have been updated.

Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
---

Changes in v2:
  - New patch

 scripts/Makefile.vmlinux_o | 26 +++++++++++++++++++++++++-
 scripts/link-vmlinux.sh    |  7 -------
 2 files changed, 25 insertions(+), 8 deletions(-)

diff --git a/scripts/Makefile.vmlinux_o b/scripts/Makefile.vmlinux_o
index 68c22879bade..5e8f75d336af 100644
--- a/scripts/Makefile.vmlinux_o
+++ b/scripts/Makefile.vmlinux_o
@@ -1,7 +1,7 @@
 # SPDX-License-Identifier: GPL-2.0-only
 
 PHONY := __default
-__default: vmlinux.o
+__default: vmlinux.o modules.builtin
 
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
index 9c3140d33ccd..5e7a12284b39 100755
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
