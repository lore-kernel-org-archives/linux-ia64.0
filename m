From: Al Stone <ahs3@redhat.com>
Date: Fri, 19 Aug 2016 23:28:50 +0000
Subject: [PATCH 2/2] ia64: fix compilation error when using struct before defining it
Message-Id: <1471649330-32415-3-git-send-email-ahs3@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471649330-32415-1-git-send-email-ahs3@redhat.com>
In-Reply-To: <1471649330-32415-1-git-send-email-ahs3@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: ahs3@redhat.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, trivial@kernel.org

In sn2_smp.c, the struct ptc_stats was being used before it was defined.
Move the usage of the struct to after the definition.

Found during cross-compilation using ia64 defconfig.

Signed-off-by: Al Stone <ahs3@redhat.com>
---
 arch/ia64/sn/kernel/sn2/sn2_smp.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/sn2_smp.c
index 8701b2f..7316e9f 100644
--- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -41,9 +41,6 @@
 #include <asm/sn/rw_mmr.h>
 #include <asm/sn/sn_feature_sets.h>
 
-DEFINE_PER_CPU(struct ptc_stats, ptcstats);
-DECLARE_PER_CPU(struct ptc_stats, ptcstats);
-
 static  __cacheline_aligned DEFINE_SPINLOCK(sn2_global_ptc_lock);
 
 /* 0 = old algorithm (no IPI flushes), 1 = ipi deadlock flush, 2 = ipi instead of SHUB ptc, >2 = always ipi */
@@ -83,6 +80,9 @@ struct ptc_stats {
 	unsigned long shub_ipi_flushes_itc_clocks;
 };
 
+DEFINE_PER_CPU(struct ptc_stats, ptcstats);
+DECLARE_PER_CPU(struct ptc_stats, ptcstats);
+
 #define sn2_ptctest	0
 
 static inline unsigned long wait_piowc(void)
-- 
2.7.4

