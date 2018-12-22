From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Sat, 22 Dec 2018 09:50:34 +0000
Subject: [PATCH 2/3] treewide: add intermediate .s files to targets
Message-Id: <1545472235-12782-2-git-send-email-yamada.masahiro@socionext.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1545472235-12782-1-git-send-email-yamada.masahiro@socionext.com>
In-Reply-To: <1545472235-12782-1-git-send-email-yamada.masahiro@socionext.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Alexandre Belloni <alexandre.belloni@bootlin.com>, Nicolas Ferre <nicolas.ferre@microchip.com>, Daniel Borkmann <daniel@iogearbox.net>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Fenghua Yu <fenghua.yu@intel.com>, Jeff Dike <jdike@addtoit.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-um@lists.infradead.org, Ludovic Desroches <ludovic.desroches@microchip.com>, Ingo Molnar <mingo@redhat.com>, linux-omap@vger.kernel.org, Russell King <linux@armlinux.org.uk>, linux-arm-kernel@lists.infradead.org, Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Richard Weinberger <richard@nod.at>, Tony Lindgren <tony@atomide.com>

Avoid unneeded recreation of these in the incremental build.

Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
---

 arch/arm/mach-at91/Makefile         | 2 ++
 arch/arm/mach-omap2/Makefile        | 2 ++
 arch/ia64/kernel/Makefile           | 2 ++
 arch/x86/um/Makefile                | 1 +
 drivers/memory/Makefile.asm-offsets | 2 ++
 samples/bpf/Makefile                | 1 +
 6 files changed, 10 insertions(+)

diff --git a/arch/arm/mach-at91/Makefile b/arch/arm/mach-at91/Makefile
index f87066b..31b61f0 100644
--- a/arch/arm/mach-at91/Makefile
+++ b/arch/arm/mach-at91/Makefile
@@ -23,3 +23,5 @@ include/generated/at91_pm_data-offsets.h: arch/arm/mach-at91/pm_data-offsets.s F
 	$(call filechk,offsets,__PM_DATA_OFFSETS_H__)
 
 arch/arm/mach-at91/pm_suspend.o: include/generated/at91_pm_data-offsets.h
+
+targets += pm_data-offsets.s
diff --git a/arch/arm/mach-omap2/Makefile b/arch/arm/mach-omap2/Makefile
index 55c482c..4afdf56 100644
--- a/arch/arm/mach-omap2/Makefile
+++ b/arch/arm/mach-omap2/Makefile
@@ -240,3 +240,5 @@ include/generated/ti-pm-asm-offsets.h: arch/arm/mach-omap2/pm-asm-offsets.s FORC
 	$(call filechk,offsets,__TI_PM_ASM_OFFSETS_H__)
 
 $(obj)/sleep33xx.o $(obj)/sleep43xx.o: include/generated/ti-pm-asm-offsets.h
+
+targets += pm-asm-offsets.s
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 7372d99..4ba0514 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -52,3 +52,5 @@ include $(src)/Makefile.gate
 
 include/generated/nr-irqs.h: arch/$(SRCARCH)/kernel/nr-irqs.s FORCE
 	$(call filechk,offsets,__ASM_NR_IRQS_H__)
+
+targets += nr-irqs.s
diff --git a/arch/x86/um/Makefile b/arch/x86/um/Makefile
index 1792464..2d686ae 100644
--- a/arch/x86/um/Makefile
+++ b/arch/x86/um/Makefile
@@ -38,6 +38,7 @@ USER_OBJS := bugs_$(BITS).o ptrace_user.o fault.o
 
 $(obj)/user-offsets.s: c_flags = -Wp,-MD,$(depfile) $(USER_CFLAGS) \
 	-Iarch/x86/include/generated
+targets += user-offsets.s
 
 include/generated/user_constants.h: $(obj)/user-offsets.s
 	$(call filechk,offsets,__USER_CONSTANT_H__)
diff --git a/drivers/memory/Makefile.asm-offsets b/drivers/memory/Makefile.asm-offsets
index f968dfa..0447e17 100644
--- a/drivers/memory/Makefile.asm-offsets
+++ b/drivers/memory/Makefile.asm-offsets
@@ -1,2 +1,4 @@
 include/generated/ti-emif-asm-offsets.h: drivers/memory/emif-asm-offsets.s FORCE
 	$(call filechk,offsets,__TI_EMIF_ASM_OFFSETS_H__)
+
+targets += emif-asm-offsets.s
diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 100a49d..82d5a38 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -230,6 +230,7 @@ $(LIBBPF): FORCE
 $(obj)/syscall_nrs.h:	$(obj)/syscall_nrs.s FORCE
 	$(call filechk,offsets,__SYSCALL_NRS_H__)
 
+targets += syscall_nrs.s
 clean-files += syscall_nrs.h
 
 FORCE:
-- 
2.7.4
