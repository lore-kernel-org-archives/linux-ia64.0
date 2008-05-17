From: Russ Anderson <rja@sgi.com>
Date: Sat, 17 May 2008 14:10:35 +0000
Subject: Re: [patch] Fix Altix boot breakage in ACPI
Message-Id: <20080517141034.GA24214@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080516202020.GA21250@sgi.com>
In-Reply-To: <20080516202020.GA21250@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 16, 2008 at 03:40:28PM -0700, Luck, Tony wrote:
> > A recent ACPI change (commit 5dc90c0b2d4bd0127624bab67cec159b2c6c4daf)
> 
> -ENOSUCHCOMMIT ... well I can't see it in Linus' tree.

Sorry, I should have added more information.

It is in Andrew's tree (2.6.26-rc2-mm1).  It has yet to make it to Linus' tree.

http://lkml.org/lkml/2008/5/14/366

The patch name is acpi-acpi_numa_init-build-fix
http://kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc2/2.6.26-rc2-mm1/patch-list

git bisect found:
------------------------------------------------------------------------------------
5dc90c0b2d4bd0127624bab67cec159b2c6c4daf is first bad commit
commit 5dc90c0b2d4bd0127624bab67cec159b2c6c4daf
Author: Ingo Molnar <mingo@elte.hu>
Date:   Thu May 1 09:51:47 2008 +0000

    acpi-acpi_numa_init-build-fix

    x86.git testing found the following build error on latest -git:

     drivers/acpi/numa.c: In function 'acpi_numa_init':
     drivers/acpi/numa.c:226: error: 'NR_NODE_MEMBLKS' undeclared (first use in this function)
     drivers/acpi/numa.c:226: error: (Each undeclared identifier is reported only once
     drivers/acpi/numa.c:226: error: for each function it appears in.)

    with this config:

     http://redhat.com/~mingo/misc/config-Wed_Apr_30_22_42_42_CEST_2008.bad

    i suspect we dont want SRAT parsing when CONFIG_HAVE_ARCH_PARSE_SRAT
    is unset - but the fix looks a bit ugly. Perhaps we should define
    NR_NODE_MEMBLKS even in this case and just let the code fall back
    to some sane behavior?

    Signed-off-by: Ingo Molnar <mingo@elte.hu>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

:040000 040000 65397f028a8bc082be2bde667554c9115e88064b 58d35b65618fafdcbb449dd114e0381df467431d M      drivers
------------------------------------------------------------------------------------

The inadvertent breakage is the patch puts #ifdef CONFIG_HAVE_ARCH_PARSE_SRAT
around acpi_parse_memory_affinity() and acpi_table_parse_srat(), but Altix
needs to parse the SRAT.  The result is that Altix dies early in boot in the
ACPI code.

The fix defines CONFIG_HAVE_ARCH_PARSE_SRAT in ia64 config and 
prevents the parsing routines from being defined as stubs if
NR_NODE_MEMBLKS is defined.  

Since the problem effects Altix, I sent the fix to linux-ia64.  Would it 
have been better to send the fix directly to lkml & Andrew?

This patch fixes the problem
------------------------------------------------------------------------------------
A recent ACPI change (commit 5dc90c0b2d4bd0127624bab67cec159b2c6c4daf)
inadvertently broke Altix boot.  This patch allow Altix to boot.


Signed-off-by: Russ Anderson <rja@sgi.com>
Acked-by: Ingo Molnar <mingo@elte.hu>

---
 arch/ia64/Kconfig    |    4 ++++
 include/linux/acpi.h |    2 +-
 2 files changed, 5 insertions(+), 1 deletion(-)

Index: 2.6.26-rc2/arch/ia64/Kconfig
=================================--- 2.6.26-rc2.orig/arch/ia64/Kconfig	2008-05-16 09:36:37.285558037 -0500
+++ 2.6.26-rc2/arch/ia64/Kconfig	2008-05-16 09:37:39.149204580 -0500
@@ -60,6 +60,10 @@ config RWSEM_XCHGADD_ALGORITHM
 	bool
 	default y
 
+config HAVE_ARCH_PARSE_SRAT
+	bool
+	default y
+
 config ARCH_HAS_ILOG2_U32
 	bool
 	default n
Index: 2.6.26-rc2/include/linux/acpi.h
=================================--- 2.6.26-rc2.orig/include/linux/acpi.h	2008-05-16 09:37:12.989971159 -0500
+++ 2.6.26-rc2/include/linux/acpi.h	2008-05-16 09:50:17.082906375 -0500
@@ -93,7 +93,7 @@ int acpi_parse_mcfg (struct acpi_table_h
 void acpi_table_print_madt_entry (struct acpi_subtable_header *madt);
 
 /* the following four functions are architecture-dependent */
-#ifdef CONFIG_HAVE_ARCH_PARSE_SRAT
+#if defined(CONFIG_HAVE_ARCH_PARSE_SRAT) && !defined(NR_NODE_MEMBLKS)
 #define NR_NODE_MEMBLKS MAX_NUMNODES
 #define acpi_numa_slit_init(slit) do {} while (0)
 #define acpi_numa_processor_affinity_init(pa) do {} while (0)
------------------------------------------------------------------------------------
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
