From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 16 Mar 2001 07:22:18 +0000
Subject: [Linux-ia64] Finally: success with 2.4.2-ia64-010228
Message-Id: <marc-linux-ia64-105590693005276@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Several independent bugs combined to make 2.4.2-ia64-010228 fail.  The
first two patches below came from an SGI mailing list and may already
be known on this list, although I have not seen them mentioned here.

The ivt.S change caused random errors on kdb break points.

The missing '\' in ia64/config.in slips through menuconfig and results
in CONFIG_ITANIUM_PTCG being set to y for B1 and B2.  As soon as init
calls mprotect() on my B1 it does ptcg and hangs.  This explains why
some people were reporting hang after the kernel gives control to user
space.

I am still seeing random EFI delays, before it even gets to the kernel,
using build 84.  AFAICT there is no higher build for B1.

Index: 2.17/drivers/acpi/resources/rscalc.c
--- 2.17/drivers/acpi/resources/rscalc.c Sat, 10 Feb 2001 13:20:52 +1100 kaos (linux-2.4/q/b/43_rscalc.c 1.3 644)
+++ 2.17(w)/drivers/acpi/resources/rscalc.c Fri, 16 Mar 2001 13:31:09 +1100 kaos (linux-2.4/q/b/43_rscalc.c 1.3 644)
@@ -866,7 +866,7 @@ acpi_rs_calculate_pci_routing_table_leng
 	}
 
 
-	*buffer_size_needed = temp_size_needed;
+	*buffer_size_needed = temp_size_needed + sizeof(PCI_ROUTING_TABLE);
 
 	return (AE_OK);
 }
Index: 2.17/drivers/acpi/common/cmxface.c
--- 2.17/drivers/acpi/common/cmxface.c Sat, 10 Feb 2001 13:20:52 +1100 kaos (linux-2.4/s/b/41_cmxface.c 1.4 644)
+++ 2.17(w)/drivers/acpi/common/cmxface.c Fri, 16 Mar 2001 13:33:07 +1100 kaos (linux-2.4/s/b/41_cmxface.c 1.4 644)
@@ -158,7 +158,12 @@ acpi_enable_subsystem (
 	if (!(flags & ACPI_NO_ACPI_ENABLE)) {
 		status = acpi_enable ();
 		if (ACPI_FAILURE (status)) {
+#define BIGSUR_WA
+#ifdef BIGSUR_WA
+			printk("acpi_enable fail:ignored\n");
+#else
 			return (status);
+#endif
 		}
 
 	/*
 	 * Note:
Index: 2.17/arch/ia64/kernel/ivt.S
--- 2.17/arch/ia64/kernel/ivt.S Fri, 02 Mar 2001 13:03:52 +1100 kaos (linux-2.4/s/c/6_ivt.S 1.1.2.1 644)
+++ 2.17(w)/arch/ia64/kernel/ivt.S Fri, 16 Mar 2001 15:05:27 +1100 kaos (linux-2.4/s/c/6_ivt.S 1.1.2.1 644)
@@ -899,7 +899,7 @@ ENTRY(non_syscall)
 	// suitable spot...
 
 	alloc r14=ar.pfs,0,0,2,0
-	mov out0=r8
+	mov out0=cr.iim			// get break immediate (must be done while psr.ic is off)
 	add out1,sp
 	adds r3=8,r2			// set up second base pointer for SAVE_REST
 
Index: 2.17/arch/ia64/config.in
--- 2.17/arch/ia64/config.in Fri, 02 Mar 2001 23:28:22 +1100 kaos (linux-2.4/s/c/38_config.in 1.1.2.1.1.2 644)
+++ 2.17(w)/arch/ia64/config.in Fri, 16 Mar 2001 17:47:20 +1100 kaos (linux-2.4/s/c/38_config.in 1.1.2.1.1.2 644)
@@ -57,7 +57,7 @@ if [ "$CONFIG_ITANIUM" = "y" ]; then
 	if [ "$CONFIG_ITANIUM_CSTEP_SPECIFIC" = "y" ]; then
 	  bool '   Enable Itanium C0-step specific code' CONFIG_ITANIUM_C0_SPECIFIC
 	fi
-	if [ "$CONFIG_ITANIUM_ASTEP_SPECIFIC" = "y" -o "$CONFIG_ITANIUM_B0_SPECIFIC" = "y"
+	if [ "$CONFIG_ITANIUM_ASTEP_SPECIFIC" = "y" -o "$CONFIG_ITANIUM_B0_SPECIFIC" = "y" \
 	     -o "$CONFIG_ITANIUM_B1_SPECIFIC" = "y" -o "$CONFIG_ITANIUM_B2_SPECIFIC" = "y" ]; then
 	  define_bool CONFIG_ITANIUM_PTCG n
 	else


