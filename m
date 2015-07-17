From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Fri, 17 Jul 2015 07:31:03 +0000
Subject: [PATCH] ia64: sn2: Add missing kfree in error path
Message-Id: <1437118263-14342-1-git-send-email-christophe.jaillet@wanadoo.fr>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org, Christophe JAILLET <christophe.jaillet@wanadoo.fr>

If 'ia64_sn_hwperf_op' fails, then 'ptdata' should be freed, otherwise,
there is a memory leak.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
This patch is *untested* because I have no way to trigger the error.
---
 arch/ia64/sn/kernel/sn2/sn_hwperf.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/sn/kernel/sn2/sn_hwperf.c b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
index b999257..9e1694f 100644
--- a/arch/ia64/sn/kernel/sn2/sn_hwperf.c
+++ b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
@@ -499,8 +499,10 @@ static int sn_topology_show(struct seq_file *s, void *d)
 		e = ia64_sn_hwperf_op(sn_hwperf_master_nasid,
 				      SN_HWPERF_ENUM_PORTS, obj->id, sz,
 				      (u64) ptdata, 0, 0, NULL);
-		if (e != SN_HWPERF_OP_OK)
+		if (e != SN_HWPERF_OP_OK) {
+			kfree(ptdata);
 			return -EINVAL;
+		}
 		for (ordinal=0, p=objs; p != obj; p++) {
 			if (!SN_HWPERF_FOREIGN(p))
 				ordinal += p->ports;
-- 
2.1.4

