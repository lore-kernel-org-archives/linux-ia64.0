From: Paul Jackson <pj@sgi.com>
Date: Fri, 07 Nov 2003 11:14:15 +0000
Subject: [PATCH preview] Adds nodemask_t for use in cpusets (NUMA memory
Message-Id: <marc-linux-ia64-106825306926864@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following patch is not intended to be applied yet, except by Simon
and Sylvain, Bull, France.  It is my small contribution so far to Simon
and Sylvain's work in progress for developing cpusets.

This patch adds a nodemask_t, that is similar to the existing cpumask_t
(much code copied, in fact).

This nodemask_t will be used as the type of a mems_allowed bit vector,
similar to the existing cpus_allowed vector. The memory allocation
(mm/page_alloc.c:__alloc_pages()) will be taught to honor the
mems_allowed restriction on certain of its allocations.

The following patch just adds the new nodemask_t.  It doesn't yet make
any use of it.  No existing kernel files are changed - just new include
files added.  So I guess if you patched your kernel with it anyway, it
shouldn't break anything.  Actual usage of this code has not yet been
tested.

It is being posted to linux-ia64@vger.kernel.org in order that others
may see what we're planning on doing.  Comments and criticisms welcome.


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1393  -> 1.1394 
#	               (new)	        -> 1.1     include/asm-generic/nodemask_const_value.h
#	               (new)	        -> 1.1     include/asm-generic/nodemask_arith.h
#	               (new)	        -> 1.1     include/linux/nodemask.h
#	               (new)	        -> 1.1     include/asm-generic/nodemask_smp.h
#	               (new)	        -> 1.1     include/asm-generic/nodemask_const_reference.h
#	               (new)	        -> 1.1     include/asm-generic/nodemask_array.h
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/11/07	pj@sgi.com	1.1394
# This adds a new kernel type, nodemask_t, similar to cpumask_t.
# This type will be used for the mems_allowed field of cpusets.
# --------------------------------------------
#
diff -Nru a/include/asm-generic/nodemask_arith.h b/include/asm-generic/nodemask_arith.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-generic/nodemask_arith.h	Fri Nov  7 02:52:30 2003
@@ -0,0 +1,36 @@
+#ifndef __ASM_GENERIC_NODEMASK_ARITH_H
+#define __ASM_GENERIC_NODEMASK_ARITH_H
+
+/*
+ * Arithmetic type -based node bitmaps. A single unsigned long is used
+ * to contain the whole node bitmap.
+ */
+
+#define node_set(node, map)		set_bit(node, &(map))
+#define node_clear(node, map)		clear_bit(node, &(map))
+#define node_isset(node, map)		test_bit(node, &(map))
+#define node_test_and_set(node, map)	test_and_set_bit(node, &(map))
+
+#define nodes_and(dst,src1,src2)	do { dst = (src1) & (src2); } while (0)
+#define nodes_or(dst,src1,src2)		do { dst = (src1) | (src2); } while (0)
+#define nodes_clear(map)		do { map = 0; } while (0)
+#define nodes_complement(map)		do { map = ~(map); } while (0)
+#define nodes_equal(map1, map2)		((map1) = (map2))
+#define nodes_empty(map)		((map) = 0)
+
+#if BITS_PER_LONG = 32
+#define nodes_weight(map)		hweight32(map)
+#elif BITS_PER_LONG = 64
+#define nodes_weight(map)		hweight64(map)
+#endif
+
+#define nodes_shift_right(dst, src, n)	do { dst = (src) >> (n); } while (0)
+#define nodes_shift_left(dst, src, n)	do { dst = (src) << (n); } while (0)
+
+#define NODE_MASK_ALL	(~((nodemask_t)0) >> (8*sizeof(nodemask_t) - NR_NODES))
+#define NODE_MASK_NONE	((nodemask_t)0)
+
+#define first_node(map)			__ffs(map)
+#define next_node(node, map)		find_next_bit(&(map), NR_NODES, node + 1)
+
+#endif /* __ASM_GENERIC_NODEMASK_ARITH_H */
diff -Nru a/include/asm-generic/nodemask_array.h b/include/asm-generic/nodemask_array.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-generic/nodemask_array.h	Fri Nov  7 02:52:30 2003
@@ -0,0 +1,35 @@
+#ifndef __ASM_GENERIC_NODEMASK_ARRAY_H
+#define __ASM_GENERIC_NODEMASK_ARRAY_H
+
+/*
+ * Array-based node bitmaps. An array of unsigned longs is used to contain
+ * the bitmap, and then contained in a structure so it may be passed by
+ * value.
+ */
+
+#define NODE_ARRAY_SIZE			BITS_TO_LONGS(NR_NODES)
+
+#define node_set(node, map)		set_bit(node, (map).mask)
+#define node_clear(node, map)		clear_bit(node, (map).mask)
+#define node_isset(node, map)		test_bit(node, (map).mask)
+#define node_test_and_set(node, map)	test_and_set_bit(node, (map).mask)
+
+#define nodes_and(dst,src1,src2)	bitmap_and((dst).mask,(src1).mask, (src2).mask, NR_NODES)
+#define nodes_or(dst,src1,src2)		bitmap_or((dst).mask, (src1).mask, (src2).mask, NR_NODES)
+#define nodes_clear(map)		bitmap_clear((map).mask, NR_NODES)
+#define nodes_complement(map)		bitmap_complement((map).mask, NR_NODES)
+#define nodes_equal(map1, map2)		bitmap_equal((map1).mask, (map2).mask, NR_NODES)
+#define nodes_empty(map)		bitmap_empty(map.mask, NR_NODES)
+#define nodes_weight(map)		bitmap_weight((map).mask, NR_NODES)
+#define nodes_shift_right(d, s, n)	bitmap_shift_right((d).mask, (s).mask, n, NR_NODES)
+#define nodes_shift_left(d, s, n)	bitmap_shift_left((d).mask, (s).mask, n, NR_NODES)
+#define first_node(map)			find_first_bit((map).mask, NR_NODES)
+#define next_node(node, map)		find_next_bit((map).mask, NR_NODES, node + 1)
+
+/*
+ * um, these need to be usable as static initializers
+ */
+#define NODE_MASK_ALL	{ {[0 ... NODE_ARRAY_SIZE-1] = ~0UL} }
+#define NODE_MASK_NONE	{ {[0 ... NODE_ARRAY_SIZE-1] =  0UL} }
+
+#endif /* __ASM_GENERIC_NODEMASK_ARRAY_H */
diff -Nru a/include/asm-generic/nodemask_const_reference.h b/include/asm-generic/nodemask_const_reference.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-generic/nodemask_const_reference.h	Fri Nov  7 02:52:30 2003
@@ -0,0 +1,25 @@
+#ifndef __ASM_GENERIC_NODEMASK_CONST_REFERENCE_H
+#define __ASM_GENERIC_NODEMASK_CONST_REFERENCE_H
+
+struct nodemask_ref {
+	const nodemask_t *val;
+};
+
+typedef const struct nodemask_ref nodemask_const_t;
+
+#define mk_nodemask_const(map)		((nodemask_const_t){ &(map) })
+#define node_isset_const(node, map)	node_isset(node, *(map).val)
+
+#define nodes_and_const(dst,src1,src2)	nodes_and(dst,*(src1).val,*(src2).val)
+#define nodes_or_const(dst,src1,src2)	nodes_or(dst,*(src1).val,*(src2).val)
+
+#define nodes_equal_const(map1, map2)	nodes_equal(*(map1).val, *(map2).val)
+
+#define nodes_copy_const(map1, map2)	bitmap_copy((map1).mask, (map2).val->mask, NR_NODES)
+
+#define nodes_empty_const(map)		nodes_empty(*(map).val)
+#define nodes_weight_const(map)		nodes_weight(*(map).val)
+#define first_node_const(map)		first_node(*(map).val)
+#define next_node_const(node, map)	next_node(node, *(map).val)
+
+#endif /* __ASM_GENERIC_NODEMASK_CONST_REFERENCE_H */
diff -Nru a/include/asm-generic/nodemask_const_value.h b/include/asm-generic/nodemask_const_value.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-generic/nodemask_const_value.h	Fri Nov  7 02:52:30 2003
@@ -0,0 +1,17 @@
+#ifndef __ASM_GENERIC_NODEMASK_CONST_VALUE_H
+#define __ASM_GENERIC_NODEMASK_CONST_VALUE_H
+
+typedef const nodemask_t nodemask_const_t;
+
+#define mk_nodemask_const(map)		(map)
+#define node_isset_const(node, map)	node_isset(node, map)
+#define nodes_and_const(dst,src1,src2)	nodes_and(dst, src1, src2)
+#define nodes_or_const(dst,src1,src2)	nodes_or(dst, src1, src2)
+#define nodes_equal_const(map1, map2)	nodes_equal(map1, map2)
+#define nodes_empty_const(map)		nodes_empty(map)
+#define nodes_copy_const(map1, map2)	do { map1 = (nodemask_t)map2; } while (0)
+#define nodes_weight_const(map)		nodes_weight(map)
+#define first_node_const(map)		first_node(map)
+#define next_node_const(node, map)	next_node(node, map)
+
+#endif /* __ASM_GENERIC_NODEMASK_CONST_VALUE_H */
diff -Nru a/include/asm-generic/nodemask_smp.h b/include/asm-generic/nodemask_smp.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-generic/nodemask_smp.h	Fri Nov  7 02:52:30 2003
@@ -0,0 +1,52 @@
+#ifndef __ASM_GENERIC_NODEMASK_UP_H
+#define __ASM_GENERIC_NODEMASK_UP_H
+
+/*
+ * Single node (smp or uni-processor) node bitmap.
+ * A single unsigned long, with the low bit set, or not.
+ */
+
+#define nodes_coerce(map)	(map)
+
+#define node_set(node, map)		do { (void)(node); nodes_coerce(map) = 1UL; } while (0)
+#define node_clear(node, map)		do { (void)(node); nodes_coerce(map) = 0UL; } while (0)
+#define node_isset(node, map)		((void)(node), nodes_coerce(map) != 0UL)
+#define node_test_and_set(node, map)	((void)(node), test_and_set_bit(0, &(map)))
+
+#define nodes_and(dst, src1, src2)					\
+	do {								\
+		if (nodes_coerce(src1) && nodes_coerce(src2))		\
+			nodes_coerce(dst) = 1UL;			\
+		else							\
+			nodes_coerce(dst) = 0UL;			\
+	} while (0)
+
+#define nodes_or(dst, src1, src2)					\
+	do {								\
+		if (nodes_coerce(src1) || nodes_coerce(src2))		\
+			nodes_coerce(dst) = 1UL;			\
+		else							\
+			nodes_coerce(dst) = 0UL;			\
+	} while (0)
+
+#define nodes_clear(map)			do { nodes_coerce(map) = 0UL; } while (0)
+
+#define nodes_complement(map)						\
+	do {								\
+		nodes_coerce(map) = !nodes_coerce(map);			\
+	} while (0)
+
+#define nodes_equal(map1, map2)		(nodes_coerce(map1) = nodes_coerce(map2))
+#define nodes_empty(map)			(nodes_coerce(map) = 0UL)
+#define nodes_weight(map)		(nodes_coerce(map) ? 1UL : 0UL)
+#define nodes_shift_right(d, s, n)	do { nodes_coerce(d) = 0UL; } while (0)
+#define nodes_shift_left(d, s, n)	do { nodes_coerce(d) = 0UL; } while (0)
+#define first_node(map)			(nodes_coerce(map) ? 0 : 1)
+#define next_node(node, map)		1
+/*
+ * um, these need to be usable as static initializers
+ */
+#define NODE_MASK_ALL	1UL
+#define NODE_MASK_NONE	0UL
+
+#endif /* __ASM_GENERIC_NODEMASK_UP_H */
diff -Nru a/include/linux/nodemask.h b/include/linux/nodemask.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/linux/nodemask.h	Fri Nov  7 02:52:30 2003
@@ -0,0 +1,42 @@
+#ifndef __LINUX_NODEMASK_H
+#define __LINUX_NODEMASK_H
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/threads.h>
+#include <linux/types.h>
+#include <linux/bitmap.h>
+
+#if MAX_NUMNODES > BITS_PER_LONG
+#define NODE_ARRAY_SIZE		BITS_TO_LONGS(MAX_NUMNODES)
+
+struct nodemask
+{
+	unsigned long mask[NODE_ARRAY_SIZE];
+};
+
+typedef struct nodemask nodemask_t;
+
+#else
+typedef unsigned long nodemask_t;
+#endif
+
+#if defined(CONFIG_DISCONTIGMEM) || defined(CONFIG_NUMA)
+#if MAX_NUMNODES > BITS_PER_LONG
+#include <asm-generic/nodemask_array.h>
+#else
+#include <asm-generic/nodemask_arith.h>
+#endif
+#else
+#include <asm-generic/nodemask_smp.h>
+#endif
+
+#if MAX_NUMNODES <= 4*BITS_PER_LONG
+#include <asm-generic/nodemask_const_value.h>
+#else
+#include <asm-generic/nodemask_const_reference.h>
+#endif
+
+/* If need 'for_each_node', loop from 0 to numnodes-1 */
+
+#endif /* __LINUX_NODEMASK_H */


-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
