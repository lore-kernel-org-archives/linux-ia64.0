From: Jack Steiner <steiner@sgi.com>
Date: Wed, 01 Dec 2004 20:38:53 +0000
Subject: SN support for new chipset - [1 of 4]
Message-Id: <20041201203852.GA26131@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Add support for a future SGI chipset (shub2).
(All code is SN-specific)

This patch changes the SN macros for calulating the addresses
of shub MMRs. Functionally, shub1 (current chipset) and shub2
are very similar. The primary differences are in the addresses
of MMRs and in the location of the NASID (node number) in
a physical address. This patch adds the basic infrastructure 
for running a single binary kernel image on either shub1 or shub2.





Index: linux/arch/ia64/sn/kernel/setup.c
=================================--- linux.orig/arch/ia64/sn/kernel/setup.c	2004-12-01 14:16:26.976783772 -0600
+++ linux/arch/ia64/sn/kernel/setup.c	2004-12-01 14:16:43.788424824 -0600
@@ -340,7 +340,7 @@ void __init sn_setup(char **cmdline_p)
  *
  * One time setup for Node Data Area.  Called by sn_setup().
  */
-void __init sn_init_pdas(char **cmdline_p)
+static void __init sn_init_pdas(char **cmdline_p)
 {
 	cnodeid_t cnode;
 
@@ -416,8 +416,17 @@ void __init sn_cpu_init(void)
 	int slice;
 	int cnode;
 	int i;
+	u64 shubtype, nasid_bitmask, nasid_shift;
 	static int wars_have_been_checked;
 
+	memset(pda, 0, sizeof(pda));
+	if (ia64_sn_get_hub_info(0, &shubtype, &nasid_bitmask, &nasid_shift))
+		BUG();
+	pda->shub2 = (u8)shubtype;
+	pda->nasid_bitmask = (u16)nasid_bitmask;
+	pda->nasid_shift = (u8)nasid_shift;
+	pda->as_shift = pda->nasid_shift - 2;
+
 	/*
 	 * The boot cpu makes this call again after platform initialization is
 	 * complete.
@@ -441,7 +450,6 @@ void __init sn_cpu_init(void)
 
 	cnode = nasid_to_cnodeid(nasid);
 
-	memset(pda, 0, sizeof(pda));
 	pda->p_nodepda = nodepdaindr[cnode];
 	pda->led_address  	    (typeof(pda->led_address)) (LED0 + (slice << LED_CPU_SHIFT));
@@ -475,10 +483,6 @@ void __init sn_cpu_init(void)
 	pda->pio_write_status_addr = (volatile unsigned long *)
 	    LOCAL_MMR_ADDR((slice <
 			    2 ? SH_PIO_WRITE_STATUS_0 : SH_PIO_WRITE_STATUS_1));
-	pda->mem_write_status_addr = (volatile u64 *)
-	    LOCAL_MMR_ADDR((slice <
-			    2 ? SH_MEMORY_WRITE_STATUS_0 :
-			    SH_MEMORY_WRITE_STATUS_1));
 
 	if (local_node_data->active_cpu_count++ = 0) {
 		int buddy_nasid;
Index: linux/include/asm-ia64/sn/addrs.h
=================================--- linux.orig/include/asm-ia64/sn/addrs.h	2004-12-01 14:16:26.978736684 -0600
+++ linux/include/asm-ia64/sn/addrs.h	2004-12-01 14:28:58.160621780 -0600
@@ -9,204 +9,175 @@
 #ifndef _ASM_IA64_SN_ADDRS_H
 #define _ASM_IA64_SN_ADDRS_H
 
+#include <asm/percpu.h>
+#include <asm/sn/types.h>
+#include <asm/sn/pda.h>
 
-/* McKinley Address Format:
- *
- *   4 4       3 3  3 3
- *   9 8       8 7  6 5             0
- *  +-+---------+----+--------------+
- *  |0| Node ID | AS | Node Offset  |
- *  +-+---------+----+--------------+
+/*
+ *  Memory/SHUB Address Format:
+ *  +-+---------+--+--------------+
+ *  |0|  NASID  |AS| NodeOffset   |
+ *  +-+---------+--+--------------+
  *
- *   Node ID: If bit 38 = 1, is ICE, else is SHUB
- *   AS: Address Space Identifier. Used only if bit 38 = 0.
- *     b'00: Local Resources and MMR space
- *           bit 35
+ *  NASID: (low NASID bit is 0) Memory and SHUB MMRs
+ *   AS: 2-bit Address Space Identifier. Used only if low NASID bit is 0
+ *     00: Local Resources and MMR space
+ *           Top bit of NodeOffset
  *               0: Local resources space
  *                  node id:
  *                        0: IA64/NT compatibility space
  *                        2: Local MMR Space
  *                        4: Local memory, regardless of local node id
  *               1: Global MMR space
- *     b'01: GET space.
- *     b'10: AMO space.
- *     b'11: Cacheable memory space.
+ *     01: GET space.
+ *     10: AMO space.
+ *     11: Cacheable memory space.
  *
  *   NodeOffset: byte offset
+ *
+ *
+ *  TIO address format:
+ *  +-+----------+--+--------------+
+ *  |0|  NASID   |AS| Nodeoffset   |
+ *  +-+----------+--+--------------+
+ *
+ *  NASID: (low NASID bit is 1) TIO
+ *   AS: 2-bit Chiplet Identifier
+ *     00: TIO LB (Indicates TIO MMR access.)
+ *     01: TIO ICE (indicates coretalk space access.)
+ * 
+ *   NodeOffset: top bit must be set.
+ *
+ *
+ * Note that in both of the above address formats, the low
+ * NASID bit indicates if the reference is to the SHUB or TIO MMRs.
  */
 
-/* TIO address format:
- *  4 4        3 3 3 3 3             0
- *  9 8        8 7 6 5 4
- * +-+----------+-+---+--------------+
- * |0| Node ID  |0|CID| Node offset  |
- * +-+----------+-+---+--------------+
- *
- * Node ID: if bit 38 = 1, is ICE.
- * Bit 37: Must be zero.
- * CID: Chiplet ID:
- *     b'01: TIO LB (Indicates TIO MMR access.)
- *     b'11: TIO ICE (indicates coretalk space access.)
- * Node offset: byte offest.
+
+/*
+ * Define basic shift & mask constants for manipulating NASIDs and AS values.
  */
+#define NASID_BITMASK		(pda->nasid_bitmask)
+#define NASID_SHIFT		(pda->nasid_shift)
+#define AS_SHIFT		(pda->as_shift)
+#define AS_BITMASK		0x3UL
+
+#define NASID_MASK              ((u64)NASID_BITMASK << NASID_SHIFT)
+#define AS_MASK			((u64)AS_BITMASK << AS_SHIFT)
+#define REGION_BITS		0xe000000000000000UL
+
 
 /*
- * Note that in both of the above address formats, bit
- * 35 set indicates that the reference is to the 
- * shub or tio MMRs.
- */
-
-#ifndef __ASSEMBLY__
-typedef union ia64_sn2_pa {
-	struct {
-		unsigned long off  : 36;
-		unsigned long as   : 2;
-		unsigned long nasid: 11;
-		unsigned long fill : 15;
-	} f;
-	unsigned long l;
-	void *p;
-} ia64_sn2_pa_t;
-#endif
-
-#define TO_PHYS_MASK		0x0001ffcfffffffffUL	/* Note - clear AS bits */
-
-
-/* Regions determined by AS */
-#define LOCAL_MMR_SPACE		0xc000008000000000UL	/* Local MMR space */
-#define LOCAL_PHYS_MMR_SPACE	0x8000008000000000UL	/* Local PhysicalMMR space */
-#define LOCAL_MEM_SPACE		0xc000010000000000UL	/* Local Memory space */
-/* It so happens that setting bit 35 indicates a reference to the SHUB or TIO
- * MMR space.  
- */
-#define GLOBAL_MMR_SPACE	0xc000000800000000UL	/* Global MMR space */
-#define TIO_MMR_SPACE		0xc000000800000000UL	/* TIO MMR space */
-#define ICE_MMR_SPACE		0xc000000000000000UL	/* ICE MMR space */
-#define GLOBAL_PHYS_MMR_SPACE	0x0000000800000000UL	/* Global Physical MMR space */
-#define GET_SPACE		0xe000001000000000UL	/* GET space */
-#define AMO_SPACE		0xc000002000000000UL	/* AMO space */
-#define CACHEABLE_MEM_SPACE	0xe000003000000000UL	/* Cacheable memory space */
-#define UNCACHED                0xc000000000000000UL	/* UnCacheable memory space */
-#define UNCACHED_PHYS           0x8000000000000000UL	/* UnCacheable physical memory space */
-
-#define PHYS_MEM_SPACE		0x0000003000000000UL	/* physical memory space */
-
-/* SN2 address macros */
-/* NID_SHFT has the right value for both SHUB and TIO addresses.*/
-#define NID_SHFT		38
-#define LOCAL_MMR_ADDR(a)	(UNCACHED | LOCAL_MMR_SPACE | (a))
-#define LOCAL_MMR_PHYS_ADDR(a)	(UNCACHED_PHYS | LOCAL_PHYS_MMR_SPACE | (a))
-#define LOCAL_MEM_ADDR(a)	(LOCAL_MEM_SPACE | (a))
-#define REMOTE_ADDR(n,a)	((((unsigned long)(n))<<NID_SHFT) | (a))
-#define GLOBAL_MMR_ADDR(n,a)	(UNCACHED | GLOBAL_MMR_SPACE | REMOTE_ADDR(n,a))
-#define GLOBAL_MMR_PHYS_ADDR(n,a) (UNCACHED_PHYS | GLOBAL_PHYS_MMR_SPACE | REMOTE_ADDR(n,a))
-#define GET_ADDR(n,a)		(GET_SPACE | REMOTE_ADDR(n,a))
-#define AMO_ADDR(n,a)		(UNCACHED | AMO_SPACE | REMOTE_ADDR(n,a))
-#define GLOBAL_MEM_ADDR(n,a)	(CACHEABLE_MEM_SPACE | REMOTE_ADDR(n,a))
+ * AS values. These are the same on both SHUB1 & SHUB2.
+ */
+#define AS_GET_VAL		1UL
+#define AS_AMO_VAL		2UL
+#define AS_CAC_VAL		3UL
+#define AS_GET_SPACE		(AS_GET_VAL << AS_SHIFT)
+#define AS_AMO_SPACE		(AS_AMO_VAL << AS_SHIFT)
+#define AS_CAC_SPACE		(AS_CAC_VAL << AS_SHIFT)
 
-/* non-II mmr's start at top of big window space (4G) */
-#define BWIN_TOP		0x0000000100000000UL
 
 /*
- * general address defines - for code common to SN0/SN1/SN2
+ * Base addresses for various address ranges.
+ */
+#define CACHED			0xe000000000000000UL
+#define UNCACHED                0xc000000000000000UL
+#define UNCACHED_PHYS           0x8000000000000000UL
+
+
+/* 
+ * Virtual Mode Local & Global MMR space.  
  */
-#define CAC_BASE		CACHEABLE_MEM_SPACE			/* cacheable memory space */
-#define IO_BASE			(UNCACHED | GLOBAL_MMR_SPACE)		/* lower 4G maps II's XIO space */
-#define TIO_BASE		(UNCACHED | ICE_MMR_SPACE)		/* lower 4G maps TIO space */
-#define AMO_BASE		(UNCACHED | AMO_SPACE)			/* fetch & op space */
-#define MSPEC_BASE		AMO_BASE				/* fetch & op space */
-#define UNCAC_BASE		(UNCACHED | CACHEABLE_MEM_SPACE)	/* uncached global memory */
-#define GET_BASE		GET_SPACE				/* momentarily coherent remote mem. */
-#define CALIAS_BASE             LOCAL_CACHEABLE_BASE			/* cached node-local memory */
-#define UALIAS_BASE             (UNCACHED | LOCAL_CACHEABLE_BASE)	/* uncached node-local memory */
-
-#define TO_PHYS(x)              (              ((x) & TO_PHYS_MASK))
-#define TO_CAC(x)               (CAC_BASE    | ((x) & TO_PHYS_MASK))
-#define TO_UNCAC(x)             (UNCAC_BASE  | ((x) & TO_PHYS_MASK))
-#define TO_MSPEC(x)             (MSPEC_BASE  | ((x) & TO_PHYS_MASK))
-#define TO_GET(x)		(GET_BASE    | ((x) & TO_PHYS_MASK))
-#define TO_CALIAS(x)            (CALIAS_BASE | TO_NODE_ADDRSPACE(x))
-#define TO_UALIAS(x)            (UALIAS_BASE | TO_NODE_ADDRSPACE(x))
-#define NODE_SIZE_BITS		36	/* node offset : bits <35:0> */
-#define BWIN_SIZE_BITS		29	/* big window size: 512M */
-#define TIO_BWIN_SIZE_BITS	30	/* big window size: 1G */
-#define NASID_BITS		11	/* bits <48:38> */
-#define NASID_BITMASK		(0x7ffULL)
-#define NASID_SHFT		NID_SHFT
-#define NASID_META_BITS		0	/* ???? */
-#define NASID_LOCAL_BITS	7	/* same router as SN1 */
-
-#define NODE_ADDRSPACE_SIZE     (1UL << NODE_SIZE_BITS)
-#define NASID_MASK              ((uint64_t) NASID_BITMASK << NASID_SHFT)
-#define NASID_GET(_pa)          (int) (((uint64_t) (_pa) >>            \
-                                        NASID_SHFT) & NASID_BITMASK)
-#define PHYS_TO_DMA(x)          ( ((x & NASID_MASK) >> 2) |             \
-                                  (x & (NODE_ADDRSPACE_SIZE - 1)) )
-
-/*
- * This address requires a chiplet id in bits 38-39.  For DMA to memory,
- * the chiplet id is zero.  If we implement TIO-TIO dma, we might need
- * to insert a chiplet id into this macro.  However, it is our belief
- * right now that this chiplet id will be ICE, which is also zero.
- */
-#define PHYS_TO_TIODMA(x)     ( ((x & NASID_MASK) << 2) |             \
-                                 (x & (NODE_ADDRSPACE_SIZE - 1)) )
-
-#define CHANGE_NASID(n,x)	({ia64_sn2_pa_t _v; _v.l = (long) (x); _v.f.nasid = n; _v.p;})
-
-
-#ifndef __ASSEMBLY__
-#define NODE_SWIN_BASE(nasid, widget)                                   \
-        ((widget = 0) ? NODE_BWIN_BASE((nasid), SWIN0_BIGWIN)          \
-        : RAW_NODE_SWIN_BASE(nasid, widget))
-#else
-#define NODE_SWIN_BASE(nasid, widget) \
-     (NODE_IO_BASE(nasid) + ((uint64_t) (widget) << SWIN_SIZE_BITS))
-#define LOCAL_SWIN_BASE(widget) \
-	(UNCACHED | LOCAL_MMR_SPACE | (((uint64_t) (widget) << SWIN_SIZE_BITS)))
-#endif /* __ASSEMBLY__ */
+#define SH1_LOCAL_MMR_OFFSET	0x8000000000UL
+#define SH2_LOCAL_MMR_OFFSET	0x0200000000UL
+#define LOCAL_MMR_OFFSET	(is_shub2() ? SH2_LOCAL_MMR_OFFSET : SH1_LOCAL_MMR_OFFSET)
+#define LOCAL_MMR_SPACE		(UNCACHED | LOCAL_MMR_OFFSET)
+#define LOCAL_PHYS_MMR_SPACE	(UNCACHED_PHYS | LOCAL_MMR_OFFSET)
+
+#define SH1_GLOBAL_MMR_OFFSET	0x0800000000UL
+#define SH2_GLOBAL_MMR_OFFSET	0x0300000000UL
+#define GLOBAL_MMR_OFFSET	(is_shub2() ? SH2_GLOBAL_MMR_OFFSET : SH1_GLOBAL_MMR_OFFSET)
+#define GLOBAL_MMR_SPACE	(UNCACHED | GLOBAL_MMR_OFFSET)
 
 /*
- * The following definitions pertain to the IO special address
- * space.  They define the location of the big and little windows
- * of any given node.
+ * Physical mode addresses
  */
