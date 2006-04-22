From: Jack Steiner <steiner@sgi.com>
Date: Sat, 22 Apr 2006 14:37:19 +0000
Subject: [PATCH] - Reduce overhead of reading sn_topology
Message-Id: <20060422143719.GA25562@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

MPI programs using certain debug options have a long
startup time. This was traced to a "vmalloc/vfree" in
the code that reads /proc/sgi_sn/sn_topology. On large
systems, vfree requires an IPI to all cpus to do TLB 
purging.

Replace the vmalloc/vfree with kmalloc/kfree. Although
the size of the structure being allocated is unknown, it
will not not exceed 96 bytes.

	Signed-off-by: Jack Steiner <steiner@sgi.com>


Index: linux/arch/ia64/sn/kernel/sn2/sn_hwperf.c
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2006-04-22 09:24:01.969360448 -0500
+++ linux/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2006-04-22 09:24:24.403090461 -0500
@@ -493,7 +493,7 @@ static int sn_topology_show(struct seq_f
 		 * numalink ports
 		 */
 		sz = obj->ports * sizeof(struct sn_hwperf_port_info);
-		if ((ptdata = vmalloc(sz)) = NULL)
+		if ((ptdata = kmalloc(sz, GFP_KERNEL)) = NULL)
 			return -ENOMEM;
 		e = ia64_sn_hwperf_op(sn_hwperf_master_nasid,
 				      SN_HWPERF_ENUM_PORTS, obj->id, sz,
@@ -541,7 +541,7 @@ static int sn_topology_show(struct seq_f
 				(SN_HWPERF_IS_NL3ROUTER(obj) ||
 				SN_HWPERF_IS_NL3ROUTER(p)) ?  "LLP3" : "LLP4");
 		}
-		vfree(ptdata);
+		kfree(ptdata);
 	}
 
 	return 0;
