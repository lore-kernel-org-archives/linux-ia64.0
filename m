From: Keith Owens <kaos@sgi.com>
Date: Thu, 30 Oct 2003 08:34:16 +0000
Subject: [patch 2/4] kernel salinfo changes
Message-Id: <marc-linux-ia64-106750297018129@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

patch 2 - Clean up kernel salinfo state checking.

Different bits of arch/ia64/kernel/salinfo.c checked different fields
to determine what state the processing was in.  Rationalise them all to
a single state flag.  This also positions for the ability to extend
kernel salinfo to handle more operations.

Get rid of the new_read flag, read the record when the user asks for it
or after clearing a record.


diff -ur 2.4.23-pre8-cset-1.1069.1.143-to-1.1108-salinfo1/arch/ia64/kernel/salinfo.c 2.4.23-pre8-cset-1.1069.1.143-to-1.1108-salinfo2/arch/ia64/kernel/salinfo.c
--- 2.4.23-pre8-cset-1.1069.1.143-to-1.1108-salinfo1/arch/ia64/kernel/salinfo.c	Thu Oct 30 17:06:19 2003
+++ 2.4.23-pre8-cset-1.1069.1.143-to-1.1108-salinfo2/arch/ia64/kernel/salinfo.c	Thu Oct 30 18:40:02 2003
@@ -85,6 +85,36 @@
 	int			cpu;
 };
 
+/* State transitions.  Actions are :-
+ *   Write "read <cpunum>" to the data file.
+ *   Write "clear <cpunum>" to the data file.
+ *   Read from the data file.
+ *   Close the data file.
+ *
+ * Start state is NO_DATA.
+ *
+ * NO_DATA
+ *    write "read <cpunum>" -> NO_DATA or LOG_RECORD.
+ *    write "clear <cpunum>" -> NO_DATA or LOG_RECORD.
+ *    read data -> return EOF.
+ *    close -> unchanged.  Free record areas.
+ *
+ * LOG_RECORD
+ *    write "read <cpunum>" -> NO_DATA or LOG_RECORD.
+ *    write "clear <cpunum>" -> NO_DATA or LOG_RECORD.
+ *    read data -> return the INIT/MCA/CMC/CPE record.
+ *    close -> unchanged.  Keep record areas.
+ *
+ * Closing the data file does not change the state.  This allows shell scripts
+ * to manipulate salinfo data, each shell redirection opens the file, does one
+ * action then closes it again.  The record areas are only freed at close when
+ * the state is NO_DATA.
+ */
+enum salinfo_state {
+	STATE_NO_DATA,
+	STATE_LOG_RECORD,
+};
+
 struct salinfo_data {
 	volatile cpumask_t	cpu_event;	/* which cpus have outstanding events */
 	struct semaphore	sem;		/* count of cpus with outstanding events (bits set in cpu_event) */
@@ -93,9 +123,8 @@
 	int			open;		/* single-open to prevent races */
 	u8			type;
 	u8			saved_num;	/* using a saved record? */
-	u8			new_read;	/* start of a new read? */
+	enum salinfo_state	state :8;	/* processing state */
 	u8			padding;
-	int			cpu_read;	/* "current" cpu for reads */
 	int			cpu_check;	/* next CPU to check */
 	struct salinfo_data_saved data_saved[5];/* save last 5 records from mca.c, must be < 255 */
 };
@@ -241,7 +270,8 @@
 	data->open = 1;
 	spin_unlock(&data_lock);
 
-	if (!(data->log_buffer = vmalloc(ia64_sal_get_state_info_size(data->type)))) {
+	if (data->state = STATE_NO_DATA &&
+	    !(data->log_buffer = vmalloc(ia64_sal_get_state_info_size(data->type)))) {
 		data->open = 0;
 		return -ENOMEM;
 	}
@@ -255,8 +285,10 @@
 	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
 	struct salinfo_data *data = entry->data;
 
-	vfree(data->log_buffer);
-	data->log_buffer = NULL;
+	if (data->state = STATE_NO_DATA) {
+		vfree(data->log_buffer);
+		data->log_buffer = NULL;
+	}
 	spin_lock(&data_lock);
 	data->open = 0;
 	spin_unlock(&data_lock);
@@ -283,19 +315,18 @@
 }
 
 static void
-salinfo_log_new_read(struct salinfo_data *data)
+salinfo_log_new_read(int cpu, struct salinfo_data *data)
 {
 	struct salinfo_data_saved *data_saved;
 	unsigned long flags;
 	int i;
 	int saved_size = ARRAY_SIZE(data->data_saved);
 
-	data->new_read = 0;
 	data->saved_num = 0;
 	spin_lock_irqsave(&data_saved_lock, flags);
 retry:
 	for (i = 0, data_saved = data->data_saved; i < saved_size; ++i, ++data_saved) {
-		if (data_saved->buffer && data_saved->cpu = data->cpu_read) {
+		if (data_saved->buffer && data_saved->cpu = cpu) {
 			sal_log_record_header_t *rh = (sal_log_record_header_t *)(data_saved->buffer);
 			data->log_size = data_saved->size;
 			memcpy(data->log_buffer, rh, data->log_size);
@@ -312,7 +343,8 @@
 	spin_unlock_irqrestore(&data_saved_lock, flags);
 
 	if (!data->saved_num)
-		call_on_cpu(data->cpu_read, salinfo_log_read_cpu, data);
+		call_on_cpu(cpu, salinfo_log_read_cpu, data);
+	data->state = data->log_size ? STATE_LOG_RECORD : STATE_NO_DATA;
 }
 
 static ssize_t
@@ -350,11 +382,11 @@
 static int
 salinfo_log_clear(struct salinfo_data *data, int cpu)
 {
+	data->state = STATE_NO_DATA;
 	if (!test_bit(cpu, &data->cpu_event))
 		return 0;
 	down(&data->sem);
 	clear_bit(cpu, &data->cpu_event);
-	data->log_size = 0;
 	if (data->saved_num) {
 		unsigned long flags;
 		spin_lock_irqsave(&data_saved_lock, flags);
@@ -365,10 +397,9 @@
 	call_on_cpu(cpu, salinfo_log_clear_cpu, data);
 
 	/* clearing a record may make a new record visible */
-	data->cpu_read = cpu;
-	salinfo_log_new_read(data);
-	if (data->log_size &&
-	    !test_and_set_bit(data->cpu_read,  &data->cpu_event))
+	salinfo_log_new_read(cpu, data);
+	if (data->state = STATE_LOG_RECORD &&
+	    !test_and_set_bit(cpu,  &data->cpu_event))
 		up(&data->sem);
 	return 0;
 }
@@ -390,8 +421,7 @@
 		return -EFAULT;
 
 	if (sscanf(cmd, "read %d", &cpu) = 1) {
-		data->cpu_read = cpu;
-		data->new_read = 1;
+		salinfo_log_new_read(cpu, data);
 	} else if (sscanf(cmd, "clear %d", &cpu) = 1) {
 		int ret;
 		if ((ret = salinfo_log_clear(data, cpu)))

