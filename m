From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 22 Mar 2005 04:42:58 +0000
Subject: Re: [PATCH] move cnodeid_to_nasid_table out of pda
Message-Id: <Pine.LNX.4.58.0503212039280.11202@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <423F2342.mailxGRL11RVD3@aqua.americas.sgi.com>
In-Reply-To: <423F2342.mailxGRL11RVD3@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> On Mon, 21 Mar 2005, Dean Nelson wrote:
>
> > Another step in the effort to eliminate the SN pda structure.
> > This patch moves the cnodeid_to_nasid_table field out of the pda,
> > making it a standalone per-cpu data item, and exports it so it can
> > be accessed by kernel modules.

Yuck something went wrong with the test. Turns out that I need a lot more
definitions to make mmtimer a module since it uses the SHUB access macros.
The following patch applies on top of Dean's patch:

Make key components of the pda_s structure cpu local and export them so that
the low level access macros to the SN2 SHub work. This is necessary to make
mmtimer work as a module.

Also removes the unused p_subnodepda in pda_s.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.11/include/asm-ia64/sn/pda.h
=================================--- linux-2.6.11.orig/include/asm-ia64/sn/pda.h	2005-03-21 18:54:47.000000000 -0800
+++ linux-2.6.11/include/asm-ia64/sn/pda.h	2005-03-21 20:31:19.000000000 -0800
@@ -25,23 +25,10 @@

 typedef struct pda_s {

-	/* Having a pointer in the begining of PDA tends to increase
-	 * the chance of having this pointer in cache. (Yes something
-	 * else gets pushed out). Doing this reduces the number of memory
-	 * access to all nodepda variables to be one
-	 */
-	struct nodepda_s *p_nodepda;		/* Pointer to Per node PDA */
-	struct subnodepda_s *p_subnodepda;	/* Pointer to CPU  subnode PDA */
-
 	/*
 	 * Support for SN LEDs
 	 */
 	volatile short	*led_address;
-	u16		nasid_bitmask;
-	u8		shub2;
-	u8		nasid_shift;
-	u8		as_shift;
-	u8		shub_1_1_found;
 	u8		led_state;
 	u8		hb_state;	/* supports blinking heartbeat leds */
 	unsigned int	hb_count;
@@ -83,12 +70,17 @@ DECLARE_PER_CPU(struct pda_s, pda_percpu

 #define pdacpu(cpu)	(&per_cpu(pda_percpu, cpu))

+DECLARE_PER_CPU(u64, __sn_shub2);
+#define sn_shub2	(__get_cpu_var(__sn_shub2))
+DECLARE_PER_CPU(u64, __sn_shub_1_1_found);
+#define sn_shub_1_1_found	(__get_cpu_var(__sn_shub_1_1_found))
+
 /*
  * Use this macro to test if shub 1.1 wars should be enabled
  */
-#define enable_shub_wars_1_1()	(pda->shub_1_1_found)
+#define enable_shub_wars_1_1()	(sn_shub_1_1_found)

-#define is_shub2()	(pda->shub2)
-#define is_shub1()	(pda->shub2 = 0)
+#define is_shub2()	(sn_shub2)
+#define is_shub1()	(sn_shub2 = 0)

 #endif /* _ASM_IA64_SN_PDA_H */
Index: linux-2.6.11/include/asm-ia64/sn/arch.h
=================================--- linux-2.6.11.orig/include/asm-ia64/sn/arch.h	2005-03-21 18:54:47.000000000 -0800
+++ linux-2.6.11/include/asm-ia64/sn/arch.h	2005-03-21 20:01:47.000000000 -0800
@@ -30,7 +30,12 @@
  */
 DECLARE_PER_CPU(short, __sn_cnodeid_to_nasid[MAX_NUMNODES]);
 #define sn_cnodeid_to_nasid	(&__get_cpu_var(__sn_cnodeid_to_nasid[0]))
-
+DECLARE_PER_CPU(u64, __sn_nasid_bitmask);
+#define sn_nasid_bitmask	(__get_cpu_var(__sn_nasid_bitmask))
+DECLARE_PER_CPU(u64, __sn_nasid_shift);
+#define sn_nasid_shift	(__get_cpu_var(__sn_nasid_shift))
+DECLARE_PER_CPU(u64, __sn_as_shift);
+#define sn_as_shift	(__get_cpu_var(__sn_as_shift))

 extern void sn_flush_all_caches(long addr, long bytes);

Index: linux-2.6.11/arch/ia64/sn/kernel/setup.c
=================================--- linux-2.6.11.orig/arch/ia64/sn/kernel/setup.c	2005-03-21 18:54:47.000000000 -0800
+++ linux-2.6.11/arch/ia64/sn/kernel/setup.c	2005-03-21 20:30:13.000000000 -0800
@@ -72,6 +72,20 @@ EXPORT_SYMBOL(sn_rtc_cycles_per_second);

 DEFINE_PER_CPU(short, __sn_cnodeid_to_nasid[MAX_NUMNODES]);
 EXPORT_PER_CPU_SYMBOL(__sn_cnodeid_to_nasid);
+DEFINE_PER_CPU(u64, __sn_nasid_bitmask);
+EXPORT_PER_CPU_SYMBOL(__sn_nasid_bitmask);
+DEFINE_PER_CPU(u64, __sn_nasid_shift);
+EXPORT_PER_CPU_SYMBOL(__sn_nasid_shift);
+DEFINE_PER_CPU(u64, __sn_as_shift);
+EXPORT_PER_CPU_SYMBOL(__sn_as_shift);
+
+DEFINE_PER_CPU(u64, __sn_shub2);
+EXPORT_PER_CPU_SYMBOL(__sn_shub2);
+DEFINE_PER_CPU(u64, __sn_shub_1_1_found);
+EXPORT_PER_CPU_SYMBOL(__sn_shub_1_1_found);
+
+DEFINE_PER_CPU(struct nodepda_s *, __sn_nodepda);
+EXPORT_PER_CPU_SYMBOL(__sn_nodepda);

 partid_t sn_partid = -1;
 EXPORT_SYMBOL(sn_partid);
@@ -433,10 +447,10 @@ void __init sn_cpu_init(void)
 	memset(pda, 0, sizeof(pda));
 	if (ia64_sn_get_hub_info(0, &shubtype, &nasid_bitmask, &nasid_shift))
 		BUG();
-	pda->shub2 = (u8)shubtype;
-	pda->nasid_bitmask = (u16)nasid_bitmask;
-	pda->nasid_shift = (u8)nasid_shift;
-	pda->as_shift = pda->nasid_shift - 2;
+	sn_shub2 = shubtype;
+	sn_nasid_bitmask = nasid_bitmask;
+	sn_nasid_shift = nasid_shift;
+	sn_as_shift = nasid_shift - 2;

 	/*
 	 * The boot cpu makes this call again after platform initialization is
@@ -461,7 +475,7 @@ void __init sn_cpu_init(void)

 	cnode = nasid_to_cnodeid(nasid);

-	pda->p_nodepda = nodepdaindr[cnode];
+	nodepda = nodepdaindr[cnode];
 	pda->led_address  	    (typeof(pda->led_address)) (LED0 + (slice << LED_CPU_SHIFT));
 	pda->led_state = LED_ALWAYS_SET;
@@ -488,7 +502,7 @@ void __init sn_cpu_init(void)
 		sn_check_for_wars();
 		wars_have_been_checked = 1;
 	}
-	pda->shub_1_1_found = shub_1_1_found;
+	sn_shub_1_1_found = shub_1_1_found;

 	/*
 	 * Set up addresses of PIO/MEM write status registers.
Index: linux-2.6.11/include/asm-ia64/sn/addrs.h
=================================--- linux-2.6.11.orig/include/asm-ia64/sn/addrs.h	2005-03-01 23:38:38.000000000 -0800
+++ linux-2.6.11/include/asm-ia64/sn/addrs.h	2005-03-21 19:21:36.000000000 -0800
@@ -57,9 +57,9 @@
 /*
  * Define basic shift & mask constants for manipulating NASIDs and AS values.
  */
-#define NASID_BITMASK		(pda->nasid_bitmask)
-#define NASID_SHIFT		(pda->nasid_shift)
-#define AS_SHIFT		(pda->as_shift)
+#define NASID_BITMASK		(sn_nasid_bitmask)
+#define NASID_SHIFT		(sn_nasid_shift)
+#define AS_SHIFT		(sn_as_shift)
 #define AS_BITMASK		0x3UL

 #define NASID_MASK              ((u64)NASID_BITMASK << NASID_SHIFT)
Index: linux-2.6.11/include/asm-ia64/sn/nodepda.h
=================================--- linux-2.6.11.orig/include/asm-ia64/sn/nodepda.h	2005-03-01 23:38:37.000000000 -0800
+++ linux-2.6.11/include/asm-ia64/sn/nodepda.h	2005-03-21 20:12:31.000000000 -0800
@@ -74,7 +74,9 @@ typedef struct nodepda_s nodepda_t;
  *	SUBNODEPDA(cnode,sn)	-> to access subnode PDA for cnodeid/subnode
  */

-#define	nodepda		pda->p_nodepda		/* Ptr to this node's PDA */
+DECLARE_PER_CPU(struct nodepda_s *, __sn_nodepda);
+#define nodepda (__get_cpu_var(__sn_nodepda))
+
 #define	NODEPDA(cnode)		(nodepda->pernode_pdaindr[cnode])

 /*