+#define GLOBAL_PHYS_MMR_SPACE	(UNCACHED_PHYS | GLOBAL_MMR_OFFSET)
 
-#define BWIN_SIZE               (1UL << BWIN_SIZE_BITS)
-#define BWIN_SIZEMASK           (BWIN_SIZE - 1)
-#define BWIN_WIDGET_MASK        0x7
-#define NODE_BWIN_BASE0(nasid)  (NODE_IO_BASE(nasid) + BWIN_SIZE)
-#define NODE_BWIN_BASE(nasid, bigwin)   (NODE_BWIN_BASE0(nasid) +       \
-                        ((uint64_t) (bigwin) << BWIN_SIZE_BITS))
 
-#define BWIN_WIDGETADDR(addr)   ((addr) & BWIN_SIZEMASK)
-#define BWIN_WINDOWNUM(addr)    (((addr) >> BWIN_SIZE_BITS) & BWIN_WIDGET_MASK)
+/*
+ * Clear region & AS bits.
+ */
+#define TO_PHYS_MASK		(~(REGION_BITS | AS_MASK))
 
-#define TIO_BWIN_WINDOW_SELECT_MASK 0x7
-#define TIO_BWIN_WINDOWNUM(addr)    (((addr) >> TIO_BWIN_SIZE_BITS) & TIO_BWIN_WINDOW_SELECT_MASK)
 
