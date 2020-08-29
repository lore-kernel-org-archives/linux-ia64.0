From: Masahiro Yamada <masahiroy@kernel.org>
Date: Sat, 29 Aug 2020 05:15:24 +0000
Subject: [PATCH 3/3] ia64: remove generated/nr-irqs.h generation to fix build warning
Message-Id: <20200829051524.706585-4-masahiroy@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200829051524.706585-1-masahiroy@kernel.org>
In-Reply-To: <20200829051524.706585-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org
Cc: Randy Dunlap <rdunlap@infradead.org>, linux-kbuild@vger.kernel.org, Masahiro Yamada <masahiroy@kernel.org>, linux-kernel@vger.kernel.org

Randy reports the following warning when building ARCH=3Dia64 with
CONFIG_IA64_PALINFO=3Dm:

../scripts/Makefile.build:68: 'arch/ia64/kernel/palinfo.ko' will not be bui=
lt even though obj-m is specified.
../scripts/Makefile.build:69: You cannot use subdir-y/m to visit a module M=
akefile. Use obj-y/m instead.

This message is actually false-positive, and you can get palinfo.ko
correctly built. It is emitted in the archprepare stage, where Kbuild
descends into arch/ia64/kernel to generate include/generated/nr-irqs.h
instead of any kind of kernel objects.

arch/ia64/kernel/nr-irqs.c was introduced by commit 213060a4d699
("[IA64] pvops: paravirtualize NR_IRQS") to pre-calculate:

   NR_IRQS =3D max(IA64_NATIVE_NR_IRQS, XEN_NR_IRQS, FOO_NR_IRQS...)

Since commit d52eefb47d4e ("ia64/xen: Remove Xen support for ia64"), this
union contains just one field, making NR_IRQS and IA64_NATIVE_NR_IRQS
always match.

So, the following hard-coding now works:

  #define NR_IRQS                IA64_NATIVE_NR_IRQS

If you need to re-introduce NR_IRQS =3D max(...) gimmick in the future,
please try to implement it in asm-offsets.c instead of a separate file.
It will be possible because the header inclusion has been consolidated
to make asm-offsets.c independent of <asm/irqs.h>.

Reported-by: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
---

 arch/ia64/Makefile          |  6 ------
 arch/ia64/include/asm/irq.h |  4 +++-
 arch/ia64/kernel/Makefile   |  5 -----
 arch/ia64/kernel/nr-irqs.c  | 22 ----------------------
 4 files changed, 3 insertions(+), 34 deletions(-)
 delete mode 100644 arch/ia64/kernel/nr-irqs.c

diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 2876a7df1b0a..3d54d411fcc4 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -87,9 +87,3 @@ define archhelp
   echo '  install	- Install compressed kernel image'
   echo '* unwcheck	- Check vmlinux for invalid unwind info'
 endef
-
-archprepare: make_nr_irqs_h
-PHONY +=3D make_nr_irqs_h
-
-make_nr_irqs_h:
-	$(Q)$(MAKE) $(build)=3Darch/ia64/kernel include/generated/nr-irqs.h
diff --git a/arch/ia64/include/asm/irq.h b/arch/ia64/include/asm/irq.h
index 5acf52e90872..0eccf33dfe8b 100644
--- a/arch/ia64/include/asm/irq.h
+++ b/arch/ia64/include/asm/irq.h
@@ -14,7 +14,9 @@
=20
 #include <linux/types.h>
 #include <linux/cpumask.h>
-#include <generated/nr-irqs.h>
+#include <asm/native/irq.h>
+
+#define NR_IRQS		IA64_NATIVE_NR_IRQS
=20
 static __inline__ int
 irq_canonicalize (int irq)
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 1a8df6669eee..7c9354ee4b3e 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -48,8 +48,3 @@ CFLAGS_traps.o  +=3D -mfixed-range=F2-f5,f16-f31
=20
 # The gate DSO image is built using a special linker script.
 include $(src)/Makefile.gate
-
-include/generated/nr-irqs.h: arch/$(SRCARCH)/kernel/nr-irqs.s FORCE
-	$(call filechk,offsets,__ASM_NR_IRQS_H__)
-
-targets +=3D nr-irqs.s
diff --git a/arch/ia64/kernel/nr-irqs.c b/arch/ia64/kernel/nr-irqs.c
deleted file mode 100644
index f2633b22d3be..000000000000
--- a/arch/ia64/kernel/nr-irqs.c
+++ /dev/null
@@ -1,22 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * calculate
- * NR_IRQS =3D max(IA64_NATIVE_NR_IRQS, XEN_NR_IRQS, FOO_NR_IRQS...)
- * depending on config.
- * This must be calculated before processing asm-offset.c.
- */
-
-#define ASM_OFFSETS_C 1
-
-#include <linux/kbuild.h>
-#include <linux/threads.h>
-#include <asm/native/irq.h>
-
-void foo(void)
-{
-	union paravirt_nr_irqs_max {
-		char ia64_native_nr_irqs[IA64_NATIVE_NR_IRQS];
-	};
-
-	DEFINE(NR_IRQS, sizeof (union paravirt_nr_irqs_max));
-}
--=20
2.25.1
