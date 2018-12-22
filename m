From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Sat, 22 Dec 2018 09:50:33 +0000
Subject: [PATCH 1/3] treewide: remove explicit rules for *offsets.s
Message-Id: <1545472235-12782-1-git-send-email-yamada.masahiro@socionext.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-kbuild@vger.kernel.org
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>, Ludovic Desroches <ludovic.desroches@microchip.com>, Alexandre Belloni <alexandre.belloni@bootlin.com>, Tony Lindgren <tony@atomide.com>, Nicolas Ferre <nicolas.ferre@microchip.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-omap@vger.kernel.org, Russell King <linux@armlinux.org.uk>, linux-arm-kernel@lists.infradead.org

These explicit rules are unneeded because scripts/Makefile.build
provides a pattern rule to create %.s from %.c

Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
---

 Kbuild                              | 9 +--------
 arch/arm/mach-at91/Makefile         | 3 ---
 arch/arm/mach-omap2/Makefile        | 3 ---
 arch/ia64/kernel/Makefile           | 5 -----
 drivers/memory/Makefile.asm-offsets | 3 ---
 samples/bpf/Makefile                | 3 ---
 6 files changed, 1 insertion(+), 25 deletions(-)

diff --git a/Kbuild b/Kbuild
index 0053042..b24210c 100644
--- a/Kbuild
+++ b/Kbuild
@@ -16,10 +16,6 @@ bounds-file :=3D include/generated/bounds.h
 always  :=3D $(bounds-file)
 targets :=3D kernel/bounds.s
=20
-# We use internal kbuild rules to avoid the "is up to date" message from m=
ake
-kernel/bounds.s: kernel/bounds.c FORCE
-	$(call if_changed_dep,cc_s_c)
-
 $(obj)/$(bounds-file): kernel/bounds.s FORCE
 	$(call filechk,offsets,__LINUX_BOUNDS_H__)
=20
@@ -50,10 +46,7 @@ offsets-file :=3D include/generated/asm-offsets.h
 always  +=3D $(offsets-file)
 targets +=3D arch/$(SRCARCH)/kernel/asm-offsets.s
=20
-# We use internal kbuild rules to avoid the "is up to date" message from m=
ake
-arch/$(SRCARCH)/kernel/asm-offsets.s: arch/$(SRCARCH)/kernel/asm-offsets.c=
 \
-                                      $(obj)/$(timeconst-file) $(obj)/$(bo=
unds-file) FORCE
-	$(call if_changed_dep,cc_s_c)
+arch/$(SRCARCH)/kernel/asm-offsets.s: $(obj)/$(timeconst-file) $(obj)/$(bo=
unds-file)
=20
 $(obj)/$(offsets-file): arch/$(SRCARCH)/kernel/asm-offsets.s FORCE
 	$(call filechk,offsets,__ASM_OFFSETS_H__)
diff --git a/arch/arm/mach-at91/Makefile b/arch/arm/mach-at91/Makefile
index 7415f18..f87066b 100644
--- a/arch/arm/mach-at91/Makefile
+++ b/arch/arm/mach-at91/Makefile
@@ -19,9 +19,6 @@ ifeq ($(CONFIG_PM_DEBUG),y)
 CFLAGS_pm.o +=3D -DDEBUG
 endif
=20
-arch/arm/mach-at91/pm_data-offsets.s: arch/arm/mach-at91/pm_data-offsets.c
-	$(call if_changed_dep,cc_s_c)
-
 include/generated/at91_pm_data-offsets.h: arch/arm/mach-at91/pm_data-offse=
ts.s FORCE
 	$(call filechk,offsets,__PM_DATA_OFFSETS_H__)
=20
diff --git a/arch/arm/mach-omap2/Makefile b/arch/arm/mach-omap2/Makefile
index 01377c2..55c482c 100644
--- a/arch/arm/mach-omap2/Makefile
+++ b/arch/arm/mach-omap2/Makefile
@@ -236,9 +236,6 @@ obj-y					+=3D omap_phy_internal.o
=20
 obj-$(CONFIG_MACH_OMAP2_TUSB6010)	+=3D usb-tusb6010.o
=20
-arch/arm/mach-omap2/pm-asm-offsets.s: arch/arm/mach-omap2/pm-asm-offsets.c
-	$(call if_changed_dep,cc_s_c)
-
 include/generated/ti-pm-asm-offsets.h: arch/arm/mach-omap2/pm-asm-offsets.=
s FORCE
 	$(call filechk,offsets,__TI_PM_ASM_OFFSETS_H__)
=20
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index d0c0ccd..7372d99 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -50,10 +50,5 @@ CFLAGS_traps.o  +=3D -mfixed-range=F2-f5,f16-f31
 # The gate DSO image is built using a special linker script.
 include $(src)/Makefile.gate
=20
-# We use internal kbuild rules to avoid the "is up to date" message from m=
ake
-arch/$(SRCARCH)/kernel/nr-irqs.s: arch/$(SRCARCH)/kernel/nr-irqs.c
-	$(Q)mkdir -p $(dir $@)
-	$(call if_changed_dep,cc_s_c)
-
 include/generated/nr-irqs.h: arch/$(SRCARCH)/kernel/nr-irqs.s FORCE
 	$(call filechk,offsets,__ASM_NR_IRQS_H__)
diff --git a/drivers/memory/Makefile.asm-offsets b/drivers/memory/Makefile.=
asm-offsets
index 843ff60..f968dfa 100644
--- a/drivers/memory/Makefile.asm-offsets
+++ b/drivers/memory/Makefile.asm-offsets
@@ -1,5 +1,2 @@
-drivers/memory/emif-asm-offsets.s: drivers/memory/emif-asm-offsets.c
-	$(call if_changed_dep,cc_s_c)
-
 include/generated/ti-emif-asm-offsets.h: drivers/memory/emif-asm-offsets.s=
 FORCE
 	$(call filechk,offsets,__TI_EMIF_ASM_OFFSETS_H__)
diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index be0a961..100a49d 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -227,9 +227,6 @@ $(LIBBPF): FORCE
 # Fix up variables inherited from Kbuild that tools/ build system won't li=
ke
 	$(MAKE) -C $(dir $@) RM=3D'rm -rf' LDFLAGS=3D srctree=3D$(BPF_SAMPLES_PAT=
H)/../../ O=20
-$(obj)/syscall_nrs.s:	$(src)/syscall_nrs.c
-	$(call if_changed_dep,cc_s_c)
-
 $(obj)/syscall_nrs.h:	$(obj)/syscall_nrs.s FORCE
 	$(call filechk,offsets,__SYSCALL_NRS_H__)
=20
--=20
2.7.4
