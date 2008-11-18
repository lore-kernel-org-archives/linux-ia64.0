From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 18 Nov 2008 10:20:51 +0000
Subject: [PATCH] ia64/xen: fix xen_get_eflags.
Message-Id: <20081118102051.GB12360%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

fix xen_get_eflags. It doesn't take any argument.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/hypercall.S |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/xen/hypercall.S b/arch/ia64/xen/hypercall.S
index d4ff0b9..45e02bb 100644
--- a/arch/ia64/xen/hypercall.S
+++ b/arch/ia64/xen/hypercall.S
@@ -58,7 +58,7 @@ __HCALL2(xen_set_rr, HYPERPRIVOP_SET_RR)
 __HCALL2(xen_set_kr, HYPERPRIVOP_SET_KR)
 
 #ifdef CONFIG_IA32_SUPPORT
-__HCALL1(xen_get_eflag, HYPERPRIVOP_GET_EFLAG)
+__HCALL0(xen_get_eflag, HYPERPRIVOP_GET_EFLAG)
 __HCALL1(xen_set_eflag, HYPERPRIVOP_SET_EFLAG)	// refer SDM vol1 3.1.8
 #endif /* CONFIG_IA32_SUPPORT */
 
-- 
1.6.0.2
