From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 09 Dec 2003 00:17:56 +0000
Subject: Re: q-tools OOPS: Fixed perfmon.
Message-Id: <marc-linux-ia64-107092926502909@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Stephane" = Stephane Eranian <eranian@hpl.hp.com> writes:

Stephane> I don't think that perfmon-2 support CONFIG_PREEMPT. Try
Stephane> without it.

Here's a  fix for non-preemption safety in perfmon.c.

I haven't tried it while running a preemption stress test, but this
allows q-syscollect to work.

=== arch/ia64/kernel/perfmon.c 1.67 vs edited ==--- 1.67/arch/ia64/kernel/perfmon.c   Tue Oct 28 17:36:50 2003
+++ edited/arch/ia64/kernel/perfmon.c Tue Dec  9 10:55:58 2003
@@ -5475,7 +5475,7 @@
	int this_cpu;
	int ret;
 
-	this_cpu = smp_processor_id();
+	this_cpu = get_cpu();
	min      = pfm_stats[this_cpu].pfm_ovfl_intr_cycles_min;
	max      = pfm_stats[this_cpu].pfm_ovfl_intr_cycles_max;
 
