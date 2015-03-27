From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Fri, 27 Mar 2015 11:43:35 +0000
Subject: [PATCH 1/4] kbuild: use relative path to include Makefile
Message-Id: <1427456618-23830-2-git-send-email-yamada.masahiro@socionext.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1427456618-23830-1-git-send-email-yamada.masahiro@socionext.com>
In-Reply-To: <1427456618-23830-1-git-send-email-yamada.masahiro@socionext.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-kbuild@vger.kernel.org
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Michal Marek <mmarek@suse.cz>, Fenghua Yu <fenghua.yu@intel.com>, linux-arm-kernel@lists.infradead.org

The "MAKEFLAGS +=3D --include-dir=3D$(srctree)" line in the top Makefile
allows us to do this.

Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
---

 arch/arm/boot/Makefile    | 2 +-
 arch/ia64/kernel/Makefile | 2 +-
 scripts/Makefile.dtbinst  | 2 +-
 scripts/Makefile.fwinst   | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/arm/boot/Makefile b/arch/arm/boot/Makefile
index ec2f806..9eca7ae 100644
--- a/arch/arm/boot/Makefile
+++ b/arch/arm/boot/Makefile
@@ -12,7 +12,7 @@
 #
=20
 ifneq ($(MACHINE),)
-include $(srctree)/$(MACHINE)/Makefile.boot
+include $(MACHINE)/Makefile.boot
 endif
=20
 # Note: the following conditions must always be true:
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 20678a9..47e8aff 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -51,7 +51,7 @@ obj-$(CONFIG_BINFMT_ELF)	+=3D elfcore.o
 CFLAGS_traps.o  +=3D -mfixed-range=F2-f5,f16-f31
=20
 # The gate DSO image is built using a special linker script.
-include $(srctree)/arch/ia64/kernel/Makefile.gate
+include arch/ia64/kernel/Makefile.gate
 # tell compiled for native
 CPPFLAGS_gate.lds +=3D -D__IA64_GATE_PARAVIRTUALIZED_NATIVE
=20
diff --git a/scripts/Makefile.dtbinst b/scripts/Makefile.dtbinst
index 909ed7a..7cbff16 100644
--- a/scripts/Makefile.dtbinst
+++ b/scripts/Makefile.dtbinst
@@ -18,7 +18,7 @@ export dtbinst-root ?=3D $(obj)
=20
 include include/config/auto.conf
 include scripts/Kbuild.include
-include $(srctree)/$(obj)/Makefile
+include $(obj)/Makefile
=20
 PHONY +=3D __dtbs_install_prep
 __dtbs_install_prep:
diff --git a/scripts/Makefile.fwinst b/scripts/Makefile.fwinst
index 5b698ad..baf5eae 100644
--- a/scripts/Makefile.fwinst
+++ b/scripts/Makefile.fwinst
@@ -13,7 +13,7 @@ src :=3D $(obj)
 -include $(objtree)/.config
=20
 include scripts/Kbuild.include
-include $(srctree)/$(obj)/Makefile
+include $(obj)/Makefile
=20
 include scripts/Makefile.host
=20
--=20
1.9.1

