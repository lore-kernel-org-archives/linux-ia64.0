From: Jim Garlick <garlick@llnl.gov>
Date: Thu, 29 Jan 2004 03:58:33 +0000
Subject: [patch/rfc] mca ia64_log_print() race
Message-Id: <Pine.LNX.4.30.0401281942340.18291-100000@cleomedes.llnl.gov>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

We have been exercising some of the MCA code on the bench with an instrumented
DIMM that can generate single and multibit errors and found that fairly
frequently the kernel would crash in the process of handling CPE's.

The following patch addresses what we think is a race on ia64_state_log
that occurs when CPE's occur back to back (as happens with our crude error
generator, probably more than in nature), possibly exacerbated by configuring
a slow serial console.

Does this look correct?  It seems to have cured our ills.

Jim Garlick
LLNL

diff -u -r1.4.2.1.4.10 -r1.4.2.1.4.15
--- arch/ia64/kernel/mca.c      26 Jan 2004 21:18:49 -0000      1.4.2.1.4.10
+++ arch/ia64/kernel/mca.c      29 Jan 2004 01:37:42 -0000      1.4.2.1.4.15
@@ -2397,7 +2451,9 @@
 ia64_log_print(int sal_info_type, prfunc_t prfunc)
 {
        int platform_err = 0;
+       int s;

+       IA64_LOG_LOCK(sal_info_type);
        switch(sal_info_type) {
              case SAL_INFO_TYPE_MCA:
                prfunc("+CPU %d: SAL log contains MCA error record\n", smp_processor_id());
@@ -2421,6 +2477,7 @@
                prfunc("+MCA UNKNOWN ERROR LOG (UNIMPLEMENTED)\n");
                break;
        }
+       IA64_LOG_UNLOCK(sal_info_type);
        return platform_err;
 }



