From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 26 Oct 2006 18:22:32 +0000
Subject: [PATCH] ia64 sparse cleanups
Message-Id: <20061026182232.GF5591@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


0/NULL confusion and some missing UL on constants.

Signed-off-by: Matthew Wilcox <matthew@wil.cx>

diff --git a/arch/ia64/kernel/kprobes.c b/arch/ia64/kernel/kprobes.c
index 51217d6..898a07d 100644
--- a/arch/ia64/kernel/kprobes.c
+++ b/arch/ia64/kernel/kprobes.c
@@ -851,7 +851,7 @@ static void ia64_get_bsp_cfm(struct unw_
 			return;
 		}
 	} while (unw_unwind(info) >= 0);
-	lp->bsp = 0;
+	lp->bsp = NULL;
 	lp->cfm = 0;
 	return;
 }
diff --git a/arch/ia64/kernel/perfmon_montecito.h b/arch/ia64/kernel/perfmon_montecito.h
index cd06ac6..7f8da4c 100644
--- a/arch/ia64/kernel/perfmon_montecito.h
+++ b/arch/ia64/kernel/perfmon_montecito.h
@@ -45,16 +45,16 @@ static pfm_reg_desc_t pfm_mont_pmc_desc[
 /* pmc29 */ { PFM_REG_NOTIMPL, },
 /* pmc30 */ { PFM_REG_NOTIMPL, },
 /* pmc31 */ { PFM_REG_NOTIMPL, },
-/* pmc32 */ { PFM_REG_CONFIG,  0, 0x30f01ffffffffff, 0x30f01ffffffffff, NULL, pfm_mont_pmc_check, {0,0, 0, 0}, {0,0, 0, 0}},
-/* pmc33 */ { PFM_REG_CONFIG,  0, 0x0,  0x1ffffffffff, NULL, pfm_mont_pmc_check, {0,0, 0, 0}, {0,0, 0, 0}},
-/* pmc34 */ { PFM_REG_CONFIG,  0, 0xf01ffffffffff, 0xf01ffffffffff, NULL, pfm_mont_pmc_check, {0,0, 0, 0}, {0,0, 0, 0}},
-/* pmc35 */ { PFM_REG_CONFIG,  0, 0x0,  0x1ffffffffff, NULL, pfm_mont_pmc_check, {0,0, 0, 0}, {0,0, 0, 0}},
+/* pmc32 */ { PFM_REG_CONFIG,  0, 0x30f01ffffffffffUL, 0x30f01ffffffffffUL, NULL, pfm_mont_pmc_check, {0,0, 0, 0}, {0,0, 0, 0}},
+/* pmc33 */ { PFM_REG_CONFIG,  0, 0x0,  0x1ffffffffffUL, NULL, pfm_mont_pmc_check, {0,0, 0, 0}, {0,0, 0, 0}},
+/* pmc34 */ { PFM_REG_CONFIG,  0, 0xf01ffffffffffUL, 0xf01ffffffffffUL, NULL, pfm_mont_pmc_check, {0,0, 0, 0}, {0,0, 0, 0}},
+/* pmc35 */ { PFM_REG_CONFIG,  0, 0x0,  0x1ffffffffffUL, NULL, pfm_mont_pmc_check, {0,0, 0, 0}, {0,0, 0, 0}},
 /* pmc36 */ { PFM_REG_CONFIG,  0, 0xfffffff0, 0xf, NULL, pfm_mont_pmc_check, {0,0, 0, 0}, {0,0, 0, 0}},
 /* pmc37 */ { PFM_REG_MONITOR, 4, 0x0, 0x3fff, NULL, pfm_mont_pmc_check, {RDEP_MONT_IEAR, 0, 0, 0}, {0, 0, 0, 0}},
 /* pmc38 */ { PFM_REG_CONFIG,  0, 0xdb6, 0x2492, NULL, pfm_mont_pmc_check, {0,0, 0, 0}, {0,0, 0, 0}},
 /* pmc39 */ { PFM_REG_MONITOR, 6, 0x0, 0xffcf, NULL, pfm_mont_pmc_check, {RDEP_MONT_ETB,0, 0, 0}, {0,0, 0, 0}},
 /* pmc40 */ { PFM_REG_MONITOR, 6, 0x2000000, 0xf01cf, NULL, pfm_mont_pmc_check, {RDEP_MONT_DEAR,0, 0, 0}, {0,0, 0, 0}},
-/* pmc41 */ { PFM_REG_CONFIG,  0, 0x00002078fefefefe, 0x1e00018181818, NULL, pfm_mont_pmc_check, {0,0, 0, 0}, {0,0, 0, 0}},
+/* pmc41 */ { PFM_REG_CONFIG,  0, 0x00002078fefefefeUL, 0x1e00018181818UL, NULL, pfm_mont_pmc_check, {0,0, 0, 0}, {0,0, 0, 0}},
 /* pmc42 */ { PFM_REG_MONITOR, 6, 0x0, 0x7ff4f, NULL, pfm_mont_pmc_check, {RDEP_MONT_ETB,0, 0, 0}, {0,0, 0, 0}},
 	    { PFM_REG_END    , 0, 0x0, -1, NULL, NULL, {0,}, {0,}}, /* end marker */
 };
@@ -185,7 +185,7 @@ pfm_mont_pmc_check(struct task_struct *t
 	DPRINT(("cnum=%u val=0x%lx, using_dbreg=%d loaded=%d\n", cnum, tmpval, ctx->ctx_fl_using_dbreg, is_loaded));
 
 	if (cnum = 41 && is_loaded 
-	    && (tmpval & 0x1e00000000000) && (tmpval & 0x18181818UL) != 0x18181818UL && ctx->ctx_fl_using_dbreg = 0) {
+	    && (tmpval & 0x1e00000000000UL) && (tmpval & 0x18181818UL) != 0x18181818UL && ctx->ctx_fl_using_dbreg = 0) {
 
 		DPRINT(("pmc[%d]=0x%lx has active pmc41 settings, clearing dbr\n", cnum, tmpval));
 
