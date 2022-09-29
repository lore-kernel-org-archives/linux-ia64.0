From: Masahiro Yamada <masahiroy@kernel.org>
Date: Thu, 29 Sep 2022 18:17:15 +0000
Subject: [PATCH] ia64: simplify esi object addition in Makefile
Message-Id: <20220929181715.2504087-1-masahiroy@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Masahiro Yamada <masahiroy@kernel.org>, Nicolas Schier <nicolas@fjasle.eu>

CONFIG_IA64_ESI is a bool option. I do not know why the Makefile was
written like this, but this should not have any functional change.

Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
---

 arch/ia64/kernel/Makefile | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 4a1fcb121dda..ae9ff07de4ab 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -34,10 +34,7 @@ mca_recovery-y			+= mca_drv.o mca_drv_asm.o
 obj-$(CONFIG_IA64_MC_ERR_INJECT)+= err_inject.o
 obj-$(CONFIG_STACKTRACE)	+= stacktrace.o
 
-obj-$(CONFIG_IA64_ESI)		+= esi.o
-ifneq ($(CONFIG_IA64_ESI),)
-obj-y				+= esi_stub.o	# must be in kernel proper
-endif
+obj-$(CONFIG_IA64_ESI)		+= esi.o esi_stub.o # must be in kernel proper
 obj-$(CONFIG_INTEL_IOMMU)	+= pci-dma.o
 
 obj-$(CONFIG_ELF_CORE)		+= elfcore.o
-- 
2.34.1
