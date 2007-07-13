From: Mark Goodwin <markgw@sgi.com>
Date: Fri, 13 Jul 2007 01:59:37 +0000
Subject: [patch] correctly count CPU objects in the ia64/sn hwperf interface
Message-Id: <4696DC89.2090706@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------010109000801030906090506"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------010109000801030906090506
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Tony,

please accept this patch to fix a logic error in the SGI ia64/sn
hwperf interface.

Thanks
-- Mark


--------------010109000801030906090506
Content-Type: text/plain;
 name="sn_hwperf_cpuinfo_fix.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sn_hwperf_cpuinfo_fix.diff"

Correctly count CPU objects for SGI ia64/sn hwperf interface

Signed-off-by: Mark Goodwin <markgw@sgi.com>
Signed-off-by: Jack Steiner <steiner@sgi.com>

--- a/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2007-07-03 20:48:17.000000000 +1000
+++ b/arch/ia64/sn/kernel/sn2/sn_hwperf.c	2007-07-03 16:04:35.472855575 +1000
@@ -750,9 +750,10 @@
 			goto error;
 		} else
 		if ((r = sn_hwperf_enum_objects(&nobj, &objs)) == 0) {
+			int cpuobj_index = 0;
+
 			memset(p, 0, a.sz);
 			for (i = 0; i < nobj; i++) {
-				int cpuobj_index = 0;
 				if (!SN_HWPERF_IS_NODE(objs + i))
 					continue;
 				node = sn_hwperf_obj_to_cnode(objs + i);

--------------010109000801030906090506--
