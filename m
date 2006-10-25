From: Russ Anderson <rja@sgi.com>
Date: Wed, 25 Oct 2006 22:59:47 +0000
Subject: Re: [patch] MCA recovery: Montecito support
Message-Id: <200610252259.k9PMxlE521680592@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200610201555.k9KFtnvu20317790@clink.americas.sgi.com>
In-Reply-To: <200610201555.k9KFtnvu20317790@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hidetoshi Seto wrote:
> Russ Anderson wrote:
> > +	/*
> > +	 * Look through the cache checks for a valid target identifier
> > +	 */
> > +	for (i = 0; i < peidx_cache_check_num(peidx); i++) {
> > +		smei = (sal_log_mod_error_info_t *)peidx_cache_check(peidx, i);
> > +		if (smei->valid.target_identifier && smei->target_identifier)
> > +			return smei->target_identifier;
> > +	}
> 
> This says there would be more than 1 cache_check in the sal log.
> I suppose it also means there would be more than 1 identifier.
> Are there any reason why you don't handle identifiers other than
> listed earliest?

I reworked that routine to look at all the valid cache target identifiers
and use the one with the lowest cache level.  

I've opened a Quad issue to get clarification from Intel as to 
which target identifier triggered the MCA if there are multiple
cache checks with valid target identifiers.  

This patch also leaves mca.c unchanged.  I'll treat that as a seperate
patch if needed.

Signed-off-by: Russ Anderson (rja@sgi.com)

---
 arch/ia64/kernel/mca_drv.c |   93 ++++++++++++++++++++++++++++++++-------------
 1 file changed, 67 insertions(+), 26 deletions(-)

Index: test/arch/ia64/kernel/mca_drv.c
=================================--- test.orig/arch/ia64/kernel/mca_drv.c	2006-10-25 14:01:12.245158144 -0500
+++ test/arch/ia64/kernel/mca_drv.c	2006-10-25 17:09:30.720299537 -0500
@@ -435,6 +435,50 @@ is_mca_global(peidx_table_t *peidx, pal_
 }
 
 /**
+ * get_target_identifier - Get the valid Cache or Bus check target identifier.
+ * @peidx:	pointer of index of processor error section
+ *
+ * Return value:
+ *	target address on Success / 0 on Failue
+ */
+static u64
+get_target_identifier(peidx_table_t *peidx)
+{
+	u64 target_address = 0;
+	sal_log_mod_error_info_t *smei;
+	pal_cache_check_info_t *pcci;
+	int i, level = 9;
+
+	/*
+	 * Look through the cache checks for a valid target identifier
+	 * If more than one valid target identifier, return the one
+	 * with the lowest cache level.
+	 */
+	for (i = 0; i < peidx_cache_check_num(peidx); i++) {
+		smei = (sal_log_mod_error_info_t *)peidx_cache_check(peidx, i);
+		if (smei->valid.target_identifier && smei->target_identifier) {
+			pcci = (pal_cache_check_info_t *)&(smei->check_info);
+			if (!target_address || (pcci->level < level)) {
+				target_address = smei->target_identifier;
+				level = pcci->level;
+				continue;
+			}
+		}
+	}
+	if (target_address)
+		return target_address;
+
+	/*
+	 * Look at the bus check for a valid target identifier
+	 */
+	smei = peidx_bus_check(peidx, 0);
+	if (smei && smei->valid.target_identifier)
+		return smei->target_identifier;
+
+	return 0;
+}
+
+/**
  * recover_from_read_error - Try to recover the errors which type are "read"s.
  * @slidx:	pointer of index of SAL error record
  * @peidx:	pointer of index of processor error section
@@ -450,13 +494,14 @@ recover_from_read_error(slidx_table_t *s
 			peidx_table_t *peidx, pal_bus_check_info_t *pbci,
 			struct ia64_sal_os_state *sos)
 {
-	sal_log_mod_error_info_t *smei;
+	u64 target_identifier;
 	pal_min_state_area_t *pmsa;
 	struct ia64_psr *psr1, *psr2;
 	ia64_fptr_t *mca_hdlr_bh = (ia64_fptr_t*)mca_handler_bhhook;
 
 	/* Is target address valid? */
-	if (!pbci->tv)
+	target_identifier = get_target_identifier(peidx);
+	if (!target_identifier)
 		return fatal_mca("target address not valid");
 
 	/*
@@ -487,32 +532,28 @@ recover_from_read_error(slidx_table_t *s
 	pmsa = sos->pal_min_state;
 	if (psr1->cpl != 0 ||
 	   ((psr2->cpl != 0) && mca_recover_range(pmsa->pmsa_iip))) {
-		smei = peidx_bus_check(peidx, 0);
-		if (smei->valid.target_identifier) {
-			/*
-			 *  setup for resume to bottom half of MCA,
-			 * "mca_handler_bhhook"
-			 */
-			/* pass to bhhook as argument (gr8, ...) */
-			pmsa->pmsa_gr[8-1] = smei->target_identifier;
-			pmsa->pmsa_gr[9-1] = pmsa->pmsa_iip;
-			pmsa->pmsa_gr[10-1] = pmsa->pmsa_ipsr;
-			/* set interrupted return address (but no use) */
-			pmsa->pmsa_br0 = pmsa->pmsa_iip;
-			/* change resume address to bottom half */
-			pmsa->pmsa_iip = mca_hdlr_bh->fp;
-			pmsa->pmsa_gr[1-1] = mca_hdlr_bh->gp;
-			/* set cpl with kernel mode */
-			psr2 = (struct ia64_psr *)&pmsa->pmsa_ipsr;
-			psr2->cpl = 0;
-			psr2->ri  = 0;
-			psr2->bn  = 1;
-			psr2->i  = 0;
+		/*
+		 *  setup for resume to bottom half of MCA,
+		 * "mca_handler_bhhook"
+		 */
+		/* pass to bhhook as argument (gr8, ...) */
+		pmsa->pmsa_gr[8-1] = target_identifier;
+		pmsa->pmsa_gr[9-1] = pmsa->pmsa_iip;
+		pmsa->pmsa_gr[10-1] = pmsa->pmsa_ipsr;
+		/* set interrupted return address (but no use) */
+		pmsa->pmsa_br0 = pmsa->pmsa_iip;
+		/* change resume address to bottom half */
+		pmsa->pmsa_iip = mca_hdlr_bh->fp;
+		pmsa->pmsa_gr[1-1] = mca_hdlr_bh->gp;
+		/* set cpl with kernel mode */
+		psr2 = (struct ia64_psr *)&pmsa->pmsa_ipsr;
+		psr2->cpl = 0;
+		psr2->ri  = 0;
+		psr2->bn  = 1;
+		psr2->i  = 0;
 
-			return mca_recovered("user memory corruption. "
+		return mca_recovered("user memory corruption. "
 				"kill affected process - recovered.");
-		}
-
 	}
 
 	return fatal_mca("kernel context not recovered, iip 0x%lx\n",

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
