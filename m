From: Randy Dunlap <rdunlap@infradead.org>
Date: Sun, 26 Jul 2020 00:40:13 +0000
Subject: [PATCH 5/5] ia64: kernel: perfmon_m*.h: delete duplicated words
Message-Id: <20200726004013.20534-6-rdunlap@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200726004013.20534-1-rdunlap@infradead.org>
In-Reply-To: <20200726004013.20534-1-rdunlap@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Randy Dunlap <rdunlap@infradead.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Delete the repeated word "the" in two places.

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/perfmon_mckinley.h  |    2 +-
 arch/ia64/kernel/perfmon_montecito.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--- linux-next-20200720.orig/arch/ia64/kernel/perfmon_mckinley.h
+++ linux-next-20200720/arch/ia64/kernel/perfmon_mckinley.h
@@ -92,7 +92,7 @@ pfm_mck_pmc_check(struct task_struct *ta
 	/*
 	 * we must clear the debug registers if pmc13 has a value which enable
 	 * memory pipeline event constraints. In this case we need to clear the
-	 * the debug registers if they have not yet been accessed. This is required
+	 * debug registers if they have not yet been accessed. This is required
 	 * to avoid picking stale state.
 	 * PMC13 is "active" if:
 	 * 	one of the pmc13.cfg_dbrpXX field is different from 0x3
--- linux-next-20200720.orig/arch/ia64/kernel/perfmon_montecito.h
+++ linux-next-20200720/arch/ia64/kernel/perfmon_montecito.h
@@ -174,7 +174,7 @@ pfm_mont_pmc_check(struct task_struct *t
 	/*
 	 * we must clear the debug registers if pmc41 has a value which enable
 	 * memory pipeline event constraints. In this case we need to clear the
-	 * the debug registers if they have not yet been accessed. This is required
+	 * debug registers if they have not yet been accessed. This is required
 	 * to avoid picking stale state.
 	 * PMC41 is "active" if:
 	 * 	one of the pmc41.cfg_dtagXX field is different from 0x3
