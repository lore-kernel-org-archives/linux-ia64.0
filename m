From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 12 Dec 2008 06:39:04 +0000
Subject: [PATCH 15/15] ia64/pv_ops/xen/gate.S: xen gate page paravirtualization
Message-Id: <1229063944-27462-16-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

xen gate page paravirtualization

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/xen/inst.h |    4 ++++
 arch/ia64/xen/Makefile           |    1 +
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/include/asm/xen/inst.h b/arch/ia64/include/asm/xen/inst.h
index 90537dc..c53a476 100644
--- a/arch/ia64/include/asm/xen/inst.h
+++ b/arch/ia64/include/asm/xen/inst.h
@@ -386,6 +386,10 @@
 #define RSM_PSR_DT		\
 	XEN_HYPER_RSM_PSR_DT
 
+#define RSM_PSR_BE_I(clob0, clob1)	\
+	RSM_PSR_I(p0, clob0, clob1);	\
+	rum psr.be
+
 #define SSM_PSR_DT_AND_SRLZ_I	\
 	XEN_HYPER_SSM_PSR_DT
 
diff --git a/arch/ia64/xen/Makefile b/arch/ia64/xen/Makefile
index 94f0d8e..e6f4a0a 100644
--- a/arch/ia64/xen/Makefile
+++ b/arch/ia64/xen/Makefile
@@ -13,6 +13,7 @@ include $(srctree)/arch/ia64/kernel/Makefile.gate
 
 # tell compiled for xen
 CPPFLAGS_gate.lds += -D__IA64_GATE_PARAVIRTUALIZED_XEN
+AFLAGS_gate.o += -D__IA64_ASM_PARAVIRTUALIZED_XEN -D__IA64_GATE_PARAVIRTUALIZED_XEN
 
 # use same file of native.
 $(obj)/gate.o: $(src)/../kernel/gate.S FORCE
-- 
1.6.0.2

