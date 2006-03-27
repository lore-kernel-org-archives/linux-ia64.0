From: hawkes@sgi.com
Date: Mon, 27 Mar 2006 21:18:17 +0000
Subject: [PATCH] ia64 sn_hwperf use of num_online_cpus()
Message-Id: <20060327211817.16768.77971.sendpatchset@tomahawk.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Jack Steiner <steiner@sgi.com>, hawkes@sgi.com, Jes Sorensen <jes@sgi.com>

Eliminate an unnecessary -- and flawed -- use of the expensive
num_online_cpus().

Signed-off-by: John Hawkes <hawkes@sgi.com>

Index: linux/arch/ia64/sn/kernel/sn2/sn_hwperf.c
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2006-03-19 21:53:29.000000000 -0800
+++ linux/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2006-03-27 13:14:12.000000000 -0800
@@ -605,7 +605,7 @@ static int sn_hwperf_op_cpu(struct sn_hw
 	op_info->a->arg &= SN_HWPERF_ARG_OBJID_MASK;
 
 	if (cpu != SN_HWPERF_ARG_ANY_CPU) {
-		if (cpu >= num_online_cpus() || !cpu_online(cpu)) {
+		if (cpu >= NR_CPUS || !cpu_online(cpu)) {
 			r = -EINVAL;
 			goto out;
 		}
