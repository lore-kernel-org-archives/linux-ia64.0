From: Len Brown <len.brown@intel.com>
Date: Thu, 25 Aug 2005 14:57:03 +0000
Subject: IA64 allnoconfig buildfix
Message-Id: <1124982076.16880.8.camel@toshiba>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-XH3cWEXZ73e4iKM/77oi"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--=-XH3cWEXZ73e4iKM/77oi
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Tony,
The ia64 allnoconfig build fails for some ACPI vs PCI reasons I've fixed
in my tree, but this small IA64 specific fix is needed also.
It stems from allnoconfig choosing CONFIG_PROC_FS=n
and sn_forc_interrupt_flag being defined within
CONFIG_PROC_FS, but used outside it.

cheers,
-Len

Index: linux-acpi-2.6/arch/ia64/sn/kernel/irq.c
===================================================================
--- linux-acpi-2.6.orig/arch/ia64/sn/kernel/irq.c
+++ linux-acpi-2.6/arch/ia64/sn/kernel/irq.c
@@ -23,7 +23,7 @@ static void force_interrupt(int irq);
 static void register_intr_pda(struct sn_irq_info *sn_irq_info);
 static void unregister_intr_pda(struct sn_irq_info *sn_irq_info);
 
-extern int sn_force_interrupt_flag;
+int sn_force_interrupt_flag = 1;
 extern int sn_ioif_inited;
 static struct list_head **sn_irq_lh;
 static spinlock_t sn_irq_info_lock = SPIN_LOCK_UNLOCKED; /* non-IRQ
lock */
Index: linux-acpi-2.6/arch/ia64/sn/kernel/sn2/sn_proc_fs.c
===================================================================
--- linux-acpi-2.6.orig/arch/ia64/sn/kernel/sn2/sn_proc_fs.c
+++ linux-acpi-2.6/arch/ia64/sn/kernel/sn2/sn_proc_fs.c
@@ -52,7 +52,7 @@ static int licenseID_open(struct inode *
  * the bridge chip.  The hardware will then send an interrupt message
if the
  * interrupt line is active.  This mimics a level sensitive interrupt.
  */
-int sn_force_interrupt_flag = 1;
+extern int sn_force_interrupt_flag;
 
 static int sn_force_interrupt_show(struct seq_file *s, void *p)
 {


--=-XH3cWEXZ73e4iKM/77oi
Content-Disposition: attachment; filename="SN-vs-CONFIG_PROC_FS=n.patch"
Content-Type: text/x-patch; name="SN-vs-CONFIG_PROC_FS=n.patch"; charset=UTF-8
Content-Transfer-Encoding: 7bit

Index: linux-acpi-2.6/arch/ia64/sn/kernel/irq.c
===================================================================
--- linux-acpi-2.6.orig/arch/ia64/sn/kernel/irq.c
+++ linux-acpi-2.6/arch/ia64/sn/kernel/irq.c
@@ -23,7 +23,7 @@ static void force_interrupt(int irq);
 static void register_intr_pda(struct sn_irq_info *sn_irq_info);
 static void unregister_intr_pda(struct sn_irq_info *sn_irq_info);
 
-extern int sn_force_interrupt_flag;
+int sn_force_interrupt_flag = 1;
 extern int sn_ioif_inited;
 static struct list_head **sn_irq_lh;
 static spinlock_t sn_irq_info_lock = SPIN_LOCK_UNLOCKED; /* non-IRQ lock */
Index: linux-acpi-2.6/arch/ia64/sn/kernel/sn2/sn_proc_fs.c
===================================================================
--- linux-acpi-2.6.orig/arch/ia64/sn/kernel/sn2/sn_proc_fs.c
+++ linux-acpi-2.6/arch/ia64/sn/kernel/sn2/sn_proc_fs.c
@@ -52,7 +52,7 @@ static int licenseID_open(struct inode *
  * the bridge chip.  The hardware will then send an interrupt message if the
  * interrupt line is active.  This mimics a level sensitive interrupt.
  */
-int sn_force_interrupt_flag = 1;
+extern int sn_force_interrupt_flag;
 
 static int sn_force_interrupt_show(struct seq_file *s, void *p)
 {

--=-XH3cWEXZ73e4iKM/77oi--

