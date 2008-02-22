From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 05:07:38 +0000
Subject: [PATCH 01/11] xen: add missing __HYPERVISOR_arch_[0-7] definisions which ia64 needs.
Message-Id: <12036568682767-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12036568683779-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12036568683779-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, yamahata@valinux.co.jp

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 include/xen/interface/xen.h |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/include/xen/interface/xen.h b/include/xen/interface/xen.h
index 518a5bf..87ad143 100644
--- a/include/xen/interface/xen.h
+++ b/include/xen/interface/xen.h
@@ -58,6 +58,16 @@
 #define __HYPERVISOR_physdev_op           33
 #define __HYPERVISOR_hvm_op               34
 
+/* Architecture-specific hypercall definitions. */
+#define __HYPERVISOR_arch_0               48
+#define __HYPERVISOR_arch_1               49
+#define __HYPERVISOR_arch_2               50
+#define __HYPERVISOR_arch_3               51
+#define __HYPERVISOR_arch_4               52
+#define __HYPERVISOR_arch_5               53
+#define __HYPERVISOR_arch_6               54
+#define __HYPERVISOR_arch_7               55
+
 /*
  * VIRTUAL INTERRUPTS
  *
-- 
1.5.3