+/*
+ * Misc NASID manipulation.
+ */
+#define NASID_SPACE(n)		((u64)(n) << NASID_SHIFT)
+#define REMOTE_ADDR(n,a)	(NASID_SPACE(n) | (a))
+#define NODE_OFFSET(x)		((x) & (NODE_ADDRSPACE_SIZE - 1))
+#define NODE_ADDRSPACE_SIZE     (1UL << AS_SHIFT)
+#define NASID_GET(x)		(int) (((u64) (x) >> NASID_SHIFT) & NASID_BITMASK)
+#define LOCAL_MMR_ADDR(a)	(LOCAL_MMR_SPACE | (a))
+#define GLOBAL_MMR_ADDR(n,a)	(GLOBAL_MMR_SPACE | REMOTE_ADDR(n,a))
+#define GLOBAL_MMR_PHYS_ADDR(n,a) (GLOBAL_PHYS_MMR_SPACE | REMOTE_ADDR(n,a))
+#define GLOBAL_CAC_ADDR(n,a)	(CAC_BASE | REMOTE_ADDR(n,a))
+#define CHANGE_NASID(n,x)	((void *)(((u64)(x) & ~NASID_MASK) | NASID_SPACE(n)))
 
-#ifndef __ASSEMBLY__
-#include <asm/sn/types.h>
-#endif 
+
+/* non-II mmr's start at top of big window space (4G) */
+#define BWIN_TOP		0x0000000100000000UL
 
 /*
- * The following macros are used to index to the beginning of a specific
- * node's address space.
+ * general address defines
  */
