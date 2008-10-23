From: Russ Anderson <rja@sgi.com>
Date: Thu, 23 Oct 2008 19:12:00 +0000
Subject: [patch] Add partition id and region size to UV.
Message-Id: <20081023191200.GA76007@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add partition id and region size to UV.

Signed-off-by: Russ Anderson <rja@sgi.com>

---
The SGI xp drivers (drivers/misc/sgi-xp) are used on both
sn (Itanium) and uv (Tukwilla).  Using the same names 
(sn_coherency_id, sn_region_size) simplies the driver code.



 arch/ia64/uv/kernel/setup.c |    5 +++++
 1 file changed, 5 insertions(+)

Index: test/arch/ia64/uv/kernel/setup.c
=================================--- test.orig/arch/ia64/uv/kernel/setup.c	2008-10-20 15:15:48.000000000 -0500
+++ test/arch/ia64/uv/kernel/setup.c	2008-10-23 13:26:29.690059958 -0500
@@ -21,6 +21,11 @@ EXPORT_PER_CPU_SYMBOL_GPL(__uv_hub_info)
 int sn_prom_type;
 #endif
 
+long sn_partition_id;
+EXPORT_SYMBOL(sn_partition_id);
+long sn_region_size;
+EXPORT_SYMBOL(sn_region_size);
+
 struct redir_addr {
 	unsigned long redirect;
 	unsigned long alias;
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
