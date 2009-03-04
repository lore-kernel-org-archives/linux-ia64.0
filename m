From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 04 Mar 2009 12:05:33 +0000
Subject: [PATCH 02/15] ia64/xen: short-circuit tests for dom0
Message-Id: <1236168346-29788-3-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch is ia64 counter part of clean up of the xen predicates.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/xen/hypervisor.h |   39 ++++++++++++++-----------------
 1 files changed, 18 insertions(+), 21 deletions(-)

diff --git a/arch/ia64/include/asm/xen/hypervisor.h b/arch/ia64/include/asm/xen/hypervisor.h
index 7a804e8..e425227 100644
--- a/arch/ia64/include/asm/xen/hypervisor.h
+++ b/arch/ia64/include/asm/xen/hypervisor.h
@@ -33,9 +33,6 @@
 #ifndef _ASM_IA64_XEN_HYPERVISOR_H
 #define _ASM_IA64_XEN_HYPERVISOR_H
 
-#ifdef CONFIG_XEN
-
-#include <linux/init.h>
 #include <xen/interface/xen.h>
 #include <xen/interface/version.h>	/* to compile feature.c */
 #include <xen/features.h>		/* to comiple xen-netfront.c */
@@ -43,22 +40,32 @@
 
 /* xen_domain_type is set before executing any C code by early_xen_setup */
 enum xen_domain_type {
-	XEN_NATIVE,
-	XEN_PV_DOMAIN,
-	XEN_HVM_DOMAIN,
+	XEN_NATIVE,	/* running on bare hardware */
+	XEN_PV_DOMAIN,	/* running in a PV domain */
+	XEN_HVM_DOMAIN,	/* running in a Xen hvm domain*/
 };
 
+#ifdef CONFIG_XEN
 extern enum xen_domain_type xen_domain_type;
+#else
+#define xen_domain_type		XEN_NATIVE
+#endif
 
 #define xen_domain()		(xen_domain_type != XEN_NATIVE)
-#define xen_pv_domain()		(xen_domain_type = XEN_PV_DOMAIN)
-#define xen_initial_domain()	(xen_pv_domain() && \
+#define xen_pv_domain()		(xen_domain() &&			\
+				 xen_domain_type = XEN_PV_DOMAIN)
+#define xen_hvm_domain()	(xen_domain() &&			\
+				 xen_domain_type = XEN_HVM_DOMAIN)
+
+#ifdef CONFIG_XEN_DOM0
+#define xen_initial_domain()	(xen_pv_domain() &&			\
 				 (xen_start_info->flags & SIF_INITDOMAIN))
-#define xen_hvm_domain()	(xen_domain_type = XEN_HVM_DOMAIN)
+#else
+#define xen_initial_domain()	(0)
+#endif
 
-/* deprecated. remove this */
-#define is_running_on_xen()	(xen_domain_type = XEN_PV_DOMAIN)
 
+#ifdef CONFIG_XEN
 extern struct shared_info *HYPERVISOR_shared_info;
 extern struct start_info *xen_start_info;
 
@@ -74,16 +81,6 @@ void force_evtchn_callback(void);
 
 /* For setup_arch() in arch/ia64/kernel/setup.c */
 void xen_ia64_enable_opt_feature(void);
-
-#else /* CONFIG_XEN */
-
-#define xen_domain()		(0)
-#define xen_pv_domain()		(0)
-#define xen_initial_domain()	(0)
-#define xen_hvm_domain()	(0)
-#define is_running_on_xen()	(0)	/* deprecated. remove this */
 #endif
 
-#define is_initial_xendomain()	(0)	/* deprecated. remove this */
-
 #endif /* _ASM_IA64_XEN_HYPERVISOR_H */
-- 
1.6.0.2

