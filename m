From: Mark Goodwin <markgw@sgi.com>
Date: Thu, 13 Jan 2005 00:55:28 +0000
Subject: RE: fixing 2.6.10 UP builds
Message-Id: <Pine.LNX.4.61.0501131149260.6506@woolami.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050106201427.GA6009@jale>
In-Reply-To: <20050106201427.GA6009@jale>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Wed, 12 Jan 2005, Luck, Tony wrote:

> just what is sn_hwperf_op_cpu() supposed to do in the UP case?

Needs to be wrapped with CONFIG_SMP, as follows (untested) :

=== arch/ia64/sn/kernel/sn2/sn_hwperf.c 1.5 vs edited ==--- 1.5/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2004-10-27 05:12:58 +10:00
+++ edited/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2005-01-13 11:53:01 +11:00
@@ -355,9 +355,13 @@
  	}
  	else {
  		if (use_ipi) {
+#ifdef CONFIG_SMP
  			/* use an interprocessor interrupt to call SAL */
  			smp_call_function_single(cpu, sn_hwperf_call_sal,
  				op_info, 1, 1);
+#else
+			sn_hwperf_call_sal(op_info);
+#endif
