From: Keith Owens <kaos@sgi.com>
Date: Sun, 31 Jul 2005 00:51:37 +0000
Subject: [patch 2.6.12-rc4] Initialize some spinlocks
Message-Id: <16842.1122771097@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Some IA64 spinlocks are not being initialized, make it so.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/sn/kernel/io_init.c
=================================--- linux.orig/arch/ia64/sn/kernel/io_init.c	2005-07-30 15:49:12.624369059 +1000
+++ linux/arch/ia64/sn/kernel/io_init.c	2005-07-30 15:49:15.188823497 +1000
@@ -203,6 +203,7 @@ static void sn_fixup_ionodes(void)
 				continue;
 			}
 
+			spin_lock_init(&sn_flush_device_list->sfdl_flush_lock);
 			hubdev->hdi_flush_nasid_list.widget_p[widget]  			    sn_flush_device_list;
 		}
Index: linux/drivers/serial/sn_console.c
=================================--- linux.orig/drivers/serial/sn_console.c	2005-07-30 15:49:12.617533118 +1000
+++ linux/drivers/serial/sn_console.c	2005-07-30 15:49:15.189800060 +1000
@@ -1138,6 +1138,7 @@ int __init sn_serial_console_early_setup
 		return -1;
 
 	sal_console_port.sc_ops = &poll_ops;
+	spin_lock_init(&sal_console_port.sc_port.lock);
 	early_sn_setup();	/* Find SAL entry points */
 	register_console(&sal_console_early);
 
Index: linux/arch/ia64/kernel/salinfo.c
=================================--- linux.orig/arch/ia64/kernel/salinfo.c	2005-06-18 05:48:29.000000000 +1000
+++ linux/arch/ia64/kernel/salinfo.c	2005-07-30 16:07:54.973576514 +1000
@@ -143,7 +143,8 @@ struct salinfo_data {
 
 static struct salinfo_data salinfo_data[ARRAY_SIZE(salinfo_log_name)];
 
-static spinlock_t data_lock, data_saved_lock;
+static DEFINE_SPINLOCK(data_lock);
+static DEFINE_SPINLOCK(data_saved_lock);
 
 /** salinfo_platform_oemdata - optional callback to decode oemdata from an error
  * record.

