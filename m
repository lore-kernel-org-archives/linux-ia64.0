From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Tue, 07 Aug 2001 01:21:22 +0000
Subject: [Linux-ia64] important perfmon kernel patch for 2.4.7
MIME-Version: 1
Content-Type: multipart/mixed; boundary="HWvPVVuAAfuRc6SZ"
Message-Id: <marc-linux-ia64-105590693006007@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--HWvPVVuAAfuRc6SZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

We recently discovered some problems with the perfmon code in 2.4.7 and
probably all older kernels. 

The counts reported by the API are incorrect if the monitored process
was context-switched during its execution. More or less the counts
would be double of what they should be. 

Also we fixed a problem that was affecting people doing DATA EARS. 
The content of some PMD14-PMD17 was not saved and restored on context-switch
due to an error in the perfmon initialization code where, somehow, the
number of PMDs and PMCs reported by PAL got swapped.

This patches fixes both problems. As a results, events which are
not likely not to change between runs of fairly deterministic programs
are much more stable (like LOADS_RETIRED or IA64_INST_RETIRED, for instance).


Also note that, if you have downloaded pfmon-0.06 from ftp.hpl.hp.com
since June 5th,2001, do not trust the results it gives. Under certain
event configurations, it will swap results between counters. This should
be fixed in an intermediate 0.06a release which should be out this week.


-- 
-Stephane

--HWvPVVuAAfuRc6SZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="perfmon-010803.diff"

--- /nue/usr/src/sys/lia64-kdb/arch/ia64/kernel/perfmon.c	Mon Jul 23 14:14:54 2001
+++ build.247/arch/ia64/kernel/perfmon.c	Fri Aug  3 19:45:57 2001
@@ -783,6 +783,8 @@
 	/* XXX: ctx locking may be required here */
 
 	for (i = 0; i < count; i++, req++) {
+		unsigned long reg_val = ~0, ctx_val = ~0;
+
 		if (copy_from_user(&tmp, req, sizeof(tmp))) return -EFAULT;
 
 		if (!PMD_IS_IMPL(tmp.pfr_reg.reg_num)) return -EINVAL;
@@ -791,23 +793,24 @@
 			if (ta == current){
 				val = ia64_get_pmd(tmp.pfr_reg.reg_num);
 			} else {
-				val = th->pmd[tmp.pfr_reg.reg_num];
+				val = reg_val = th->pmd[tmp.pfr_reg.reg_num];
 			}
 			val &= pmu_conf.perf_ovfl_val;
 			/*
 			 * lower part of .val may not be zero, so we must be an addition because of
 			 * residual count (see update_counters).
 			 */
-			val += ctx->ctx_pmds[tmp.pfr_reg.reg_num - PMU_FIRST_COUNTER].val;
+			val += ctx_val = ctx->ctx_pmds[tmp.pfr_reg.reg_num - PMU_FIRST_COUNTER].val;
 		} else {
 			/* for now */
 			if (ta != current) return -EINVAL;
 
+			ia64_srlz_d();
 			val = ia64_get_pmd(tmp.pfr_reg.reg_num);
 		}
 		tmp.pfr_reg.reg_value = val;
 
-		DBprintk((" reading PMD[%ld]=0x%lx\n", tmp.pfr_reg.reg_num, val));
+		DBprintk((" reading PMD[%ld]=0x%lx reg=0x%lx ctx_val=0x%lx pmc=0x%lx\n", tmp.pfr_reg.reg_num, val, reg_val, ctx_val, ia64_get_pmc(tmp.pfr_reg.reg_num)));
 
 		if (copy_to_user(req, &tmp, sizeof(tmp))) return -EFAULT;
 	}
@@ -1648,8 +1651,8 @@
 	}
 	pmu_conf.perf_ovfl_val = (1L << pm_info.pal_perf_mon_info_s.width) - 1;
 	pmu_conf.max_counters  = pm_info.pal_perf_mon_info_s.generic;
-	pmu_conf.num_pmds      = find_num_pm_regs(pmu_conf.impl_regs);
-	pmu_conf.num_pmcs      = find_num_pm_regs(&pmu_conf.impl_regs[4]);
+	pmu_conf.num_pmcs      = find_num_pm_regs(pmu_conf.impl_regs);
+	pmu_conf.num_pmds      = find_num_pm_regs(&pmu_conf.impl_regs[4]);
 
 	printk("perfmon: %d bits counters (max value 0x%lx)\n", pm_info.pal_perf_mon_info_s.width, pmu_conf.perf_ovfl_val);
 	printk("perfmon: %ld PMC/PMD pairs, %ld PMCs, %ld PMDs\n", pmu_conf.max_counters, pmu_conf.num_pmcs, pmu_conf.num_pmds);
@@ -1842,7 +1845,7 @@
 
 /*
  * This function is called when a thread exits (from exit_thread()).
- * This is a simplified pfm_save_regs() that simply flushes hthe current
+ * This is a simplified pfm_save_regs() that simply flushes the current
  * register state into the save area taking into account any pending
  * overflow. This time no notification is sent because the taks is dying
  * anyway. The inline processing of overflows avoids loosing some counts.
@@ -1933,12 +1936,20 @@
 		/* collect latest results */
 		ctx->ctx_pmds[i].val += ia64_get_pmd(j) & pmu_conf.perf_ovfl_val;
 
+		/*
+		 * now everything is in ctx_pmds[] and we need
+		 * to clear the saved context from save_regs() such that
+		 * pfm_read_pmds() gets the correct value
+		 */
+		ta->thread.pmd[j] = 0;
+
 		/* take care of overflow inline */
 		if (mask & 0x1) {
 			ctx->ctx_pmds[i].val += 1 + pmu_conf.perf_ovfl_val;
 			DBprintk((" PMD[%d] overflowed pmd=0x%lx pmds.val=0x%lx\n",
 			j, ia64_get_pmd(j), ctx->ctx_pmds[i].val));
 		}
+		mask >>=1;
 	}
 }
 

--HWvPVVuAAfuRc6SZ--

