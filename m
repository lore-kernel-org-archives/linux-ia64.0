From: Jack Steiner <steiner@sgi.com>
Date: Sun, 31 Oct 2004 13:35:36 +0000
Subject: [PATCH] - Delete unused variable (master_node_bedrock_address)
Message-Id: <20041031133536.GA32758@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Tony - please apply

Delete master_node_bedrock_address. It is no longer needed.


Signed-off-by: Jack Steiner <steiner@sgi.com>

--- linux_base/arch/ia64/sn/kernel/setup.c	2004-10-30 17:52:11 -05:00
+++ linux/arch/ia64/sn/kernel/setup.c	2004-10-31 07:10:18 -06:00
@@ -82,15 +82,6 @@ short physical_node_map[MAX_PHYSNODE_ID]
 EXPORT_SYMBOL(physical_node_map);
 
 int numionodes;
-/*
- * This is the address of the RRegs in the HSpace of the global
- * master.  It is used by a hack in serial.c (serial_[in|out],
- * printk.c (early_printk), and kdb_io.c to put console output on that
- * node's Bedrock UART.  It is initialized here to 0, so that
- * early_printk won't try to access the UART before
- * master_node_bedrock_address is properly calculated.
- */
-u64 __iomem *master_node_bedrock_address;
 
 static void sn_init_pdas(char **);
 static void scan_for_ionodes(void);
@@ -207,14 +198,6 @@ void __init early_sn_setup(void)
 			}
 		}
 	}
-
-	if (IS_RUNNING_ON_SIMULATOR()) {
-		master_node_bedrock_address = (u64 __iomem *)
-			REMOTE_HUB(boot_get_nasid(), SH_JUNK_BUS_UART0);
-		printk(KERN_DEBUG "early_sn_setup: setting "
-		       "master_node_bedrock_address to 0x%p\n",
-		       master_node_bedrock_address);
-	}
 }
 
 extern int platform_intr_list[];
@@ -324,14 +307,6 @@ void __init sn_setup(char **cmdline_p)
 		sn_rtc_cycles_per_second = ticks_per_sec;
 
 	platform_intr_list[ACPI_INTERRUPT_CPEI] = IA64_CPE_VECTOR;
-
-	if (IS_RUNNING_ON_SIMULATOR()) {
-		master_node_bedrock_address = (u64 __iomem *)
-			REMOTE_HUB(boot_get_nasid(), SH_JUNK_BUS_UART0);
-		printk(KERN_DEBUG "sn_setup: setting "
-		       "master_node_bedrock_address to 0x%p\n",
-		       master_node_bedrock_address);
-	}
 
 	/*
 	 * we set the default root device to /dev/hda
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


