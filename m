From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 04 Mar 2009 12:05:32 +0000
Subject: [PATCH 01/15] ia64/pv_ops/xen: use __initconst instead of __initdata for const data
Message-Id: <1236168346-29788-2-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

use __initconst instead of __initdata for const data like
ec8148de85a73a3be397a59b6d8f4f32cf2dd254

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/xen_pv_ops.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
index 936cff3..fa3b967 100644
--- a/arch/ia64/xen/xen_pv_ops.c
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -260,7 +260,7 @@ xen_intrin_local_irq_restore(unsigned long mask)
 		xen_rsm_i();
 }
 
-static const struct pv_cpu_ops xen_cpu_ops __initdata = {
+static const struct pv_cpu_ops xen_cpu_ops __initconst = {
 	.fc		= xen_fc,
 	.thash		= xen_thash,
 	.get_cpuid	= xen_get_cpuid,
-- 
1.6.0.2