+#define CAC_BASE		(CACHED   | AS_CAC_SPACE)
+#define AMO_BASE		(UNCACHED | AS_AMO_SPACE)
+#define GET_BASE		(CACHED   | AS_GET_SPACE)
 
-#define NODE_OFFSET(_n)		((uint64_t) (_n) << NASID_SHFT)
+/*
+ * Convert Memory addresses between various addressing modes.
+ */
+#define TO_PHYS(x)		(TO_PHYS_MASK & (x))
+#define TO_CAC(x)		(CAC_BASE     | TO_PHYS(x))
+#define TO_AMO(x)		(AMO_BASE     | TO_PHYS(x))
+#define TO_GET(x)		(GET_BASE     | TO_PHYS(x))
 
-#define NODE_CAC_BASE(_n)	(CAC_BASE  + NODE_OFFSET(_n))
-#define NODE_HSPEC_BASE(_n)	(HSPEC_BASE + NODE_OFFSET(_n))
-#define NODE_IO_BASE(_n)	(IO_BASE    + NODE_OFFSET(_n))
-#define NODE_MSPEC_BASE(_n)	(MSPEC_BASE + NODE_OFFSET(_n))
-#define NODE_UNCAC_BASE(_n)	(UNCAC_BASE + NODE_OFFSET(_n))
 
