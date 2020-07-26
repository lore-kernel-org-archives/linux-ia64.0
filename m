From: Randy Dunlap <rdunlap@infradead.org>
Date: Sun, 26 Jul 2020 00:40:10 +0000
Subject: [PATCH 2/5] ia64: perfmon.h: delete duplicated word
Message-Id: <20200726004013.20534-3-rdunlap@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200726004013.20534-1-rdunlap@infradead.org>
In-Reply-To: <20200726004013.20534-1-rdunlap@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Randy Dunlap <rdunlap@infradead.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Delete the repeated word "of".

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/include/asm/perfmon.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next-20200720.orig/arch/ia64/include/asm/perfmon.h
+++ linux-next-20200720/arch/ia64/include/asm/perfmon.h
@@ -53,7 +53,7 @@ typedef struct {
 	unsigned short  active_set;			/* event set active at the time of the overflow */
 	pfm_ovfl_ctrl_t ovfl_ctrl;			/* return: perfmon controls to set by handler */
 
-	unsigned long   pmd_last_reset;			/* last reset value of of the PMD */
+	unsigned long   pmd_last_reset;			/* last reset value of the PMD */
 	unsigned long	smpl_pmds[4];			/* bitmask of other PMD of interest on overflow */
 	unsigned long   smpl_pmds_values[PMU_MAX_PMDS]; /* values for the other PMDs of interest */
 	unsigned long   pmd_value;			/* current 64-bit value of the PMD */
