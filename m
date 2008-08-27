From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 27 Aug 2008 02:05:05 +0000
Subject: [PATCH] ia64: implement efficient node_to_cpumask_ptr()
Message-Id: <20080827105911.D6F9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Subject: ia64: implement efficient node_to_cpumask_ptr()

Now, arch generic node_to_cpumask_ptr() is slightly inefficient.
it makes cpumask_t local variable.

	generic version
	--------------------------------------
	#define node_to_cpumask_ptr(v, node)                                    \
	                cpumask_t _##v = node_to_cpumask(node), *v = &_##v

but x86 specific node_to_cpumask_ptr() is more efficient.

	x86 version
	------------------------------------
	#define node_to_cpumask_ptr(v, node)            \
	                 cpumask_t *v = &(node_to_cpumask_map[node])

So, if we make ia64 specific node_to_cpusmask_ptr(),
we can reduce stack a bit.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Mike Travis <travis@sgi.com>

---
 include/asm-ia64/topology.h |    7 +++++++
 1 file changed, 7 insertions(+)

Index: b/include/asm-ia64/topology.h
=================================--- a/include/asm-ia64/topology.h
+++ b/include/asm-ia64/topology.h
@@ -37,6 +37,13 @@
  */
 #define node_to_cpumask(node) (node_to_cpu_mask[node])
 
+/* Replace default node_to_cpumask_ptr with optimized version */
+#define node_to_cpumask_ptr(v, node)		\
+		const cpumask_t *v = &node_to_cpumask(node)
+
+#define node_to_cpumask_ptr_next(v, node)	\
+		v = &node_to_cpumask(node)
+
 /*
  * Returns the number of the node containing Node 'nid'.
  * Not implemented here. Multi-level hierarchies detected with




