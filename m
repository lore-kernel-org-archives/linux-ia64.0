From: Andrea Gelmini <andrea.gelmini@gelma.net>
Date: Sun, 23 May 2010 20:01:48 +0000
Subject: [PATCH 152/199] arch/ia64/kernel/perfmon_generic.h: Checkpatch cleanup
Message-Id: <1274644930-26600-4-git-send-email-andrea.gelmini@gelma.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Trailing lines

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 arch/ia64/kernel/perfmon_generic.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/perfmon_generic.h b/arch/ia64/kernel/perfmon_generic.h
index 6748947..daafffe 100644
--- a/arch/ia64/kernel/perfmon_generic.h
+++ b/arch/ia64/kernel/perfmon_generic.h
@@ -42,4 +42,3 @@ static pmu_config_t pmu_conf_gen={
 	.pmd_desc   = pfm_gen_pmd_desc,
 	.pmc_desc   = pfm_gen_pmc_desc
 };
-
-- 
1.7.1.251.gf80a2

