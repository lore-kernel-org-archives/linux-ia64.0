From: Nicholas Piggin <npiggin@gmail.com>
Date: Wed, 21 Jun 2017 07:56:37 +0000
Subject: [PATCH 1/2] ia64: thin archives fix linking
Message-Id: <20170621075638.19251-2-npiggin@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170621075638.19251-1-npiggin@gmail.com>
In-Reply-To: <20170621075638.19251-1-npiggin@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Nicholas Piggin <npiggin@gmail.com>, linux-kbuild@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

The VDSO symbols can't be linked into built-in.o when building with
thin archives, so change this to linking them into the final link.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 arch/ia64/Makefile             | 1 +
 arch/ia64/kernel/Makefile.gate | 3 ---
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index c100d780f1eb..302f7edbcfd1 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -22,6 +22,7 @@ CHECKFLAGS	+= -m64 -D__ia64=1 -D__ia64__=1 -D_LP64 -D__LP64__
 
 OBJCOPYFLAGS	:= --strip-all
 LDFLAGS_vmlinux	:= -static
+LDFLAGS_vmlinux	+= -R arch/ia64/kernel/gate-syms.o
 KBUILD_LDFLAGS_MODULE += -T $(srctree)/arch/ia64/module.lds
 KBUILD_AFLAGS_KERNEL := -mconstant-gp
 EXTRA		:diff --git a/arch/ia64/kernel/Makefile.gate b/arch/ia64/kernel/Makefile.gate
index a32903ada016..9d9c69100d35 100644
--- a/arch/ia64/kernel/Makefile.gate
+++ b/arch/ia64/kernel/Makefile.gate
@@ -14,9 +14,6 @@ GATECFLAGS_gate.so = -shared -s -Wl,-soname=linux-gate.so.1 \
 $(obj)/gate.so: $(obj)/gate.lds $(obj)/gate.o FORCE
 	$(call if_changed,gate)
 
-$(obj)/built-in.o: $(obj)/gate-syms.o
-$(obj)/built-in.o: ld_flags += -R $(obj)/gate-syms.o
-
 GATECFLAGS_gate-syms.o = -r
 $(obj)/gate-syms.o: $(obj)/gate.lds $(obj)/gate.o FORCE
 	$(call if_changed,gate)
-- 
2.11.0

