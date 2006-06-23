From: William Cohen <wcohen@redhat.com>
Date: Fri, 23 Jun 2006 21:13:47 +0000
Subject: Re: [perfmon] 2.6.17.1 new perfmon code base, libpfm, pfmon available
Message-Id: <449C598B.7070803@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060621142447.GA29389@frankl.hpl.hp.com>
In-Reply-To: <20060621142447.GA29389@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: eranian@hpl.hp.com
Cc: perfmon@napali.hpl.hp.com, oprofile-list@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, perfctr-devel@lists.sourceforge.net

Hi Stephane,

Some quick questions about the current perfmon code.


The athlon has very similar hw to the amd64 and there is now 32-bit
x86-64 support. Wouldn't it make sense to move perfmon_amd.c to i386
and have it work in the same way as perfmon_p4.c does currently for p4
and em64t?

Could the 32-bit and 64-bit code be combined in a manner similar to
oprofile and avoid duplication between perfmon_em64t_pebs.c and
perfmon_p4_pebs.c?  pfm_{p4|em64}_ds_area and
pfm_{p4|em64t}_pebs_sample_entry have differences due to the upgrade
from 32 to 64 bit values.

Why isn't Intel family 0xf model 3 not supported?
	Model 1,2, 4, and 5 are supported.
	Model 3 Pentium4 isn't that different is it?

Why the following patch in the code and array using this constant in
sys_pfm_write_pmcs and sys_pfm_write_pmds? The the p4/em64t certainly
has more registers than that.

--- linux-2.6.17.1.old/include/asm-i386/perfmon.h	2006-06-21 
05:19:04.000000000 -0700
+++ linux-2.6.17.1/include/asm-i386/perfmon.h	2006-06-21 
04:22:51.000000000 -0700
@@ -18,6 +18,14 @@

  #ifdef __KERNEL__

+#ifdef CONFIG_4KSTACKS
+#define PFM_ARCH_PMD_ARG	2
+#define PFM_ARCH_PMC_ARG	2
+#else
+#define PFM_ARCH_PMD_ARG	4
+#define PFM_ARCH_PMC_ARG	4
+#endif
+
  #include <asm/desc.h>
  #include <asm/apic.h>


What is the purpose of PFM_MAX_XTRA_PMCS and PFM_MAX_XTRA_PMDS? Are
they used for anything other than increasing the size of PFM_MAX_PMCS
and PFM_MAX_PMDS?


-Will
