From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Sun, 13 Mar 2016 00:13:55 +0000
Subject: [PATCH] kbuild: drop FORCE from PHONY targets
Message-Id: <1457828035-30584-1-git-send-email-yamada.masahiro@socionext.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, Tony Luck <tony.luck@intel.com>, Nathan Lynch <nathan_lynch@mentor.com>, linux-ia64@vger.kernel.org, Michal Marek <mmarek@suse.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Russell King <linux@arm.linux.org.uk>, Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-arm-kernel@lists.infradead.org

These targets are marked as PHONY.  No need to add FORCE to their
dependency.

Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
---

 Makefile                     | 8 ++++----
 arch/arm/vdso/Makefile       | 2 +-
 arch/ia64/Makefile           | 4 ++--
 arch/x86/entry/vdso/Makefile | 4 ++--
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/Makefile b/Makefile
index 2d519d2..e3ef6b6 100644
--- a/Makefile
+++ b/Makefile
@@ -142,7 +142,7 @@ PHONY += $(MAKECMDGOALS) sub-make
 $(filter-out _all sub-make $(CURDIR)/Makefile, $(MAKECMDGOALS)) _all: sub-make
 	@:
 
-sub-make: FORCE
+sub-make:
 	$(Q)$(MAKE) -C $(KBUILD_OUTPUT) KBUILD_SRC=$(CURDIR) \
 	-f $(CURDIR)/Makefile $(filter-out _all sub-make,$(MAKECMDGOALS))
 
@@ -989,7 +989,7 @@ prepare1: prepare2 $(version_h) include/generated/utsrelease.h \
 
 archprepare: archheaders archscripts prepare1 scripts_basic
 
-prepare0: archprepare FORCE
+prepare0: archprepare
 	$(Q)$(MAKE) $(build)=.
 
 # All the preparing..
@@ -1034,7 +1034,7 @@ INSTALL_FW_PATH=$(INSTALL_MOD_PATH)/lib/firmware
 export INSTALL_FW_PATH
 
 PHONY += firmware_install
-firmware_install: FORCE
+firmware_install:
 	@mkdir -p $(objtree)/firmware
 	$(Q)$(MAKE) -f $(srctree)/scripts/Makefile.fwinst obj=firmware __fw_install
 
@@ -1054,7 +1054,7 @@ PHONY += archscripts
 archscripts:
 
 PHONY += __headers
-__headers: $(version_h) scripts_basic asm-generic archheaders archscripts FORCE
+__headers: $(version_h) scripts_basic asm-generic archheaders archscripts
 	$(Q)$(MAKE) $(build)=scripts build_unifdef
 
 PHONY += headers_install_all
diff --git a/arch/arm/vdso/Makefile b/arch/arm/vdso/Makefile
index 1160434..59a8fa7 100644
--- a/arch/arm/vdso/Makefile
+++ b/arch/arm/vdso/Makefile
@@ -74,5 +74,5 @@ $(MODLIB)/vdso: FORCE
 	@mkdir -p $(MODLIB)/vdso
 
 PHONY += vdso_install
-vdso_install: $(obj)/vdso.so.dbg $(MODLIB)/vdso FORCE
+vdso_install: $(obj)/vdso.so.dbg $(MODLIB)/vdso
 	$(call cmd,vdso_install)
diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 970d0bd..648f1ce 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -95,8 +95,8 @@ define archhelp
   echo '* unwcheck	- Check vmlinux for invalid unwind info'
 endef
 
-archprepare: make_nr_irqs_h FORCE
+archprepare: make_nr_irqs_h
 PHONY += make_nr_irqs_h FORCE
 
-make_nr_irqs_h: FORCE
+make_nr_irqs_h:
 	$(Q)$(MAKE) $(build)=arch/ia64/kernel include/generated/nr-irqs.h
diff --git a/arch/x86/entry/vdso/Makefile b/arch/x86/entry/vdso/Makefile
index c854541..a81b539 100644
--- a/arch/x86/entry/vdso/Makefile
+++ b/arch/x86/entry/vdso/Makefile
@@ -188,10 +188,10 @@ vdso_img_insttargets := $(vdso_img_sodbg:%.dbg=install_%)
 $(MODLIB)/vdso: FORCE
 	@mkdir -p $(MODLIB)/vdso
 
-$(vdso_img_insttargets): install_%: $(obj)/%.dbg $(MODLIB)/vdso FORCE
+$(vdso_img_insttargets): install_%: $(obj)/%.dbg $(MODLIB)/vdso
 	$(call cmd,vdso_install)
 
 PHONY += vdso_install $(vdso_img_insttargets)
-vdso_install: $(vdso_img_insttargets) FORCE
+vdso_install: $(vdso_img_insttargets)
 
 clean-files := vdso32.so vdso32.so.dbg vdso64* vdso-image-*.c vdsox32.so*
-- 
1.9.1

