From: dcn@sgi.com (Dean Nelson)
Date: Wed, 23 Mar 2005 19:11:23 +0000
Subject: [PATCH] Add some needed externs currently not defined
Message-Id: <4241BF5B.mailxHAS1ZXZBP@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add some needed externs currently not defined.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6/include/asm-ia64/sn/arch.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/arch.h	2005-03-18 10:40:56.989155675 -0600
+++ linux-2.6/include/asm-ia64/sn/arch.h	2005-03-18 10:42:48.309318957 -0600
@@ -57,6 +57,12 @@
 #define sn_cnodeid_to_nasid	(&__get_cpu_var(__sn_cnodeid_to_nasid[0]))
 
 
+
+extern u8 sn_partition_id;
+extern u8 sn_system_size;
+extern u8 sn_sharing_domain_size;
+extern u8 sn_region_size;
+
 extern void sn_flush_all_caches(long addr, long bytes);
 
 #endif /* _ASM_IA64_SN_ARCH_H */