-#define TO_NODE_CAC(_n, _x)	(NODE_CAC_BASE(_n) | ((_x) & TO_PHYS_MASK))
+/*
+ * Covert from processor physical address to II/TIO physical address:
+ *	II - squeeze out the AS bits
+ *	TIO- requires a chiplet id in bits 38-39.  For DMA to memory,
+ *           the chiplet id is zero.  If we implement TIO-TIO dma, we might need
+ *           to insert a chiplet id into this macro.  However, it is our belief
+ *           right now that this chiplet id will be ICE, which is also zero.
+ */
+#define PHYS_TO_TIODMA(x)	( (((u64)(x) & NASID_MASK) << 2) | NODE_OFFSET(x))
+#define PHYS_TO_DMA(x)          ( (((u64)(x) & NASID_MASK) >> 2) | NODE_OFFSET(x))
+
+
+/*
+ * The following definitions pertain to the IO special address
+ * space.  They define the location of the big and little windows
+ * of any given node.
+ */
+#define BWIN_SIZE_BITS			29	/* big window size: 512M */
+#define TIO_BWIN_SIZE_BITS		30	/* big window size: 1G */
+#define NODE_SWIN_BASE(n, w)		((w = 0) ? NODE_BWIN_BASE((n), SWIN0_BIGWIN) \
+		: RAW_NODE_SWIN_BASE(n, w))
+#define NODE_IO_BASE(n)			(GLOBAL_MMR_SPACE | NASID_SPACE(n))
+#define BWIN_SIZE			(1UL << BWIN_SIZE_BITS)
+#define NODE_BWIN_BASE0(n)		(NODE_IO_BASE(n) + BWIN_SIZE)
+#define NODE_BWIN_BASE(n, w)		(NODE_BWIN_BASE0(n) + ((u64) (w) << BWIN_SIZE_BITS))
+#define RAW_NODE_SWIN_BASE(n, w)	(NODE_IO_BASE(n) + ((u64) (w) << SWIN_SIZE_BITS))
+#define BWIN_WIDGET_MASK		0x7
+#define BWIN_WINDOWNUM(x)		(((x) >> BWIN_SIZE_BITS) & BWIN_WIDGET_MASK)
+
+#define TIO_BWIN_WINDOW_SELECT_MASK	0x7
+#define TIO_BWIN_WINDOWNUM(x)		(((x) >> TIO_BWIN_SIZE_BITS) & TIO_BWIN_WINDOW_SELECT_MASK)
 
-#define RAW_NODE_SWIN_BASE(nasid, widget)				\
-	(NODE_IO_BASE(nasid) + ((uint64_t) (widget) << SWIN_SIZE_BITS))
 
 
 /*
@@ -215,15 +186,12 @@ typedef union ia64_sn2_pa {
  * of any given node.
  */
 
-#define SWIN_SIZE_BITS		24
-#define SWIN_SIZE		(1UL << 24)
-#define	SWIN_SIZEMASK		(SWIN_SIZE - 1)
-#define	SWIN_WIDGET_MASK	0xF
-
-#define TIO_SWIN_SIZE_BITS	28
-#define TIO_SWIN_SIZE		(1UL << 28)
-#define TIO_SWIN_SIZEMASK	(SWIN_SIZE - 1)
-#define TIO_SWIN_WIDGET_MASK	0x3
+#define SWIN_SIZE_BITS			24
+#define	SWIN_WIDGET_MASK		0xF
+
+#define TIO_SWIN_SIZE_BITS		28
+#define TIO_SWIN_SIZE			(1UL << TIO_SWIN_SIZE_BITS)
+#define TIO_SWIN_WIDGET_MASK		0x3
 
 /*
  * Convert smallwindow address to xtalk address.
@@ -231,82 +199,39 @@ typedef union ia64_sn2_pa {
  * 'addr' can be physical or virtual address, but will be converted
  * to Xtalk address in the range 0 -> SWINZ_SIZEMASK
  */
-#define	SWIN_WIDGETNUM(addr)	(((addr)  >> SWIN_SIZE_BITS) & SWIN_WIDGET_MASK)
+#define	SWIN_WIDGETNUM(x)		(((x)  >> SWIN_SIZE_BITS) & SWIN_WIDGET_MASK)
+#define TIO_SWIN_WIDGETNUM(x)		(((x)  >> TIO_SWIN_SIZE_BITS) & TIO_SWIN_WIDGET_MASK)
 
