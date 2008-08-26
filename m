From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 26 Aug 2008 05:58:26 +0000
Subject: [PATCH 14/30] ia64/xen: introduce helper function to identify domain mode.
Message-Id: <1219730322-11687-15-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There are four operating modes Xen code may find itself running in:
- native
- hvm domain
- pv dom0
- pv domU

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/xen/hypervisor.h |   75 ++++++++++++++++++++++++++++++++
 1 files changed, 75 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/include/asm/xen/hypervisor.h

diff --git a/arch/ia64/include/asm/xen/hypervisor.h b/arch/ia64/include/asm/xen/hypervisor.h
new file mode 100644
index 0000000..d1f84e1
--- /dev/null
+++ b/arch/ia64/include/asm/xen/hypervisor.h
@@ -0,0 +1,75 @@
+/******************************************************************************
+ * hypervisor.h
+ *
+ * Linux-specific hypervisor handling.
+ *
+ * Copyright (c) 2002-2004, K A Fraser
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this source file (the "Software"), to deal in the Software without
+ * restriction, including without limitation the rights to use, copy, modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the Software,
+ * and to permit persons to whom the Software is furnished to do so, subject to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#ifndef _ASM_IA64_XEN_HYPERVISOR_H
+#define _ASM_IA64_XEN_HYPERVISOR_H
+
+#ifdef CONFIG_XEN
+
+#include <linux/init.h>
+#include <xen/interface/xen.h>
+#include <xen/interface/version.h>	/* to compile feature.c */
+#include <xen/features.h>		/* to comiple xen-netfront.c */
+#include <asm/xen/hypercall.h>
+
+/* xen_domain_type is set before executing any C code by early_xen_setup */
+enum xen_domain_type {
+	XEN_NATIVE,
+	XEN_PV_DOMAIN,
+	XEN_HVM_DOMAIN,
+};
+
+extern enum xen_domain_type xen_domain_type;
+
+#define xen_domain()		(xen_domain_type != XEN_NATIVE)
+#define xen_pv_domain()		(xen_domain_type = XEN_PV_DOMAIN)
+#define xen_initial_domain()	(xen_pv_domain() && \
+				 (xen_start_info->flags & SIF_INITDOMAIN))
+#define xen_hvm_domain()	(xen_domain_type = XEN_HVM_DOMAIN)
+
+/* deprecated. remove this */
+#define is_running_on_xen()	(xen_domain_type = XEN_PV_DOMAIN)
+
+extern struct start_info *xen_start_info;
+
+#else /* CONFIG_XEN */
+
+#define xen_domain()		(0)
+#define xen_pv_domain()		(0)
+#define xen_initial_domain()	(0)
+#define xen_hvm_domain()	(0)
+#define is_running_on_xen()	(0)	/* deprecated. remove this */
+#endif
+
+#define is_initial_xendomain()	(0)	/* deprecated. remove this */
+
+#endif /* _ASM_IA64_XEN_HYPERVISOR_H */
-- 
1.6.0.rc0.42.g186458

