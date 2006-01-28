From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Sat, 28 Jan 2006 03:34:31 +0000
Subject: [PATCH 001/003]Fix unify mapping from pxm to node id.
Message-Id: <20060128122758.CF50.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060123165644.C147.Y-GOTO@jp.fujitsu.com> <20060126074846.1a6dd300.pj@sgi.com>
In-Reply-To: <20060126074846.1a6dd300.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@osdl.org, Andy Whitcroft <apw@shadowen.org>, Bob Picco <bob.picco@hp.com>, Paul Jackson <pj@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com, ak@suse.de, len.brown@intel.com, discuss@x86-64.org

I'm sorry for my lazy work.
There were some compile errors for i386 and ia64. Not only Paul-san,
Bob-san and Andy-san also sent me result of complile or patches.
(Thanks a lot!)
To tell all of here and summarize what was wrong,
I'll repost all patches to solve them. These are for 2.6.16-rc1-mm3.

Andrew-san. Please apply.

----------------

This is for fix unification from pxm to node id against i386.
acpi_numa_processor_affinity_init() and other 3 function was defined for
x86-64 and ia64. But i386 doesn't use them.
This is just dummy function for compile.
And some of garbages are removed.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: new_pxm/arch/i386/Kconfig
=================================--- new_pxm.orig/arch/i386/Kconfig
+++ new_pxm/arch/i386/Kconfig
@@ -141,6 +141,11 @@ config ACPI_SRAT
 	depends on NUMA && (X86_SUMMIT || X86_GENERICARCH)
 	select ACPI_NUMA
 
+config HAVE_ARCH_PARSE_SRAT
+       bool
+       default y
+       depends on ACPI_SRAT
+
 config X86_SUMMIT_NUMA
 	bool
 	default y
Index: new_pxm/include/linux/acpi.h
=================================--- new_pxm.orig/include/linux/acpi.h
+++ new_pxm/include/linux/acpi.h
@@ -409,10 +409,18 @@ void acpi_table_print_madt_entry (acpi_t
 void acpi_table_print_srat_entry (acpi_table_entry_header *srat);
 
 /* the following four functions are architecture-dependent */
+#ifdef CONFIG_HAVE_ARCH_PARSE_SRAT
+#define NR_NODE_MEMBLKS MAX_NUMNODES
+#define acpi_numa_slit_init(slit) do {} while (0)
+#define acpi_numa_processor_affinity_init(pa) do {} while (0)
+#define acpi_numa_memory_affinity_init(ma) do {} while (0)
+#define acpi_numa_arch_fixup() do {} while (0)
+#else
 void acpi_numa_slit_init (struct acpi_table_slit *slit);
 void acpi_numa_processor_affinity_init (struct acpi_table_processor_affinity *pa);
 void acpi_numa_memory_affinity_init (struct acpi_table_memory_affinity *ma);
 void acpi_numa_arch_fixup(void);
+#endif
 
 #ifdef CONFIG_ACPI_HOTPLUG_CPU
 /* Arch dependent functions for cpu hotplug support */
Index: new_pxm/arch/i386/kernel/srat.c
=================================--- new_pxm.orig/arch/i386/kernel/srat.c
+++ new_pxm/arch/i386/kernel/srat.c
@@ -39,7 +39,6 @@
 #define NODE_ARRAY_OFFSET(x)	((x) % 8)	/* 8 bits/char */
 #define BMAP_SET(bmap, bit)	((bmap)[NODE_ARRAY_INDEX(bit)] |= 1 << NODE_ARRAY_OFFSET(bit))
 #define BMAP_TEST(bmap, bit)	((bmap)[NODE_ARRAY_INDEX(bit)] & (1 << NODE_ARRAY_OFFSET(bit)))
-#define MAX_PXM_DOMAINS		256	/* 1 byte and no promises about values */
 /* bitmap length; _PXM is at most 255 */
 #define PXM_BITMAP_LEN (MAX_PXM_DOMAINS / 8) 
 static u8 pxm_bitmap[PXM_BITMAP_LEN];	/* bitmap of proximity domains */
@@ -218,7 +217,6 @@ static int __init acpi20_parse_srat(stru
 {
 	u8 *start, *end, *p;
 	int i, j, nid;
-	u8 nid_to_pxm_map[MAX_NUMNODES];/* logical node ID to _PXM map */
 
 	start = (u8 *)(&(sratp->reserved) + 1);	/* skip header */
 	p = start;

-- 
Yasunori Goto 


