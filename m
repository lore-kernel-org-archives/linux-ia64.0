From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Wed, 03 Mar 2004 20:38:57 +0000
Subject: RE: [PATCH] more robust halt_light
Message-Id: <01EF044AAEE12F4BAAD955CB75064943010F084C@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1078336640.2480.37.camel@patsy.fc.hp.com>
In-Reply-To: <1078336640.2480.37.camel@patsy.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The issue with performance counters is only when PAL_HALT_LIGHT is
enabled.  It is nice to be able to use this power save feature when the
performance counters are not currently/actively used system wide.  Can
we use the disable_hlt and enable_hlt APIs (mentioned in the patch
below) in perfmon kind of tools to disable/enable PAL_HALT_LIGHT
whenever the system is transitioning in and out of system wide
performance monitoring.  That way we don't have to have any tests for
Mckinley, PAL versions etc. etc.

rohit
>-----Original Message-----
>From: linux-ia64-owner@vger.kernel.org [mailto:linux-ia64-
>owner@vger.kernel.org] On Behalf Of Alex Williamson
>Sent: Wednesday, March 03, 2004 9:57 AM
>To: linux-ia64@vger.kernel.org
>Subject: [PATCH] more robust halt_light
>
>
>  This patch adds some i386-ish enable/disable features to the
>pal_halt_light cpu idle implementation as well as tries to avoid bad
>interactions with certain revs of PAL on McKinley cpus.  Hopefully this
>will provide enough flexibility that we can leave it configured on in
>the kernel by default.  My latest measurements on a 1.3GHz rx2600 show
>that enabling pal_halt_light in the cpu_idle routine saves 23W/cpu on
an
>idle system.
>
>   FWIW, I added the enable/disable_hlt routines.  I don't see any
>consumers of this for ia64 now, but it looked useful.  Patch against
>latest linux-2.5 bk.  Thanks,
>
>	Alex
>
>--
>Alex Williamson                             HP Linux & Open Source Lab
>
>=== arch/ia64/kernel/process.c 1.51 vs edited ==>--- 1.51/arch/ia64/kernel/process.c	Sat Feb 28 03:02:47 2004
>+++ edited/arch/ia64/kernel/process.c	Wed Mar  3 09:12:44 2004
>@@ -39,6 +39,8 @@
>
> #include "sigframe.h"
>
>+int hlt_counter;
>+
> void (*ia64_mark_idle)(int);
>
>
>@@ -159,6 +161,20 @@
> 		ia64_do_signal(oldset, scr, in_syscall);
> }
>
>+void disable_hlt(void)
>+{
>+	hlt_counter++;
>+}
>+
>+EXPORT_SYMBOL(disable_hlt);
>+
>+void enable_hlt(void)
>+{
>+	hlt_counter--;
>+}
>+
>+EXPORT_SYMBOL(enable_hlt);
>+
> /*
>  * We use this if we don't have any better idle routine..
>  */
>@@ -166,7 +182,7 @@
> default_idle (void)
> {
> #ifdef CONFIG_IA64_PAL_IDLE
>-	if (!need_resched())
>+	if (!hlt_counter && local_cpu_data->hlt_works_ok &&
!need_resched())
> 		safe_halt();
> #endif
> }
>=== arch/ia64/kernel/setup.c 1.68 vs edited ==>--- 1.68/arch/ia64/kernel/setup.c	Mon Jan 19 16:38:10 2004
>+++ edited/arch/ia64/kernel/setup.c	Wed Mar  3 09:12:45 2004
>@@ -76,6 +76,10 @@
>
> unsigned char aux_device_present = 0xaa;        /* XXX remove this
when
>legacy I/O is gone */
>
>+#ifdef CONFIG_IA64_PAL_IDLE
>+static unsigned char nohlt;
>+#endif
>+
> /*
>  * The merge_mask variable needs to be set to
(max(iommu_page_size(iommu))
>- 1).  This
>  * mask specifies a mask of address bits that must be 0 in order for
two
>buffers to be
>@@ -429,13 +433,20 @@
> 		   "revision   : %u\n"
> 		   "archrev    : %u\n"
> 		   "features   :%s\n"	/* don't change this---it _is_
right!
>*/
>+#ifdef CONFIG_IA64_PAL_IDLE
>+		   "halt works : %s\n"
>+#endif
> 		   "cpu number : %lu\n"
> 		   "cpu regs   : %u\n"
> 		   "cpu MHz    : %lu.%06lu\n"
> 		   "itc MHz    : %lu.%06lu\n"
> 		   "BogoMIPS   : %lu.%02lu\n\n",
> 		   cpunum, c->vendor, family, c->model, c->revision, c-
>>archrev,
>-		   features, c->ppn, c->number,
>+		   features,
>+#ifdef CONFIG_IA64_PAL_IDLE
>+		   c->hlt_works_ok ? "yes" : "no",
>+#endif
>+		   c->ppn, c->number,
> 		   c->proc_freq / 1000000, c->proc_freq % 1000000,
> 		   c->itc_freq / 1000000, c->itc_freq % 1000000,
> 		   lpj*HZ/500000, (lpj*HZ/5000) % 100);
>@@ -523,6 +534,30 @@
> 	}
> 	c->unimpl_va_mask = ~((7L<<61) | ((1L << (impl_va_msb + 1)) -
1));
> 	c->unimpl_pa_mask = ~((1L<<63) | ((1L << phys_addr_size) - 1));
>+
>+#ifdef CONFIG_IA64_PAL_IDLE
>+	if (!nohlt) {
>+
>+		c->hlt_works_ok = 1;
>+
>+#ifdef CONFIG_PERFMON
>+		/*
>+		 * McKinley has a PAL that in some revisions that
doesn't
>behave well with
>+		 * the PMU.  The belief is PAL >= 7.64 will fix the
problem.
>+		 */
>+		if (c->family = 0x1f && c->model = 0) {
>+			pal_version_u_t min_ver, cur_ver;
>+
>+			if (ia64_pal_version(&min_ver, &cur_ver) = 0) {
>+
>+				if (cur_ver.pal_version_s.pv_pal_b_model
<= 0x7 &&
>+				    cur_ver.pal_version_s.pv_pal_b_rev <
0x64)
>+					c->hlt_works_ok = 0;
>+			}
>+		}
>+#endif
>+	}
>+#endif
> }
>
> void
>@@ -674,3 +709,14 @@
> 	ia64_patch_mckinley_e9((unsigned long)
__start___mckinley_e9_bundles,
> 			       (unsigned long)
__end___mckinley_e9_bundles);
> }
>+
>+#ifdef CONFIG_IA64_PAL_IDLE
>+static int __init no_halt(char *s)
>+{
>+	local_cpu_data->hlt_works_ok = 0;
>+	nohlt = 1;
>+	return 1;
>+}
>+
>+__setup("no-hlt", no_halt);
>+#endif
>=== include/asm-ia64/processor.h 1.56 vs edited ==>--- 1.56/include/asm-ia64/processor.h	Wed Feb 25 15:46:40 2004
>+++ edited/include/asm-ia64/processor.h	Wed Mar  3 09:12:46 2004
>@@ -180,6 +180,9 @@
> #ifdef CONFIG_NUMA
> 	struct ia64_node_data *node_data;
> #endif
>+#ifdef CONFIG_IA64_PAL_IDLE
>+	__u8 hlt_works_ok;
>+#endif
> };
>
> DECLARE_PER_CPU(struct cpuinfo_ia64, cpu_info);
>
>
>-
>To unsubscribe from this list: send the line "unsubscribe linux-ia64"
in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