-#define TIO_SWIN_WIDGETNUM(addr)	(((addr)  >> TIO_SWIN_SIZE_BITS) & TIO_SWIN_WIDGET_MASK)
 
 /*
  * The following macros produce the correct base virtual address for
- * the hub registers.  The LOCAL_HUB_* macros produce the appropriate
- * address for the local registers.  The REMOTE_HUB_* macro produce
+ * the hub registers. The REMOTE_HUB_* macro produce
  * the address for the specified hub's registers.  The intent is
  * that the appropriate PI, MD, NI, or II register would be substituted
- * for _x.
- */
-
-
-/*
- * SN2 has II mmr's located inside small window space.
- * As all other non-II mmr's located at the top of big window
- * space.
- */
-#define REMOTE_HUB_BASE(_x)						\
-        (UNCACHED | GLOBAL_MMR_SPACE |                                  \
-        (((~(_x)) & BWIN_TOP)>>8)    |                                       \
-        (((~(_x)) & BWIN_TOP)>>9)    | (_x))
-
-#define REMOTE_HUB(_n, _x)						\
-	((uint64_t *)(REMOTE_HUB_BASE(_x) | ((((long)(_n))<<NASID_SHFT))))
-
-
-/*
- * WARNING:
+ * for x.
+ *
+ *   WARNING:
  *	When certain Hub chip workaround are defined, it's not sufficient
  *	to dereference the *_HUB_ADDR() macros.  You should instead use
  *	HUB_L() and HUB_S() if you must deal with pointers to hub registers.
  *	Otherwise, the recommended approach is to use *_HUB_L() and *_HUB_S().
  *	They're always safe.
  */
-/*
- * LOCAL_HUB_ADDR doesn't need to be changed for TIO, since, by definition,
- * there are no "local" TIOs.
- */
-#define LOCAL_HUB_ADDR(_x)							\
-	(((_x) & BWIN_TOP) ? ((volatile uint64_t *)(LOCAL_MMR_ADDR(_x)))		\
-	: ((volatile uint64_t *)(IALIAS_BASE + (_x))))
-#define REMOTE_HUB_ADDR(_n, _x)						\
-	((_n & 1) ?							\
+#define REMOTE_HUB_ADDR(n,x)						\
+	((n & 1) ?							\
 	/* TIO: */							\
-	((volatile uint64_t *)(GLOBAL_MMR_ADDR(_n, _x)))				\
+	((volatile u64 *)(GLOBAL_MMR_ADDR(n,x)))			\
 	: /* SHUB: */							\
-	(((_x) & BWIN_TOP) ? ((volatile uint64_t *)(GLOBAL_MMR_ADDR(_n, _x)))	\
-	: ((volatile uint64_t *)(NODE_SWIN_BASE(_n, 1) + 0x800000 + (_x)))))
-
-#ifndef __ASSEMBLY__
+	(((x) & BWIN_TOP) ? ((volatile u64 *)(GLOBAL_MMR_ADDR(n,x)))\
+	: ((volatile u64 *)(NODE_SWIN_BASE(n,1) + 0x800000 + (x)))))
 
-#define HUB_L(_a)			(*((volatile typeof(*_a) *)_a))
-#define	HUB_S(_a, _d)			(*((volatile typeof(*_a) *)_a) = (_d))
 
-#define LOCAL_HUB_L(_r)			HUB_L(LOCAL_HUB_ADDR(_r))
-#define LOCAL_HUB_S(_r, _d)		HUB_S(LOCAL_HUB_ADDR(_r), (_d))
-#define REMOTE_HUB_L(_n, _r)		HUB_L(REMOTE_HUB_ADDR((_n), (_r)))
-#define REMOTE_HUB_S(_n, _r, _d)	HUB_S(REMOTE_HUB_ADDR((_n), (_r)), (_d))
-#define REMOTE_HUB_PI_L(_n, _sn, _r)	HUB_L(REMOTE_HUB_PI_ADDR((_n), (_sn), (_r)))
-#define REMOTE_HUB_PI_S(_n, _sn, _r, _d) HUB_S(REMOTE_HUB_PI_ADDR((_n), (_sn), (_r)), (_d))
 
-#endif /* __ASSEMBLY__ */
-
-/*
- * The following macros are used to get to a hub/bridge register, given
- * the base of the register space.
- */
-#define HUB_REG_PTR(_base, _off)	\
-	(volatile uint64_t *)((unsigned long)(_base) + (__psunsigned_t)(_off)))
+#define HUB_L(x)			(*((volatile typeof(*x) *)x))
+#define	HUB_S(x,d)			(*((volatile typeof(*x) *)x) = (d))
 
-#define HUB_REG_PTR_L(_base, _off)	\
-	HUB_L(HUB_REG_PTR((_base), (_off)))
+#define REMOTE_HUB_L(n, a)		HUB_L(REMOTE_HUB_ADDR((n), (a)))
+#define REMOTE_HUB_S(n, a, d)		HUB_S(REMOTE_HUB_ADDR((n), (a)), (d))
 
-#define HUB_REG_PTR_S(_base, _off, _data)	\
-	HUB_S(HUB_REG_PTR((_base), (_off)), (_data))
 
 #endif /* _ASM_IA64_SN_ADDRS_H */
