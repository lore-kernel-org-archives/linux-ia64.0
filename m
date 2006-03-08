From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Wed, 08 Mar 2006 13:41:44 +0000
Subject: [PATCH: 005/017](RFC) Memory hotplug for new nodes v.3. (generic refresh NODE_DATA())
Message-Id: <20060308212759.002C.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Joel Schopp <jschopp@austin.ibm.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>

This function refresh NODE_DATA() for generic archs.
In this case, NODE_DATA(nid) = node_data[nid].
node_data[] is array of address of pgdat.
So, refresh is quite simple.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: pgdat6/include/linux/memory_hotplug.h
=================================--- pgdat6.orig/include/linux/memory_hotplug.h	2006-03-06 19:42:21.000000000 +0900
+++ pgdat6/include/linux/memory_hotplug.h	2006-03-06 19:42:30.000000000 +0900
@@ -87,10 +87,13 @@ static inline int arch_nid_probe(u64 sta
  */
 extern struct pglist_data * arch_alloc_nodedata(int nid);
 extern void arch_free_nodedata(pg_data_t *pgdat);
+extern void arch_refresh_nodedata(int nid, pg_data_t *pgdat);
 
 #else /* !CONFIG_HAVE_ARCH_NODEDATA_EXTENSION */
 #define arch_alloc_nodedata(nid)	generic_alloc_nodedata(nid)
 #define arch_free_nodedata(pgdat)	generic_free_nodedata(pgdat)
+#define arch_refresh_nodedata(nid, pgdat)	\
+				generic_refresh_nodedata(nid, pgdat)
 
 #ifdef CONFIG_NUMA
 /*
@@ -109,6 +112,11 @@ static inline void generic_free_nodedata
 	kfree(pgdat);
 }
 
+static inline void generic_refresh_nodedata(int nid, struct pglist_data *pgdat)
+{
+	NODE_DATA(nid) = pgdat;
+}
+
 #else /* !CONFIG_NUMA */
 /* never called */
 static inline struct pglist_data *generic_alloc_nodedata(int nid)
@@ -119,6 +127,9 @@ static inline struct pglist_data *generi
 static inline void generic_free_nodedata(struct pglist_data *pgdat)
 {
 }
+static inline void generic_refresh_nodedata(int nid, struct pglist_data *pgdat)
+{
+}
 #endif /* CONFIG_NUMA */
 #endif /* CONFIG_HAVE_ARCH_NODEDATA_EXTENSION */
 

-- 
Yasunori Goto 


