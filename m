From: Christoph Hellwig <hch@lst.de>
Date: Sat, 27 Sep 2003 14:26:58 +0000
Subject: [PATCH] fix two compiler warnings in SN2 code
Message-Id: <marc-linux-ia64-106467284026858@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


diff -Nru a/arch/ia64/sn/io/sn2/ml_iograph.c b/arch/ia64/sn/io/sn2/ml_iograph.c
--- a/arch/ia64/sn/io/sn2/ml_iograph.c	Sat Sep 27 16:24:56 2003
+++ b/arch/ia64/sn/io/sn2/ml_iograph.c	Sat Sep 27 16:24:56 2003
@@ -508,13 +508,10 @@
 			ASSERT_ALWAYS(to);
 			rc = hwgraph_edge_add(from, to,
 				EDGE_LBL_INTERCONNECT);
-			if (rc = -EEXIST)
-				goto link_done;
-			if (rc != GRAPH_SUCCESS) {
+			if (rc != -EEXIST && rc != GRAPH_SUCCESS) {
 				printk("%s: Unable to establish link"
 					" for xbmon.", pathname);
 			}
-link_done:
 		}
 
 #ifdef	SN0_USE_BTE
@@ -617,7 +614,6 @@
 	nodepda_t	*npdap;
 	struct semaphore *peer_sema = 0;
 	uint32_t	widget_partnum;
-	cpu_cookie_t	c = 0;
 
 	npdap = NODEPDA(cnodeid);
 
diff -Nru a/arch/ia64/sn/io/sn2/shub.c b/arch/ia64/sn/io/sn2/shub.c
--- a/arch/ia64/sn/io/sn2/shub.c	Sat Sep 27 16:24:56 2003
+++ b/arch/ia64/sn/io/sn2/shub.c	Sat Sep 27 16:24:56 2003
@@ -203,7 +203,7 @@
         uint64_t        longarg;
 	int		nasid;
 
-        cnode = (cnodeid_t)file->f_dentry->d_fsdata;
+        cnode = (cnodeid_t)(long)file->f_dentry->d_fsdata;
 
         switch (cmd) {
 	case SNDRV_SHUB_CONFIGURE:
