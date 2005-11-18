From: hawkes@sgi.com
Date: Fri, 18 Nov 2005 19:30:34 +0000
Subject: [PATCH] fix bug in sn/ia64 for sparse CPU numbering
Message-Id: <20051118193034.21647.22047.sendpatchset@tomahawk.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@osdl.org>, hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>

The kernel's use of the for_each_*cpu(i) macros has allowed for sparse CPU
numbering.  When I hacked the kernel to test sparse cpu_present_map[] and
cpu_possible_map[] cpumasks, I discovered one remaining spot, in
sn_hwperf_ioctl() during sn initialization, that needs to be fixed.

This is a patch against 2.6.14.

Signed-off-by: John Hawkes <hawkes@sgi.com>
Signed-off-by: Dean Roe <roe@sgi.com>

Index: linux/arch/ia64/sn/kernel/sn2/sn_hwperf.c
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2005-11-09 16:51:25.000000000 -0800
+++ linux/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2005-11-10 09:45:30.000000000 -0800
@@ -743,13 +743,14 @@
 		if ((r = sn_hwperf_enum_objects(&nobj, &objs)) = 0) {
 			memset(p, 0, a.sz);
 			for (i = 0; i < nobj; i++) {
+				int cpuobj_index = 0;
 				if (!SN_HWPERF_IS_NODE(objs + i))
 					continue;
 				node = sn_hwperf_obj_to_cnode(objs + i);
 				for_each_online_cpu(j) {
 					if (node != cpu_to_node(j))
 						continue;
-					cpuobj = (struct sn_hwperf_object_info *) p + j;
+					cpuobj = (struct sn_hwperf_object_info *) p + cpuobj_index++;
 					slice = 'a' + cpuid_to_slice(j);
 					cdata = cpu_data(j);
 					cpuobj->id = j;
