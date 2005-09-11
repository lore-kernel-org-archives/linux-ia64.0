From: Keith Owens <kaos@sgi.com>
Date: Sun, 11 Sep 2005 07:21:46 +0000
Subject: [PATCH 2.6.13 3/6] MCA/INIT: avoid reading INIT record during INIT event
Message-Id: <25417.1126423306@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Reading the INIT record from SAL during the INIT event has proved to be
unreliable, and a source of hangs during INIT processing.  The new
MCA/INIT handlers remove the need to get the INIT record from SAL.
Change salinfo.c so mca.c can just flag that a new record is available,
without having to read the record during INIT processing.  This patch
can be applied without the new MCA/INIT handlers.

Also clean up some usage of NR_CPUS which should have been using
cpu_online().

Signed-off-by: Keith Owens <kaos@sgi.com>

---

 salinfo.c |   62 ++++++++++++++++++++++++++++++++++----------------------------
 1 files changed, 34 insertions(+), 28 deletions(-)

Index: linux/arch/ia64/kernel/salinfo.c
=================================--- linux.orig/arch/ia64/kernel/salinfo.c	2005-08-18 17:21:51.991680310 +1000
+++ linux/arch/ia64/kernel/salinfo.c	2005-08-18 17:32:18.440243239 +1000
@@ -22,6 +22,11 @@
  *
  * Dec  5 2004	kaos@sgi.com
  *   Standardize which records are cleared automatically.
+ *
+ * Aug 18 2005	kaos@sgi.com
+ *   mca.c may not pass a buffer, a NULL buffer just indicates that a new
+ *   record is available in SAL.
+ *   Replace some NR_CPUS by cpus_online, for hotplug cpu.
  */
 
 #include <linux/types.h>
@@ -193,7 +198,7 @@ shift1_data_saved (struct salinfo_data *
  * The buffer passed from mca.c points to the output from ia64_log_get. This is
  * a persistent buffer but its contents can change between the interrupt and
  * when user space processes the record.  Save the record id to identify
- * changes.
+ * changes.  If the buffer is NULL then just update the bitmap.
  */
 void
 salinfo_log_wakeup(int type, u8 *buffer, u64 size, int irqsafe)
@@ -206,27 +211,29 @@ salinfo_log_wakeup(int type, u8 *buffer,
 
 	BUG_ON(type >= ARRAY_SIZE(salinfo_log_name));
 
-	if (irqsafe)
-		spin_lock_irqsave(&data_saved_lock, flags);
-	for (i = 0, data_saved = data->data_saved; i < saved_size; ++i, ++data_saved) {
-		if (!data_saved->buffer)
-			break;
-	}
-	if (i = saved_size) {
-		if (!data->saved_num) {
-			shift1_data_saved(data, 0);
-			data_saved = data->data_saved + saved_size - 1;
-		} else
-			data_saved = NULL;
-	}
-	if (data_saved) {
-		data_saved->cpu = smp_processor_id();
-		data_saved->id = ((sal_log_record_header_t *)buffer)->id;
-		data_saved->size = size;
-		data_saved->buffer = buffer;
+	if (buffer) {
+		if (irqsafe)
+			spin_lock_irqsave(&data_saved_lock, flags);
+		for (i = 0, data_saved = data->data_saved; i < saved_size; ++i, ++data_saved) {
+			if (!data_saved->buffer)
+				break;
+		}
+		if (i = saved_size) {
+			if (!data->saved_num) {
+				shift1_data_saved(data, 0);
+				data_saved = data->data_saved + saved_size - 1;
+			} else
+				data_saved = NULL;
+		}
+		if (data_saved) {
+			data_saved->cpu = smp_processor_id();
+			data_saved->id = ((sal_log_record_header_t *)buffer)->id;
+			data_saved->size = size;
+			data_saved->buffer = buffer;
+		}
+		if (irqsafe)
+			spin_unlock_irqrestore(&data_saved_lock, flags);
 	}
-	if (irqsafe)
-		spin_unlock_irqrestore(&data_saved_lock, flags);
 
 	if (!test_and_set_bit(smp_processor_id(), &data->cpu_event)) {
 		if (irqsafe)
@@ -244,7 +251,7 @@ salinfo_timeout_check(struct salinfo_dat
 	int i;
 	if (!data->open)
 		return;
-	for (i = 0; i < NR_CPUS; ++i) {
+	for_each_online_cpu(i) {
 		if (test_bit(i, &data->cpu_event)) {
 			/* double up() is not a problem, user space will see no
 			 * records for the additional "events".
@@ -291,7 +298,7 @@ retry:
 
 	n = data->cpu_check;
 	for (i = 0; i < NR_CPUS; i++) {
-		if (test_bit(n, &data->cpu_event)) {
+		if (test_bit(n, &data->cpu_event) && cpu_online(n)) {
 			cpu = n;
 			break;
 		}
@@ -585,11 +592,10 @@ salinfo_init(void)
 
 		/* we missed any events before now */
 		online = 0;
-		for (j = 0; j < NR_CPUS; j++)
-			if (cpu_online(j)) {
-				set_bit(j, &data->cpu_event);
-				++online;
-			}
+		for_each_online_cpu(j) {
+			set_bit(j, &data->cpu_event);
+			++online;
+		}
 		sema_init(&data->sem, online);
 
 		*sdir++ = dir;