Index: linux/include/asm-ia64/sn/klconfig.h
=================================--- linux.orig/include/asm-ia64/sn/klconfig.h	2004-12-01 14:16:26.978736684 -0600
+++ linux/include/asm-ia64/sn/klconfig.h	2004-12-01 14:16:32.444936609 -0600
@@ -29,7 +29,7 @@ typedef struct kl_config_hdr {
 } kl_config_hdr_t;
 
 
-#define NODE_OFFSET_TO_LBOARD(nasid,off)        (lboard_t*)(NODE_CAC_BASE(nasid) + (off))
+#define NODE_OFFSET_TO_LBOARD(nasid,off)        (lboard_t*)(GLOBAL_CAC_ADDR((nasid), (off)))
 
 /*
  * The KLCONFIG area is organized as a LINKED LIST of BOARDs. A BOARD
Index: linux/include/asm-ia64/sn/pda.h
=================================--- linux.orig/include/asm-ia64/sn/pda.h	2004-12-01 14:16:26.978736684 -0600
+++ linux/include/asm-ia64/sn/pda.h	2004-12-01 14:16:32.444936609 -0600
@@ -37,17 +37,21 @@ typedef struct pda_s {
 	 * Support for SN LEDs
 	 */
 	volatile short	*led_address;
+	u16		nasid_bitmask;
+	u8		shub2;
+	u8		nasid_shift;
+	u8		as_shift;
+	u8		shub_1_1_found;
 	u8		led_state;
 	u8		hb_state;	/* supports blinking heartbeat leds */
-	u8		shub_1_1_found;
 	unsigned int	hb_count;
 
 	unsigned int	idle_flag;
 	
 	volatile unsigned long *bedrock_rev_id;
 	volatile unsigned long *pio_write_status_addr;
+	unsigned long pio_write_status_val;
 	volatile unsigned long *pio_shub_war_cam_addr;
-	volatile unsigned long *mem_write_status_addr;
 
 	struct bteinfo_s *cpu_bte_if[BTES_PER_NODE];	/* cpu interface order */
 
