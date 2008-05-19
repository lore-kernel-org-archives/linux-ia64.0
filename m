From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Mon, 19 May 2008 13:13:35 +0000
Subject: [PATCH 08/17] ia64/pv_ops: preparation for paravirtulization of hand written assembly code.
Message-Id: <12112028251525-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Preparation for paravirtualization of hand written assembly code.
They are paravirtualized by single source code and compiled multi times.
To tell those files for target (including native), add one defines.

Cc: "Dong, Eddie" <eddie.dong@intel.com>
Cc: Keith Owens <kaos@ocs.com.au>
Cc: tgingold@free.fr
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/Makefile |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 10a4ddb..8b25242 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -72,3 +72,12 @@ $(obj)/gate-syms.o: $(obj)/gate.lds $(obj)/gate.o FORCE
 # We must build gate.so before we can assemble it.
 # Note: kbuild does not track this dependency due to usage of .incbin
 $(obj)/gate-data.o: $(obj)/gate.so
+
+#
+# native ivt.S and entry.S
+#
+ASM_PARAVIRT_OBJS = ivt.o entry.o
+define paravirtualized_native
+AFLAGS_$(1) += -D__IA64_ASM_PARAVIRTUALIZED_NATIVE
+endef
+$(foreach obj,$(ASM_PARAVIRT_OBJS),$(eval $(call paravirtualized_native,$(obj))))
-- 
1.5.3

