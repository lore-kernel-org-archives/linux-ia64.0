From: Keith Owens <kaos@sgi.com>
Date: Fri, 06 Feb 2004 06:37:03 +0000
Subject: [patch] 2.4.25-pre8, 2.6.2-rc2 mca.c - pass irq_safe around
Message-Id: <9337.1076049423@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch is against 2.4.25-pre8 bk.  It also applies to 2.6.2-rc2 bk
(with some fuzz and offsets), after applying my previous 6 patches to
2.6.2-rc2 mca.c.

Patches from Ben Woodward to calculate irq_safe once and pass it
around.

Index: 25-pre8.5/arch/ia64/kernel/mca.c
--- 25-pre8.5/arch/ia64/kernel/mca.c Fri, 06 Feb 2004 17:15:40 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.2.1.1.1.1.1.1.1.5 644)
+++ 25-pre8.6/arch/ia64/kernel/mca.c Fri, 06 Feb 2004 17:29:43 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.2.1.1.1.1.1.1.1.6 644)
@@ -130,7 +130,7 @@ static int cmc_polling_enabled = 1;
  */
 static int cpe_poll_enabled = 1;
 
-extern void salinfo_log_wakeup(int type, u8 *buffer, u64 size);
+extern void salinfo_log_wakeup(int type, u8 *buffer, u64 size, int irqsafe);
 
 static struct tq_struct	cmc_disable_tq, cmc_enable_tq;
 
@@ -201,17 +201,17 @@ ia64_log_init(int sal_info_type)
  *	Get the current MCA log from SAL and copy it into the OS log buffer.
  *
  *  Inputs  :   info_type   (SAL_INFO_TYPE_{MCA,INIT,CMC,CPE})
+ *              irq_safe    whether you can use printk at this point
  *  Outputs :   size        (total record length)
  *              *buffer     (ptr to error record)
  *
  */
 static u64
-ia64_log_get(int sal_info_type, u8 **buffer)
+ia64_log_get(int sal_info_type, u8 **buffer, int irq_safe)
 {
 	sal_log_record_header_t     *log_buffer;
 	u64                         total_len = 0;
 	int                         s;
-	int irq_safe = sal_info_type != SAL_INFO_TYPE_MCA && sal_info_type != SAL_INFO_TYPE_INIT;
 
 	IA64_LOG_LOCK(sal_info_type);
 
@@ -252,11 +252,11 @@ ia64_mca_log_sal_error_record(int sal_in
 	int irq_safe = sal_info_type != SAL_INFO_TYPE_MCA && sal_info_type != SAL_INFO_TYPE_INIT;
 	static const char * const rec_name[] = { "MCA", "INIT", "CMC", "CPE" };
 
-	size = ia64_log_get(sal_info_type, &buffer);
+	size = ia64_log_get(sal_info_type, &buffer, irq_safe);
 	if (!size)
 		return;
 
-	salinfo_log_wakeup(sal_info_type, buffer, size);
+	salinfo_log_wakeup(sal_info_type, buffer, size, irq_safe);
 
 	if (irq_safe || called_from_init)
 		printk(KERN_INFO "CPU %d: SAL log contains %s error record\n",
Index: 25-pre8.5/arch/ia64/kernel/salinfo.c
--- 25-pre8.5/arch/ia64/kernel/salinfo.c Sun, 25 Jan 2004 06:42:02 +1100 kaos (linux-2.4/K/g/22_salinfo.c 1.1.1.1.1.1.1.2 644)
+++ 25-pre8.6/arch/ia64/kernel/salinfo.c Fri, 06 Feb 2004 17:29:43 +1100 kaos (linux-2.4/K/g/22_salinfo.c 1.1.1.1.1.1.1.3 644)
@@ -194,12 +194,12 @@ shift1_data_saved (struct salinfo_data *
  * changes.
  */
 void
-salinfo_log_wakeup(int type, u8 *buffer, u64 size)
+salinfo_log_wakeup(int type, u8 *buffer, u64 size, int irqsafe)
 {
 	struct salinfo_data *data = salinfo_data + type;
 	struct salinfo_data_saved *data_saved;
 	unsigned long flags = 0;
-	int i, irqsafe = type != SAL_INFO_TYPE_MCA && type != SAL_INFO_TYPE_INIT;
+	int i;
 	int saved_size = ARRAY_SIZE(data->data_saved);
 
 	BUG_ON(type >= ARRAY_SIZE(salinfo_log_name));