@@ -76,7 +80,7 @@ typedef struct pda_s {
  */
 DECLARE_PER_CPU(struct pda_s, pda_percpu);
 
-#define pda		(&__get_cpu_var(pda_percpu))
+#define pda		(&__ia64_per_cpu_var(pda_percpu))
 
 #define pdacpu(cpu)	(&per_cpu(pda_percpu, cpu))
 
@@ -85,4 +89,7 @@ DECLARE_PER_CPU(struct pda_s, pda_percpu
  */
 #define enable_shub_wars_1_1()	(pda->shub_1_1_found)
 
+#define is_shub2()	(pda->shub2)
+#define is_shub1()	(pda->shub2 = 0)
+
 #endif /* _ASM_IA64_SN_PDA_H */
Index: linux/include/asm-ia64/sn/sn_sal.h
=================================--- linux.orig/include/asm-ia64/sn/sn_sal.h	2004-12-01 14:16:26.979713140 -0600
+++ linux/include/asm-ia64/sn/sn_sal.h	2004-12-01 14:16:32.445913065 -0600
@@ -32,9 +32,10 @@
 #define  SN_SAL_NO_FAULT_ZONE_VIRTUAL		   0x02000010
 #define  SN_SAL_NO_FAULT_ZONE_PHYSICAL		   0x02000011
 #define  SN_SAL_PRINT_ERROR			   0x02000012
-#define  SN_SAL_GET_SAPIC_INFO                     0x02009999	//ZZZZ fix
 #define  SN_SAL_SET_ERROR_HANDLING_FEATURES	   0x0200001a	// reentrant
 #define  SN_SAL_GET_FIT_COMPT			   0x0200001b	// reentrant
+#define  SN_SAL_GET_HUB_INFO                       0x0200001c
+#define  SN_SAL_GET_SAPIC_INFO                     0x0200001d
 #define  SN_SAL_CONSOLE_PUTC                       0x02000021
 #define  SN_SAL_CONSOLE_GETC                       0x02000022
 #define  SN_SAL_CONSOLE_PUTS                       0x02000023
@@ -847,6 +848,14 @@ ia64_sn_irtr_init(nasid_t nasid, void *b
 
 /*
  * Returns the nasid, subnode & slice corresponding to a SAPIC ID
+ *
+ *  In:
+ *	arg0 - SN_SAL_GET_SAPIC_INFO
+ *	arg1 - sapicid (lid >> 16) 
+ *  Out:
+ *	v0 - nasid
+ *	v1 - subnode
+ *	v2 - slice
  */
 static inline u64
 ia64_sn_get_sapic_info(int sapicid, int *nasid, int *subnode, int *slice)
@@ -859,7 +868,7 @@ ia64_sn_get_sapic_info(int sapicid, int 
 	ret_stuff.v2 = 0;
 	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_GET_SAPIC_INFO, sapicid, 0, 0, 0, 0, 0, 0);
 
-/***** BEGIN HACK - temp til new proms available ********/
+/***** BEGIN HACK - temp til old proms no longer supported ********/
 	if (ret_stuff.status = SALRET_NOT_IMPLEMENTED) {
 		if (nasid) *nasid = sapicid & 0xfff;
 		if (subnode) *subnode = (sapicid >> 13) & 1;
@@ -876,6 +885,46 @@ ia64_sn_get_sapic_info(int sapicid, int 
 	if (slice) *slice = (int) ret_stuff.v2;
 	return 0;
 }
+ 
+/*
+ * Returns information about the HUB/SHUB.
+ *  In:
+ *	arg0 - SN_SAL_GET_HUB_INFO
+ * 	arg1 - 0 (other values reserved for future use)
+ *  Out:
+ *	v0 - shub type (0=shub1, 1=shub2)
+ *	v1 - masid mask (ex., 0x7ff for 11 bit nasid)
+ *	v2 - bit position of low nasid bit
+ */
+static inline u64
+ia64_sn_get_hub_info(int fc, u64 *arg1, u64 *arg2, u64 *arg3)
+{
+	struct ia64_sal_retval ret_stuff;
+
+	ret_stuff.status = 0;
+	ret_stuff.v0 = 0;
+	ret_stuff.v1 = 0;
+	ret_stuff.v2 = 0;
+	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_GET_HUB_INFO, fc, 0, 0, 0, 0, 0, 0);
+
+/***** BEGIN HACK - temp til old proms no longer supported ********/
+	if (ret_stuff.status = SALRET_NOT_IMPLEMENTED) {
+		if (arg1) *arg1 = 0;
+		if (arg2) *arg2 = 0x7ff;
+		if (arg3) *arg3 = 38;
+		return 0;
+	}
+/***** END HACK *******/
+
+	if (ret_stuff.status < 0)
+		return ret_stuff.status;
+
+	if (arg1) *arg1 = ret_stuff.v0;
+	if (arg2) *arg2 = ret_stuff.v1;
+	if (arg3) *arg3 = ret_stuff.v2;
+	return 0;
+}
+ 
 /*
  * This is the access point to the Altix PROM hardware performance
  * and status monitoring interface. For info on using this, see
Index: linux/include/asm-ia64/sn/sndrv.h
=================================--- linux.orig/include/asm-ia64/sn/sndrv.h	2004-12-01 14:16:26.979713140 -0600
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,47 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (c) 2002-2004 Silicon Graphics, Inc.  All Rights Reserved.
- */
-
-#ifndef _ASM_IA64_SN_SNDRV_H
-#define _ASM_IA64_SN_SNDRV_H
-
-/* ioctl commands */
-#define SNDRV_GET_ROUTERINFO		1
-#define SNDRV_GET_INFOSIZE		2
-#define SNDRV_GET_HUBINFO		3
-#define SNDRV_GET_FLASHLOGSIZE		4
-#define SNDRV_SET_FLASHSYNC		5
-#define SNDRV_GET_FLASHLOGDATA		6
-#define SNDRV_GET_FLASHLOGALL		7
-
-#define SNDRV_SET_HISTOGRAM_TYPE	14
-
-#define SNDRV_ELSC_COMMAND		19
-#define	SNDRV_CLEAR_LOG			20
-#define	SNDRV_INIT_LOG			21
-#define	SNDRV_GET_PIMM_PSC		22
-#define SNDRV_SET_PARTITION		23
-#define SNDRV_GET_PARTITION		24
-
-/* see synergy_perf_ioctl() */
-#define SNDRV_GET_SYNERGY_VERSION	30
-#define SNDRV_GET_SYNERGY_STATUS	31
-#define SNDRV_GET_SYNERGYINFO		32
-#define SNDRV_SYNERGY_APPEND		33
-#define SNDRV_SYNERGY_ENABLE		34
-#define SNDRV_SYNERGY_FREQ		35
-
-/* Devices */
-#define SNDRV_UKNOWN_DEVICE		-1
-#define SNDRV_ROUTER_DEVICE		1
-#define SNDRV_HUB_DEVICE		2
-#define SNDRV_ELSC_NVRAM_DEVICE		3
-#define SNDRV_ELSC_CONTROLLER_DEVICE	4
-#define SNDRV_SYSCTL_SUBCH		5
-#define SNDRV_SYNERGY_DEVICE		6
-
-#endif /* _ASM_IA64_SN_SNDRV_H */
Index: linux/arch/ia64/sn/kernel/sn2/timer.c
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/timer.c	2004-12-01 14:16:26.977760228 -0600
+++ linux/arch/ia64/sn/kernel/sn2/timer.c	2004-12-01 14:16:43.787448369 -0600
@@ -26,12 +26,12 @@ static struct time_interpolator sn2_inte
 	.drift = -1,
 	.shift = 10,
 	.mask = (1LL << 55) - 1,
-	.source = TIME_SOURCE_MMIO64,
-	.addr = RTC_COUNTER_ADDR
+	.source = TIME_SOURCE_MMIO64
 };
 
 void __init sn_timer_init(void)
 {
 	sn2_interpolator.frequency = sn_rtc_cycles_per_second;
+	sn2_interpolator.addr = RTC_COUNTER_ADDR;
 	register_time_interpolator(&sn2_interpolator);
 }
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


