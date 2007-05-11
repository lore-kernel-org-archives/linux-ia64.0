From: Simon Horman <horms@verge.net.au>
Date: Fri, 11 May 2007 01:55:54 +0000
Subject: [request-for-test] [patch] [IA64] Allow SPARSEMEM without NUMA
Message-Id: <20070511015552.GD10715@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Build on the previous patch to allow DISCONTIGMEM without NUMA, which
actually turns out to be most of the work in allowing SPARSEMEM without
NUMA to compile. Beyond that, the changes are:

* Extend the definition of NEED_MULTIPLE_NODES.
  SPARSEMEM kind of includes DISCONTIGMEM from a compile point of view, but
  the config symbols don't represent that. I guess a new symbol could be
  created. But it seems logical enough the way it is below.

* Create a dummy early_pfn_to_nid() as that function is
  in numa.c and thus only exists if CONFIG_NUMA (and CONFIG_SPARSEMEM)
  is set. Its just used to allow mm/sparse.c:node_memmap_size_bytes()
  to compile, a function that is never used in IA64 (or anywhere
  else outside of i386 according to its comment), but is compiled
  anyway. I guess the hope is by having it there other arches
  will use it in the future. In any case, making a bogus
  early_pfn_to_nid(), though untidy, shouldn't break anything.

  The main drawback of this approach as suddenly there is
  a spruious early_pfn_to_nid() in disctontig.c - I couldn't
  think of a better place for it off hand.

Booted up on a HP RX2620, but not tested beyond that.

Signed-off-by: Simon Horma <horms@verge.net.au>

Index: linux-2.6/mm/Kconfig
=================================--- linux-2.6.orig/mm/Kconfig	2007-05-11 10:18:13.000000000 +0900
+++ linux-2.6/mm/Kconfig	2007-05-11 10:27:13.000000000 +0900
@@ -78,13 +78,13 @@ config FLAT_NODE_MEM_MAP
 	depends on !SPARSEMEM
 
 #
-# Both the NUMA code and DISCONTIGMEM use arrays of pg_data_t's
+# The NUMA, DISCONTIGMEM and SPARSEMEM code all use arrays of pg_data_t's
 # to represent different areas of memory.  This variable allows
 # those dependencies to exist individually.
 #
 config NEED_MULTIPLE_NODES
 	def_bool y
-	depends on DISCONTIGMEM || NUMA
+	depends on DISCONTIGMEM || SPARSEMEM || NUMA
 
 config HAVE_MEMORY_PRESENT
 	def_bool y
Index: linux-2.6/arch/ia64/mm/discontig.c
=================================--- linux-2.6.orig/arch/ia64/mm/discontig.c	2007-05-11 10:27:12.000000000 +0900
+++ linux-2.6/arch/ia64/mm/discontig.c	2007-05-11 10:48:08.000000000 +0900
@@ -731,3 +731,7 @@ void arch_refresh_nodedata(int update_no
 	scatter_node_data();
 }
 #endif
+
+#if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_NUMA)
+int early_pfn_to_nid(unsigned long pfn) { BUG(); };
+#endif
