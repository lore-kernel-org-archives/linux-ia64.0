From: Nicholas Piggin <npiggin@gmail.com>
Date: Thu, 22 Jun 2017 12:39:28 +0000
Subject: [PATCH v2 2/3] ia64: thin archives fix linking
Message-Id: <20170622123929.15054-3-npiggin@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170622123929.15054-1-npiggin@gmail.com>
In-Reply-To: <20170622123929.15054-1-npiggin@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Nicholas Piggin <npiggin@gmail.com>, linux-kbuild@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

The VDSO symbols can't be linked into built-in.o when building with
thin archives, so change this to linking a new object file that is
included into the built-in.o.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 arch/ia64/kernel/Makefile.gate | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/kernel/Makefile.gate b/arch/ia64/kernel/Makefile.gate
index a32903ada016..e20c711c2b1e 100644
--- a/arch/ia64/kernel/Makefile.gate
+++ b/arch/ia64/kernel/Makefile.gate
@@ -2,7 +2,9 @@
 
 targets += gate.so gate-syms.o
 
-extra-y += gate.so gate-syms.o gate.lds gate.o
+obj-y += gate-syms.o
+
+extra-y += gate.so gate.lds gate.o
 
 CPPFLAGS_gate.lds := -P -C -U$(ARCH)
 
@@ -14,12 +16,12 @@ GATECFLAGS_gate.so = -shared -s -Wl,-soname=linux-gate.so.1 \
 $(obj)/gate.so: $(obj)/gate.lds $(obj)/gate.o FORCE
 	$(call if_changed,gate)
 
-$(obj)/built-in.o: $(obj)/gate-syms.o
-$(obj)/built-in.o: ld_flags += -R $(obj)/gate-syms.o
+# create an object file to resolve gate symbols
+quiet_cmd_gate_syms = GATESYM $@
+      cmd_gate_syms = $(LD) -r -T $(obj)/gate.lds -R $(obj)/gate.o -o $@
 
-GATECFLAGS_gate-syms.o = -r
 $(obj)/gate-syms.o: $(obj)/gate.lds $(obj)/gate.o FORCE
-	$(call if_changed,gate)
+	$(call if_changed,gate_syms)
 
 # gate-data.o contains the gate DSO image as data in section .data..gate.
 # We must build gate.so before we can assemble it.
-- 
2.11.0

