From: Keith Owens <kaos@sgi.com>
Date: Sat, 21 Oct 2006 05:22:55 +0000
Subject: Re: [patch] MCA recovery: Montecito support
Message-Id: <13095.1161408175@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200610201555.k9KFtnvu20317790@clink.americas.sgi.com>
In-Reply-To: <200610201555.k9KFtnvu20317790@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson (on Fri, 20 Oct 2006 10:55:49 -0500 (CDT)) wrote:
>[patch] MCA recovery: Montecito support
>
>The information in MCA records is filled in slightly differently on
>Montecito than on Madison/McKinley.  Usually, the cache check and bus
>check target identifiers have the same address.   On Montecito the
>cache check and bus check target identifiers can be different if 
>a corrected error (ie SBE or unconsumed poison data) was encountered and
>then an uncorrected error (ie DBE) was consumed.  In that case, the 
>cache check target identifier is the physical address of the DBE (that
>caused the MCA to surface) while the bus check target identifier is the 
>physical address of the SBE.  This patch correctly finds the target
>identifier that triggered the MCA.
>
>This change works with both Montecito and Madison/McKinley and was
>tested on a mixed Montecito and Madison system.
>
>Signed-off-by: Russ Anderson (rja@sgi.com)
>
>---
> arch/ia64/kernel/mca.c     |   52 +++++++++++++---------------
> arch/ia64/kernel/mca_drv.c |   81 ++++++++++++++++++++++++++++++---------------
> 2 files changed, 80 insertions(+), 53 deletions(-)
>
>Index: test/arch/ia64/kernel/mca_drv.c
>=================================>--- test.orig/arch/ia64/kernel/mca_drv.c	2006-10-19 16:23:24.543535104 -0500
>+++ test/arch/ia64/kernel/mca_drv.c	2006-10-20 10:31:20.553249675 -0500
>@@ -435,6 +435,38 @@ is_mca_global(peidx_table_t *peidx, pal_
> }
> 
> /**
>+ * get_target_identifier - Get the valid Cache or Bus check target identifier.
>+ * @peidx:	pointer of index of processor error section
>+ *
>+ * Return value:
>+ *	target address on Success / 0 on Failue
>+ */
>+static u64
>+get_target_identifier(peidx_table_t *peidx)
>+{
>+	sal_log_mod_error_info_t *smei;
>+	int i;
>+
>+	/*
>+	 * Look through the cache checks for a valid target identifier
>+	 */
>+	for (i = 0; i < peidx_cache_check_num(peidx); i++) {
>+		smei = (sal_log_mod_error_info_t *)peidx_cache_check(peidx, i);
>+		if (smei->valid.target_identifier && smei->target_identifier)
>+			return smei->target_identifier;
>+	}
>+
>+	/*
>+	 * Look at the bus check for a valid target identifier
>+	 */
>+	smei = peidx_bus_check(peidx, 0);
>+	if (smei && smei->valid.target_identifier)
>+		return smei->target_identifier;
>+
>+	return 0;
>+}
>+
>+/**
>  * recover_from_read_error - Try to recover the errors which type are "read"s.
>  * @slidx:	pointer of index of SAL error record
>  * @peidx:	pointer of index of processor error section
>@@ -450,13 +482,14 @@ recover_from_read_error(slidx_table_t *s
> 			peidx_table_t *peidx, pal_bus_check_info_t *pbci,
> 			struct ia64_sal_os_state *sos)
> {
>-	sal_log_mod_error_info_t *smei;
>+	u64 target_identifier;
> 	pal_min_state_area_t *pmsa;
> 	struct ia64_psr *psr1, *psr2;
> 	ia64_fptr_t *mca_hdlr_bh = (ia64_fptr_t*)mca_handler_bhhook;
> 
> 	/* Is target address valid? */
>-	if (!pbci->tv)
>+	target_identifier = get_target_identifier(peidx);
>+	if (!target_identifier)
> 		return fatal_mca("target address not valid");
> 
> 	/*
>@@ -487,32 +520,28 @@ recover_from_read_error(slidx_table_t *s
> 	pmsa = sos->pal_min_state;
> 	if (psr1->cpl != 0 ||
> 	   ((psr2->cpl != 0) && mca_recover_range(pmsa->pmsa_iip))) {
>-		smei = peidx_bus_check(peidx, 0);
>-		if (smei->valid.target_identifier) {
>-			/*
>-			 *  setup for resume to bottom half of MCA,
>-			 * "mca_handler_bhhook"
>-			 */
>-			/* pass to bhhook as argument (gr8, ...) */
>-			pmsa->pmsa_gr[8-1] = smei->target_identifier;
>-			pmsa->pmsa_gr[9-1] = pmsa->pmsa_iip;
>-			pmsa->pmsa_gr[10-1] = pmsa->pmsa_ipsr;
>-			/* set interrupted return address (but no use) */
>-			pmsa->pmsa_br0 = pmsa->pmsa_iip;
>-			/* change resume address to bottom half */
>-			pmsa->pmsa_iip = mca_hdlr_bh->fp;
>-			pmsa->pmsa_gr[1-1] = mca_hdlr_bh->gp;
>-			/* set cpl with kernel mode */
>-			psr2 = (struct ia64_psr *)&pmsa->pmsa_ipsr;
>-			psr2->cpl = 0;
>-			psr2->ri  = 0;
>-			psr2->bn  = 1;
>-			psr2->i  = 0;
>+		/*
>+		 *  setup for resume to bottom half of MCA,
>+		 * "mca_handler_bhhook"
>+		 */
>+		/* pass to bhhook as argument (gr8, ...) */
>+		pmsa->pmsa_gr[8-1] = target_identifier;
>+		pmsa->pmsa_gr[9-1] = pmsa->pmsa_iip;
>+		pmsa->pmsa_gr[10-1] = pmsa->pmsa_ipsr;
>+		/* set interrupted return address (but no use) */
>+		pmsa->pmsa_br0 = pmsa->pmsa_iip;
>+		/* change resume address to bottom half */
>+		pmsa->pmsa_iip = mca_hdlr_bh->fp;
>+		pmsa->pmsa_gr[1-1] = mca_hdlr_bh->gp;
>+		/* set cpl with kernel mode */
>+		psr2 = (struct ia64_psr *)&pmsa->pmsa_ipsr;
>+		psr2->cpl = 0;
>+		psr2->ri  = 0;
>+		psr2->bn  = 1;
>+		psr2->i  = 0;
> 
>-			return mca_recovered("user memory corruption. "
>+		return mca_recovered("user memory corruption. "
> 				"kill affected process - recovered.");
>-		}
>-
> 	}
> 
> 	return fatal_mca("kernel context not recovered, iip 0x%lx\n",
>Index: test/arch/ia64/kernel/mca.c
>=================================>--- test.orig/arch/ia64/kernel/mca.c	2006-10-19 16:23:24.543535104 -0500
>+++ test/arch/ia64/kernel/mca.c	2006-10-19 17:06:36.447259750 -0500
>@@ -962,33 +962,31 @@ ia64_mca_modify_original_stack(struct pt
> 		goto no_mod;
> 	}
> 
>-	if (!mca_recover_range(ms->pmsa_iip)) {
>-		if (r13 != sos->prev_IA64_KR_CURRENT) {
>-			msg = "inconsistent previous current and r13";
>-			goto no_mod;
>-		}
>-		if ((r12 - r13) >= KERNEL_STACK_SIZE) {
>-			msg = "inconsistent r12 and r13";
>-			goto no_mod;
>-		}
>-		if ((ar_bspstore - r13) >= KERNEL_STACK_SIZE) {
>-			msg = "inconsistent ar.bspstore and r13";
>-			goto no_mod;
>-		}
>-		va.p = old_bspstore;
>-		if (va.f.reg < 5) {
>-			msg = "old_bspstore is in the wrong region";
>-			goto no_mod;
>-		}
>-		if ((ar_bsp - r13) >= KERNEL_STACK_SIZE) {
>-			msg = "inconsistent ar.bsp and r13";
>-			goto no_mod;
>-		}
>-		size += (ia64_rse_skip_regs(old_bspstore, slots) - old_bspstore) * 8;
>-		if (ar_bspstore + size > r12) {
>-			msg = "no room for blocked state";
>-			goto no_mod;
>-		}
>+	if (r13 != sos->prev_IA64_KR_CURRENT) {
>+		msg = "inconsistent previous current and r13";
>+		goto no_mod;
>+	}
>+	if ((r12 - r13) >= KERNEL_STACK_SIZE) {
>+		msg = "inconsistent r12 and r13";
>+		goto no_mod;
>+	}
>+	if ((ar_bspstore - r13) >= KERNEL_STACK_SIZE) {
>+		msg = "inconsistent ar.bspstore and r13";
>+		goto no_mod;
>+	}
>+	va.p = old_bspstore;
>+	if (va.f.reg < 5) {
>+		msg = "old_bspstore is in the wrong region";
>+		goto no_mod;
>+	}
>+	if ((ar_bsp - r13) >= KERNEL_STACK_SIZE) {
>+		msg = "inconsistent ar.bsp and r13";
>+		goto no_mod;
>+	}
>+	size += (ia64_rse_skip_regs(old_bspstore, slots) - old_bspstore) * 8;
>+	if (ar_bspstore + size > r12) {
>+		msg = "no room for blocked state";
>+		goto no_mod;
> 	}
> 
> 	ia64_mca_modify_comm(previous_current);

Why remove the mca_recover_range() check from
ia64_mca_modify_original_stack()?

