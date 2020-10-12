From: Ujjwal Kumar <ujjwalkumar0501@gmail.com>
Date: Mon, 12 Oct 2020 17:18:31 +0000
Subject: [PATCH v2 2/2] kbuild: use interpreters to invoke scripts
Message-Id: <20201012170631.1241502-3-ujjwalkumar0501@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201012170631.1241502-1-ujjwalkumar0501@gmail.com>
In-Reply-To: <20201012170631.1241502-1-ujjwalkumar0501@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Masahiro Yamada <masahiroy@kernel.org>, Michal Marek <michal.lkml@markovi.net>
Cc: Ujjwal Kumar <ujjwalkumar0501@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Lukas Bulwahn <lukas.bulwahn@gmail.com>, Nathan Chancellor <natechancellor@gmail.com>, Nick Desaulniers <ndesaulniers@google.com>, linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, clang-built-linux@googlegroups.com, linux-kernel-mentees@lists.linuxfoundation.org

We cannot rely on execute bits to be set on files in the repository.
The build script should use the explicit interpreter when invoking any
script from the repository.

Link: https://lore.kernel.org/lkml/20200830174409.c24c3f67addcce0cea9a9d4c@=
linux-foundation.org/
Link: https://lore.kernel.org/lkml/202008271102.FEB906C88@keescook/

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Suggested-by: Kees Cook <keescook@chromium.org>
Suggested-by: Lukas Bulwahn <lukas.bulwahn@gmail.com>
Signed-off-by: Ujjwal Kumar <ujjwalkumar0501@gmail.com>
---
 Makefile                          | 4 ++--
 arch/arm64/kernel/vdso/Makefile   | 2 +-
 arch/arm64/kernel/vdso32/Makefile | 2 +-
 arch/ia64/Makefile                | 4 ++--
 arch/nds32/kernel/vdso/Makefile   | 2 +-
 scripts/Makefile.build            | 2 +-
 scripts/Makefile.package          | 4 ++--
 7 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/Makefile b/Makefile
index 0af7945caa61..df20e71dd7c8 100644
--- a/Makefile
+++ b/Makefile
@@ -1256,7 +1256,7 @@ include/generated/utsrelease.h: include/config/kernel=
.release FORCE
 PHONY +=3D headerdep
 headerdep:
 	$(Q)find $(srctree)/include/ -name '*.h' | xargs --max-args 1 \
-	$(srctree)/scripts/headerdep.pl -I$(srctree)/include
+	$(PERL) $(srctree)/scripts/headerdep.pl -I$(srctree)/include

 # ------------------------------------------------------------------------=
---
 # Kernel headers
@@ -1312,7 +1312,7 @@ PHONY +=3D kselftest-merge
 kselftest-merge:
 	$(if $(wildcard $(objtree)/.config),, $(error No .config exists, config y=
our kernel first!))
 	$(Q)find $(srctree)/tools/testing/selftests -name config | \
-		xargs $(srctree)/scripts/kconfig/merge_config.sh -m $(objtree)/.config
+		xargs $(CONFIG_SHELL) $(srctree)/scripts/kconfig/merge_config.sh -m $(ob=
jtree)/.config
 	$(Q)$(MAKE) -f $(srctree)/Makefile olddefconfig

 # ------------------------------------------------------------------------=
---
diff --git a/arch/arm64/kernel/vdso/Makefile b/arch/arm64/kernel/vdso/Makef=
ile
index edccdb77c53e..fb07804b7fc1 100644
--- a/arch/arm64/kernel/vdso/Makefile
+++ b/arch/arm64/kernel/vdso/Makefile
@@ -65,7 +65,7 @@ $(obj)/%.so: $(obj)/%.so.dbg FORCE
 # Generate VDSO offsets using helper script
 gen-vdsosym :=3D $(srctree)/$(src)/gen_vdso_offsets.sh
 quiet_cmd_vdsosym =3D VDSOSYM $@
-      cmd_vdsosym =3D $(NM) $< | $(gen-vdsosym) | LC_ALL=3DC sort > $@
+      cmd_vdsosym =3D $(NM) $< | $(CONFIG_SHELL) $(gen-vdsosym) | LC_ALL=
=3DC sort > $@

 include/generated/vdso-offsets.h: $(obj)/vdso.so.dbg FORCE
 	$(call if_changed,vdsosym)
diff --git a/arch/arm64/kernel/vdso32/Makefile b/arch/arm64/kernel/vdso32/M=
akefile
index 7f96a1a9f68c..617c9ac58156 100644
--- a/arch/arm64/kernel/vdso32/Makefile
+++ b/arch/arm64/kernel/vdso32/Makefile
@@ -205,7 +205,7 @@ quiet_cmd_vdsomunge =3D MUNGE   $@
 gen-vdsosym :=3D $(srctree)/$(src)/../vdso/gen_vdso_offsets.sh
 quiet_cmd_vdsosym =3D VDSOSYM $@
 # The AArch64 nm should be able to read an AArch32 binary
