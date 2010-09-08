From: Nikitas Angelinas <nikitasangelinas@gmail.com>
Date: Wed, 08 Sep 2010 21:04:30 +0000
Subject: [PATCH 1/8] arch/ia64/xen: use ARRAY_SIZE macro in xen_pv_ops.c
Message-Id: <1283979870-4764-1-git-send-email-nikitasangelinas@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1283979457-4649-1-git-send-email-nikitasangelinas@gmail.com>
In-Reply-To: <1283979457-4649-1-git-send-email-nikitasangelinas@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Nikitas Angelinas <nikitasangelinas@gmail.com>

Replace sizeof(xen_branch_target) / sizeof(xen_branch_target[0]) with
ARRAY_SIZE(xen_branch_target) in arch/ia64/xen/xen_pv_ops.c

Signed-off-by: Nikitas Angelinas <nikitasangelinas@gmail.com>
---
 arch/ia64/xen/xen_pv_ops.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
index 8adc6a1..3e8d350 100644
--- a/arch/ia64/xen/xen_pv_ops.c
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -1136,7 +1136,6 @@ __initconst = {
 static void __init
 xen_patch_branch(unsigned long tag, unsigned long type)
 {
-	const unsigned long nelem -		sizeof(xen_branch_target) / sizeof(xen_branch_target[0]);
-	__paravirt_patch_apply_branch(tag, type, xen_branch_target, nelem);
+	__paravirt_patch_apply_branch(tag, type, xen_branch_target,
+					ARRAY_SIZE(xen_branch_target));
 }
-- 
1.7.2.3

