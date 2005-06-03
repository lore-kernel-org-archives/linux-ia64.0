From: dcn@sgi.com (Dean Nelson)
Date: Fri, 03 Jun 2005 12:25:28 +0000
Subject: [PATCH] fix setting of sn_hub_info->shub_1_1_found
Message-Id: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix a bug in which shub_1_1_found is not being properly initialized or set,
resulting in the improper setting of sn_hub_info->shub_1_1_found.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: test-2.6.git/arch/ia64/sn/kernel/setup.c
=================================--- test-2.6.git.orig/arch/ia64/sn/kernel/setup.c	2005-06-03 06:46:36.157095014 -0500
+++ test-2.6.git/arch/ia64/sn/kernel/setup.c	2005-06-03 06:50:07.272080003 -0500
@@ -216,7 +216,7 @@
 
 extern int platform_intr_list[];
 extern nasid_t master_nasid;
-static int shub_1_1_found __initdata;
+static int __initdata shub_1_1_found = 0;
 
 /*
  * sn_check_for_wars
@@ -245,7 +245,7 @@
 	} else {
 		for_each_online_node(cnode) {
 			if (is_shub_1_1(cnodeid_to_nasid(cnode)))
-				sn_hub_info->shub_1_1_found = 1;
+				shub_1_1_found = 1;
 		}
 	}
 }