-      cmd_vdsosym =3D $(NM) $< | $(gen-vdsosym) | LC_ALL=3DC sort > $@
+      cmd_vdsosym =3D $(NM) $< | $(CONFIG_SHELL) $(gen-vdsosym) | LC_ALL=
=3DC sort > $@

 # Install commands for the unstripped file
 quiet_cmd_vdso_install =3D INSTALL32 $@
diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 703b1c4f6d12..86d42a2d09cb 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -27,8 +27,8 @@ cflags-y	:=3D -pipe $(EXTRA) -ffixed-r13 -mfixed-range=F1=
2-f15,f32-f127 \
 		   -falign-functions2 -frename-registers -fno-optimize-sibling-calls
 KBUILD_CFLAGS_KERNEL :=3D -mconstant-gp

-GAS_STATUS	=3D $(shell $(srctree)/arch/ia64/scripts/check-gas "$(CC)" "$(O=
BJDUMP)")
-KBUILD_CPPFLAGS +=3D $(shell $(srctree)/arch/ia64/scripts/toolchain-flags =
"$(CC)" "$(OBJDUMP)" "$(READELF)")
+GAS_STATUS	=3D $(shell $(CONFIG_SHELL) $(srctree)/arch/ia64/scripts/check-=
gas "$(CC)" "$(OBJDUMP)")
+KBUILD_CPPFLAGS +=3D $(shell $(CONFIG_SHELL) $(srctree)/arch/ia64/scripts/=
toolchain-flags "$(CC)" "$(OBJDUMP)" "$(READELF)")

 ifeq ($(GAS_STATUS),buggy)
 $(error Sorry, you need a newer version of the assember, one that is built=
 from	\
diff --git a/arch/nds32/kernel/vdso/Makefile b/arch/nds32/kernel/vdso/Makef=
ile
index 55df25ef0057..e77d4bcfa7c1 100644
--- a/arch/nds32/kernel/vdso/Makefile
+++ b/arch/nds32/kernel/vdso/Makefile
@@ -39,7 +39,7 @@ $(obj)/%.so: $(obj)/%.so.dbg FORCE
 # Generate VDSO offsets using helper script
 gen-vdsosym :=3D $(srctree)/$(src)/gen_vdso_offsets.sh
 quiet_cmd_vdsosym =3D VDSOSYM $@
-      cmd_vdsosym =3D $(NM) $< | $(gen-vdsosym) | LC_ALL=3DC sort > $@
+      cmd_vdsosym =3D $(NM) $< | $(CONFIG_SHELL) $(gen-vdsosym) | LC_ALL=
=3DC sort > $@

 include/generated/vdso-offsets.h: $(obj)/vdso.so.dbg FORCE
 	$(call if_changed,vdsosym)
diff --git a/scripts/Makefile.build b/scripts/Makefile.build
index a467b9323442..893217ee4a17 100644
--- a/scripts/Makefile.build
+++ b/scripts/Makefile.build
@@ -104,7 +104,7 @@ else ifeq ($(KBUILD_CHECKSRC),2)
 endif

 ifneq ($(KBUILD_EXTRA_WARN),)
-  cmd_checkdoc =3D $(srctree)/scripts/kernel-doc -none $<
+  cmd_checkdoc =3D $(PERL) $(srctree)/scripts/kernel-doc -none $<
 endif

 # Compile C sources (.c)
diff --git a/scripts/Makefile.package b/scripts/Makefile.package
index f952fb64789d..4fc16c4776cc 100644
--- a/scripts/Makefile.package
+++ b/scripts/Makefile.package
@@ -44,7 +44,7 @@ if test "$(objtree)" !=3D "$(srctree)"; then \
 	echo >&2; \
 	false; \
 fi ; \
-$(srctree)/scripts/setlocalversion --save-scmversion; \
+$(CONFIG_SHELL) $(srctree)/scripts/setlocalversion --save-scmversion; \
 tar -I $(KGZIP) -c $(RCS_TAR_IGNORE) -f $(2).tar.gz \
 	--transform 's:^:$(2)/:S' $(TAR_CONTENT) $(3); \
 rm -f $(objtree)/.scmversion
@@ -123,7 +123,7 @@ git --git-dir=3D$(srctree)/.git archive --prefix=3D$(pe=
rf-tar)/         \
 mkdir -p $(perf-tar);                                               \
 git --git-dir=3D$(srctree)/.git rev-parse HEAD > $(perf-tar)/HEAD;    \
 (cd $(srctree)/tools/perf;                                          \
-util/PERF-VERSION-GEN $(CURDIR)/$(perf-tar)/);              \
+$(CONFIG_SHELL) util/PERF-VERSION-GEN $(CURDIR)/$(perf-tar)/);            =
  \
 tar rf $(perf-tar).tar $(perf-tar)/HEAD $(perf-tar)/PERF-VERSION-FILE; \
 rm -r $(perf-tar);                                                  \
 $(if $(findstring tar-src,$@),,                                     \
--
2.25.1
